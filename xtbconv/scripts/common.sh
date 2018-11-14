#!/bin/bash

readonly DATE=$(date "+%Y%m%d")
readonly GENERATED_DIR=${BASE_DIR}/xtbconv/generated
readonly TEMP_DIR=${GENERATED_DIR}/temp
readonly LOG_FILE=${GENERATED_DIR}/logs/${DATE}.log
readonly WIKIPLEXUS_LOG_FILE=${GENERATED_DIR}/logs/wikiplexus-${DATE}.log
readonly CONVERTED_LIST_FILE=${GENERATED_DIR}/logs/CONVERTED_LIST_FILE-${DATE}.log
readonly MKXTBWIKIPLEXUS=${BASE_DIR}/xtbconv/bin/MkXTBWikiplexus-bin
readonly YOMIGENESIS=${BASE_DIR}/xtbconv/bin/YomiGenesis-bin
readonly MKRAX=${BASE_DIR}/xtbconv/bin/MkRax-bin
readonly MKXTBINDEXDB=${BASE_DIR}/xtbconv/bin/MkXTBIndexDB-bin
readonly MKIMAGECOMPLEX=${BASE_DIR}/xtbconv/bin/MkImageComplex-bin

mkdir -p  ${TEMP_DIR} ${GENERATED_DIR}/logs

echo "Base dir = \"${BASE_DIR}\"" >> ${LOG_FILE}
echo "Generated dir = \"${GENERATED_DIR}\"" >> ${LOG_FILE}
echo "Temp dir = \"${TEMP_DIR}\"" >> ${LOG_FILE}
echo "Converted list = \"${CONVERTED_LIST_FILE}\"" >> ${LOG_FILE}
echo "MkXTBWikiplexus = \"${MKXTBWIKIPLEXUS}\"" >> ${LOG_FILE}
echo "YomiGenesis = \"${YOMIGENESIS}\"" >> ${LOG_FILE}
echo "MkRax = \"${MKRAX}\"" >> ${LOG_FILE}
echo "MkXTBIndexDB = \"${MKXTBINDEXDB}\"" >> ${LOG_FILE}
echo "MkImageComplex = \"${MKIMAGECOMPLEX}\"" >> ${LOG_FILE}

if [ ! -e ${MKXTBWIKIPLEXUS} ]; then
  echo "MkXTBWikiplexusが見つかりません。変換を中断しました。" >> ${LOG_FILE}
  exit 3
elif [ ! -e ${YOMIGENESIS} ]; then
  echo "YomiGenesisが見つかりません。変換を中断しました。" >> ${LOG_FILE}
  exit 3
elif [ ! -e ${MKRAX} ]; then
  echo "MkRaxが見つかりません。変換を中断しました。" >> ${LOG_FILE}
  exit 3
elif [ ! -e ${MKXTBINDEXDB} ]; then
  echo "MkXTBIndexDBが見つかりません。変換を中断しました。" >> ${LOG_FILE}
  exit 3
elif [ ! -e ${MKIMAGECOMPLEX} ]; then
  echo "MkImageComplexが見つかりません。変換を中断しました。" >> ${LOG_FILE}
  exit 3
fi

function check_option() {
  if [ "${flag_name_array}" = "true" ]; then
    for temp_name in ${name_array[@]}; do
      if [ "${wiki_name}" != "${temp_name}" ]; then
        flag_wiki_name=false
      else
        flag_wiki_name=true
        break
      fi
    done
  fi

  if [ "${flag_lang_array}" = "true" ]; then
    for temp_lang in ${lang_array[@]}; do
      if [ "${wiki_lang}" != "${temp_lang}" ]; then
        flag_wiki_lang=false
      else
        flag_wiki_lang=true
        break
      fi
    done
  fi

  return 0
}

function compression_files(){
  if [ "${flag_compression}" = "true" ]; then
    mkdir -p ${GENERATED_DIR}/compression/${full_name}/
    if [ ${size} -gt 2000 ] ; then
      echo -e "分割圧縮" >> ${LOG_FILE}
      7z a -v1800m -- ${compression_dir}/${out_bundle_dirname}.7z ${out_bundle_dir} 2>> ${LOG_FILE}
    else
      echo "通常圧縮" >> ${LOG_FILE}
      7z a -- ${compression_dir}/${out_bundle_dirname}.7z ${out_bundle_dir} 2>> ${LOG_FILE}
    fi
  fi
  return 0
}

function upload_files(){
  if [ "${flag_upload}" = "true" ]; then
    echo "アップロードを開始します" >> ${LOG_FILE}
    osdn frs_upload ${GENERATED_DIR}/compression 2>> ${LOG_FILE}
  fi
  return 0
}

function delete_files(){
  if [ "${flag_delete}" = "true" ]; then
    echo "変換したデータを削除します" >> ${LOG_FILE}
    while IFS=, read -r full_name out_bundle_dirname
    do
      if [ -e ${GENERATED_DIR}/xtbdict/${out_bundle_dirname} ]; then
        echo "削除:${GENERATED_DIR}/xtbdict/${out_bundle_dirname}" >> ${LOG_FILE}
        cd ${GENERATED_DIR}/xtbdict/
        rm -rf ${out_bundle_dirname} 2>> ${LOG_FILE}
      else
        echo "${out_bundle_dirname}が見つかりません。" >> ${LOG_FILE}
      fi
      if [ -e ${GENERATED_DIR}/compression/${full_name}/${DATE}/${out_bundle_dirname}.7z ]; then
        echo "削除:${GENERATED_DIR}/compression/${full_name}/${DATE}/${out_bundle_dirname}.7z" >> ${LOG_FILE}
        cd ${GENERATED_DIR}/compression/${full_name}
        rm -rf ${DATE} 2>> ${LOG_FILE}
      elif [ -e ${GENERATED_DIR}/compression/${full_name}/${DATE}/${out_bundle_dirname}.7z.001 ]; then
        echo "削除:${GENERATED_DIR}/compression/${full_name}/${DATE}/${out_bundle_dirname}.7z.001" >> ${LOG_FILE}
        cd ${GENERATED_DIR}/compression/${full_name}
        rm -rf ${DATE} 2>> ${LOG_FILE}
      else
        echo "${out_bundle_dirname}.7zは見つかりません。" >> ${LOG_FILE}
      fi
    done < ${CONVERTED_LIST_FILE}
  fi
  return 0
}
