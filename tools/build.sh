#!/usr/bin/env bash
set -euo pipefail

# Root of the project = parent directory of this script
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Source directory containing .tex files
SRC_DIR="$ROOT/src"

# Output directory for generated HTML
SITE_DIR="$ROOT/site"

# Directory for LaTeXML logs
LOG_DIR="$ROOT/logs"

# Create output and log directories if they do not exist
mkdir -p "$SITE_DIR" "$LOG_DIR"

# Find all .tex files under src/,
# but exclude anything inside an "images" directory
# (so .tex files accidentally placed under images/ are ignored)
mapfile -t TEX_FILES < <(
  find "$SRC_DIR" -type f -name '*.tex' \
    -not -path '*/images/*' \
    -print | sort
)

# Exit early if no .tex files were found
if [[ ${#TEX_FILES[@]} -eq 0 ]]; then
  echo "No .tex files found in $SRC_DIR"
  exit 0
fi

# Process each .tex file
for TEX in "${TEX_FILES[@]}"; do
  # Directory containing the .tex file
  TEX_DIR="$(dirname "$TEX")"

  # Base name of the .tex file (without extension)
  TEX_BASENAME="$(basename "$TEX" .tex)"

  # "Module" name:
  # - src/aamini/aamini.tex -> module = aamini
  # - src/foo.tex           -> module = foo
  REL="${TEX#"$SRC_DIR"/}"   # e.g. aamini/aamini.tex or foo.tex
  MODULE="${REL%%/*}"        # e.g. aamini or foo.tex
  MODULE="${MODULE%.tex}"    # if it was foo.tex -> foo

  # Output directory and HTML file for this module
  OUT_DIR="$SITE_DIR/$MODULE"
  OUT_HTML="$OUT_DIR/$TEX_BASENAME.html"

  # Log file for this module
  LOG_FILE="$LOG_DIR/$MODULE.latexmlc.log"

  # Create output directory for the module
  mkdir -p "$OUT_DIR"

  # Images directory for this module (if it exists)
  IMG_DIR="$TEX_DIR/images"

  echo "==> Building: $REL  ->  ${OUT_HTML#"$ROOT/"}"
  echo "    Log: ${LOG_FILE#"$ROOT/"}"

  # Build the latexmlc command
  # - sourcedirectory: logical root of the document
  # - path: directory of the .tex file (and images, if present)
  # - destination: output HTML file
  CMD=(latexmlc
    "$TEX"
    --format=html5 --pmml
    --sourcedirectory="$TEX_DIR"
    --path="$TEX_DIR"
    --destination="$OUT_HTML"
    --log="$LOG_FILE"
    --verbose
  )

  # If an images directory exists, add it to the search path
  if [[ -d "$IMG_DIR" ]]; then
    CMD+=( --path="$IMG_DIR" )
  fi

  # Execute the LaTeXML command
  "${CMD[@]}"
done

# Final summary
echo "Done. Output in: ${SITE_DIR#"$ROOT/"}  | Logs in: ${LOG_DIR#"$ROOT/"}"

