#!/bin/bash

readonly BASE_DIR=$(cd $(dirname $0); pwd)

source ${BASE_DIR}/xtbconv/scripts/common.sh

for script in $(find ${BASE_DIR}/xtbconv/scripts/wikis/image -mindepth 1 -maxdepth 1 -type f -name "*.sh"); do
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

  echo "Image URL = \"${image_url}\"" >> ${LOG_FILE}
  echo "ImageMagick options = \"${imagemagick_options}\"" >> ${LOG_FILE}
  echo "plist = \"${plist_file}\"" >> ${LOG_FILE}
  echo "out bundle dir = \"${out_bundle_dir}\"" >> ${LOG_FILE}
  echo "compression dir = \"${compression_dir}\"" >> ${LOG_FILE}
  echo "WikiPlexus log = \"${WIKIPLEXUS_LOG_FILE}\"" >>${LOG_FILE}

  mkdir -p ${out_bundle_dir} ${TEMP_DIR}/images/resized

  curl --retry 5 ${image_url} -o${TEMP_DIR}/${src_image_filename}
  7z e -y ${TEMP_DIR}/${src_image_filename} -o${TEMP_DIR}/images
  convmv -r -f shift_jis -t utf8 ${TEMP_DIR}/images/* --notest 2>> ${LOG_FILE}
  cd ${TEMP_DIR}/images
  find ./ -type f \( -iname '-*' -o -iname '*.mp3' -o -iname '*.ogg' -o -iname '*.swf' \) -delete 2>> ${LOG_FILE}
  find ./ -maxdepth 1 -mindepth 1 -type f -exec convert {} ${imagemagick_options}\> resized/{}.jpg \; 2>> ${LOG_FILE}
  find ${TEMP_DIR}/images/resized -maxdepth 1 -mindepth 1 -name "*.jpg" > ${TEMP_DIR}/imageList.txt

  ${MKIMAGECOMPLEX} -o ${out_bundle_dir} -s < ${TEMP_DIR}/imageList.txt 2>> ${WIKIPLEXUS_LOG_FILE}

  cd ${TEMP_DIR}
  rm -rf *
  cp ${plist_file} ${out_bundle_dir}/Info.plist

  size=`du -m ${out_bundle_dir} |awk '{print $1}'`
  echo "圧縮前のファイルサイズ:${size}MB" >> ${LOG_FILE}
  #compression_files
  echo "${full_name},${out_bundle_dirname}" >> ${CONVERTED_LIST_FILE}
done
#upload_files
#delete_files
rm -f ${CONVERTED_LIST_FILE}
