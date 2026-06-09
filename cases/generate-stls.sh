#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

scad="specta6-13.scad"

for part in front back base; do
  echo "Generating specta6-13-${part}.stl ..."
  openscad -D "part=\"${part}\"" -o "specta6-13-${part}.stl" "${scad}"
done

exec ./generate-stls-split.sh
