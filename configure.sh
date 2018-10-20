#!/bin/bash
set -eu -o pipefail
trap 'echo "エラー。環境構築に失敗しました。: 行番号 = $LINENO, 終了ステータス = $?" >&2; exit 1' ERR
readonly SCRIPT_DIR=$(cd $(dirname $0); pwd)
exec > >(tee ${SCRIPT_DIR}/logs/configure.log) 2>&1
mkdir -p ${SCRIPT_DIR}/logs

echo "環境構築を開始します。"
sudo apt update && sudo apt install -y g++ make mecab libmecab-dev mecab-ipadic kakasi libkakasi2-dev libxml2-dev liblzma-dev curl imagemagick p7zip-full unar aria2 libssl-dev python python-dev python-pip

echo -e "libiconvのインストール中…"
cd /usr/src
sudo wget http://ftp.gnu.org/gnu/libiconv/libiconv-1.15.tar.gz
sudo tar zxvf libiconv-1.15.tar.gz
cd libiconv-1.15
sudo sed -i -e 's/_GL_WARN_ON_USE (gets/\/\/_GL_WARN_ON_USE (gets/g' srclib/stdio.in.h
sudo ./configure
sudo make -j2
sudo make install
cd /usr/src
sudo rm -rf libiconv-1.15.tar.gz libiconv-1.15

echo -e "MkXTBWikiplexusのコンパイル中…"
cd ${SCRIPT_DIR}
wget https://github.com/yvt/xtbook/releases/download/v0.2.6/MkXTBWikiplexus-R3.tar.gz
tar zxvf MkXTBWikiplexus-R3.tar.gz
rm -f MkXTBWikiplexus-R3.tar.gz
sudo sed -i -e 's/gets(buf)/scanf("%s",buf)!=EOF/g' MkXTBWikiplexus/MkImageComplex/main.cpp
make -C MkXTBWikiplexus/build.unix all -j2
cp MkXTBWikiplexus/build.unix/*-bin xtbconv/bin/

echo ""
echo ""
echo "----------------------------------------------"
echo ""
echo "環境構築に成功しました。"
echo ""
echo "----------------------------------------------"
echo ""
