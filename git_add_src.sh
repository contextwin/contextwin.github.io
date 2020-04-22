#!/bin/sh
DATE=`date`
/usr/bin/git add index.html image projectdocs archives autoarchiveiohtml.sh git_add_src.sh
/usr/bin/git commit -m "${DATE}"
/usr/bin/git push origin master
