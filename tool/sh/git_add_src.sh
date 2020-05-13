#!/bin/sh
DATE=`date`
/usr/bin/git add index.html image projectdocs archives webautoarchive.sh url_list.txt git_add_src.sh tool
/usr/bin/git commit -m "${DATE}"
/usr/bin/git push origin master
./webautoarchive.sh
