#!/bin/bash

# Check for argument
if [ -z "$1" ]; then
  echo "Usage: $0 file.md"
  exit 1
fi

# Get absolute path to input file
MD_INPUT=$(realpath "$1")
MD_DIR=$(dirname "$MD_INPUT")
MD_FILE=$(basename "$MD_INPUT")
PDF_OUTPUT="${MD_FILE%.*}.pdf"

# Create temporary file in system temp directory
TMP_TYP=$(mktemp --suffix=.typ)

# Function to delete temporary file on exit
cleanup() {
  rm -f "$TMP_TYP"
}
trap cleanup EXIT

# 1. Create template
cat << 'EOF' > "$TMP_TYP"
#import "@preview/cmarker:0.1.8"
#let filename = sys.inputs.at("mdfile", default: none)

#set page(margin: 2cm) // You can add basic settings right away

#if filename != none {
  cmarker.render(read("/work/" + filename))
}
EOF

echo "Compiling $MD_FILE to $PDF_OUTPUT..."

# 2. Run compilation
# Mount the directory containing the MD file as working directory
podman run --rm \
  -v "$MD_DIR:/work" \
  -v "$TMP_TYP:/template.typ:ro" \
  -w /work \
  typst-cmarker \
  compile --input mdfile="$MD_FILE" /template.typ "$PDF_OUTPUT"

echo "PDF successfully created in directory: $MD_DIR/$PDF_OUTPUT"
