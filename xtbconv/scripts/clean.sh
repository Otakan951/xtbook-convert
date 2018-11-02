#!/bin/bash
echo "変換したデータを削除します" >> ${LOG_FILE}
while IFS=, read -r full_name out_bundle_dirname
do
  echo "削除:${GENERATED_DIR}/xtbdict/${out_bundle_dirname}" >> ${LOG_FILE}
  cd ${GENERATED_DIR}/xtbdict/
  rm -rf ${out_bundle_dirname} 2>> ${LOG_FILE}
  echo "削除:${GENERATED_DIR}/compression/${full_name}/${DATE}/${out_bundle_dirname}.7z" >> ${LOG_FILE}
  cd ${GENERATED_DIR}/compression/${full_name}
  rm -rf ${DATE} 2>> ${LOG_FILE}
done < ${CONVERTED_LIST_FILE}
