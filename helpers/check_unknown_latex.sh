#!/bin/bash

# Check for unknown LaTeX. Exit with 2 if found.

TEX_SRC="$1"

# The LaTeX that pandoc can convert
# The LaTeX which we can replace with sth which pandoc can convert
RES=$(cat "$TEX_SRC" | \
          pcregrep -M -v -e "\n% *LATEX_BEGIN(\n|.)*?% *LATEX_END" | \
          pcregrep -e '\\.' | \
          sed 's/\\./\n&/g' | \
          grep -E '\\.' | \
          grep -vf ./helpers/pandoc_known_latex | \
          grep -vf ./helpers/replace_known_latex | \
          sort | uniq)

if [ "$RES" != "" ]; then
    echo "Warning! Unknown LaTeX found. Edit the document or write replacement rules."
    echo "$RES"
    exit 2
fi
