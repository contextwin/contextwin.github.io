#!/bin/sh
iconv -f SHIFT_JIS -t UTF-8 $1 > tmp
cat tmp > $1
rm tmp
