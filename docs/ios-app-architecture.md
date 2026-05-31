# 勺子星人 iOS 应用实现架构

## 1. 数据存储

当前 MVP 使用本地 JSON 文件作为轻量数据库：

- 文件：`daily_entries.json`
- 文件：`echo_posts.json`
- 文件：`user_profile.json`
- 位置：App 沙盒 `Documents`
- 代码：`ios/Spoonie/Spoonie/Support/SpoonieDatabase.swift`

记录模型为 `DailyEntry`，字段包括：

- `id`
- `date`
- `weather`
- `weatherShort`
- `tags`
- `statement`
- `capybaraState`
- `supplementalNote`
- `supplementalImages`
- `echoPostId`
- `echoPublishedAt`
- `echoSourceText`

`EchoPost` 是回声 MVP 的本地模型，字段包括：

- `sourceEntryId`
- `authorHash`
- `identityMode`
- `authorDisplayName`
- `authorAvatarPreset`
- `text`
- `tags`
- `weatherShort`
- `reactionCounts`
- `myReaction`
- `isHidden`
- `isReported`

`UserProfile` 是低负担账号资料，字段包括手机号、随机昵称、头像预设和登录状态。这样先保证离线可用和隐私感。后续需要云同步时，保留本地库作为缓存层，云端可映射到 CloudBase / Supabase / 自建 API 的 `records`、`echo_posts`、`echo_reactions`、`echo_reports`、`user_profiles` 表。

## 2. 天气与定位链路

入口在状态收集页顶部天气胶囊。

当前实现：

1. 用户点击天气胶囊。
2. App 请求 `When In Use` 位置权限。
3. 拿到城市级位置。
4. 用 Open-Meteo 拉取基础天气。
5. 本地 `WeatherNarrativeService` 把硬天气转成口语化天气。

代码：

- `ios/Spoonie/Spoonie/Services/LocationWeatherService.swift`
- `WeatherContext`
- `WeatherStatus`

边界：

- 不保存精确经纬度。
- App 内只展示城市级天气。
- 权限拒绝时进入无天气模式，不阻断用户生成今日声明。
- 天气只作为氛围上下文，不用于推断心理状态。

后续 AI 化方式：

- 客户端仍只上传最小天气字段：城市、天气码、温度区间、湿度、风速。
- 云函数 `summarizeWeather` 输出 `narrative` 和 `shortText`。
- 禁止输出诊断式语句，比如“天气导致你抑郁”。

## 3. 今日声明 AI 链路

当前实现采用“CloudBase 优先，本地兜底”的声明生成链路，已经有 loading 流程和服务协议。

代码：

- `ios/Spoonie/Spoonie/Services/StatementAIService.swift`
- `StatementAIProviding`
- `LocalStatementAIService`
- `CloudBaseStatementAIService`
- `cloudbase/functions/generateDeclaration`

正式版不在 iOS App 内保存智谱 token。App 只调用 CloudBase 云函数 URL；云函数通过环境变量读取 `ZHIPU_API_KEY`，再调用智谱 `chat/completions` / OpenAI 兼容接口。

云函数侧还会读取 `spoonie_remote_config/declaration_generation` 作为远程配置，并把生成结果写入 `spoonie_daily_declarations`。v1 图片只传数量和云存储引用，补充文本只传截断摘要，后续如果开启多模态，再通过远程配置切换处理策略。

开发阶段可用模拟器写入云函数 URL：

```bash
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcrun simctl spawn 8229385F-A685-4B2C-B45D-10643645897F defaults write com.cansheng.spoonie cloudBaseGenerateDeclarationURL "https://你的-cloudbase-http-url"
```

未配置 URL 时，`StatementAIServiceFactory` 自动使用 `LocalStatementAIService`。

请求变量：

- 用户选择标签
- 用户自定义短语
- 口语化天气
- 短天气
- 主要 IP 状态 key
- 日期/时间语境
- “说多点”补充文本摘要
- 补充图片数量和后续云存储引用

边界：

