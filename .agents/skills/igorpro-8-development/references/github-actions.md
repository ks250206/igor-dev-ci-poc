# GitHub Actions による IPT 静的検証

サンプル YAML: [igorpro-ci.yml](../assets/igorpro-ci.yml)

## 追加前に確認

`gh repo view --json isPrivate --jq '.isPrivate'`（または同等の GitHub API）で対象リポジトリの公開設定を確認する。

- **Private または確認できない場合は必ず事前にユーザーへ確認**し、Actions の利用枠・料金の可能性を説明する。
  1. PR / Push で自動実行
  2. `workflow_dispatch` による手動実行だけ
  3. Actions を導入せずローカルで IPT を実行
- 承認されない限り、Actions の新設・有効化・トリガー拡大をしない。
- **Public** は依頼範囲内で導入できるが、既存 CI と重複させない。

## 導入方法

1. 利用先リポジトリの `.github/workflows/` を調べる。
2. 承認・公開設定に合うなら、`assets/igorpro-ci.yml` を利用先の `.github/workflows/igorpro.yml` にコピーする。
3. Private の「手動のみ」なら `pull_request` / `push` を削除し、`workflow_dispatch` のみにする。
4. YAML 構文を検証し、実際に Actions を実行してログを確認する（未実行なら未検証と報告）。
5. 後で見直しやすいよう、IPT の配布方式や期限切れへの対処を README に記録する。

## テンプレートの動作

- Ubuntu ランナーで IPT 公式ドキュメントの HTML から **公式 Linux 版**を取得する。想定ドメイン・パス以外の URL は受け付けない。
- `ipt --version` で起動を確認する。
- Git に登録済みの `.ipf` に `ipt check`、`ipt lint` を実行する。
- エラーがあれば失敗させる。CI 上で Formatter・自動修正は実施しない。
- Igor Pro 8.04 本体のコンパイルは行わない。

## 注意

IPT の配布バイナリには **リリースから 3 か月の使用期限**がある。サイトの最新版が期限切れの場合もあり、CI 側で回避せずエラーを報告する。

テンプレートは最新バイナリの URL を動的に取得しており、**バージョン・SHA-256 を固定していない**。本番運用で再現性・安全性を求める場合はチェックサム検証を追加し、期限内に更新すること。配布元の HTML 変更時はワークフローが失敗するため、勝手に未知のミラーに切り替えないこと。
