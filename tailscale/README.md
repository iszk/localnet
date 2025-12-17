# tailscale

## コンテナ作成方法

- proxmox helper script の debian lxc でコンテナを作成
    - 設定は適当で良い
- proxmox helper script の tailscale addon で上記コンテナにアドオンする

## コンテナ設定変更

### IPフォーワーディングをONにする必要がある

設定を書く
```
echo 'net.ipv4.ip_forward = 1' | tee -a /etc/sysctl.d/99-tailscale.conf
echo 'net.ipv6.conf.all.forwarding = 1' | tee -a /etc/sysctl.d/99-tailscale.conf
```

設定を即時反映させる
```
sysctl -p /etc/sysctl.d/99-tailscale.conf
```

コンテナ再起動後も有効

## 起動方法

### 初回
- tailscale の AUTH_KEY をゲットする
- tailscale-up.sh をコンテナに転送する
- 転送したスクリプトの AUTH_KEY= の行を書き換える
- root で書き換えたスクリプトを実行する

### コンテナ再起動時

自動で前回のオプションで起動してくれる


### 普通に起動したいとき

tailscale down で落として再度起動したいときなど
./tailscale-up.sh から起動する必要がある
tailscale up だけだと「オプションなしで起動」として処理される

## その他
tailscale の管理画面で routes とか exit node とかを有効化する必要がある
