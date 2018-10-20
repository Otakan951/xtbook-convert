#!/bin/bash

name=jawikiquote
full_name=Wikiquote

xml=${name}-latest-pages-articles.xml.bz2
xmlUrl=https://dumps.wikimedia.org/${name}/latest/${xml}
#テンプレートページの非表示化と変換しない名前空間の指定
wikiplexusOptions="-m -x1 -x2 -x3 -x5 -x6 -x7 -x8 -x9 -x11 -x12 -x13 -x15"
#変換しないカスタム名前空間の指定
wikiplexusOptions+=" -x828 -x829"
