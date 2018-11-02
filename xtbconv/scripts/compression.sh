#!/bin/bash
mkdir -p ${GENERATED_DIR}/compression/${full_name}/
if [ ${size} -gt 2000 ] ; then
  echo -e "分割圧縮" >> ${LOG_FILE}
  7z a -v1800m -- ${compression_dir}/${out_bundle_dirname}.7z ${out_bundle_dir} 2>> ${LOG_FILE}
else
  echo "通常圧縮" >> ${LOG_FILE}
  7z a -- ${compression_dir}/${out_bundle_dirname}.7z ${out_bundle_dir} 2>> ${LOG_FILE}
fi
