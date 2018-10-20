#!/bin/bash
echo "変換したデータを削除します" >> ${logPath}
cd ${derivedPath}/xtbdict/
find -name "*-${DATE}.xtbdict" >> ${logPath}
rm -rf *-${DATE}.xtbdict
while IFS= read -r name
do
  cd ${derivedPath}/7z/${name}/
  find -name ${DATE} >> ${logPath}
  rm -rf ${DATE}
done < ${converedList}