- 不把用户状态诊断成疾病。
- 不输出行动建议。
- 不说“明天一定会更好”。
- 不使用勺子隐喻，除非用户自己输入。
- 不逐字复述“说多点”里的隐私原文，只把它作为轻量上下文。
- 遇到高风险文本时，后续要先走 `riskCheck`，不要普通生成。

## 4. 状态词与素材映射

状态词在 `SpoonieStore.baseMoodTags` 中定义，每个词绑定：

- 分类：生理 / 心理 / 环境 / 关系 / 自定义
- `capybaraState`
- 标签宽度
- 轻微旋转角度

IP 资源通过 `CapybaraState` 映射到 `assets/app-final`：

- 状态收集页：默认使用 `idle_default`
- 今日声明页：使用用户选择的主要状态
- 日子抽屉卡片：使用主要状态对应的紫色剪影
- 日子抽屉详情：使用该记录保存时的真实状态

## 5. 回声链路

`回声`是底部第四个 tab，定位为匿名低压力真人回应空间，不是论坛或信息流。

当前实现：

1. 今日声明页点击 `发到回声`。
2. 如果未登录，弹出低负担手机号登录 sheet，并保留随机头像昵称。
3. App 打开预览编辑 sheet，只默认带入“说多点”正文；没有补充正文时保持空白，不使用 AI 今日声明代替用户。
4. 用户选择匿名或用头像昵称发送。
5. 用户确认后，本地创建 `EchoPost`，并在 `DailyEntry` 上记录 `echoPostId`、`echoPublishedAt`、`echoSourceText`。
6. 回声页展示纸条、身份展示方式、状态标签、模糊时间和轻回应按钮。
7. 每张非本人纸条只能选择一个轻回应；可执行 `不想看到`、`举报`；本人纸条可 `收回这张纸条`。

后续 CloudBase 化：

- `publishEcho` 云函数：保存用户确认过的匿名文字，并先调用 `riskCheck`。
- `reactEcho` 云函数：对同一用户同一纸条做单选回应 upsert。
- `moderateEcho` 云函数：处理隐藏、举报和作者收回。
- `sendSmsCode` / `verifySmsCode` 云函数：手机号验证码登录。
- 推荐排序优先同状态标签和近 48 小时，不按热度排序。

边界：

- v1 不发布图片到回声。
- 回声只发布用户自己写的内容，不发布 AI 今日声明。
- 不开放评论、私信、关注、热门、点赞排行。
- 匿名发送不公开头像昵称；署名发送只公开头像昵称，不公开手机号、精确时间、精确位置。
- 危机内容不进入普通回声，转为帮助提示。

## 6. 账号与触发式登录

App 不在启动时强制登录。首次打开会生成随机头像昵称，让用户能先进入体验。

触发登录的操作：

- 生成今日声明。
- 发到回声。
- 给回声做轻回应。
- 查看自己的回声。

当前开发版用本地模拟验证码 `1234`，正式版需要接短信服务和 CloudBase 登录态。手机号只用于账号识别，不展示给其他用户。
个人中心使用“氛围头图 + 居中头像昵称 + 少量设置项”的结构。未登录时头像区显示 `未登录`，点击进入登录；登录后头像和昵称可直接点击编辑，未上传时使用随机默认头像；登录后提供低强调退出登录，退出后保留本地随机头像昵称，方便下次继续低负担使用。

## 7. 已实现交互

- 定位授权入口和天气加载状态。
- 标签横向三行滑动云。
- 未选中标签也保留淡勾。
- 默认不选中任何标签。
- 自定义短语输入，提交后插入词云并自动选中。
- 未选择标签时禁用生成按钮。
- 今日声明 loading 页。
- 声明自动保存到本地记录。
- 今日声明主动发到回声。
- 触发式手机号登录、随机头像昵称、个人中心头像上传/昵称编辑。
- 回声四 tab、匿名/署名纸条、轻回应、隐藏/举报/收回。
- 日子抽屉记录列表。
- 抽屉滚动时出现简化标题栏。
- 点击记录进入详情页并可返回。
