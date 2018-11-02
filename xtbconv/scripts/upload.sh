#!/bin/bash
echo "アップロードを開始します" >> ${LOG_FILE}
osdn frs_upload ${GENERATED_DIR}/compression 2>> ${LOG_FILE}
