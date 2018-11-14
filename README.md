# xtbook-convert: Utilities for convert to XTBook Dictionary

## これはなに
- XTBook辞書の変換をするためのもの
- 割と雑です

## 環境構築
configure.shを実行すれば環境構築が可能です。

YomiGenesisは環境によっては正常に動作しないため、**確実に** 動作テストが必要です。
xtbconv/bin/YomiGenesis-binに対して漢字仮名混じりの文を入力し、すべて平仮名で出力されれば問題ありません。

```
YomiGenesis-bin: error while loading shared libraries: libiconv.so.2: cannot open shared object file: No such file or directory
```
上記のエラーが出た場合、/usr/local/libにパスが通っていない可能性が高いです。

```
# iconv --version
iconv: error while loading shared libraries: libiconv.so.2: cannot open shared object file: No such file or directory
# find / -name libiconv.so.2
/usr/local/lib/libiconv.so.2
# echo '/usr/local/lib' >> /etc/ld.so.conf
# ldconfig
# iconv --version
iconv (GNU libiconv 1.15)
```

# 使い方
article.shを実行するとxtbconv/scripts/wikisに入っているものが順に変換されていきます。

image.shを実行するとxtbconv/scripts/wikis/imageに入っているものが順に変換されていきます。

``` shell
article.sh [-n Wiki名] [-l Wiki言語] [-c] [-u] [-d]
```
-nで変換するWikiを名前で指定可能です。また、-lで変換するWikiを言語で指定可能です。特に指定がない場合は、発見されたすべてのWikiが変換対象となります。

-cで変換したファイルを7z形式で圧縮、-uで圧縮されたファイルをアップロード、-dで変換したファイルと圧縮済みファイルを削除します。

例:日本語版アンサイクロペディアの記事を変換し、7zで圧縮する場合
``` shell
article.sh -n unwiki -l ja -c
```

# 変換するWikiを追加するには
- xtbconv/plistsの中にInfo.plistを追加し、xtbconv/scripts/wikisにスクリプトを追加してください
- 画像の場合はxtbconv/plistsの中にInfo.plistを追加し、xtbconv/scripts/wikis/imageにスクリプトを追加してください

# ライセンス
- The MIT License

# 作者
- [@Otakan951](https://github.com/Otakan951)
