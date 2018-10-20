#!/bin/bash
mkdir -p ${derivedPath}/compression/${full_name}/
if [ $size -gt 2000 ] ; then
  echo -e "分割圧縮" >> ${logPath}
  7z a -v1800m -- ${compressionPath}/${outBundleName}.7z ${outBundle} 2>> $logPath
else
  echo "通常圧縮" >> ${logPath}
  7z a -- ${compressionPath}/${outBundleName}.7z ${outBundle} 2>> $logPath
fi
echo ${full_name} >> ${converedList}
