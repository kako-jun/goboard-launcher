# GoBoard Launcher

GoBoard Launcher は囲碁盤（9 路盤）を模したアプリランチャーを目指すプロジェクトです。碁盤の交点をアプリの配置とショートカット体系に見立て、直感的かつ高速にアプリを起動できることをコンセプトとしています。

## コンセプト
- 9×9 の碁盤に 81 個のアプリを配置し、座標入力で高速起動
- 世界的に "Go"（囲碁）を想起させるユニークな UI
- 天元（中央 5,5）には最重要アプリを設定

## UI 仕様
- 9×9＝81 の交点を基本構造とするランチャー画面
- 各交点にアプリアイコンを表示し、ページ切り替えは不要
- 天元（5,5）は特別枠として扱い、重要アプリを配置

## ショートカット仕様
- `ggg` と 3 回打つことでランチャーを呼び出し
- 座標指定は `ggg11` ～ `ggg99`
  - 例: `ggg34` → 縦 3・横 4 の交点にあるアプリを起動
- 予備ホットキーとして `Ctrl + Alt + G` などを併用可能

## プラットフォーム別挙動
- **Windows / Linux**
  - タスクトレイに常駐し、`system_tray` パッケージでアイコン管理
- **macOS**
  - Dock に表示し、Dock メニューはネイティブ連携でカスタマイズ
- **Android**
  - ホーム画面アイコンから起動
  - ウィジェットやショートカットで碁盤 UI を直接配置可能

## 技術スタック
- Flutter を共通 UI / ロジックとして利用
- プラットフォームチャネルで OS 固有機能を呼び出し
  - Windows / Linux: タスクトレイ連携
  - macOS: Dock メニュー連携
  - Android: ウィジェット / ショートカット連携

## プロジェクト概要
- リポジトリ名: `goboard-launcher`
- 9 路盤 UI で 81 個のアプリを座標入力で起動
- ショートカット体系: `ggg11` ～ `ggg99`
- Flutter ベースで PC / Mac / Linux / Android に対応
- 各 OS 固有の起動方法を柔軟に実装予定

## 実装状況（2024-05-09 時点）
- `lib/main.dart` に 9×9 の碁盤 UI と天元ハイライト、モック用 81 アプリを定義
- `RawKeyboardListener` を用いた `ggg` + 座標のショートカット解析と、状態遷移を可視化するショートカットインジケーターを実装
- 認識した座標に応じてセルをアニメーション付きでハイライトし、実行結果メッセージと連動
- Flutter Lints に準拠したコードスタイルを維持するため `analysis_options.yaml` を整備

## 開発環境のセットアップ
1. Flutter 3.22 以降（Dart 3.3 以降）がインストールされていることを確認
2. Dart/Flutter の依存関係を解決
   ```bash
   flutter pub get
   ```
3. Husky の Git フックを有効化（初回のみ）
   ```bash
   npm install
   npm run prepare  # core.hooksPath を .husky に設定
   ```
4. デスクトップまたはモバイル向けに起動
   ```bash
   flutter run
   ```

### Web/デスクトップでのキーバインド確認
アプリ起動後にキーボードで `ggg55` などと入力すると、ショートカットインジケーターのチップが入力済み文字を示し、該当セルが緑色にハイライトされます。これにより、座標解釈と UI 反応を即座に確認できます。

## 自動生成と Lint フロー
- `tool/shortcuts.yaml` から 9×9 のショートカット定義を生成するスクリプトを追加しています。
  ```bash
  dart run tool/generate_shortcuts.dart
  ```
- Husky の pre-commit フックで自動生成 → Dart フォーマット → `flutter analyze` を連続実行し、生成物を自動で `git add` します。
- CI (`.github/workflows/ci.yml`) でもコード生成差分とフォーマット/解析/テストを検証します。

## GitHub Actions によるビルド/リリース
- `ci.yml` で Pull Request/`main` ブランチへの push に対してコード生成の差分チェック、フォーマット、`flutter analyze`、`flutter test` を実行します。
- `release.yml` は `v*` タグの push をトリガーに Flutter Web のリリースビルドを作成し、`goboard-launcher-web.tar.gz` として GitHub Release に添付します（同時にアーティファクトもアップロード）。
