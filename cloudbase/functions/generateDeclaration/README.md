# generateDeclaration 云函数

用于正式版今日声明生成。iOS App 只调用 CloudBase 云函数 URL，不保存智谱 token。

## 环境变量

- `ZHIPU_API_KEY`: 智谱 API Key，必填。
- `ZHIPU_MODEL`: 模型名，默认 `glm-4.7-flash`。
- `ZHIPU_TEMPERATURE`: 默认 `0.82`。
- `ZHIPU_MAX_TOKENS`: 默认 `360`。
- `TCB_ENV`: CloudBase 环境 ID；不填时使用当前云函数环境。

## 远程配置

云函数会尝试读取 `spoonie_remote_config/declaration_generation` 文档，支持字段：

- `model`
- `temperature`
- `maxTokens`
- `style`
- `targetLength`
- `modelVersion`
- `enableMultimodal`
- `enableShareVersion`

读取失败时使用默认配置，不影响生成。

## 请求体

```json
{
  "tags": ["躺了一天", "胸口闷", "不想回消息"],
  "weatherNarrative": "广州 · 天灰蒙蒙的，像罩了层毛玻璃",
  "weatherShort": "广州 · 微风有雾",
  "dateISO": "2026-05-30T10:00:00Z",
  "primaryState": "chest_tight_hug",
  "supplementalNoteHint": "用户补充文本的截断摘要",
  "supplementalImageCount": 2,
  "supplementalImageRefs": [],
  "style": "friend_companion",
  "targetLength": "90-140"
}
```

## 响应体

```json
{
  "statement": "三段式今日声明",
  "recordId": "CloudBase 数据库记录 id",
  "model": "glm-4.7-flash",
  "style": "friend_companion",
  "targetLength": "90-140"
}
```

生成成功后，云函数会把记录写入 `spoonie_daily_declarations`。补充文本只保存截断摘要，图片只保存引用和数量，避免在声明文案里逐字复述隐私。

## iOS 配置

开发阶段可以用模拟器写入云函数 URL：

```bash
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcrun simctl spawn 8229385F-A685-4B2C-B45D-10643645897F defaults write com.cansheng.spoonie cloudBaseGenerateDeclarationURL "https://你的-cloudbase-http-url"
```

未配置 URL 时，App 会自动使用本地 fallback 生成，不影响离线调试。
