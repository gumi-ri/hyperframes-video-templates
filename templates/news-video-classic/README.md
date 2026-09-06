# news-video-classic · 经典三色标题带模板

9:16 竖屏模板「经典三色标题带」：顶部三条标题色带 + 中部满幅图片 + 底部逐字打字机字幕。适合资讯、政务、企业、宣传、栏目包装等口播 / 图文快讯场景。

## 渲染

在**仓库根目录**执行（该模板相对依赖会自动基于自身目录解析）：

```powershell
.\render.ps1 -Composition templates\news-video-classic\video-template-classic.hf.html -Out renders\out.mp4
```

或用 HyperFrames CLI 直接渲染：

```bash
npx hyperframes render -c templates/news-video-classic/video-template-classic.hf.html -o out.mp4
```

## 改内容

编辑 `video-template-classic.hf.html` 顶部的 `TEMPLATE_DATA`：

- `titles`：三行标题（`titles[0]/[1]/[2]` → 红字带 / 黄字带 / 白字红带）；
- `segments`：图文段落数组，每段 = 一张图 + 若干行正文；
  - `"普通文字"` → 黄字黑描边；
  - `{ html: "…<em>重点</em>…" }` → `<em>` 内为白字红描边；
- `perCharMs / segHoldMs / imgInMs / loop`：播放节奏参数（毫秒）；
- 图片路径相对于模板文件写，例如 `./images/pic_1043.jpg`。

## 版式规则（已内建）

- 标题区占满「顶部白条 → 图片」整段高度，三根色带 flex 等分、文字垂直居中。
- **高度死线**：标题块底部不得侵入图片区，间距恒为 0、绝不为负。
- **字号最大化**：每根色带先按宽度倒推最大字号，再按自身色带高度约束，长标题可折行、不裁切。
- 正文每行 ≤ 20 字、每页 ≥ 5 行（按 `segments` 分段控制）。
- 打字机按「逻辑字符」逐字计时，正文含 `& < > " '` 等符号不会出现 `undefined`。