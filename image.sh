#!/bin/bash

readonly basePath=$(cd $(dirname $0); pwd)

source ${basePath}/xtbconv/scripts/common.sh

for script in `ls ${basePath}/xtbconv/scripts/wikis/image`; do
  source ${basePath}/xtbconv/scripts/wikis/image/${script}
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

  echo "imageUrl = \"${imageUrl}\"" >> ${logPath}
  echo "plistPath = \"${plistPath}\"" >> ${logPath}
  echo "outBundle = \"${outBundle}\"" >> ${logPath}
  echo "compressionPath = \"${compressionPath}\"" >> ${logPath}
  echo "wikiplexusLogPath = \"${wikiplexusLogPath}\"" >>${logPath}

  mkdir -p ${outBundle} ${tempPath}/images/resized

  curl --retry 5 ${imageUrl} -o${tempPath}/${srcImage}
  7z e -y ${tempPath}/${srcImage} -o${tempPath}/images
  convmv -r -f shift_jis -t utf8 ${tempPath}/images/* --notest 2>> ${logPath}
  cd ${tempPath}/images
  find ./ -type f \( -iname '-*' -o -iname '*.mp3' -o -iname '*.ogg' -o -iname '*.swf' \) -delete 2>> ${logPath}
  find ./ -maxdepth 1 -mindepth 1 -type f -exec convert {} -quality 80 -resize 800x480\> resized/{}.jpg \; 2>> ${logPath}
  find ${tempPath}/images/resized -maxdepth 1 -mindepth 1 -name "*.jpg" > ${tempPath}/imageList.txt

  ${MkImageComplexPath} -o ${outBundle} -s < ${tempPath}/imageList.txt 2>> ${wikiplexusLogPath}

  cd ${tempPath}
  rm -rf *
  cp ${plistPath} ${outBundle}/Info.plist

  size=`du -m ${outBundle} |awk '{print $1}'`
  echo "圧縮前のファイルサイズ:${size}MB" >> ${logPath}
  source ${basePath}/xtbconv/scripts/compression.sh
  echo "${full_name},${outBundleName}" >> ${converedList}
done
#source ${basePath}/xtbconv/scripts/upload.sh
#source ${basePath}/xtbconv/scripts/clean.sh
rm -f ${converedList}
