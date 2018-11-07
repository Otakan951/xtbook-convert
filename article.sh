#!/bin/bash

readonly BASE_DIR=$(cd $(dirname $0); pwd)

source ${BASE_DIR}/xtbconv/scripts/common.sh

for script in $(find ${BASE_DIR}/xtbconv/scripts/wikis -mindepth 1 -maxdepth 1 -type f -name "*.sh"); do
  source ${script}
  plist_file=${BASE_DIR}/xtbconv/plists/${name}/Info.plist
  out_bundle_dirname=${name}-${DATE}.xtbdict
  out_bundle_dir=${GENERATED_DIR}/xtbdict/${out_bundle_dirname}
  compression_dir=${GENERATED_DIR}/compression/${full_name}/${DATE}

  echo "Name = \"${name}:${full_name}\"" >> ${LOG_FILE}

  if [ -e ${out_bundle_dir} -o -e ${compression_dir}/${out_bundle_dirname}.7z* ]; then
    echo "${name}は既に変換済みです。${name}の変換をスキップします。" >> ${LOG_FILE}
    continue
  elif [ ! -e ${plist_file} ]; then
    echo "Info.plistが見つかりません。${name}の変換をスキップします。" >> ${LOG_FILE}
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
