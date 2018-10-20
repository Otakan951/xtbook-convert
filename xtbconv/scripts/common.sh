#!/bin/bash

readonly DATE=`date "+%Y%m%d"`
readonly derivedPath=${basePath}/xtbconv/derived
readonly tempPath=${derivedPath}/temp
readonly logPath=${derivedPath}/logs/${DATE}.log
readonly converedList=${derivedPath}/logs/converedList-${DATE}.log
readonly MkXTBWikiplexusPath=${basePath}/xtbconv/bin/MkXTBWikiplexus-bin
readonly YomiGenesisPath=${basePath}/xtbconv/bin/YomiGenesis-bin
readonly MkRaxPath=${basePath}/xtbconv/bin/MkRax-bin
readonly MkXTBIndexDBPath=${basePath}/xtbconv/bin/MkXTBIndexDB-bin

echo "実行日:${DATE}" > ${logPath}
echo "basePath"=\"${basePath}\" >> ${logPath}
echo "derivedPath=\"${derivedPath}\"" >> ${logPath}
echo "tempPath=\"${tempPath}\"" >> ${logPath}
echo "converedList=\"${converedList}\"" >> ${logPath}
echo "MkXTBWikiplexusPath=\"${MkXTBWikiplexusPath}\"" >> ${logPath}
echo "YomiGenesisPath=\"${YomiGenesisPath}\"" >> ${logPath}
echo "MkRaxPath=\"${MkRaxPath}\"" >> ${logPath}
echo "MkXTBIndexDBPath=\"${MkXTBIndexDBPath}\"" >> ${logPath}

if [ ! -e ${MkXTBWikiplexusPath} ]; then
  echo "MkXTBWikiplexusが見つかりません。変換を中断しました。" >> ${logPath}
  exit 3
fi

if [ ! -e ${YomiGenesisPath} ]; then
  echo "YomiGenesisが見つかりません。変換を中断しました。" >> ${logPath}
  exit 3
fi

if [ ! -e ${MkRaxPath} ]; then
  echo "MkRaxが見つかりません。変換を中断しました。" >> ${logPath}
  exit 3
fi

if [ ! -e ${MkXTBIndexDBPath} ]; then
  echo "MkXTBIndexDBが見つかりません。変換を中断しました。" >> ${logPath}
  exit 3
fi
