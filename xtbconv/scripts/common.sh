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
