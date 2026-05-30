# Figma 导入文件

这个目录用于把刚生成的 3 个主功能页面导入 Figma。

## 文件

* `spoonie-main-pages-reference.png`：原始生成图，作为最高还原度参考。
* `spoonie-main-pages-reference-embedded.svg`：把原始生成图嵌入到 SVG 中，拖入 Figma 后视觉还原度最高，但仍是位图。
* `spoonie-main-pages-editable.svg`：按三屏结构重建的可编辑 SVG，文字、按钮、卡片、基础插画可在 Figma 里继续拆改。
* `spoonie-main-pages-editable-preview.png`：可编辑 SVG 的渲染预览。
* `spoonie-main-pages-reference-embedded-preview.png`：嵌入参考 SVG 的渲染预览。

## 建议用法

1. 先把 `spoonie-main-pages-reference-embedded.svg` 拖进 Figma，当作精确参考层。
2. 再把 `spoonie-main-pages-editable.svg` 拖进 Figma，放到参考层旁边或上方。
3. 后续在 Figma 里以参考层为准，逐步替换可编辑层里的 IP、卡片、按钮和文字。

当前 Figma MCP 只能读取/截图/获取上下文，不能直接写入 Figma 文件或创建图层，所以这里先产出 Figma 可导入文件。
