# IPT のセットアップ

公式サイト: https://docs.byte-physics.de/ipt/

IPT は Igor Programming Tool の CLI で、Igor Pro 本体とは別のツールです。公式配布バイナリは **リリース後 3 か月**で期限が切れます。この Skill にバイナリは同梱しません。

## 共通：まず PATH と既存のインストール先を確認

~~~bash
command -v ipt
ipt --version
ipt --help
~~~

すでに動作する場合は再インストールしない。

## macOS

1. `uname -s` で `Darwin` か、`uname -m` で CPU アーキテクチャを確認する。
2. `command -v ipt` が失敗したら、`~/.local/bin/ipt` 等に既存バイナリがないか探す。
3. 未インストールなら公式の **MacOSX Standalone (64 bit)** をダウンロードし、ファイルを展開する。zip 等の配布形式・実際のファイル配置を確認する。
4. **実際の実行ファイルを確認した後にのみ** `~/.local/bin/ipt` に配置する。`.app` 形式なら、存在を確認した内部の実行ファイルにリンクする。存在しないパスを決め打ちしない。
5. `~/.local/bin` が PATH にない場合は、重複しないよう `~/.zshrc` に追加する。
6. `ipt --version` と `ipt --help` を確認する。

展開後の実ファイルのパスを確認してから実行する例：

~~~bash
mkdir -p "$HOME/.local/bin"
# 下記のパスを展開された実ファイルのパスに変更すること
install -m 0755 "/absolute/path/to/extracted/ipt" "$HOME/.local/bin/ipt"

case ":$PATH:" in
  *":$HOME/.local/bin:"*) ;;
  *)
    grep -Fqx 'export PATH="$HOME/.local/bin:$PATH"' "$HOME/.zshrc" 2>/dev/null ||
      printf '%s\n' 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.zshrc"
    export PATH="$HOME/.local/bin:$PATH"
    ;;
esac

command -v ipt
ipt --version
~~~

**既存の `~/.local/bin/ipt` を無断で上書きしない。** macOS 版は未署名との公式案内がある。Gatekeeper 等の保護を無断で解除せず、実行時の制限をユーザーに説明する。Apple Silicon などではアーキテクチャ互換性も確認する。

## Linux

公式サイトの Linux Standalone (64 bit) を取得し、`$HOME/.local/bin` など PATH 上に配置する。CI などでは `ipt --version` で検証する。権限がない環境で `sudo` を強制しない。

## Windows

公式の Windows インストーラを使うか、公式が案内する以下のコマンドを使う。

~~~powershell
winget install -e --id byte-physics.ipt
~~~

## コマンドと注意事項

~~~bash
ipt check path/to/file.ipf
ipt lint path/to/file.ipf
# 必要時に限り、差分確認を前提として:
ipt format -i path/to/file.ipf
~~~

- `check` と `lint` は読み取り専用。`format -i` はソースを書き換える。
- `lint --fix --inplace` はコード変換と整形を行うため、無断実行しない。
- IPT が受け付けるソースは UTF-8 または ASCII。
- 起動不能、期限切れ、通信失敗の場合に検証成功とは報告しない。
- IPT は Igor Pro 8.04 専用コンパイラではない。`#if` や特殊な構文などで誤検出があり得る。

公式資料:
- https://docs.byte-physics.de/ipt/commands.html
- https://docs.byte-physics.de/ipt/limitations.html
