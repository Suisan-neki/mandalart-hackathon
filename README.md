# mandalart-hackathon

目標管理アプリ `MandalartSync` の試作リポジトリです。  
FigmaのUI案をベースに、`SwiftUI` で iPhone 上で確認できる形まで移植しています。

## アプリ概要

`MandalartSync` は、掲げた目標と日々の行動をゆるく同期させながら振り返ることを目的にしたアプリです。

- 目標をマンダラート形式で整理する
- 日々の行動や達成度を可視化する
- 記録を振り返って次の行動につなげる
- GitHub や Google Calendar などの外部サービス連携を想定する

## 主な画面

### 目標

ブロック状のマンダラートで目標を一覧表示します。  
各ブロックの進捗や達成率を見ながら、個別の目標詳細を確認できます。

### アクション

今週の実行率、今日やること、クイックアクションをまとめて確認するホーム画面です。  
チェックインや記録画面への導線もここにあります。

### 記録

達成率のリング表示、行動の内訳、振り返り用の記録画面を扱います。  
日々の積み上げを視覚的に確認する想定です。

### 設定

GitHub や Google Calendar などの連携状態、通知設定、リセットなどをまとめています。

## リポジトリ構成

- `ios/MandalartSync`
  - `SwiftUI` のアプリ本体
- `MandalartSync.xcodeproj`
  - Xcodeで開くプロジェクト
- `project.yml`
  - `xcodegen` 用のプロジェクト定義

## 起動方法

普段は `MandalartSync.xcodeproj` を開けばOKです。

```bash
open MandalartSync.xcodeproj
```

実機で見るときは、Xcode で `Team` を設定してから `Run` してください。

## ビルド確認

Xcodeを開かずにビルドだけ確認したいときは以下です。

```bash
xcodebuild -project "MandalartSync.xcodeproj" -scheme "MandalartSync" -destination 'generic/platform=iOS' -derivedDataPath ".derivedData" CODE_SIGNING_ALLOWED=NO build
```

## 補足

- Xcodeプロジェクトを作り直す場合は `xcodegen generate` を使います
- `xcuserdata` や `.derivedData` はローカル専用です
