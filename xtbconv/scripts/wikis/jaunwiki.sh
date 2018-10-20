#!/bin/bash

name=jaunwiki
full_name=Uncyclopedia

xml=ja-wiki.zip
xmlUrl=http://download.uncyc.org/${xml}
#変換しない名前空間の指定
wikiplexusOptions="-m -x1 -x2 -x3 -x5 -x6 -x7 -x8 -x9 -x11 -x12 -x13 -x15"
#変換しないカスタム名前空間の指定
wikiplexusOptions+=" -x33 -x103 -x105 -x107 -x110 -x111 -x113 -x117"
