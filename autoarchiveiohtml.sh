#!/bin/sh
# 外部コマンド wgetコマンドに依存しています!!
DATE=`date "+%Y%m%d_%H%M%S"`
WEBURL="https://contextwin.github.io"
CONTEXTWINIO="."
ARCHIVESDIR="${CONTEXTWINIO}/archives"
CURRENTDOCDIR="${ARCHIVESDIR}/current"
OLDARCHIVESDIR="${ARCHIVESDIR}/old"
HOROBIDOCS="./projectdocs"

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
WC=`ls -1 ${CURRENTDOCDIR}/${LIST} | wc -l`
 if [ ${WC} -eq 0 ]; then
 touch ${CURRENTDOCDIR}/${LIST}/a.html
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
  mv ${CURRENTDOCDIR}/${LIST}/*html ${OLDARCHIVESDIR}/${LIST}/.
  mv ${CURRENTDOCDIR}/${DATE}.html ${CURRENTDOCDIR}/${LIST}/.
  if [ -e ${CURRENTDOCDIR}/${LIST}/a.html ]; then
  rm ${CURRENTDOCDIR}/${LIST}/a.html
  fi
 else
  echo no-updated ${LIST} >> update_list
  rm ${CURRENTDOCDIR}/${DATE}.html
 fi

done

cat update_list
rm update_list
rm tmp_list
