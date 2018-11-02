#!/bin/bash

name=jawikisource
full_name=Wikisource

src_xml_filename=${name}-latest-pages-articles.xml.bz2
xml_url=https://dumps.wikimedia.org/${name}/latest/${src_xml_filename}
#テンプレートページの非表示化と変換しない名前空間の指定
wikiplexus_options="-m -x1 -x2 -x3 -x5 -x6 -x7 -x8 -x9 -x11 -x12 -x13 -x15"
#変換しないカスタム名前空間の指定
wikiplexus_options+=" -x103 -x251 -x253 -x828 -x829"
