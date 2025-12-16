#!/usr/bin/env bash
set -euo pipefail

SRC_ROOT="src"
SITE_ROOT="site"
LOG_ROOT="logs"

mkdir -p "$SITE_ROOT" "$LOG_ROOT"

shopt -s nullglob

DOC_DIRS=("$SRC_ROOT"/*/)
if [ ${#DOC_DIRS[@]} -eq 0 ]; then
  echo "No document directories found under: $SRC_ROOT/<docname>/"
  exit 1
fi

echo "Found ${#DOC_DIRS[@]} document directorie(s)."

for doc_dir in "${DOC_DIRS[@]}"; do
  doc_dir="${doc_dir%/}"
  doc_name="$(basename "$doc_dir")"

  tex_files=("$doc_dir"/*.tex)
  if [ ${#tex_files[@]} -eq 0 ]; then
    echo "==> [$doc_name] SKIP: no .tex found in $doc_dir"
    continue
  fi
  if [ ${#tex_files[@]} -gt 1 ]; then
    echo "==> [$doc_name] WARNING: multiple .tex files found; using: ${tex_files[0]}"
  fi

  tex="${tex_files[0]}"
  img_dir="$doc_dir/images"

  out_dir="$SITE_ROOT/$doc_name"
  mkdir -p "$out_dir"

  html_raw="$out_dir/index.html"
  html_nav="$out_dir/index.nav.html"

  log_latexml="$LOG_ROOT/latexmlc_${doc_name}.log"
  log_post="$LOG_ROOT/postprocess_${doc_name}.log"

  echo "==> [$doc_name] LaTeXML -> HTML"
  latexmlc "$tex" \
    --dest="$html_raw" \
    --format=html5 \
    --sourcedirectory="$doc_dir" \
    --sitedirectory="$out_dir" \
    --path="$doc_dir" \
    $( [ -d "$img_dir" ] && echo --path="$img_dir" ) \
    --log="$log_latexml"

  # Organize assets: move images into /images
  mkdir -p "$out_dir/images"
  shopt -s nullglob
  for img in "$out_dir"/*.{png,jpg,jpeg,gif,svg,pdf}; do
    mv "$img" "$out_dir/images/"
  done
  shopt -u nullglob

  # Normalize/force image references to images/<file>
  sed -i -E 's/(src=")(images\/)+/\1images\//g' "$html_raw"
  sed -i -E 's/(src=")([^"]*\/)?([^"\/]+\.(png|jpg|jpeg|gif|svg|pdf))"/\1images\/\3"/gI' "$html_raw"

  echo "==> [$doc_name] Post-process -> Navigable HTML"
  python3 tools/postprocess_html.py "$html_raw" "$html_nav" \
    > "$log_post" 2>&1

  echo "==> [$doc_name] OK: $html_nav"
done

echo "All documents processed."

