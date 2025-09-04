FROM docker.io/library/caddy:2.10.0-builder AS builder

# Install the Caddy plugins
RUN xcaddy build \
    --with github.com/caddy-dns/cloudflare

# --- ステージ2: 最終イメージ ---
# ビルドしたCaddyバイナリを軽量な公式イメージにコピーする
FROM docker.io/library/caddy:2.10.0

# ビルダーステージからCaddyのカスタムバイナリのみをコピー
COPY --from=builder /usr/bin/caddy /usr/bin/caddy

# ローカルのCaddyfileをコンテナの所定の場所にコピー
COPY /etc/caddy/Caddyfile /etc/caddy/Caddyfile

# Caddyが使用するポートを公開
# 80: HTTP (HTTP->HTTPSリダイレクト用)
# 443: HTTPS (SSL終端用)
EXPOSE 80 443

# (オプション) Caddyが証明書などを保存するデータボリュームを指定
VOLUME /data
VOLUME /config

# コンテナ起動時にCaddyを実行
CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
