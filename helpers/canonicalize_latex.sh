#!/bin/bash

# Replace or remove LaTeX which pandoc doesn't know.

TEX_SRC="$1"

cat "$TEX_SRC" | \
# Converting quote environments. Put the original markup in a role attribute forasciidoc
perl -0777 -pe "s/\\\\begin\{quote\}(.*?)\\\\end\{quote\}/\\\\begin{quote}% <attr role=quote>\n\\\\itshape \1\\\\end{quote}/gs" | \
# \begin{lpchah} > \begin{quote}
perl -0777 -pe "s/\\\\begin\{lpchah\}(.*?)\\\\end\{lpchah\}/\\\\begin{quote}% <attr role=lpchah>\n\1\\\\end{quote}/gs" | \
# remove \item from dialogue env
sed -e '/\\begin[{]dialogue[}]/,/\\end[{]dialogue[}]/{ s/^\\item *//; };' | \
# \begin{dialogue} > \begin{quote}
perl -0777 -pe "s/\\\\begin\{dialogue\}(.*?)\\\\end\{dialogue\}/\\\\begin{quote}% <attr role=dialogue>\n\1\\\\end{quote}/gs" | \
# \begin{siderule-quote} > \begin{quote}
perl -0777 -pe "s/\\\\begin\{siderule-quote\}(.*?)\\\\end\{siderule-quote\}/\\\\begin{quote}\n\1\\\\end{quote}/gs" | \
# \begin{openingVerse} > \begin{verse}
perl -0777 -pe "s/\\\\begin\{openingVerse\}(.*?)\\\\end\{openingVerse\}/\\\\begin{verse}% <attr role=opening-verse>\n\\\\itshape \1\\\\end{verse}/gs" | \
# glossarydescription
sed -e 's/\\begin{glossarydescription}/\\begin{description}/; s/\\end{glossarydescription}/\\end{description}/;' | \
# chapter title and subtitle
perl -0777 -pe "s/\\\\chapterTitle\{(.*?)\}(.*?)\\\\theChapterTitle/\2\1/gs" | \
perl -0777 -pe "s/\\\\chapterSubtitle\{(.*?)\}(.*?)\\\\theChapterSubtitle/\2\1/gs" | \
# chapter note with a footnote which has an emph
perl -0777 -pe "s/\\\\chapterNote\{([^\}]+\\\\footnote\{[^\}]+\\\\emph\{[^\}]+\}[^\}]*\}[^\}]*?)\}(.*?\\\\chapter\{.*?\})/\2\n\n\\\\emph{\1}/gs" | \
# chapter note with a footnote
perl -0777 -pe "s/\\\\chapterNote\{([^\}]+\\\\footnote\{[^\}]+\}[^\}]*?)\}(.*?\\\\chapter\{.*?\})/\2\n\n\\\\emph{\1}/gs" | \
# chapter note
perl -0777 -pe "s/\\\\chapterNote\{(.*?)\}(.*?\\\\chapter\{.*?\})/\2\n\n\\\\emph{\1}/gs" | \
# toc chapter note
perl -0777 -pe "s/\\\\tocChapterNote\{.*?\}//gs" | \
perl -0777 -pe "s/\\\\chapterPhotoTwoPage\{(.*?)\}\{.*?\}\{.*?\}\{.*?\}/\\\\includegraphics{\1}/gs" | \
perl -0777 -pe "s/\\\\chapterPhotoInlinePortrait\{.*?\}\{(.*?)\}/\\\\includegraphics{\1}/gs" | \
perl -0777 -pe "s/\\\\chapterPhotoInlineLandscape\{(.*?)\}/\\\\includegraphics{\1}/gs" | \
perl -0777 -pe "s/\\\\includegraphics[[][^]]+[]]\{.*?\}//gs" | \
perl -0777 -pe "s/\\\\verseRef\{(.*?)\}/\n\\\\emph{\1}% <attr attribution=\1>\n/gs" | \
perl -0777 -pe "s/\\\\quoteRef\{(.*?)\}/\n\\\\emph{\1}% <attr attribution=\1>\n/gs" | \
perl -0777 -pe "s/\\\\quoteRefInline\{(.*?)\}/\n\\\\emph{\1}% <attr attribution=\1>\n/gs" | \
perl -0777 -pe "s/\\\\thai\{(.*?)\}/\1/gs" | \
perl -0777 -pe "s/\\\\textup\{(.*?)\}/{\\\\upshape \1}/gs" | \
perl -0777 -pe "s/\\\\label\{.*?\}//gs" | \
perl -0777 -pe "s/\\\\enlargethispage\**\{.*?\}//gs" | \
perl -0777 -pe "s/\\\\setlength\{.*?\}\{.*?\}//gs" | \
perl -0777 -pe "s/\\\\pageref\{.*?\}/FIXME:pageref/gs" | \
# Repeating hyphen (in Portuguese)
sed 's/\(\w\)"-\(\w\)/\1-\2/g' |\
sed 's/^\\vspace\**[{][^}]\+[}]%*$//g' |\
sed 's/\\thinspace\s*/~/g' |\
sed 's/\\par/\n\n/g' |\
sed 's/\\mainmatter//g' |\
sed 's/\\centering//g' |\
sed 's/\\raggedleft//g' |\
sed 's/\\clearpage//g' |\
sed 's/\\parskip//g' |\
sed 's/\\baselineskip//g' |\
sed 's/\\linewidth//g' |\
sed 's/\\Large//g' |\
sed 's/\\sectionBreak/\n\n<* * * * *>\n\n/g' |\
sed 's/\\quoteBreak/\n\n<* * *>\n\n/g' |\
perl -0777 -pe "s/\{[\s\%]+\}//gs"
