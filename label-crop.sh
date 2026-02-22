#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# TWEAK THESE
#
# Coordinates are PDF points: llx lly urx ury
# Origin is bottom-left of the page.
#
# Use these to crop EXACTLY the label area you want to print + affix.
#
# fr.pdf is typically portrait A4 (595 x 842 pt)
# ie.pdf may be landscape A4 (841.68 x 595.2 pt) depending on generator.
###############################################################################

# Crop rectangle for FR label (llx lly urx ury as separate elements)
FR_BBOX=(0 0 595 482)

# Crop rectangle for IE label
IE_BBOX=(500 130 820 570)

###############################################################################
# Script
###############################################################################

show_help() {
cat <<'EOF'
Usage:
label-crop.sh [--type fr|ie] [input.pdf] [output.pdf]

Behaviour:
--type      Label type (fr or ie). Default: ie
input.pdf   Input PDF. If omitted, first *.pdf in current dir is used
output.pdf  Output PDF. If omitted, _cropped.pdf is appended to input name
--help      Show this help

Notes:
- Crops using pdfcrop --bbox (explicit rectangle; no auto-detect).
- BBox format is: "llx lly urx ury" in PDF points.
EOF
}

TYPE="ie"

POSITIONAL=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --type)
      TYPE="${2:-}"
      shift 2
      ;;
    --help)
      show_help
      exit 0
      ;;
    *)
      POSITIONAL+=("$1")
      shift
      ;;
  esac
done

INPUT="${POSITIONAL[0]:-}"
OUTPUT="${POSITIONAL[1]:-}"

if [[ -z "$INPUT" ]]; then
  INPUT="$(ls *.pdf 2>/dev/null | head -n 1 || true)"
  if [[ -z "$INPUT" ]]; then
    echo "No PDF found in current directory."
    exit 1
  fi
fi

if [[ -z "$OUTPUT" ]]; then
  BASENAME="${INPUT%.pdf}"
  OUTPUT="${BASENAME}_cropped.pdf"
fi

case "$TYPE" in
  fr)
    BBOX=("${FR_BBOX[@]}")
    ;;
  ie)
    BBOX=("${IE_BBOX[@]}")
    ;;
  *)
    echo "Invalid type: $TYPE (expected fr or ie)"
    exit 1
    ;;
esac

# Build the exact command string and run it
CMD="pdfcrop --bbox \"${BBOX[*]}\" \"$INPUT\" \"$OUTPUT\""
eval "$CMD"

echo "Cropped → $OUTPUT"