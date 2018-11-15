#!/bin/bash

function usage_exit() {
  echo "仕様:image.sh [-n wiki名] [-l Wiki言語]"
  echo "-cで変換されたファイルを7zで圧縮、-uで変換されたファイルをアップロード、-dで変換されたファイルと圧縮されたファイルを削除します"
  echo "複数のWiki名・Wiki言語を指定することも可能です。"
}

name_array=()
lang_aray=()
while getopts :n:l: OPT; do
  case ${OPT} in
    n)
      name_array+=(${OPTARG})
      flag_name_array=true ;;
    l)
      lang_array+=(${OPTARG})
      flag_lang_array=true ;;
    c)
      flag_compression=true ;;
    u)
      flag_upload=true ;;
    d)
      flag_delete=true ;;
    *)
      echo "ERROR:引数が正しくありません。" | tee ${LOG_FILE}
      usage_exit
      exit 1 ;;
  esac
done

readonly BASE_DIR=$(cd $(dirname $0); pwd)

source ${BASE_DIR}/xtbconv/scripts/common.sh

for script in $(find ${BASE_DIR}/xtbconv/scripts/wikis/image -mindepth 1 -maxdepth 1 -type f -name "*.sh"); do
  source ${script}

  echo "" >> ${LOG_FILE}
  echo "INFO:Name = \"${wiki_lang}${wiki_name}:${full_name}\"" >> ${LOG_FILE}

  site_state=$(curl --head ${xml_url} -o /dev/null -w '%{http_code}\n' -s)
  if [ "${site_state}" = "200" ]; then
    :
  else
    echo "ERROR:${site_state}"
    continue
  fi

  if [ $# != 0 ]; then
    check_option
    #WIki言語もWiki名も指定されていない場合はすべて変換
    if [ "${flag_name_array}" != "true" -a "${flag_wiki_lang}" != "true" ]; then
      #Wiki名が指定されず、指定されたWiki言語に一致する言語が見つからない場合
      echo "INFO:${wiki_lang}${wiki_name}は条件に一致しません。${wiki_lang}${wiki_name}の変換をスキップします。" >> ${LOG_FILE}
      continue
    elif [ "INFO:${flag_lang_array}" != "true" -a "${flag_wiki_name}" != "true" ]; then
      #WIki言語が指定されず、指定されたWiki名に一致する名前が見つからない場合
      echo "INFO:${wiki_lang}${wiki_name}は条件に一致しません。${wiki_lang}${wiki_name}の変換をスキップします。" >> ${LOG_FILE}
      continue
    elif [ "${flag_name_array}" = "true" -a "${flag_lang_array}" = "true" ] && [ "${flag_wiki_name}" = "false" -o "${flag_wiki_lang}" = "false" ]; then
      #Wiki名もWiki言語も指定されたが、一致する名前と言語が見つからない場合
      echo "INFO:${wiki_lang}${wiki_name}は条件に一致しません。${wiki_lang}${wiki_name}の変換をスキップします。" >> ${LOG_FILE}
      continue
    fi
  fi

  plist_file=${BASE_DIR}/xtbconv/plists/${wiki_lang}${wiki_name}/Info.plist
  out_bundle_dirname=${wiki_lang}${wiki_name}-${DATE}.xtbdict
  out_bundle_dir=${GENERATED_DIR}/xtbdict/${out_bundle_dirname}
  compression_dir=${GENERATED_DIR}/compression/${full_name}/${DATE}

  if [ -e ${out_bundle_dir} -o -e ${compression_dir}/${out_bundle_dirname}.7z* ]; then
    #同日に変換したWikiのファイル、もしくは圧縮済みファイルが存在する場合
    echo "NOTICE:${wiki_lang}${wiki_name}は既に変換済みです。${wiki_lang}${wiki_name}の変換をスキップします。" >> ${LOG_FILE}
    continue
  elif [ ! -e ${plist_file} ]; then
    echo "ERROR:Info.plistが見つかりません。${wiki_lang}${wiki_name}の変換をスキップします。" >> ${LOG_FILE}
    continue
  fi

  echo "INFO:Archive Type = \"${archive_type}\"" >> ${LOG_FILE}
  echo "INFO:Image URL = \"${image_url}\"" >> ${LOG_FILE}
  echo "INFO:ImageMagick Options = \"${imagemagick_options}\"" >> ${LOG_FILE}
  echo "INFO:plist File = \"${plist_file}\"" >> ${LOG_FILE}
  echo "INFO:Out Bundle Directory = \"${out_bundle_dir}\"" >> ${LOG_FILE}
  echo "INFO:Compression Directory = \"${compression_dir}\"" >> ${LOG_FILE}
  echo "INFO:Wikiplexus Log = \"${WIKIPLEXUS_LOG_FILE}\"" >>${LOG_FILE}

  mkdir -p ${out_bundle_dir} ${TEMP_DIR}/images/resized

  if [ "${archive_type}" = "zip" ]; then
    curl --retry 5 ${image_url} -o${TEMP_DIR}/${src_image_filename}
    7z e -y ${TEMP_DIR}/${src_image_filename} -o${TEMP_DIR}/images
    convmv -r -f shift_jis -t utf8 ${TEMP_DIR}/images/* --notest 2>> ${LOG_FILE}
    cd ${TEMP_DIR}/images
    find ./ -type f \( -iname '-*' -o -iname '*.mp3' -o -iname '*.ogg' -o -iname '*.swf' \) -delete 2>> ${LOG_FILE}
    find ./ -maxdepth 1 -mindepth 1 -type f -exec convert {} ${imagemagick_options}\> resized/{}.jpg \; 2>> ${LOG_FILE}
    find ${TEMP_DIR}/images/resized -maxdepth 1 -mindepth 1 -name "*.jpg" > ${TEMP_DIR}/imageList.txt
  else
    curl --retry 5 -s ${image_url} | \
    7z e -y -si${src_image_filename} -o${TEMP_DIR}/images
    convmv -r -f shift_jis -t utf8 ${TEMP_DIR}/images/* --notest 2>> ${LOG_FILE}
    cd ${TEMP_DIR}/images
    find ./ -type f \( -iname '-*' -o -iname '*.mp3' -o -iname '*.ogg' -o -iname '*.swf' \) -delete 2>> ${LOG_FILE}
    find ./ -maxdepth 1 -mindepth 1 -type f -exec convert {} ${imagemagick_options}\> resized/{}.jpg \; 2>> ${LOG_FILE}
    find ${TEMP_DIR}/images/resized -maxdepth 1 -mindepth 1 -name "*.jpg" > ${TEMP_DIR}/imageList.txt
  fi

  ${MKIMAGECOMPLEX} -o ${out_bundle_dir} -s < ${TEMP_DIR}/imageList.txt 2>> ${WIKIPLEXUS_LOG_FILE}

  cd ${TEMP_DIR}
  rm -rf *
  cp ${plist_file} ${out_bundle_dir}/Info.plist

  size=`du -m ${out_bundle_dir} |awk '{print $1}'`
  echo "INFO:圧縮前のファイルサイズ:${size}MB" >> ${LOG_FILE}
  compression_files
  echo "${full_name},${out_bundle_dirname}" >> ${CONVERTED_LIST_FILE}
done
upload_files
delete_files
rm -f ${CONVERTED_LIST_FILE}
