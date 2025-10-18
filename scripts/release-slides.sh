#!/usr/bin/env bash
set -euo pipefail

# Ensure required tools are available before doing any work.
for cmd in typst pdftoppm magick; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Missing required command: $cmd" >&2
    exit 1
  fi
done

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"
slides_root="$repo_root/typslides"

mkdir -p "$slides_root"

# Detect the highest existing version number.
latest_version=-1
for dir in "$slides_root"/version*; do
  [[ -d "$dir" ]] || continue
  basename="$(basename "$dir")"
  version_suffix="${basename#version}"
  if [[ "$version_suffix" =~ ^[0-9]+$ ]] && (( version_suffix > latest_version )); then
    latest_version="$version_suffix"
  fi
done

next_version=$((latest_version + 1))
target_dir="$slides_root/version$next_version"

if [[ -e "$target_dir" ]]; then
  echo "Target directory already exists: $target_dir" >&2
  exit 1
fi

if (( latest_version >= 0 )); then
  previous_dir="$slides_root/version$latest_version"
  cp -R "$previous_dir" "$target_dir"
  rm -f "$target_dir/main.pdf" "$target_dir/overview.png" || true
  rm -rf "$target_dir/thumbs" || true
else
  typst init @preview/typslides:1.3.0 "$target_dir" >/dev/null
fi

mkdir -p "$target_dir/thumbs"

typst compile "$target_dir/main.typ" "$target_dir/main.pdf"

rm -f "$target_dir"/thumbs/*.png || true

pdftoppm -png -r 200 "$target_dir/main.pdf" "$target_dir/thumbs/slide"

shopt -s nullglob
slide_pngs=("$target_dir"/thumbs/slide-*.png)
shopt -u nullglob

if (( ${#slide_pngs[@]} == 0 )); then
  echo "No slide PNGs were produced for $target_dir/main.pdf" >&2
  exit 1
fi

magick montage "${slide_pngs[@]}" -tile 5x -geometry +8+8 -background white "$target_dir/overview.png"

echo "Created $target_dir"
echo "PDF:        $target_dir/main.pdf"
echo "Overview:   $target_dir/overview.png"
