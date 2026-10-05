#!/usr/bin/env python3
"""Build current handoff projects with native Linux UCC in private scratch trees."""
from __future__ import annotations
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile
import zipfile
ROOT = Path(__file__).resolve().parents[1]
PROJECTS = {'better-skin-browser': (['BetterSkinBrowser'], [], 'BetterSkinBrowser')}

def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def paths():
    game = Path(os.environ.get('UT2004_GAME_DIR', str(Path.home() / '.local/share/OldUnreal/UT2004'))).resolve(strict=True)
    config = Path(os.environ.get('UT2004_CONFIG_DIR', str(Path.home() / '.ut2004/System'))).resolve(strict=True)
    ucc = Path(os.environ.get('UT2004_UCC', str(game / 'System/UCC'))).resolve(strict=True)
    for path in (game, config, ucc):
        if any((x in str(path).lower() for x in ('steam', 'proton', 'compatdata'))):
            raise ValueError('Only native OldUnreal paths are supported')
    if sys.platform != 'linux' or ucc.read_bytes()[:4] != b'\x7fELF':
        raise ValueError('A native Linux ELF UCC is required')
    for name in ('UT2004.ini', 'User.ini'):
        if not (config / name).is_file():
            raise ValueError('Missing writable configuration: ' + name)
    return (game, config, ucc)

def stage_tree(destination, game, config, ucc, excluded):
    system = destination / 'System'
    system.mkdir(parents=True)
    for file in (game / 'System').iterdir():
        if not file.is_file() or file.stem.casefold() in {n.casefold() for n in excluded}:
            continue
        target = system / file.name
        if file.suffix.lower() in ('.ini', '.int', '.ucl', '.upl'):
            shutil.copy2(file, target)
        elif file.suffix.lower() in ('.u', '.so', '.md5') or '.so.' in file.name:
            target.symlink_to(file)
    shutil.copy2(ucc, system / 'UCC')
    for file in config.glob('*.ini'):
        shutil.copy2(file, system / file.name)
    for name in ('Maps', 'Textures', 'Animations', 'StaticMeshes', 'Sounds', 'Music', 'KarmaData'):
        if (game / name).is_dir():
            (destination / name).symlink_to(game / name, target_is_directory=True)
    for name in ('cache', 'Screenshots'):
        (destination / name).mkdir()
    ini = (system / 'UT2004.ini').read_text(encoding='latin-1')
    ini = re.sub('(?m)^ServerActors=.*\\n?', '', ini)
    ini = re.sub('(?m)^(DoUplink|UplinkToGamespy|SendStats)=True', '\\1=False', ini)
    (system / 'UT2004.ini').write_text(ini, encoding='latin-1')
    return system

def environment(game, stage):
    env = dict(os.environ)
    env['LD_LIBRARY_PATH'] = str(game / 'System') + (':' + env['LD_LIBRARY_PATH'] if env.get('LD_LIBRARY_PATH') else '')
    env['XDG_CACHE_HOME'] = str(stage / 'cache')
    return env

def run_ucc(stage, game, args, name, baseline=(), baseline_export=False):
    logfile = stage / (name + '.log')
    command = [str(stage / 'System/UCC'), *args, '-nohomedir', '-ini=UT2004.ini', '-userini=User.ini', '-log=' + str(logfile)]
    with (stage / (name + '.stdout')).open('w') as output:
        result = subprocess.run(command, cwd=stage / 'System', env=environment(game, stage), stdout=output, stderr=subprocess.STDOUT)
    text = logfile.read_text(errors='replace') if logfile.exists() else (stage / (name + '.stdout')).read_text(errors='replace')
    warnings = set(re.findall('(?m)^Warning:.*$', text))
    errors = re.findall('(?im)^.*(?:Critical:|Error:|Assertion failed).*$', text)
    if result.returncode or errors or (not re.search('Success - 0 error\\(s\\), \\d+ warning\\(s\\)', text)) or (warnings - set(baseline) and (not baseline_export)):
        raise RuntimeError(f'UCC failed or emitted unreviewed diagnostics: {logfile}\n' + text[-4500:])
    return warnings

