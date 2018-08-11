#!/bin/bash

make document && \
make document && \
make document && \
make document

RET=$?

if [ $RET -eq 0 ]; then
    notify-send "Document compiled"
else
    notify-send --urgency=critical "Document failed to compile"
fi

