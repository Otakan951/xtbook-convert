#!/bin/bash

readonly basePath=$(cd $(dirname $0); pwd)

source ${basePath}/xtbconv/scripts/common.sh

for script in `ls ${basePath}/xtbconv/scripts/wikis`; do
  source ${basePath}/xtbconv/scripts/wikis/${script}
  plistPath=${basePath}/xtbconv/plists/${name}/Info.plist
  outBundleName=${name}-${DATE}.xtbdict
  outBundle=${derivedPath}/xtbdict/${outBundleName}
  compressionPath=${derivedPath}/compression/${full_name}/${DATE}
  wikiplexusLogPath=${derivedPath}/logs/wikiplexus-${DATE}.log

  echo "Name = \"${name}:${full_name}\"" >> ${logPath}

  if [ -e ${outBundle} -o -e ${compressionPath}/${outBundleName}.7z* ]; then
    echo "${name}は既に変換済みです。${name}の変換をスキップします。" >> ${logPath}
    continue
  elif [ ! -e ${plistPath} ]; then
    echo "Info.plistが見つかりません。${name}の変換をスキップします。" >> ${logPath}
    continue
  fi

  echo "xmlUrl = \"${xmlUrl}\"" >> ${logPath}
  echo "wikiplexusOptions = \"${wikiplexusOptions}\"" >> ${logPath}
  echo "plistPath = \"${plistPath}\"" >> ${logPath}
  echo "outBundle = \"${outBundle}\"" >> ${logPath}
  echo "compressionPath = \"${compressionPath}\"" >> ${logPath}
  echo "wikiplexusLogPath = \"${wikiplexusLogPath}\"" >>${logPath}

  mkdir ${outBundle}

  curl --retry 5 -s ${xmlUrl} | \
  7z x -si${xml} -so | \
  ${MkXTBWikiplexusPath} -o ${outBundle} -s ${wikiplexusOptions} 2>> ${wikiplexusLogPath} | \
  ${MkRaxPath} -o ${outBundle}/Articles.db.rax 2>> ${wikiplexusLogPath} >> ${wikiplexusLogPath}
  ${YomiGenesisPath} < ${outBundle}/BaseNames.csv > ${outBundle}/Yomis.csv 2>> ${wikiplexusLogPath}
  ${MkXTBIndexDBPath} -o ${outBundle}/Search ${outBundle}/Yomis.csv 2>> ${wikiplexusLogPath}

  rm -f ${outBundle}/BaseNames.csv ${outBundle}/Titles.csv
  cp ${plistPath} ${outBundle}/Info.plist

  size=`du -m ${outBundle} |awk '{print $1}'`
  echo "圧縮前のファイルサイズ:${size}MB" >> ${logPath}
  #source ${basePath}/xtbconv/scripts/compression.sh
done

#source ${basePath}/xtbconv/scripts/upload.sh
#source ${basePath}/xtbconv/scripts/clean.sh
