# atcoder-library-d

[![Actions · kotet/atcoder-library-d](https://github.com/kotet/atcoder-library-d/workflows/Test:%20dmd%20&%20ldc/badge.svg?branch=master)](https://github.com/kotet/atcoder-library-d/actions?query=workflow%3A%22Test%3A+dmd+%26+ldc%22)
[![Actions · kotet/atcoder-library-d](https://github.com/kotet/atcoder-library-d/workflows/Test:%20gdc/badge.svg?branch=master)](https://github.com/kotet/atcoder-library-d/actions?query=workflow%3A%22Test%3A+gdc%22)
[![Coverage Status](https://coveralls.io/repos/github/kotet/atcoder-library-d/badge.svg?branch=master)](https://coveralls.io/github/kotet/atcoder-library-d?branch=master)

[AtCoder Library (ACL)](https://atcoder.jp/posts/517)
のD言語移植です。
`D (DMD 2.091.0)`、`D (GDC 9.2.1)`、`D (LDC 1.20.1)`で動作することを目標にしています。
This project is waiting for your contribution.

## build

`concat.sh`を実行するとimportやunittestを除いたコードを1つに結合した`snippets.d`が生成されます。
これ全体を自分のコードにコピペして利用します。