# 勺子星人 iOS MVP

这是按 Figma 节点 `323:16045` 起的 SwiftUI 原生工程。

## 当前实现

- `今天`：状态收集页，流式状态词，多选后生成今日声明。
- `今日声明`：展示日期、天气、所选状态词、声明正文，并自动写入记录。
- `抽屉`：历史记录列表，右侧使用状态对应的紫色剪影素材。
- `我的`：偏好、数据、安全说明入口的第一版页面。
- IP 动图：使用 `AppAssets/ip/states/*/frames` 帧序列，避免 WebP/APNG 抖动和边缘脏点。

## 打开方式

用 Xcode 打开：

```sh
open ios/Spoonie/Spoonie.xcodeproj
```

当前机器的命令行环境只有 Command Line Tools，`xcodebuild` 不能在这里完成真机构建；需要安装/切换完整 Xcode 后再跑模拟器验证。
