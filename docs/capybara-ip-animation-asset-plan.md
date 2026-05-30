# 勺子星人水豚 IP 动图资产规划

## 1. 资产目标

水豚 IP 不再用 SVG / CSS 拼出来，而是用 image2 生成一套统一风格的角色动画资产。

核心目标：

* 保持水豚 + 木勺的稳定识别。
* 用姿态表达用户状态，而不是让功能文案强行讲“勺子”。
* 每个页面只放一个主要水豚动图，减少装饰，让画面清爽。
* 先生成 spritesheet，再由工程侧转成 WebP / APNG / Lottie 替代方案。

---

## 2. 统一美术设定

### 2.1 基础角色设定

```text
一只安静、柔软、圆润的水豚，抱着一把略大但不夸张的浅木色勺子。
水豚不是写实动物，也不是儿童贴纸，而是高级治愈系 App IP。
整体偏 2D 动漫插画，柔和体积感，轻微纸感颗粒，低对比，低饱和。
表情克制、内向、慢半拍，眼睛半闭，不直勾勾盯着用户。
```

### 2.2 视觉风格关键词

* 浅薰衣草、雾蓝、暖白、淡粉作为环境主色。
* 水豚毛色为温暖浅棕，不要太黄、太脏、太写实。
* 木勺为浅木色，有一点温润高光，但不要抢主角。
* 背景尽量透明；如果 image2 不稳定，则使用纯浅薰衣草背景，后期抠图。
* 禁止加入文字、UI 按钮、手机壳、图标、复杂背景。

### 2.3 统一负面约束

```text
no text, no UI, no phone mockup, no logo, no watermark, no realistic photo, no 3D render,
no plastic toy, no chibi baby style, no loud colors, no confetti, no gamification badge,
no exaggerated crying, no medical device, no diagnosis symbol, no horror, no dark depression scene
```

---

## 3. 动画规格建议

### 3.1 Spritesheet 基础规格

MVP 建议统一使用：

```text
single spritesheet, 4 columns x 4 rows, 16 frames total,
each frame same character size and same camera angle,
transparent background if possible,
character centered, full body visible, no cropping,
1024x1024 per frame, total spritesheet 4096x4096,
loopable idle animation, soft motion, no sudden jump
```

如果 image2 对 4096 输出不稳定，可以降级：

```text
single spritesheet, 4 columns x 3 rows, 12 frames total,
768x768 per frame, total spritesheet 3072x2304,
transparent background if possible,
loopable animation
```

### 3.2 工程使用建议

* App 内使用 WebP 动图优先，文件体积更可控。
* 原始资产保留 spritesheet PNG，便于后期重导。
* 每个状态导出：
  * `@1x`：256px 宽，低端机 / 列表小图。
  * `@2x`：512px 宽，主界面常规展示。
  * `@3x`：768px 宽，启动页 / 高端屏。
* 动画帧率建议 `8-12 fps`，不要太活泼。
* 循环周期建议 `2-4 秒`，状态越低落越慢。

---

## 4. MVP 必做资产

MVP 先做 9 个动图状态，覆盖三个主页面和最常见状态组合。

| 编号 | 资产名 | 使用页面 | 对应状态 | 动作表现 |
| --- | --- | --- | --- | --- |
| A01 | `idle_default` | 状态收集页默认 | 未选择 / 普通低能量 | 坐着抱勺，轻微呼吸，偶尔眨眼 |
| A02 | `sleepy_lied_down` | 状态收集 / 声明页 | 躺了一天、嗜睡、身体很沉 | 趴在软垫上，勺子横放身边，慢慢眨眼 |
| A03 | `phone_dazed` | 状态收集 / 声明页 | 沉迷刷手机、正在发呆、脑子停不下来 | 抱着勺子发呆，眼神放空，身体轻轻晃 |
| A04 | `chest_tight_hug` | 今日声明页 | 胸口闷、觉得委屈、无故流泪 | 把勺子抱在胸前，肩膀微微缩起 |
| A05 | `hide_behind_spoon` | 今日声明页 | 不想回消息、不想见人、不想解释 | 半躲在勺子后面，轻轻探头又缩回 |
| A06 | `fear_tomorrow_night` | 今日声明页 | 害怕明天、睡得很碎、这个点还醒着 | 坐在淡夜色里抱勺，缓慢抬头看一眼 |
| A07 | `no_appetite_blanket` | 今日声明页 | 没有食欲、没洗头、什么都懒得弄 | 裹小毯子，勺子靠在旁边，动作很慢 |
| A08 | `overwhelmed_noise` | 今日声明页 | 外面太吵、被消息淹没、装正常好累 | 耳朵微压，勺子像小屏障挡在身前 |
| A09 | `drawer_keeper` | 日子抽屉页 | 历史记录守护 | 水豚在抽屉旁整理纸条，动作轻慢 |

