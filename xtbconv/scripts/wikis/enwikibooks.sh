#!/bin/bash

wiki_lang=en
wiki_name=wikibooks
full_name=EnglishWikibooks
archive_type=bzip2

src_xml_filename=${wiki_lang}${wiki_name}-latest-pages-articles.xml.bz2
xml_url=https://dumps.wikimedia.org/${wiki_lang}${wiki_name}/latest/${src_xml_filename}
#テンプレートページの非表示化と変換しない名前空間の指定
wikiplexus_options="-m -x1 -x2 -x3 -x5 -x6 -x7 -x8 -x9 -x11 -x12 -x13 -x15"
#変換しないカスタム名前空間の指定
wikiplexus_options+=" -x101 -x828 -x829"
