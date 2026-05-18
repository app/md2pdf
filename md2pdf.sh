#!/bin/bash

# ---------------------------------------------------------------------------
# Helper functions
# ---------------------------------------------------------------------------

usage() {
  echo "Usage: $0 file.md"
  exit 1
}

cleanup() {
  rm -f "$TMP_TYP"
}

# Writes the Typst template to the temporary file $TMP_TYP
write_template() {
  cat << 'EOF' > "$TMP_TYP"
#import "@preview/cmarker:0.1.8"
#let filename = sys.inputs.at("mdfile", default: none)

// Page
#set page(margin: (x: 2.5cm, y: 2.5cm))

// Font: clean sans-serif, better readability for business documents
#set text(
  font: ("Noto Sans", "Liberation Sans", "DejaVu Sans"),
  size: 10.5pt,
  lang: "ru",
)

// Line height and paragraph spacing
#set par(
  leading: 0.75em,
  spacing: 1.4em,
  justify: false,
)

// Horizontal rules — thin and light
#show line: _ => block(
  width: 100%,
  height: 1pt,
  fill: luma(200),
)

// Headings — small spacing above and below
#show heading: it => {
  v(0.6em, weak: true)
  it
  v(0.6em, weak: true)
}

#if filename != none {
  cmarker.render(read("/work/" + filename))
}
EOF
}

# Populates FONT_VOLS and FONT_PATH_ARGS with font directories
# discovered via fontconfig (distro-agnostic)
collect_fonts() {
  FONT_VOLS=()
  FONT_PATH_ARGS=()
  command -v fc-list &>/dev/null || return
  while IFS= read -r dir; do
    FONT_VOLS+=("-v" "$dir:$dir:ro")
    FONT_PATH_ARGS+=("--font-path" "$dir")
  done < <(fc-list : file | sed 's|/[^/]*:[[:space:]]*$||' | sort -u)
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

[ -z "$1" ] && usage

MD_INPUT=$(realpath "$1")
MD_DIR=$(dirname "$MD_INPUT")
MD_FILE=$(basename "$MD_INPUT")
PDF_OUTPUT="${MD_FILE%.*}.pdf"

TMP_TYP=$(mktemp --suffix=.typ)
trap cleanup EXIT

write_template
collect_fonts

echo "Compiling $MD_FILE -> $PDF_OUTPUT..."

podman run --rm \
  -v "$MD_DIR:/work" \
  -v "$TMP_TYP:/template.typ:ro" \
  "${FONT_VOLS[@]}" \
  -w /work \
  ghcr.io/app/md2pdf \
  compile "${FONT_PATH_ARGS[@]}" --input mdfile="$MD_FILE" /template.typ "$PDF_OUTPUT"
cleanup

echo "PDF created: $MD_DIR/$PDF_OUTPUT"
