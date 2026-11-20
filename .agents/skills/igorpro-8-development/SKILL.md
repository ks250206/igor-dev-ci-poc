---
name: igorpro-8-development
description: Igor Pro 8.04のProcedureファイル（.ipf）、マクロ、関数の実装・編集・レビュー・互換性検証、IPTによる構文チェック・Lint・Formatter、macOSでのIPT導入、GitHub Actionsの設定に使用するSkill。
license: MIT
---

# Igor Pro 8.04 Development

## 目的

Igor Pro 8.04 に対応した `.ipf` の実装、修正、レビューを支援する。**最重要原則：Igor Pro 8.04 で動くコードを優先し、IPT の成功と Igor 本体でのコンパイル成功を混同しない。**

ユーザーが対象バージョンを別途指定した場合、8.04 の制約を無条件に適用せず、対象の違いを明示する。

## 1. 作業開始前の確認

1. 対象ランタイムは **Igor Pro 8.04**。Igor Pro 9 以降に導入された構文、Operation、関数、API、フラグを使用しない。
2. 既存の `.ipf`、`#include`、`#pragma`、命名規則、コメント、インデント、呼び出し元を確認する。
3. 不明な API・構文を推測で創作しない。Igor Pro 8 の公式マニュアルなど一次資料を優先する。
4. Operation と Function、`Macro` と `Function`、ローカル / グローバル変数、`WAVE` / `NVAR` / `SVAR` / `DFREF` を区別する。
5. Wave の存在・データ型・次元・インデックス範囲・データフォルダを考慮する。
6. 非 UTF-8 の疑いがあるソースはエンコーディングを確認し、黙って変換しない。

## 2. IPT の確認とセットアップ

Igor Programming Tool（IPT）を静的解析に利用する。**ローカル作業開始時は最初に以下を実行する**。

~~~bash
command -v ipt
ipt --version
ipt --help
~~~

- PATH 上に既存 IPT があればそのまま使う。PATH にない場合は既存インストール先も調べる。
- **macOS** で未インストールなら公式配布版を取得し、実行ファイルを `~/.local/bin/ipt` から起動できるようにする。`~/.local/bin` が PATH にない場合は、重複しないよう `~/.zshrc` に `export PATH="$HOME/.local/bin:$PATH"` を設定する。
- macOS 以外では対応 OS の公式版を使い、権限のない環境に無理に導入しない。
- バイナリはリリースから **3 か月**で利用期限が切れる。期限切れや起動不能を検証成功とみなさない。
- 既存の正常な IPT を不要に上書きしない。未署名バイナリのため OS の保護を無断で回避しない。
- 詳しい導入と障害時の対処は [IPT セットアップ](references/ipt-setup.md) を読む。

## 3. コーディング

- Igor Pro 8.04 で利用可能な文法を使用する。`Function` / `End`、`Macro` / `EndMacro`、`Structure`、`Menu` 等の終端を正しく対応させる。
- 引数、戻り値、スコープ、Wave の有無・型・次元を適切に扱う。
- 既存動作や設計意図を保ち、無関係な大規模変更・リファクタリングを避ける。
- 特に Igor Pro 9 / 10 の新機能を混ぜ込まない。
- IPT の診断だけを理由に、Igor Pro 8 で正常動作するコードを壊さない。

## 4. 変更後の検証

変更した **すべての `.ipf`** に対して以下を実行する。

~~~bash
ipt check path/to/file.ipf
ipt lint path/to/file.ipf
~~~

- `ipt check` と `ipt lint` はファイルを書き換えない。
- エラーを分析し、今回の変更で新たに発生した問題と既存の問題を区別する。修正後は再実行する。
- 整形が必要な場合のみ `ipt format -i path/to/file.ipf` を実行し、`git diff` で差分を確認後、`ipt check` と `ipt lint` を再実行する。
- `ipt lint --fix --inplace` は大量の書き換えを招く場合がある。ユーザーの意図と差分を確認せずに実行しない。
- IPT が Igor Pro の有効なコードを拒否する場合がある。[IPT の既知の制限](https://docs.byte-physics.de/ipt/limitations.html)と Igor Pro 8 の仕様を確認し、誤検出なら記録して無理な変更はしない。
- IPT が利用できない場合も作業可能な範囲を進めるが、**IPT 未実施**と明記し、結果を捏造しない。

## 5. コミット前

~~~bash
git diff --check
git diff
~~~

- 変更したファイルだけが差分にあるかを確認する。
- 新規の重大な静的解析エラーが残っていないか確認する。
- Igor Pro 8 との互換性を IPT とは別に確認する。
- **実際に Igor Pro 8.04 でコンパイルしていなければ「コンパイル成功」とは報告しない。**

## 6. GitHub Actions のポリシー

新規 Actions ワークフローの追加・有効化・トリガー拡大の前に、対象リポジトリの公開設定を確認する。`gh` が使える場合は以下を実行する。

~~~bash
gh repo view --json isPrivate --jq '.isPrivate'
~~~

- **Private リポジトリ、または公開設定が確認できない場合**：**ユーザーの明示的な許可が必要**。Actions の使用量・課金の可能性を説明し、次の選択肢を提示する。
  1. Push / Pull Request で自動実行
  2. `workflow_dispatch` による手動実行のみ
  3. 導入しない（ローカル IPT 検証のみ）
- 許可前に新設・有効化・実行頻度拡大を行わない。承認されない場合も他の実装を進める。
- **Public リポジトリ**：ユーザーの依頼範囲で必要なら導入可能。既存 CI の有無、重複、実行頻度を確認する。
- CI は `ipt check` と `ipt lint` を実行し、ソースを書き換えない。IPT の期限切れやダウンロード失敗を成功扱いしない。失敗を `continue-on-error: true` や `|| true` で隠さない。
- **Skill のインストールだけで GitHub Actions を自動導入しない。**

ガイド: [GitHub Actions](references/github-actions.md)  
サンプル: [igorpro-ci.yml](assets/igorpro-ci.yml)

## 7. 完了報告

1. 実装内容と変更ファイル
2. Igor Pro 8.04 の互換性を確認した範囲
3. `ipt check` / `ipt lint` の実行結果（未実施なら理由）
4. Formatter の適用状況と差分確認
5. GitHub Actions の導入・実行状況（該当時）
6. **Igor Pro 8.04 本体でのコンパイル実施有無**
7. 残るエラー、既知の IPT 誤検出、環境制約

## 公式資料

- https://docs.byte-physics.de/ipt/
- https://docs.byte-physics.de/ipt/commands/ipt_check.html
- https://docs.byte-physics.de/ipt/commands/ipt_lint.html
- https://docs.byte-physics.de/ipt/commands/ipt_format.html
- https://docs.byte-physics.de/ipt/limitations.html