---

## 5. 状态匹配规则

今日声明页根据用户选择的状态词选择水豚动图。

### 5.1 优先级

当用户选择多个状态时，按以下优先级决定主动图：

1. 危机 / 强脆弱感：无故流泪、胸口闷、觉得委屈。
2. 社交退缩：不想回消息、不想见人、不想解释。
3. 夜晚焦虑：害怕明天、睡得很碎、脑子停不下来。
4. 身体低能量：躺了一天、嗜睡、身体很沉、没有食欲、没洗头。
5. 信息过载：沉迷刷手机、被消息淹没、外面太吵。
6. 空白 / 发呆：随便吧、正在发呆、心里空空的。

### 5.2 示例

| 用户选择 | 推荐资产 |
| --- | --- |
| 躺了一天 + 嗜睡 + 没洗头 | `sleepy_lied_down` |
| 胸口闷 + 觉得委屈 + 不想回消息 | `chest_tight_hug` |
| 不想回消息 + 不想解释 + 装正常好累 | `hide_behind_spoon` |
| 害怕明天 + 睡得很碎 + 脑子停不下来 | `fear_tomorrow_night` |
| 沉迷刷手机 + 正在发呆 | `phone_dazed` |
| 外面太吵 + 被消息淹没 | `overwhelmed_noise` |

---

## 6. 通用 Image2 生图母提示词

每次生成都先复制这一段，再追加具体状态描述。

```text
Create a single animated character spritesheet for a mobile wellness app.

Character: a calm capybara holding a large warm wooden spoon, soft rounded body, gentle closed or half-closed eyes, quiet expression, emotionally safe and non-judgmental. The spoon is a visual IP prop, not a UI element.

Art style: premium 2D anime-inspired healing app mascot, soft pastel illustration, lavender mist mood, warm beige capybara fur, subtle paper grain, soft edges, low contrast, low saturation, clean and modern, similar feeling to a gentle Japanese/Korean wellness app illustration, not childish.

Spritesheet format: 4 columns x 4 rows, 16 frames total, each frame is one animation frame. Transparent background if possible. The capybara must be centered in every frame, full body visible, same size, same camera angle, consistent character design, consistent spoon design. Loopable animation, very subtle motion, slow breathing, soft blink, no sudden movement.

No text, no logo, no phone UI, no button, no watermark, no extra characters, no complex background, no confetti, no badge, no gamification, no realistic photo, no 3D render, no medical symbol.
```

---

## 7. MVP 资产生图指令

### A01 状态收集页默认：`idle_default`

用途：状态收集页默认水豚。用户刚进入页面，还没选状态。

```text
Use the common prompt.

Animation: the capybara is sitting quietly, hugging the wooden spoon with both paws. It breathes slowly, blinks once, and slightly relaxes its shoulders. The mood is calm, spacious, and safe. The character should feel like it is waiting with the user, not urging them.

Emotion: neutral low-energy, gentle, patient, quietly present.
```

### A02 身体低能量：`sleepy_lied_down`

用途：躺了一天、嗜睡、身体很沉。

```text
Use the common prompt.

Animation: the capybara lies down on a very simple soft cushion, the wooden spoon rests horizontally beside its body like a quiet companion. It slowly opens and closes its eyes, breathing gently. The body feels heavy but safe. Movement is minimal and loopable.

Emotion: exhausted, sleepy, allowed to rest, not sad.
```

### A03 手机放空：`phone_dazed`

用途：沉迷刷手机、正在发呆、脑子停不下来。

```text
Use the common prompt.

Animation: the capybara sits with the wooden spoon leaning against its shoulder, eyes unfocused and slightly blank. It slowly tilts its head, blinks, then returns to a quiet staring pose. Do not show an actual phone. Express scrolling fatigue through posture only.

Emotion: mentally foggy, zoned out, gently disconnected.
```

### A04 胸口闷 / 委屈：`chest_tight_hug`

用途：胸口闷、觉得委屈、无故流泪。

```text
Use the common prompt.

Animation: the capybara hugs the wooden spoon close to its chest, shoulders slightly curled inward. It takes a slow breath, lowers its head a little, then settles. Eyes are soft and moist but not dramatically crying. No tears flying, no exaggerated sadness.

Emotion: vulnerable, held, quietly trying to breathe.
```

### A05 不想回消息：`hide_behind_spoon`

