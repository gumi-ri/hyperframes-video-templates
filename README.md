# news-video-template-hf

9:16 竖屏「新闻 / 时政」短视频模板，基于 [HyperFrames](https://heygen.com/) 确定性渲染引擎。

顶部三条标题色带 + 中部满幅图片 + 底部逐字打字机字幕，适合政务 / 企业新闻口播视频。排版由 JS 自动适配：标题字号在「尽量大」与「不越线」之间取最优。

## 结构

```
news-video-template-hf/
├─ video-template-classic.hf.html   # 模板本体（可编辑时域合成）
├─ render.ps1                       # 一键渲染脚本（自动探测浏览器/ffmpeg）
├─ vendor/gsap.min.js               # 确定性时钟驱动（模板依赖）
└─ README.md
```

## 快速开始

1. **装依赖**：Node.js、ffmpeg、Chrome / Edge（渲染脚本会自动探测本机浏览器）。
2. **改内容**：打开 `video-template-classic.hf.html`，编辑顶部 `TEMPLATE_DATA`：
   - `titles`：三行标题（`titles[0]/[1]/[2]` → 红字带 / 黄字带 / 白字红带）；
   - `segments`：图文段落数组，每段一张图 + 若干行正文；
     - `"普通文字"` → 黄字黑描边；
     - `{ html: "…<em>重点</em>…" }` → `<em>` 内为白字红描边；
   - `perCharMs / segHoldMs / imgInMs / loop`：播放节奏参数（毫秒）。
   - 图片路径相对于模板文件写，例如 `./images/pic_1043.jpg`。
3. **渲染**：

   ```powershell
   .\render.ps1 -Composition video-template-classic.hf.html -Out renders\out.mp4
   # 60fps / 高码率
   .\render.ps1 -Composition video-template-classic.hf.html -Out renders\out.mp4 -Fps 60 -Bitrate 20M
   ```

   （HyperFrames CLI 亦可：`npx hyperframes render -c video-template-classic.hf.html -o out.mp4`）

## 版式规则（已内建，会自动遵守）

- 标题区占满「顶部白条 → 图片」的整段高度，三根色带 flex 等分，文字垂直居中。
- **高度死线**：标题块底部不得侵入图片区域，间距恒为 0、绝不为负。
- **字号最大化**：每根色带先按实际宽度倒推最大字号，再按自身色带高度约束，长标题可折行、不裁切。
- 正文每行 ≤ 20 字、每页 ≥ 5 行（按 `TEMPLATE_DATA` 分段控制）。

## 说明

- `assets/hf-fonts`（本地字体缓存）与 `renders/` 不在库内，由本机渲染时生成，见 `.gitignore`。