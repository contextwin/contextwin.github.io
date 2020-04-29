#!/bin/sh
# 同じディレクトリに url_list ファイルを用意して下さい
# 外部コマンド wgetコマンドに依存しています!!
URL_LIST="url_list.txt"
DATE=`date "+%Y%m%d_%H%M%S"`
WEBURL="https://contextwin.github.io"
CONTEXTWINIO="."
ARCHIVESDIR="${CONTEXTWINIO}/archives"
HOROBIDOCS="./projectdocs"

# 引数チェック (コマンドラインからの引数を受け取るようにしても良いかも)
if [ 0 -ne $# ]; then
 echo "== autoarchiveiohtml.sh usage =="
 echo "This command takes no actual arguments."
 echo "Sorry."
 exit 1
fi

if [ ! -e ${URL_LIST} ]; then
 echo "== autoarchiveiohtml.sh usage =="
 echo "Please create a file named url_list.txt in the current directory."
 echo "And describe the target url in url_list.txt."
 echo "Lines whose first character is not http or https are ignored."
 exit 1
fi

if [ ! -e ${ARCHIVESDIR} ]; then
 mkdir ${ARCHIVESDIR}
fi

# ftpも対応させる
for URL_STR in `grep -E "http://|https://" ${URL_LIST}`
do
 # url_list.txt 読み込み
 FILE_NAME=`basename ${URL_STR}`
 TMP_STR=`echo ${URL_STR} | sed -e "s/^http:\/\/\|^https:\/\///"`
 MKDIR_PATH=${ARCHIVESDIR}/${TMP_STR}
 MKDIR_PATH_CURRENT=`echo ${MKDIR_PATH}/${DATE}`

 # ディレクトリ作成処理 old
 if [ ! -e "${MKDIR_PATH}/old" ] ; then
  mkdir -p "${MKDIR_PATH}/old"
  echo "Created directory  ${MKDIR_PATH}/old"
 fi

 # ディレクトリ作成処理 Date
 if [ ! -e ${MKDIR_PATH_CURRENT} ]; then
  mkdir -p ${MKDIR_PATH_CURRENT}
  echo "Created directory ${MKDIR_PATH_CURRENT}"
 fi
 
 # ダウンロード処理
 wget -O "${MKDIR_PATH_CURRENT}/${FILE_NAME}" ${URL_STR} > /dev/null 2>&1
 # ダウンロード成功時,失敗時の分岐処理
 if [ 0 -eq `echo $?` ]; then # ダウンロード成功の場合の処理
  echo "Download completed " "${URL_STR} " >> wget_result.txt
  CURRENT_FILE_PATH="${MKDIR_PATH_CURRENT}/${FILE_NAME}"
  # img video のデータがあればディレクトリ作成しダウンロードする
  for LIST in `perl -nle 'print /<img[^>]+src="(.+?)"|<video[^>]+src="(.+?)"/' ./${CURRENT_FILE_PATH}`
  do
  
   # 現在相対パスの場合のみ対応
   BASENAME=`basename ${LIST}`
   LIST=`echo ${LIST} | perl -pe 's/^\.//' | perl -ne 'print /(.*)(?=\/)/'`
   URL_STR2=`dirname ${URL_STR}`
   URL_STR2="${URL_STR2}/`echo ${LIST} | perl -pe 's/^.*\///'`/${BASENAME}"
   LIST="${MKDIR_PATH_CURRENT}${LIST}"
  
   # ディレクトリ作成処理 (current)
   if [ ! -e ${LIST} ]; then
    mkdir -p ${LIST}
    echo "Created directory ${MKDIR_PATH_CURRENT}${LIST}"
   fi
   
   LIST="${LIST}/${BASENAME}"
   # ダウンロード処理
   wget -O "${LIST}" "${URL_STR2}" > /dev/null 2>&1
   echo "Download completed " " ${URL_STR2}" >> wget_result.txt
  done
 else # ダウンロード失敗の場合の処理
  echo "Download failed " "${URL_STR} " "Processing interruption." >> wget_result.txt
  continue
 fi

 # アップデート確認　&　ディレクトリ移動移動処理
 WC=`ls -1U ${MKDIR_PATH} | wc -l`
 if [ 2 -eq ${WC} ]; then # Dateディレクトリ, oldだけだった場合の処理
  echo "New ${URL_STR}" >> diff_result.txt
  continue
 elif [ 3 -eq ${WC} ]; then # Dateディレクトリにファイルが３つある場合の処理
  DIR_PATH_OLD=`ls -1U ${MKDIR_PATH} | grep -v -e ${DATE} -e old`
  find ${MKDIR_PATH}/${DATE} -type f | sort | sed -e "s/^.*${DATE}//" > currentfile.txt
  find ${MKDIR_PATH}/${DIR_PATH_OLD} -type f | sort | sed -e "s/^.*${DIR_PATH_OLD}//" > oldfile.txt
  CURRENT_FILEWC=`cat currentfile.txt | wc -l`
  OLD_FILEWC=`cat oldfile.txt | wc -l`
  
 # find ${MKDIR_PATH}/${DATE} -type f | sort | sed -e "s/^.*${DATE}//" > currentfile.txt
 # find ${MKDIR_PATH}/${DIR_PATH_OLD} -type f | sort | sed -e "s/^.*${DIR_PATH_OLD}//" > oldfile.txt
  
  if [ ${CURRENT_FILEWC} -eq ${OLD_FILEWC} ]; then # ファイル数を比較して同一の場合
  
   # ファイル名の差分比較
   FILE_NAME_DIFF=`diff currentfile.txt oldfile.txt | wc -l`
   
   if [ 0 -eq ${FILE_NAME_DIFF} ]; then # ファイル名が全て同一の場合
    
    # ダウンロードしたファイルの差分比較
    for LIST in `cat currentfile.txt`
    do
     DIFF=`diff "${MKDIR_PATH}/${DATE}${LIST}" "${MKDIR_PATH}/${DIR_PATH_OLD}${LIST}" | wc -l`
     # 更新チェック処理
     if [ 0 -eq ${DIFF} ]; then # 既にあるファイルとの差分がない場合の処理
      echo "No-updated ${URL_STR}" >> diff_result.txt
     elif [ 0 -lt ${DIFF} ]; then # 既にあるファイルとの差分がある場合の処理
      echo "Updated ${URL_STR}" >> diff_result.txt
      mv "${MKDIR_PATH}/${DIR_PATH_OLD}" "${MKDIR_PATH}/old/."
     fi
    done
    
    rm currentfile.txt oldfile.txt
    rm -r ${MKDIR_PATH_CURRENT}
    
   else # ファイル名に差がある場合
      echo "Updated ${URL_STR}" >> diff_result.txt
      mv "${MKDIR_PATH}/${DIR_PATH_OLD}" "${MKDIR_PATH}/old/."
   fi 

  else # ファイル数に差がある場合
   echo "Updated ${URL_STR}" >> diff_result.txt
   mv "${MKDIR_PATH}/${DIR_PATH_OLD}" "${MKDIR_PATH}/old/."
  fi
 
 fi
done

# 実行結果表示処理
echo == downloads result ==
cat wget_result.txt
rm wget_result.txt
echo == update info ==
cat diff_result.txt
rm diff_result.txt

exit 0

#Below URL is web pages of easy explanation this tool.
#http://contextwin.livedoor.blog/archives/5808849.html
#https://contextwin.github.io/projectdocs/about_tools.html
