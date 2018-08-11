#!/bin/bash

if [ "$1" == "" ]; then
    echo "First argument should be a book name with no spaces for the output file names."
    exit 2
fi

# 1. Generate a MOBI with asciidoctor-epub3
#   1.1 use "-a ebook-extract" to unzip the KF8 EPUB
# 2. modify it
# 3. zip back to EPUB
# 4. convert to MOBI KF8 with kindlegen
# (opt) 5. convert to MOBI 6 with ebook-convert (calibre)

MAIN_ADOC="$1.adoc"
NAME="$1"

# no trailing slash
OUT_DIR=output

MOBI_KF8_NAME="$NAME-custom-kf8.mobi"
MOBI_6_NAME="$NAME-custom-mobi6.mobi"

EPUB_NAME="$NAME-build.epub"

nav_guide_path="./manuscript/xml/nav-guide.xhtml"

build_dir="$OUT_DIR/$NAME-kf8"

# Remove output files if they exist, to make sure they will be new. For example
# zip will append to existing epub files instead of overwriting them.

for i in "$OUT_DIR/$NAME.mobi" "$OUT_DIR/$NAME-kf8.epub" "$OUT_DIR/$EPUB_NAME" "$OUT_DIR/$MOBI_KF8_NAME" "$OUT_DIR/$MOBI_6_NAME"
do
    if [ -e "$i" ]; then
        echo "Removing: $i"
        rm "$i"
    fi
done

# === 1. Generate a MOBI with asciidoctor-epub3 ===

KINDLEGEN=$HOME/bin/kindlegen asciidoctor-epub3 \
    -D "$OUT_DIR" \
    -a ebook-format=kf8 \
    -a ebook-extract \
    -o "$NAME.mobi" \
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

# === 4. convert to MOBI with kindlegen ===

# packager.rb:616
$HOME/bin/kindlegen "$OUT_DIR/$EPUB_NAME" -dont_append_source -c1 -o "$MOBI_KF8_NAME"

RET="$?"
if [ "$RET" != "0" -a "$RET" != "1" ]; then
    echo "ERROR! Kindlegen returned with $RET"
    exit 2
fi

# === (opt) 5. convert to old mobi6 format with calibre ===

#ebook-convert "$OUT_DIR/$EPUB_NAME" "$OUT_DIR/$MOBI_6_NAME" --mobi-file-type=old
#
#RET="$?"
#if [ "$RET" != "0" -a "$RET" != "1" ]; then
#    echo "ERROR! ebook-convert returned with $RET"
#    exit 2
#fi

# Tidy up after build

rm -r \
   "$build_dir" \
   "$OUT_DIR/$EPUB_NAME" \
   "$OUT_DIR/$NAME-kf8.epub" \
   "$OUT_DIR/$NAME.mobi"
