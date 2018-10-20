#!/bin/bash
echo "アップロードを開始します" >> ${logPath}
osdn frs_upload ${derivedPath}/compression 2>> ${logPath}
