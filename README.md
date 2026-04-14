# mandalart-hackathon

FigmaのUIをもとに、`SwiftUI` で iOS アプリとして確認できるようにした作業用リポジトリです。

## 何が入っているか

- `ios/MandalartSync`
  - `SwiftUI` のアプリ本体コード
- `MandalartSync.xcodeproj`
  - Xcodeで開くプロジェクト
- `project.yml`
  - `xcodegen` 用のプロジェクト定義
- `figma-make-reference`
  - Figma Make から取り込んだ React/Vite の参照実装

## まず何を開くか

普段は `MandalartSync.xcodeproj` を開けばOKです。

```bash
open MandalartSync.xcodeproj
```

## iPhone実機で見る手順

1. `MandalartSync.xcodeproj` を Xcode で開く
2. `TARGETS > MandalartSync > Signing & Capabilities` を開く
3. `Team` を選ぶ
4. `Bundle Identifier` を必要に応じて変更する
5. 実機を選んで `Run`

## ビルド確認コマンド

Xcodeを開かずにビルドだけ確認したいときは以下です。

```bash
xcodebuild -project "MandalartSync.xcodeproj" -scheme "MandalartSync" -destination 'generic/platform=iOS' -derivedDataPath ".derivedData" CODE_SIGNING_ALLOWED=NO build
```

## 参考実装

`figma-make-reference` は本番アプリではなく、Figma Make から取り込んだ Web 実装の参照用です。  
見た目や画面構成を確認しながら、`SwiftUI` 側へ移植する用途を想定しています。

## 補足

- Xcodeプロジェクトを作り直す場合は `xcodegen generate` を使います
- ローカル専用の `xcuserdata` や `.derivedData` はコミット対象外です
