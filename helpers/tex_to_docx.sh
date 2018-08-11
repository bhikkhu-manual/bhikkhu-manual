#!/bin/bash

# Call this from project root "./helpers/tex_to_docx.sh"

TEX_SRC="$1"

# no trailing slash
OUT_DIR="./manuscript/docx"
REF_DOCX="./helpers/reference.docx"

# https://stackoverflow.com/a/2352397/195141
file_ext=$(echo "$TEX_SRC" |awk -F . '{if (NF>1) {print $NF}}')

if [ "$TEX_SRC" == "" -o ! -f "$TEX_SRC" -o "$file_ext" != "tex" ]; then
   echo "First argument must be a .tex file."
   exit 2
fi

if [ ! -d "$OUT_DIR" ]; then
    echo "Folder doesn't exist: $OUT_DIR"
    exit 2
fi

echo -n "--- "$(basename $TEX_SRC)" to DOCX ... "

# Check for unknown LaTeX.

./helpers/check_unknown_latex.sh "$TEX_SRC"

if [ "$?" != "0" ]; then
    echo "Exiting."
    exit 2
fi

name=$(basename -s .tex $TEX_SRC)
OUT_FILE="$OUT_DIR/$name.docx"

# Replace or remove LaTeX which pandoc doesn't know, then convert with pandoc.

./helpers/canonicalize_latex.sh "$TEX_SRC" | \
    #cat -s | tee "$OUT_FILE.tex" |\
    pandoc -f latex -t docx --normalize --reference-docx="$REF_DOCX" -o "$OUT_FILE"

if [ "$?" == "0" ]; then
    echo "OK"
else
    echo "ERROR, Exiting."
    exit 2
fi

