param([Parameter(Mandatory)][string]$Source)
# Baut die Dateien zum Hochladen: vollständiges HTML-Gerüst, SEO-Titel, Schriften lokal statt von Google
$dir = $PSScriptRoot
$enc = New-Object Text.UTF8Encoding $false
$fontLink = '<link rel="stylesheet" href="fonts/fonts.css">'

function Use-LocalFonts([string]$html) {
  $html = [regex]::Replace($html, '<link rel="preconnect" href="https://fonts\.(googleapis|gstatic)\.com"[^>]*>\r?\n', '')
  [regex]::Replace($html, '<link rel="stylesheet" href="https://fonts\.googleapis\.com[^"]*">', $fontLink)
}

$body = [IO.File]::ReadAllText((Join-Path $Source 'portfolio.html'))
$body = $body.Replace('<title>BvK Gestaltung</title>', '<title>Webdesign in Hamburg | BvK Gestaltung</title>')
$body = [regex]::Replace($body, '<meta name="claude:viewport-fit-sides"[^>]*>\r?\n', '')
$index = "<!doctype html>`n<html lang=`"de`">`n<head>`n<meta charset=`"utf-8`">`n<meta name=`"viewport`" content=`"width=device-width, initial-scale=1, viewport-fit=cover`">`n<style>body{margin:0}img{max-width:100%}[hidden]{display:none!important}</style>`n" + (Use-LocalFonts $body) + "`n</html>`n"
[IO.File]::WriteAllText((Join-Path $dir 'index.html'), $index, $enc)

foreach ($page in 'impressum.html', 'datenschutz.html') {
  $html = Use-LocalFonts ([IO.File]::ReadAllText((Join-Path $Source $page)))
  [IO.File]::WriteAllText((Join-Path $dir $page), $html, $enc)
}
foreach ($f in 'logo.svg', 'bjoern-von-kampen.jpg', 'og-image.png') {
  Copy-Item (Join-Path $Source $f) (Join-Path $dir $f) -Force
}