def build(project_name):
    game, config, ucc = paths()
    project = ROOT
    rels, deps, primary = PROJECTS[project_name]
    sources = {(project / p).name: (project / p).resolve(strict=True) for p in rels}
    buildroot = project / 'dist/native-builds'
    buildroot.mkdir(parents=True, exist_ok=True)
    stage = Path(tempfile.mkdtemp(prefix='build-', dir=buildroot))
    system = stage_tree(stage, game, config, ucc, [*sources, 'NativeTestHarness'])
    for name, source in sources.items():
        shutil.copytree(source, stage / name)
    harness = stage / 'NativeTestHarness/Classes'
    harness.mkdir(parents=True)
    (harness / 'MutNativeTestExit.uc').write_text('class MutNativeTestExit extends Mutator;\nfunction PostBeginPlay() { Super.PostBeginPlay(); SetTimer(30.0, false); }\nfunction Timer() { ConsoleCommand("quit"); }\ndefaultproperties { GroupName="NativeTestExit" }\n')
    ini = (system / 'UT2004.ini').read_text(encoding='latin-1')
    for name in [*deps, *sources, 'NativeTestHarness']:
        ini = re.sub('(?im)^EditPackages=' + re.escape(name) + '\\s*\\n', '', ini)
    if '[UWeb.WebServer]' not in ini:
        raise ValueError('Missing editor package-list anchor')
    ini = ini.replace('[UWeb.WebServer]', ''.join(('EditPackages=' + n + '\n' for n in [*deps, *sources, 'NativeTestHarness'])) + '[UWeb.WebServer]')
    (system / 'UT2004.ini').write_text(ini, encoding='latin-1')
    baseline = set()
    dependencies = {}
    for name in deps:
        file = system / (name + '.u')
        dependencies[name] = sha(file)
    run_ucc(stage, game, ['make'], 'Make', baseline)
    for name, source in sources.items():
        out = stage / 'RoundTrip' / name
        out.mkdir(parents=True)
        run_ucc(stage, game, ['batchexport', name + '.u', 'class', 'uc', str(out)], 'Export-' + name, baseline)
        for cls in (source / 'Classes').glob('*.uc'):
            if not (out / cls.name).is_file():
                raise RuntimeError('Missing exported class ' + str(cls))
    for file in (project / 'metadata').glob('*'):
        shutil.copy2(file, system / file.name)
    dist = project / 'dist/System'
    dist.mkdir(parents=True, exist_ok=True)
    release_names = [primary]
    payload = {}
    for name in release_names:
        shutil.copy2(system / (name + '.u'), dist / (name + '.u'))
        payload['System/' + name + '.u'] = sha(dist / (name + '.u'))
    for ext in ('.ucl', '.int'):
        file = system / (primary + ext)
        if file.exists():
            if ext == '.int':
                file.write_bytes(re.sub(b'=""([^\\r\\n]*)""', b'="\\1"', file.read_bytes()))
            shutil.copy2(file, dist / file.name)
            payload['System/' + file.name] = sha(dist / file.name)
    for file in (project / 'config').glob('*.ini'):
        shutil.copy2(file, dist / file.name)
        payload['System/' + file.name] = sha(dist / file.name)
    for name, expected in dependencies.items():
        if sha(system / (name + '.u')) != expected:
            raise RuntimeError('Dependency changed during build: ' + name)
    manifest = dict(test_packages={name: sha(system / (name + '.u')) for name in [*sources, 'NativeTestHarness']}, project=project_name, build=str(stage), ucc_sha256=sha(ucc), dependencies=dependencies, baseline_warnings=sorted(baseline), files=payload, sources={name + '/Classes/' + f.name: sha(f) for name in sources for f in (stage / name / 'Classes').glob('*.uc')})
    (project / 'dist/native-build-manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
    (project / 'dist/latest-native-build.txt').write_text(str(stage) + '\n')
    archive = project / 'dist' / (primary + '-native-linux.zip')
    with zipfile.ZipFile(archive, 'w', zipfile.ZIP_DEFLATED) as z:
        for n in payload:
            z.write(project / 'dist' / n, n)
        z.write(project / 'README.md', 'README.md')
    print(json.dumps(dict(project=project_name, build=str(stage), archive=str(archive), sha256=sha(archive), baseline_warnings=len(baseline)), indent=2))
if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('project', choices=PROJECTS)
    args = parser.parse_args()
    build(args.project)
