#!/bin/bash

# Call this from project root "./helpers/tex_to_asciidoc.sh"

TEX_SRC="$1"

# no trailing slash
OUT_DIR="./manuscript/asciidoc"

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

echo -n "--- "$(basename $TEX_SRC)" to AsciiDoc ... "

# Check for unknown LaTeX.

./helpers/check_unknown_latex.sh "$TEX_SRC"

if [ "$?" != "0" ]; then
    echo "Exiting."
    exit 2
fi

name=$(basename -s .tex $TEX_SRC)
OUT_FILE="$OUT_DIR/$name.adoc"

# Replace or remove LaTeX which pandoc doesn't know, then convert with pandoc.

./helpers/canonicalize_latex.sh "$TEX_SRC" | \
    #cat -s | tee "$OUT_FILE.tex" |\
    # take attributes out of the comment hints
    perl -0777 -pe "s/% (<attr [^>]+>)\n/\n\1\n/gs" | \
    pandoc -f latex -t asciidoc --atx-headers --smart --normalize | \
    # move chapter id, title and subtitle to the top of the file
    perl -0777 -pe "s/^(.+?\n)(\[\[[^\n]+\]\]\n= [^\n]+\n)(\n*_[^_]+?_\n)?/\2\n\3\n\1/s" | \
    # brackets at the beginning of a line is the attribute markup,
    # so insert a zero-width space to "escape" it in the text
    perl -0777 -pe "s/\n(\[[[:alnum:]][^]]+?\])/\n&#8203;\$1/gs" | \
    # shorten too long quote markers
    sed 's/^_____*$/____/' | \
    # quote with role
    perl -0777 -pe "s/____\n<attr (role=[^>]+)>\s*/[quote, \1]\n____\n/gs" | \
    # quote has attribution
    perl -0777 -pe "s/\[quote(, [^\n]+)?\](\n____\n((?!____).)*)\n+_[^\n]+_ *<attr attribution=([^>]+)>\n+(____\n)/[quote, \4\1]\2\5/gs" | \
    # make sure image syntax has two colons
    sed 's/^image:\([^:]\)/image::\1/' | \
    # quote breaks
    sed 's/<\* \* \*>/image::quotebreak.png[]/g' | \
    # section breaks
    sed 's/<\* \* \* \* \*>/image::sectionbreak.png[]/g' | \
    # convert latex quotes
    sed -e "s/\`\`\([[:alnum:][:punct:]]\)/“\1/g; s/\([[:alnum:][:punct:]]\)''/\1”/g;" | \
    sed -e   "s/\`\([[:alnum:][:punct:]]\)/‘\1/g; s/\([[:alnum:][:punct:]]\)'/\1’/g;" | \
    cat -s > "$OUT_FILE"

# Check the output file.

RES=""
#RES="$RES"$(grep -E 'FIXME' "$OUT_FILE")
#RES="$RES"$(grep -E "attr:<attribution=" "$OUT_FILE")
RES="$RES"$(grep -E "\`|'|’'" "$OUT_FILE")
RES="$RES"$(grep -E '"' "$OUT_FILE")

if [ "$RES" != "" ]; then
    echo "WARNING! These lines don't look good:"
    echo "$RES"
fi

if [ "$?" == "0" ]; then
    echo "OK"
else
    echo "ERROR, Exiting."
    exit 2
fi

