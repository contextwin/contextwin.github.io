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

for URL_STR in `grep -E "http://|https://" ${URL_LIST}`
do
 # url_list.txt 読み込み
 TMP_STR=`echo ${URL_STR} | sed -e "s/^http:\/\/\|^https:\/\///"`
 MKDIR_PATH_CURRENT="${ARCHIVESDIR}/${TMP_STR}/current"
 MKDIR_PATH_OLD="${ARCHIVESDIR}/${TMP_STR}/old"
 
 # ディレクトリ作成処理
 if [ ! -e ${MKDIR_PATH_CURRENT} ]; then
  mkdir -p ${MKDIR_PATH_CURRENT}
  echo "Created directory ${MKDIR_PATH_CURRENT}"
 fi
 
 if [ ! -e ${MKDIR_PATH_OLD} ]; then
  mkdir -p ${MKDIR_PATH_OLD}
  echo "Created directory ${MKDIR_PATH_OLD}"
 fi
 
 # ダウンロード処理
 wget -O "./${DATE}" ${URL_STR} > /dev/null 2>&1
 # ダウンロード成功時,失敗時の分岐処理
 if [ 0 -eq `echo $?` ]; then # ダウンロード成功の場合の処理
  echo "Download completed " "${URL_STR}" >> wget_result.txt
 else
  echo "Download failed " "${URL_STR} " "Processing interruption." >> wget_result.txt
  continue
 fi
 
 # ダウンロードファイル移動
 WC=`ls -1U ${MKDIR_PATH_CURRENT} | wc -l`
 if [ 0 -eq ${WC} ]; then # current ディレクトリが空だった場合の処理
     echo "New ${URL_STR}" >> diff_result.txt
  mv ${DATE} "${MKDIR_PATH_CURRENT}/."
 else # current ディレクトリにすでにファイルがある場合の処理
  DIFF=`diff ${DATE} ${MKDIR_PATH_CURRENT}/* | wc -l`
  # 更新チェック処理
  if [ 0 -eq ${DIFF} ]; then # 既にあるファイルとの差分がない場合の処理
   echo "No-updated ${URL_STR}" >> diff_result.txt
   rm ${DATE}
  elif [ 0 -lt ${DIFF} ]; then # 既にあるファイルとの差分がある場合の処理
   echo "Updated ${URL_STR}" >> diff_result.txt
   mv "${MKDIR_PATH_CURRENT}/"* "${MKDIR_PATH_OLD}/."
   mv ${DATE} "${MKDIR_PATH_CURRENT}/."
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
