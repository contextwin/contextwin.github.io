#!/bin/sh
DATE=`date`
/usr/bin/git add cmemword.png index.html memword.png slaves.png xmemword.png git_add_src.sh
/usr/bin/git commit -m "${DATE}"
/usr/bin/git push origin master
