# news-video-template-hf

9:16 竖屏「新闻 / 时政 / 企业」短视频模板集，全部基于 [HyperFrames](https://heygen.com/) 确定性渲染引擎。

每个模板放在 `templates/<名称>/` 下，自成一体、可直接套用，也便于后续源源不断地往库里加新模板。

## 结构

```
news-video-template-hf/
├─ templates/
│  └─ news-video-classic/        # 「经典三色带」模板
│     ├─ video-template-classic.hf.html   # 模板本体（可编辑时域合成）
│     ├─ vendor/gsap.min.js               # 确定性时钟驱动（模板依赖）
│     └─ README.md                        # 该模板的用法
├─ render.ps1                    # 共享一键渲染脚本（自动探测浏览器/ffmpeg）
├─ README.md
└─ .gitignore
```

## 现有模板

| 模板 | 特征 |
|------|------|
| `templates/news-video-classic` | 顶部三条标题色带 + 中部满幅图片 + 底部逐字打字机字幕；标题字号自动最大化且不越图片区。 |

## 快速开始

```powershell
.\render.ps1 -Composition templates\news-video-classic\video-template-classic.hf.html -Out renders\out.mp4
# 60fps / 高码率
.\render.ps1 -Composition templates\news-video-classic\video-template-classic.hf.html -Out renders\out.mp4 -Fps 60 -Bitrate 20M
```

依赖：Node.js、ffmpeg、Chrome / Edge（`render.ps1` 会自动探测本机浏览器）。

## 如何添加一个新模板

1. 在 `templates/` 下新建目录 `templates/<你的模板名>/`；
2. 放入你的 `*.hf.html`（HyperFrames 合成，viewport 1080x1920）及其依赖；
3. 写该目录的 `README.md`（数据结构、参数说明、注意事项）；
4. 在上方「现有模板」表格里加一行索引；
5.（可选）在根 `render.ps1` 内补充你的模板默认参数。

## 说明

- `assets/hf-fonts`（本地字体缓存）与 `renders/` 不在库内，由本机渲染时生成，见 `.gitignore`。