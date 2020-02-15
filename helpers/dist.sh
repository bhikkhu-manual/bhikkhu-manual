#!/bin/bash

MASTER_DIR="../bhikkhu-manual.github.io-master"

if [ ! -d "$MASTER_DIR" -o ! -f "$MASTER_DIR/config" ]; then
    echo "Create the html master branch .git folder as $MASTER_DIR."
    exit 2
fi

if [ -d book ]; then
    mdbook clean
fi

mdbook build

# Relative path is interpreted from symlink target location, i.e. in ./book
ln -s "../$MASTER_DIR" ./book/.git

