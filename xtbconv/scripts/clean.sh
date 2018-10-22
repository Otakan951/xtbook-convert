#!/bin/bash
echo "変換したデータを削除します" >> ${logPath}
while IFS=, read -r full_name outBundleName
do
  echo "削除:${derivedPath}/xtbdict/${outBundleName}" >> ${logPath}
  cd ${derivedPath}/xtbdict/
  rm -rf ${outBundleName} 2>> ${logPath}
  echo "削除:${derivedPath}/compression/${full_name}/${DATE}/${outBundleName}.7z" >> ${logPath}
  cd ${derivedPath}/compression/${full_name}
  rm -rf ${DATE} 2>> ${logPath}
done < ${converedList}
