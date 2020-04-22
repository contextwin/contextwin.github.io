#!/bin/sh
# 外部コマンド wgetコマンドに依存しています!!
DATE=`date "+%Y%m%d_%H%M%S"`
WEBURL="https://contextwin.github.io"
CONTEXTWINIO="/home/contextwin/work/src/contextwin.github.io"
ARCHIVESDIR="${CONTEXTWINIO}/archives"
CURRENTDOCDIR="${ARCHIVESDIR}/current"
OLDARCHIVESDIR="${ARCHIVESDIR}/old"
HOROBIDOCS="/home/contextwin/work/src/contextwin.github.io/projectdocs"


if [ ! -e ${ARCHIVESDIR} ]; then
 mkdir ${ARCHIVESDIR}
fi

if [ ! -e ${CURRENTDOCDIR} ]; then
 mkdir ${CURRENTDOCDIR}
fi

if [ ! -e ${OLDARCHIVESDIR} ]; then
 mkdir ${OLDARCHIVESDIR}
fi

file ${CONTEXTWINIO}/* | grep HTML | cut -f 1 -d ":" | rev | cut -f 1 -d "/" | rev | cut -f 1 -d "." > tmp_list
file ${HOROBIDOCS}/* | grep HTML | cut -f 1 -d ":" | rev | cut -f 1 -d "/" | rev | cut -f 1 -d "." >> tmp_list

for LIST in `cat tmp_list`
do
 if [ ! -e ${CURRENTDOCDIR}/${LIST} ]; then
 mkdir ${CURRENTDOCDIR}/${LIST}
 fi
done

for LIST in `cat tmp_list`
do
 if [ ! -e ${OLDARCHIVESDIR}/${LIST} ]; then
 mkdir ${OLDARCHIVESDIR}/${LIST}
 fi
done

for LIST in `cat tmp_list`
do
 if [ "index" = "${LIST}" ]; then
 wget -O "${CURRENTDOCDIR}/${DATE}.html" ${WEBURL}/${LIST}.html
 else
 wget -O "${CURRENTDOCDIR}/${DATE}.html" ${WEBURL}/projectdocs/${LIST}.html
 fi

 WC=`diff ${CURRENTDOCDIR}/${DATE}.html ${CURRENTDOCDIR}/${LIST}/*.html | wc -l`

 if [ ${WC} -gt 0 ]; then
  echo updated ${LIST} >> update_list
  mv ${CURRENTDOCDIR}/${LIST}/*html ${OLDARCHIVESDUR}/${LIST}/.
  mv ${CURRENTDOCDIR}/${DATE}.html ${CURRENTDOCDIR}/${LIST}/.
 else
  echo no-updated ${LIST} >> update_list
  rm ${CURRENTDOCDIR}/${DATE}.html
 fi

done

cat update_list
rm tmp_list

