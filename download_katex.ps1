# Download KaTeX v0.16.11 files to rawfile directory
$base = 'https://unpkg.com/katex@0.16.11'
$out = 'entry/src/main/resources/rawfile/katex'

Write-Host "Downloading KaTeX v0.16.11..." -ForegroundColor Green

# Create directories
New-Item -ItemType Directory -Force -Path "$out/dist/fonts" | Out-Null
New-Item -ItemType Directory -Force -Path "$out/dist/contrib" | Out-Null

# Download CSS
Write-Host "  katex.min.css"
Invoke-WebRequest -Uri "$base/dist/katex.min.css" -OutFile "$out/dist/katex.min.css"

# Download JS
Write-Host "  katex.min.js"
Invoke-WebRequest -Uri "$base/dist/katex.min.js" -OutFile "$out/dist/katex.min.js"

# Download auto-render
Write-Host "  auto-render.min.js"
Invoke-WebRequest -Uri "$base/dist/contrib/auto-render.min.js" -OutFile "$out/dist/contrib/auto-render.min.js"

# Download fonts
$fonts = @(
  'KaTeX_AMS-Regular', 'KaTeX_Caligraphic-Regular', 'KaTeX_Fraktur-Regular',
  'KaTeX_Main-Bold', 'KaTeX_Main-Regular', 'KaTeX_Math-Italic',
  'KaTeX_SansSerif-Regular', 'KaTeX_Script-Regular', 'KaTeX_Size1-Regular',
  'KaTeX_Size2-Regular', 'KaTeX_Size3-Regular', 'KaTeX_Size4-Regular',
  'KaTeX_Typewriter-Regular'
)

foreach ($font in $fonts) {
  Write-Host "  $font.woff2"
  Invoke-WebRequest -Uri "$base/dist/fonts/${font}.woff2" -OutFile "$out/dist/fonts/${font}.woff2"
}

Write-Host ""
Write-Host "Done! Files downloaded to $out/" -ForegroundColor Green
Write-Host "Now build and run in DevEco Studio."
