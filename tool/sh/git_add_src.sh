#!/bin/sh
DATE=`date`
git add index.html image projectdocs archives webautoarchive.sh url_list.txt git_add_src.sh tool
git commit -m "${DATE}"
git push -u origin master
#./webautoarchive.sh
