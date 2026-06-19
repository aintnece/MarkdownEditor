# Download KaTeX v0.16.22 (matching WebUI) with ALL font formats
$base = 'https://unpkg.com/katex@0.16.22'
$out = 'entry/src/main/resources/rawfile/katex'

Write-Host "=== Downloading KaTeX v0.16.22 (all formats) ===" -ForegroundColor Green

# Clean old files
Remove-Item -Recurse -Force "$out/dist" -ErrorAction SilentlyContinue

New-Item -ItemType Directory -Force -Path "$out/dist/fonts" | Out-Null
New-Item -ItemType Directory -Force -Path "$out/dist/contrib" | Out-Null

# CSS + JS
Write-Host "  katex.min.css"
Invoke-WebRequest -Uri "$base/dist/katex.min.css" -OutFile "$out/dist/katex.min.css"
Write-Host "  katex.min.js"
Invoke-WebRequest -Uri "$base/dist/katex.min.js" -OutFile "$out/dist/katex.min.js"
Write-Host "  auto-render.min.js"
Invoke-WebRequest -Uri "$base/dist/contrib/auto-render.min.js" -OutFile "$out/dist/contrib/auto-render.min.js"

# Font files - ALL 3 formats matching WebUI
$fonts = @(
  'KaTeX_AMS-Regular', 'KaTeX_Caligraphic-Bold', 'KaTeX_Caligraphic-Regular',
  'KaTeX_Fraktur-Bold', 'KaTeX_Fraktur-Regular',
  'KaTeX_Main-Bold', 'KaTeX_Main-BoldItalic', 'KaTeX_Main-Italic', 'KaTeX_Main-Regular',
  'KaTeX_Math-BoldItalic', 'KaTeX_Math-Italic',
  'KaTeX_SansSerif-Bold', 'KaTeX_SansSerif-Italic', 'KaTeX_SansSerif-Regular',
  'KaTeX_Script-Regular', 'KaTeX_Size1-Regular', 'KaTeX_Size2-Regular',
  'KaTeX_Size3-Regular', 'KaTeX_Size4-Regular',
  'KaTeX_Typewriter-Regular'
)

foreach ($font in $fonts) {
  foreach ($ext in @('woff2', 'woff', 'ttf')) {
    Write-Host "  $font.$ext"
    try {
      Invoke-WebRequest -Uri "$base/dist/fonts/${font}.${ext}" -OutFile "$out/dist/fonts/${font}.${ext}"
    } catch {
      Write-Host "    WARN: $font.$ext skipped (not found)" -ForegroundColor Yellow
    }
  }
}

Write-Host ""
Write-Host "=== Done! Clean Build in DevEco Studio ===" -ForegroundColor Green
