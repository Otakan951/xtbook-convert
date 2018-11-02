#!/bin/bash

name=jaunwikiimg
full_name=UncyclopediaImage

src_image_filename=ja-images.zip
image_url=http://download.uncyc.org/${src_image_filename}
#画像の品質と解像度を指定
imagemagick_options="-quality 80 -resize 800x480"
