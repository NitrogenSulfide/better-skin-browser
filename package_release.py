#!/usr/bin/env python3
"""Create and verify the player-facing Unreal Skin Browser release archive."""
from __future__ import annotations

import hashlib
from pathlib import Path
import shutil
import zipfile


PROJECT = Path(__file__).resolve().parent
DIST = PROJECT / "dist"
SYSTEM = DIST / "System"
ARCHIVE = DIST / "BetterSkinBrowser-v1.2.zip"
CHECKSUMS = DIST / "SHA256SUMS.txt"


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def main() -> None:
    system_files = [
        SYSTEM / "BetterSkinBrowser.u",
        SYSTEM / "BetterSkinBrowser.int",
        SYSTEM / "BetterSkinBrowser.ucl",
    ]
    for path in system_files:
        if not path.is_file():
            raise SystemExit(f"required release file is missing: {path}")

    readme = DIST / "README.txt"
    license_file = DIST / "LICENSE.txt"
    shutil.copy2(PROJECT / "release" / "README.txt", readme)
    shutil.copy2(PROJECT / "LICENSE", license_file)

    expected = [f"System/{path.name}" for path in system_files]
    expected += ["README.txt", "LICENSE.txt"]
    with zipfile.ZipFile(ARCHIVE, "w", zipfile.ZIP_DEFLATED) as archive:
        for path in system_files:
            archive.write(path, f"System/{path.name}")
        archive.write(readme, "README.txt")
        archive.write(license_file, "LICENSE.txt")

    with zipfile.ZipFile(ARCHIVE) as archive:
        actual = archive.namelist()
        if actual != expected or archive.testzip() is not None:
            raise SystemExit(f"release archive verification failed: {actual}")

    targets = [*system_files, ARCHIVE]
    CHECKSUMS.write_text(
        "".join(f"{sha256(path)}  {path.relative_to(DIST)}\n" for path in targets),
        encoding="ascii",
    )
    print(f"Release archive: {ARCHIVE}")
    print(CHECKSUMS.read_text(encoding="ascii"), end="")



if __name__ == "__main__":
    main()
