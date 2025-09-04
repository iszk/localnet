# obsidian-livesync

obsidian の [obsidian-livesync/README_ja.md at main · vrtmrz/obsidian-livesync · GitHub](https://github.com/vrtmrz/obsidian-livesync/blob/main/README_ja.md) に利用するための couchdb

couchdb の設定ファイルに手を入れたりしているので、普通の couchdb として利用したくなっても、それと併用はしない。

couchdb の user は明示的に作成せず、環境変数を設定して起動した際に作成されるユーザーを利用する。
パスワードは生のものが書かれるので注意すること。


# 実行方法
cloudflare tunnel を通じて外に出すように作ってあるので、さきに cloudflared を実行しておく

`.env.dist` ファイルをコピーし、`.env` ファイルを作成する
ユーザー名、パスワードを適切なものに変更する
`docker compose up` で起動する
local.ini が UID/GID=5984 に変更されてしまい非常に扱いづらいので、chmod 666 をやっておく

データベースが作成されていないので作成する
http://localhost:5984/_utils にアクセスし、

