# 便携化渲染脚本（hyperframes 全离线单命令）
# 用法：
#   .\render.ps1                                                     # 用默认模板渲染,1080x1920,30fps
#   .\render.ps1 -Composition video-template-classic.hf.html -Out renders\out.mp4
#   .\render.ps1 -Fps 60 -Bitrate 20M                                 # 60fps 高码率
#   .\render.ps1 -Composition .\x.hf.html -Strict                     # 严格模式(潜在错误即失败)
# 说明：自动打包本地字体(hf-fonts)、复用本地 hyperframes CLI 与 gsap，全程离线，不设代理。

param(
    [string]$Composition = "video-template-classic.hf.html",
    [string]$Out = "renders\out.mp4",
    [int]$Fps = 30,
    [string]$Bitrate = "12M",
    [string]$BrowserPath = "",
    [switch]$Strict,
    [switch]$NoLowMem
)

$ErrorActionPreference = "Stop"
$root = $PSScriptRoot
Set-Location $root

# ---- 0) 清掉代理变量：本资源全本地，避免经代理又慢又出错 ----
Remove-Item Env:HTTP_PROXY,Env:HTTPS_PROXY,Env:ALL_PROXY,Env:http_proxy,Env:https_proxy -ErrorAction SilentlyContinue

# ---- 1) 打包字体目录 => 离线字体（核心, 不再联网拉 Google Fonts）----
$env:HYPERFRAMES_FONT_CACHE_DIR = Join-Path $root "assets\hf-fonts"
$env:HYPERFRAMES_NO_UPDATE_CHECK = "1"
$env:HYPERFRAMES_NO_AUTO_INSTALL = "1"
$env:HYPERFRAMES_NO_TELEMETRY = "1"
$env:DO_NOT_TRACK = "1"

# ---- 2) 自动探测 Chrome（headless-shell 在本宿主机崩溃，必须用正式版）----
$browser = $BrowserPath
if (-not $browser) {
    $candidates = @(
        $env:HYPERFRAMES_BROWSER_PATH,
        "$env:ProgramFiles\Google\Chrome\Application\chrome.exe",
        "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe",
        "$env:LOCALAPPDATA\Google\Chrome\Application\chrome.exe",
        "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe"
    )
    $browser = $candidates | Where-Object { $_ -and (Test-Path $_) } | Select-Object -First 1
    if (-not $browser) {
        # 回退：让 hyperframes 自己找 chromium
        Remove-Item Env:HYPERFRAMES_BROWSER_PATH -ErrorAction SilentlyContinue
        Write-Warning "未找到 Chrome/Edge，交由 hyperframes 自行探测（建议安装 Chrome 并设置 -BrowserPath）"
    } else {
        $env:HYPERFRAMES_BROWSER_PATH = $browser
        Write-Host "[portable] Chrome: $browser" -ForegroundColor Cyan
    }
} else {
    $env:HYPERFRAMES_BROWSER_PATH = $browser
}

# ---- 3) 自动探测 ffmpeg / ffprobe ----
function Find-Exe([string]$name) {
    $c = Get-Command $name -ErrorAction SilentlyContinue
    if ($c) { return $c.Source }
    $w = Get-ChildItem "$env:LOCALAPPDATA\Microsoft\WinGet\Packages" -Recurse -Filter "$name.exe" -ErrorAction SilentlyContinue |
        Select-Object -First 1 -ExpandProperty FullName
    if ($w) { return $w }
    return $null
}
$ff = Find-Exe "ffmpeg"; $fp = Find-Exe "ffprobe"
if ($ff) { $env:HYPERFRAMES_FFMPEG_PATH = $ff; Write-Host "[portable] ffmpeg:  $ff"  -ForegroundColor Cyan }
if ($fp) { $env:HYPERFRAMES_FFPROBE_PATH = $fp }
if (-not $ff) { Write-Warning "未找到 ffmpeg，渲染会失败——请安装 ffmpeg 并加入 PATH" }

# ---- 4) 用项目本地 CLI（node_modules/.bin）渲染 ----
$hf = Join-Path $root "node_modules\.bin\hyperframes.cmd"
if (-not (Test-Path $hf)) { throw "缺少本地 CLI: $hf（请先执行 .\setup.ps1）" }

$hfArgs = @("render", "-c", $Composition, "-o", $Out, "--fps", "$Fps", "--video-bitrate", $Bitrate)
if (-not $NoLowMem) { $hfArgs += "--low-memory-mode" }
if ($Strict) { $hfArgs += "--strict" }

Write-Host "[portable] 渲染 $Composition -> $Out ($Fps fps, ${Bitrate})" -ForegroundColor Green
& $hf @hfArgs
exit $LASTEXITCODE