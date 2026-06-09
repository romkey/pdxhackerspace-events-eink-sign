#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

scad="specta6-13-split.scad"

for part in front-left front-right back-left back-right foot; do
  echo "Generating specta6-13-split-${part}.stl ..."
  openscad -D "part=\"${part}\"" -o "specta6-13-split-${part}.stl" "${scad}"
done
