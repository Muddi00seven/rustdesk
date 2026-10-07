#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/macpilot/common.sh"
require_command python3
exec python3 "$MACPILOT_ROOT/scripts/macpilot/doctor.py" "$@"
