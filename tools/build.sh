#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC_DIR="$ROOT/src"
SITE_DIR="$ROOT/site"
LOG_DIR="$ROOT/logs"

mkdir -p "$SITE_DIR" "$LOG_DIR"

# Trova .tex in src, ma esclude qualsiasi cartella "images"
# (così se per errore finisce un .tex sotto images, non lo processa)
mapfile -t TEX_FILES < <(
  find "$SRC_DIR" -type f -name '*.tex' \
    -not -path '*/images/*' \
    -print | sort
)

if [[ ${#TEX_FILES[@]} -eq 0 ]]; then
  echo "Nessun file .tex trovato in $SRC_DIR"
  exit 0
fi

for TEX in "${TEX_FILES[@]}"; do
  TEX_DIR="$(dirname "$TEX")"
  TEX_BASENAME="$(basename "$TEX" .tex)"

  # Nome “modulo” = cartella sotto src (es: src/aamini/aamini.tex -> aamini)
  # Se invece hai src/foo.tex, modulo = foo
  REL="${TEX#"$SRC_DIR"/}"          # es: aamini/aamini.tex oppure foo.tex
  MODULE="${REL%%/*}"               # es: aamini oppure foo.tex
  MODULE="${MODULE%.tex}"           # se era foo.tex -> foo

  OUT_DIR="$SITE_DIR/$MODULE"
  OUT_HTML="$OUT_DIR/index.html"
  LOG_FILE="$LOG_DIR/$MODULE.latexmlc.log"

  mkdir -p "$OUT_DIR"

  # Path per immagini del modulo (se esiste)
  IMG_DIR="$TEX_DIR/images"

  echo "==> Building: $REL  ->  ${OUT_HTML#"$ROOT/"}"
  echo "    Log: ${LOG_FILE#"$ROOT/"}"

  # Costruzione comando latexmlc
  # - sourcedirectory: radice “logica” del documento (cartella del .tex)
  # - path: cartella del .tex + images (se presente)
  # - dest: index.html dentro site/<module>/
  CMD=(latexmlc
    "$TEX"
    --format=html5 --pmml
    --sourcedirectory="$TEX_DIR"
    --path="$TEX_DIR"
    --destination="$OUT_HTML"
    --log="$LOG_FILE"
    --verbose
  )

  if [[ -d "$IMG_DIR" ]]; then
    CMD+=( --path="$IMG_DIR" )
  fi

  # Esegui
  "${CMD[@]}"
done

echo "Done. Output in: ${SITE_DIR#"$ROOT/"}  | Logs in: ${LOG_DIR#"$ROOT/"}"

