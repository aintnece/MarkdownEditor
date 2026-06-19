@echo off
cd /d %~dp0

echo ==========================================
echo   下载 KaTeX v0.16.11 到 rawfile
echo ==========================================
echo.

set URL_BASE=https://unpkg.com/katex@0.16.11
set OUT_DIR=entry\src\main\resources\rawfile\katex

mkdir %OUT_DIR%\dist\fonts\ 2>nul
mkdir %OUT_DIR%\dist\contrib\ 2>nul

echo [1/5] 下载 katex.min.css ...
curl -sLo %OUT_DIR%\dist\katex.min.css %URL_BASE%/dist/katex.min.css

echo [2/5] 下载 katex.min.js ...
curl -sLo %OUT_DIR%\dist\katex.min.js %URL_BASE%/dist/katex.min.js

echo [3/5] 下载 auto-render.min.js ...
curl -sLo %OUT_DIR%\dist\contrib\auto-render.min.js %URL_BASE%/dist/contrib/auto-render.min.js

echo [4/5] 下载字体文件 ...
for %%F in (
  KaTeX_AMS-Regular
  KaTeX_Caligraphic-Regular
  KaTeX_Fraktur-Regular
  KaTeX_Main-Bold
  KaTeX_Main-Regular
  KaTeX_Math-Italic
  KaTeX_SansSerif-Regular
  KaTeX_Script-Regular
  KaTeX_Size1-Regular
  KaTeX_Size2-Regular
  KaTeX_Size3-Regular
  KaTeX_Size4-Regular
  KaTeX_Typewriter-Regular
) do (
  echo   %%F.woff2
  curl -sLo %OUT_DIR%\dist\fonts\%%F.woff2 %URL_BASE%/dist/fonts/%%F.woff2
)

echo [5/5] 验证文件 ...
dir /s /b %OUT_DIR% 2>nul | find /c "/"
echo.
echo ==========================================
echo   完成！请在 DevEco Studio Build 后运行
echo ==========================================
pause
