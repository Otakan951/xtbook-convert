#!/bin/bash

function usage_exit() {
  echo "仕様:articles.sh [-n wiki名] [-l Wiki言語]"
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
    *)
      echo "引数が正しくありません。"
      usage_exit
      exit 1 ;;
  esac
done

readonly BASE_DIR=$(cd $(dirname $0); pwd)

source ${BASE_DIR}/xtbconv/scripts/common.sh

for script in $(find ${BASE_DIR}/xtbconv/scripts/wikis -mindepth 1 -maxdepth 1 -type f -name "*.sh"); do
  source ${script}

  if [ $# != 0 ]; then
    check_option
    if [ "${flag_name_array}" != "true" -a "${flag_wiki_lang}" != "true" ]; then
      echo "${wiki_lang}${wiki_name}は条件に一致しません。${wiki_lang}${wiki_name}の変換をスキップします。" >> ${LOG_FILE}
      continue
    elif [ "${flag_lang_array}" != "true" -a "${flag_wiki_name}" != "true" ]; then
      echo "${wiki_lang}${wiki_name}は条件に一致しません。${wiki_lang}${wiki_name}の変換をスキップします。" >> ${LOG_FILE}
      continue
    elif [ "${flag_name_array}" = "true" -a "${flag_lang_array}" = "true" ] && [ "${flag_wiki_name}" = "false" -o "${flag_wiki_lang}" = "false" ]; then
      echo "${wiki_lang}${wiki_name}は条件に一致しません。${wiki_lang}${wiki_name}の変換をスキップします。" >> ${LOG_FILE}
      continue
    fi
  fi

  plist_file=${BASE_DIR}/xtbconv/plists/${wiki_lang}${wiki_name}/Info.plist
  out_bundle_dirname=${wiki_lang}${wiki_name}-${DATE}.xtbdict
  out_bundle_dir=${GENERATED_DIR}/xtbdict/${out_bundle_dirname}
  compression_dir=${GENERATED_DIR}/compression/${full_name}/${DATE}

  echo "Name = \"${wiki_lang}${wiki_name}:${full_name}\"" >> ${LOG_FILE}

  if [ -e ${out_bundle_dir} -o -e ${compression_dir}/${out_bundle_dirname}.7z* ]; then
    echo "${wiki_lang}${wiki_name}は既に変換済みです。${wiki_lang}${wiki_name}の変換をスキップします。" >> ${LOG_FILE}
    continue
  elif [ ! -e ${plist_file} ]; then
    echo "Info.plistが見つかりません。${wiki_lang}${wiki_name}の変換をスキップします。" >> ${LOG_FILE}
    continue
  fi

  echo "XML URL = \"${xml_url}\"" >> ${LOG_FILE}
  echo "WikiPlexus options = \"${wikiplexus_options}\"" >> ${LOG_FILE}
  echo "plist = \"${plist_file}\"" >> ${LOG_FILE}
  echo "out bundle dir = \"${out_bundle_dir}\"" >> ${LOG_FILE}
  echo "compression dir = \"${compression_dir}\"" >> ${LOG_FILE}
  echo "WikiPlexus log = \"${WIKIPLEXUS_LOG_FILE}\"" >>${LOG_FILE}

  mkdir ${out_bundle_dir}

  curl --retry 5 -s ${xml_url} | \
  7z x -si${src_xml_filename} -so | \
  ${MKXTBWIKIPLEXUS} -o ${out_bundle_dir} -s ${wikiplexus_options} 2>> ${WIKIPLEXUS_LOG_FILE} | \
  ${MKRAX} -o ${out_bundle_dir}/Articles.db.rax 2>> ${WIKIPLEXUS_LOG_FILE} >> ${WIKIPLEXUS_LOG_FILE}
  ${YOMIGENESIS} < ${out_bundle_dir}/BaseNames.csv > ${out_bundle_dir}/Yomis.csv 2>> ${WIKIPLEXUS_LOG_FILE}
  ${MKXTBINDEXDB} -o ${out_bundle_dir}/Search ${out_bundle_dir}/Yomis.csv 2>> ${WIKIPLEXUS_LOG_FILE}

  rm -f ${out_bundle_dir}/BaseNames.csv ${out_bundle_dir}/Titles.csv
  cp ${plist_file} ${out_bundle_dir}/Info.plist

  size=`du -m ${out_bundle_dir} |awk '{print $1}'`
  echo "圧縮前のファイルサイズ:${size}MB" >> ${LOG_FILE}
  #compression_files
  echo "${full_name},${out_bundle_dirname}" >> ${CONVERTED_LIST_FILE}
done
#upload_files
#delete_files
rm -f ${CONVERTED_LIST_FILE}
