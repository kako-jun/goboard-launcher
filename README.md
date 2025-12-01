# GoBoard Launcher

囲碁盤（9路盤）を模したアプリランチャー。81個のアプリを座標入力で高速起動できます。

## コンセプト

- 9×9の碁盤に81個のアプリを配置
- `ggg11`〜`ggg99`の座標入力で起動
- 天元（5,5）は最重要アプリ用の特別枠

## 使い方

### ショートカット

```
ggg + 座標 で起動
例: ggg34 → 縦3・横4のアプリを起動
```

予備ホットキー: `Ctrl + Alt + G`

### プラットフォーム別

- **Windows/Linux**: タスクトレイ常駐
- **macOS**: Dock表示
- **Android**: ホーム画面アイコン/ウィジェット

## 開発

```bash
flutter pub get          # 依存関係インストール
npm install && npm run prepare  # Huskyセットアップ
flutter run              # 起動
```

### コード生成

```bash
dart run tool/generate_shortcuts.dart  # ショートカット定義を再生成
```

## 技術スタック

- Flutter 3.22+
- Dart 3.3+

## ライセンス

MIT
