#!/bin/bash

if [ "$1" == "" ]; then
    echo "First argument should be a book name with no spaces for the output file names."
    exit 2
fi

# 1. Generate an EPUB with asciidoctor-epub3
#   1.1 use "-a ebook-extract" to unzip the KF8 EPUB
# 2. modify it
# 3. zip back to EPUB

MAIN_ADOC="$1.adoc"
NAME="$1"

# no trailing slash
OUT_DIR=output

EPUB_NAME="$NAME-custom.epub"

nav_guide_path="./manuscript/xml/nav-guide.xhtml"

build_dir="$OUT_DIR/$NAME"

# Remove output files if they exist, to make sure they will be new. For example
# zip will append to existing epub files instead of overwriting them.

for i in "$OUT_DIR/$NAME.epub" "$OUT_DIR/$EPUB_NAME"
do
    if [ -e "$i" ]; then
        echo "Removing: $i"
        rm "$i"
    fi
done

# === 1. Generate an EPUB with asciidoctor-epub3 ===

asciidoctor-epub3 \
    -D "$OUT_DIR" \
    -a ebook-format=epub3 \
    -a ebook-extract \
    -o "$NAME.epub" \
    "$MAIN_ADOC"

if [ "$?" != "0" ]; then
    echo "ERROR! asciidoctor-epub3 failed."
    exit 2
fi

# === 2. modify it ===

# https://unix.stackexchange.com/a/32911/2528

# put nav-guide.xhtml above the closing </body> tag in nav.xhtml

awk "/<\\/body>/{while(getline line<\"$nav_guide_path\"){print line}} //" "$build_dir/OEBPS/nav.xhtml" > tmp
mv tmp "$build_dir/OEBPS/nav.xhtml"

# The nav-guide links to nav.xhtml, so it to the spine, otherwise kindlegen will
# warn about unresolved hyperlinks.

# nav at the bottom
sed -i 's/<\/spine>/<itemref idref="nav" linear="no"\/>\n&/' "$build_dir/OEBPS/package.opf"

# === 3. zip back to EPUB ===

{ cd "$build_dir" \
  && zip -X0 "../$EPUB_NAME" mimetype \
  && zip -rg "../$EPUB_NAME" META-INF -x \*.DS_Store \
  && zip -rg "../$EPUB_NAME" OEBPS -x \*.DS_Store \
  && cd -; } > zip.log 2>&1

if [ "$?" != "0" ]; then
    echo "ERROR! See zip.log"
    exit 2
fi

# Tidy up after build

rm -r \
   "$build_dir" \
   "$OUT_DIR/$NAME.epub"