用途：不想回消息、不想见人、不想解释。

```text
Use the common prompt.

Animation: the capybara half hides behind the large wooden spoon as if using it as a gentle screen. It peeks out slowly, blinks, then hides a little again. The motion should feel like protecting personal boundaries, not fear.

Emotion: social withdrawal, self-protection, soft boundary.
```

### A06 害怕明天 / 深夜：`fear_tomorrow_night`

用途：害怕明天、睡得很碎、深夜还醒着。

```text
Use the common prompt.

Animation: the capybara sits in a simple pale lavender night mood, holding the wooden spoon upright beside itself like a quiet lamp. It slowly looks upward once, then lowers its gaze. Very subtle breathing and blink. Background should still be mostly transparent or extremely minimal.

Emotion: worried about tomorrow, sleepless, quiet night anxiety, still safe.
```

### A07 没食欲 / 没洗头：`no_appetite_blanket`

用途：没有食欲、没洗头、什么都懒得弄。

```text
Use the common prompt.

Animation: the capybara is wrapped loosely in a small soft blanket, with the wooden spoon leaning beside it like a pillow. It barely moves, only a slow blink and tiny breath. The posture says "I cannot take care of many things today" without looking dirty or comedic.

Emotion: low maintenance energy, bodily heaviness, tender acceptance.
```

### A08 外界太吵：`overwhelmed_noise`

用途：外面太吵、被消息淹没、装正常好累。

```text
Use the common prompt.

Animation: the capybara sits slightly curled, holding the wooden spoon in front as a soft shield. Its ears press down a little, then relax. Tiny abstract sound waves may appear very faintly around it, but keep the frame clean and low-stimulation.

Emotion: overwhelmed by noise, protecting itself, tired from pretending normal.
```

### A09 日子抽屉守护：`drawer_keeper`

用途：日子抽屉页默认水豚。

```text
Use the common prompt.

Animation: the capybara sits beside a simple small drawer box, gently placing a tiny paper note into the drawer while the wooden spoon rests nearby. Motion is slow and careful. The drawer is minimal pastel lavender-white, not a large scene.

Emotion: keeping memories safely, quiet archivist, gentle record keeper.
```

---

## 8. 第二阶段扩展资产

当 MVP 9 个资产稳定后，再扩展以下状态：

| 资产名 | 对应状态 | 动作表现 |
| --- | --- | --- |
| `cry_softly` | 无故流泪、一点小事就想哭 | 水豚低头，眼角一小滴泪，勺子贴近脸 |
| `messy_room_tiny` | 房间很乱、什么都懒得弄 | 水豚坐在一小堆软物旁，不做复杂房间 |
| `rainy_window` | 天气闷闷的、今天太湿了 | 水豚抱勺看淡淡雨滴 |
| `blank_empty` | 心里空空的、随便吧 | 水豚静止发呆，动作最少 |
| `angry_prickled` | 被一句话刺到、什么都很刺耳 | 水豚身体微僵，勺子护在前面 |
| `slow_recover` | 有一点点恢复、今天没那么糟 | 水豚把勺子放下，轻轻伸懒腰 |

---

## 9. 单帧兜底指令

如果 image2 暂时生成不了稳定 spritesheet，可以先生成单帧主视觉，再做轻微动效。

```text
Create one transparent PNG character illustration for a mobile wellness app.
Calm capybara holding a warm wooden spoon, premium 2D anime-inspired healing mascot, soft pastel lavender mood, warm beige fur, subtle paper grain, clean and modern, full body visible, centered, no text, no UI, no logo, no background or transparent background.

Pose: [填入具体状态姿势]
Emotion: [填入具体情绪]
```

工程侧可以对单帧做：

* 呼吸：整体 scale `1 -> 1.015 -> 1`。
* 眨眼：额外生成闭眼版本，2 帧切换。
* 漂浮：`translateY(0 -> -4px -> 0)`。
* 勺子轻晃：勺子图层单独切出后旋转 `-1deg -> 1deg`。

---

## 10. 文件命名建议

```text
assets/ip/capybara/
  idle_default/
    idle_default_spritesheet.png
    idle_default.webp
    idle_default@2x.webp
    idle_default@3x.webp
  sleepy_lied_down/
  phone_dazed/
  chest_tight_hug/
  hide_behind_spoon/
  fear_tomorrow_night/
  no_appetite_blanket/
  overwhelmed_noise/
  drawer_keeper/
```

每个目录保留：

* 原始 prompt：`prompt.md`
* 原始生成图：`source.png`
* 清理后 spritesheet：`spritesheet.png`
* App 使用动图：`animation.webp`

