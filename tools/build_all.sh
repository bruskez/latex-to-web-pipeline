#!/usr/bin/env bash
# Exit immediately if a command fails, an undefined variable is used,
# or a pipeline fails at any point.
set -euo pipefail

# Root directories
SRC_ROOT="src"     # Source documents: src/<docname>/
SITE_ROOT="site"   # Output HTML site
LOG_ROOT="logs"    # Logs for LaTeXML and post-processing

# Ensure output and log directories exist
mkdir -p "$SITE_ROOT" "$LOG_ROOT"

# Make globs that match nothing expand to an empty list
shopt -s nullglob

# Collect all document directories under src/
DOC_DIRS=("$SRC_ROOT"/*/)
if [ ${#DOC_DIRS[@]} -eq 0 ]; then
  echo "No document directories found under: $SRC_ROOT/<docname>/"
  exit 1
fi

echo "Found ${#DOC_DIRS[@]} document directorie(s)."

# Process each document directory
for doc_dir in "${DOC_DIRS[@]}"; do
  # Remove trailing slash
  doc_dir="${doc_dir%/}"
  doc_name="$(basename "$doc_dir")"

  # Look for .tex files in the document directory
  tex_files=("$doc_dir"/*.tex)
  if [ ${#tex_files[@]} -eq 0 ]; then
    echo "==> [$doc_name] SKIP: no .tex found in $doc_dir"
    continue
  fi

  # If multiple .tex files exist, use the first one
  if [ ${#tex_files[@]} -gt 1 ]; then
    echo "==> [$doc_name] WARNING: multiple .tex files found; using: ${tex_files[0]}"
  fi

  tex="${tex_files[0]}"
  img_dir="$doc_dir/images"

  # Output directory for this document
  out_dir="$SITE_ROOT/$doc_name"
  mkdir -p "$out_dir"

  # Output HTML files
  html_raw="$out_dir/index.html"        # Raw LaTeXML output
  html_nav="$out_dir/index.nav.html"    # Post-processed navigable HTML

  # Log files
  log_latexml="$LOG_ROOT/latexmlc_${doc_name}.log"
  log_post="$LOG_ROOT/postprocess_${doc_name}.log"

  echo "==> [$doc_name] LaTeXML -> HTML"

  # Run LaTeXML to convert LaTeX to HTML5
  latexmlc "$tex" \
    --dest="$html_raw" \
    --format=html5 \
    --sourcedirectory="$doc_dir" \
    --sitedirectory="$out_dir" \
    --path="$doc_dir" \
    $( [ -d "$img_dir" ] && echo --path="$img_dir" ) \
    --log="$log_latexml"

  # Create a dedicated images directory in the output
  mkdir -p "$out_dir/images"

  # Move all generated image assets into /images
  shopt -s nullglob
  for img in "$out_dir"/*.{png,jpg,jpeg,gif,svg,pdf}; do
    mv "$img" "$out_dir/images/"
  done
  shopt -u nullglob

  # Normalize image references so they always point to images/<filename>
  # 1. Collapse repeated "images/images/..." into "images/"
  sed -i -E 's/(src=")(images\/)+/\1images\//g' "$html_raw"

  # 2. Rewrite any image src to images/<filename>
  sed -i -E 's/(src=")([^"]*\/)?([^"\/]+\.(png|jpg|jpeg|gif|svg|pdf))"/\1images\/\3"/gI "$html_raw"

  echo "==> [$doc_name] Post-process -> Navigable HTML"

  # Run a Python post-processing script to add navigation or enhancements
  python3 tools/postprocess_html.py "$html_raw" "$html_nav" \
    > "$log_post" 2>&1

  echo "==> [$doc_name] OK: $html_nav"
done

# All documents completed successfully
echo "All documents processed."

