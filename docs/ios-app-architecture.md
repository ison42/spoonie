# 勺子星人 iOS 应用实现架构

## 1. 数据存储

当前 MVP 使用本地 JSON 文件作为轻量数据库：

- 文件：`daily_entries.json`
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

这样先保证离线可用和隐私感。后续需要云同步时，保留本地库作为缓存层，云端可映射到 CloudBase / Supabase / 自建 API 的 `records` 表。

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

当前实现用 `LocalStatementAIService` 模拟 AI 生成，已经有 loading 流程和服务协议。

代码：

- `ios/Spoonie/Spoonie/Services/StatementAIService.swift`
- `StatementAIProviding`
- `LocalStatementAIService`
- `RemoteStatementAIService`

后续接入真实 AI 时，只需要把 `SpoonieStore` 里的 `statementService` 替换成 `RemoteStatementAIService` 或 CloudBase SDK 包装。

请求变量：

- 用户选择标签
- 用户自定义短语
- 口语化天气
- 短天气
- 主要 IP 状态 key
- 日期/时间语境

边界：

- 不把用户状态诊断成疾病。
- 不输出行动建议。
- 不说“明天一定会更好”。
- 不使用勺子隐喻，除非用户自己输入。
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

## 5. 已实现交互

- 定位授权入口和天气加载状态。
- 标签横向三行滑动云。
- 未选中标签也保留淡勾。
- 默认不选中任何标签。
- 自定义短语输入，提交后插入词云并自动选中。
- 未选择标签时禁用生成按钮。
- 今日声明 loading 页。
- 声明自动保存到本地记录。
- 日子抽屉记录列表。
- 抽屉滚动时出现简化标题栏。
- 点击记录进入详情页并可返回。
