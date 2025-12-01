# GoBoard Launcher 開発者向けドキュメント

囲碁盤（9路盤）UIのアプリランチャー。

## プロジェクト構造

```
lib/
├── main.dart                    # エントリーポイント、碁盤UI
└── generated/
    └── shortcuts.g.dart         # 自動生成されたショートカット定義

tool/
├── shortcuts.yaml               # ショートカット定義ソース
└── generate_shortcuts.dart      # コード生成スクリプト

linux/                           # Linuxプラットフォーム固有
```

## ショートカット体系

### 入力フォーマット

```
ggg + 行番号(1-9) + 列番号(1-9)
例: ggg55 → 天元（中央）
```

### 状態遷移

```
待機 → 'g'入力 → 'gg'入力 → 'ggg'入力 → 座標入力(2桁) → 実行
```

## 実装詳細

### 碁盤UI

- 9×9グリッド = 81交点
- 天元（5,5）は特別ハイライト
- 座標認識時にセルをアニメーション

### キー入力処理

- `RawKeyboardListener`でグローバルキー監視
- ショートカットインジケーターで入力状態を可視化

## コード生成

`tool/shortcuts.yaml`から`lib/generated/shortcuts.g.dart`を生成：

```bash
dart run tool/generate_shortcuts.dart
```

pre-commitフックで自動実行される。

## プラットフォーム対応

| OS | 常駐方法 | 実装状況 |
|----|---------|---------|
| Windows | タスクトレイ | 計画中 |
| Linux | タスクトレイ | 計画中 |
| macOS | Dock | 計画中 |
| Android | ウィジェット | 計画中 |

## CI/CD

- **ci.yml**: コード生成差分チェック、フォーマット、analyze、test
- **release.yml**: Flutter Web版をGitHub Releaseに添付

## ビルド

```bash
flutter pub get
flutter analyze
flutter test
flutter build linux  # または web/windows/macos
```
