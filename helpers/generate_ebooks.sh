#!/bin/bash

MDBOOK_EPUB_BIN=../mdbook-epub-gambhiro/target/debug/mdbook-epub

EBOOK_NAME="Bhikkhu-Manual-Reference"
EPUB_FILE="$EBOOK_NAME.epub"
MOBI_FILE="$EBOOK_NAME.mobi"

# Use book-epub.toml to provide options
mv book.toml book-html.toml
cp book-epub.toml book.toml

# Use titlepage-ebook.md for a simple title page
cd manuscript/markdown
mv titlepage.md titlepage-html.md
cp titlepage-ebook.md titlepage.md
cd ../..

$MDBOOK_EPUB_BIN --standalone

if [ "$?" != "0" ]; then
    echo "Error, exiting."
    exit 2
fi

# Restore
mv book-html.toml book.toml
cd manuscript/markdown
mv titlepage-html.md titlepage.md
cd ../..

mv "./book/epub/Bhikkhu Manual.epub" "./$EPUB_FILE"

if [ "$?" != "0" ]; then
    echo "Error, exiting."
    exit 2
fi

~/bin/epubcheck "./$EPUB_FILE"

if [ "$?" != "0" ]; then
    echo "Error, exiting."
    exit 2
fi

~/lib/kindlegen/kindlegen "./$EPUB_FILE" -dont_append_source -c1 -verbose

if [ "$?" != "0" ]; then
    echo "Error, exiting."
    exit 2
fi

mv "./$EPUB_FILE" "./manuscript/markdown/includes/docs"
mv "./$MOBI_FILE" "./manuscript/markdown/includes/docs"

echo "OK"

