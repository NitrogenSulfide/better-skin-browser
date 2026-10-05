#!/usr/bin/env bash
set -euo pipefail
project_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
python3 "$project_dir/tools/native_project.py" better-skin-browser
exec python3 "$project_dir/package_release.py"
