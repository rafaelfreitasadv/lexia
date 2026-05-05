# Servidor HTTP estatico minimo para testar o LEXIA localmente.
# Serve a pasta atual em http://localhost:8000.

$ErrorActionPreference = "Continue"
$port = 8000
$root = $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($root)) { $root = (Get-Location).Path }

$mime = @{
  ".html" = "text/html; charset=utf-8"
  ".htm"  = "text/html; charset=utf-8"
  ".js"   = "application/javascript; charset=utf-8"
  ".mjs"  = "application/javascript; charset=utf-8"
  ".css"  = "text/css; charset=utf-8"
  ".json" = "application/json; charset=utf-8"
  ".png"  = "image/png"
  ".jpg"  = "image/jpeg"
  ".jpeg" = "image/jpeg"
  ".gif"  = "image/gif"
  ".svg"  = "image/svg+xml"
  ".ico"  = "image/x-icon"
  ".woff" = "font/woff"
  ".woff2"= "font/woff2"
  ".md"   = "text/markdown; charset=utf-8"
  ".txt"  = "text/plain; charset=utf-8"
}

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$port/")
$listener.Prefixes.Add("http://127.0.0.1:$port/")
try {
  $listener.Start()
} catch {
  Write-Host "Falha ao abrir porta $port. Talvez ja esteja em uso." -ForegroundColor Red
  Write-Host $_.Exception.Message
  Read-Host "Pressione Enter para sair"
  exit 1
}

Write-Host ""
Write-Host "[OK] Servidor escutando em http://localhost:$port/" -ForegroundColor Green
Write-Host "     Pasta servida: $root" -ForegroundColor Gray
Write-Host "     Para parar, feche esta janela." -ForegroundColor Gray
Write-Host ""

while ($listener.IsListening) {
  $ctx = $null
  try { $ctx = $listener.GetContext() } catch { break }
  $req = $ctx.Request
  $res = $ctx.Response
  try {
    # Decode URL path usando metodo built-in (sem System.Web)
    $rawPath = $req.Url.AbsolutePath
    try { $rel = [uri]::UnescapeDataString($rawPath) } catch { $rel = $rawPath }
    $rel = $rel.TrimStart('/').TrimStart('\')
    if ([string]::IsNullOrWhiteSpace($rel)) { $rel = "index.html" }
    # Sanitiza separadores
    $rel = $rel -replace '/', '\'
    $path = Join-Path $root $rel
    # Bloqueia tentativas de subir pasta
    $resolvedRoot = [System.IO.Path]::GetFullPath($root)
    $resolvedPath = $null
    try { $resolvedPath = [System.IO.Path]::GetFullPath($path) } catch { $resolvedPath = $path }
    if (-not $resolvedPath.StartsWith($resolvedRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
      $res.StatusCode = 403
      $bytes = [System.Text.Encoding]::UTF8.GetBytes("403 Forbidden")
      $res.ContentType = "text/plain; charset=utf-8"
      $res.OutputStream.Write($bytes, 0, $bytes.Length)
      Write-Host "[403] $rel" -ForegroundColor Yellow
    } elseif ((Test-Path $resolvedPath) -and ((Get-Item $resolvedPath) -is [System.IO.DirectoryInfo])) {
      $resolvedPath = Join-Path $resolvedPath "index.html"
      if (-not (Test-Path $resolvedPath)) {
        $res.StatusCode = 404
        $bytes = [System.Text.Encoding]::UTF8.GetBytes("404 Index nao encontrado")
        $res.ContentType = "text/plain; charset=utf-8"
        $res.OutputStream.Write($bytes, 0, $bytes.Length)
      } else {
        $ext = [System.IO.Path]::GetExtension($resolvedPath).ToLower()
        $ct = $mime[$ext]; if (-not $ct) { $ct = "application/octet-stream" }
        $res.ContentType = $ct
        $bytes = [System.IO.File]::ReadAllBytes($resolvedPath)
        $res.ContentLength64 = $bytes.Length
        $res.OutputStream.Write($bytes, 0, $bytes.Length)
        Write-Host "[200] $rel/index.html ($($bytes.Length) bytes)" -ForegroundColor DarkGray
      }
    } elseif (-not (Test-Path $resolvedPath)) {
      $res.StatusCode = 404
      $bytes = [System.Text.Encoding]::UTF8.GetBytes("404 Nao encontrado: $rel")
      $res.ContentType = "text/plain; charset=utf-8"
      $res.OutputStream.Write($bytes, 0, $bytes.Length)
      Write-Host "[404] $rel" -ForegroundColor Yellow
    } else {
      $ext = [System.IO.Path]::GetExtension($resolvedPath).ToLower()
      $ct = $mime[$ext]
      if (-not $ct) { $ct = "application/octet-stream" }
      $res.ContentType = $ct
      $bytes = [System.IO.File]::ReadAllBytes($resolvedPath)
      $res.ContentLength64 = $bytes.Length
      $res.OutputStream.Write($bytes, 0, $bytes.Length)
      Write-Host "[200] $rel ($($bytes.Length) bytes)" -ForegroundColor DarkGray
    }
  } catch {
    Write-Host "[ERRO] $($_.Exception.Message)" -ForegroundColor Red
    try {
      $res.StatusCode = 500
      $bytes = [System.Text.Encoding]::UTF8.GetBytes("500: $($_.Exception.Message)")
      $res.OutputStream.Write($bytes, 0, $bytes.Length)
    } catch {}
  } finally {
    try { $res.OutputStream.Close() } catch {}
  }
}
$listener.Stop()
