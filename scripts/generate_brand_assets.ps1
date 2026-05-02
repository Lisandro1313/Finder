$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName System.Drawing

$assetsDir = 'assets/branding'
if (-not (Test-Path $assetsDir)) {
  New-Item -ItemType Directory -Path $assetsDir | Out-Null
}

function New-GradientBrush {
  param(
    [int]$Width,
    [int]$Height,
    [string]$HexA,
    [string]$HexB
  )
  $start = [System.Drawing.ColorTranslator]::FromHtml($HexA)
  $end = [System.Drawing.ColorTranslator]::FromHtml($HexB)
  return New-Object System.Drawing.Drawing2D.LinearGradientBrush(
    (New-Object System.Drawing.Rectangle(0, 0, $Width, $Height)),
    $start,
    $end,
    [System.Drawing.Drawing2D.LinearGradientMode]::ForwardDiagonal
  )
}

function Save-Png {
  param(
    [System.Drawing.Bitmap]$Bitmap,
    [string]$Path
  )
  $Bitmap.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png)
  $Bitmap.Dispose()
}

Write-Host 'Generating Finder branding assets...'

# Launcher full icon (1024x1024)
$iconSize = 1024
$bmpIcon = New-Object System.Drawing.Bitmap($iconSize, $iconSize, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$gIcon = [System.Drawing.Graphics]::FromImage($bmpIcon)
$gIcon.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$gIcon.Clear([System.Drawing.ColorTranslator]::FromHtml('#FFF8FB'))

$mainRect = New-Object System.Drawing.Rectangle(130, 130, 764, 764)
$iconBrush = New-GradientBrush -Width $mainRect.Width -Height $mainRect.Height -HexA '#E11D48' -HexB '#FF6B6B'
$path = New-Object System.Drawing.Drawing2D.GraphicsPath
$radius = 230
$d = $radius * 2
$path.AddArc($mainRect.X, $mainRect.Y, $d, $d, 180, 90)
$path.AddArc($mainRect.Right - $d, $mainRect.Y, $d, $d, 270, 90)
$path.AddArc($mainRect.Right - $d, $mainRect.Bottom - $d, $d, $d, 0, 90)
$path.AddArc($mainRect.X, $mainRect.Bottom - $d, $d, $d, 90, 90)
$path.CloseFigure()
$gIcon.FillPath($iconBrush, $path)

$heartFont = New-Object System.Drawing.Font('Segoe UI Emoji', 390, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$heartFormat = New-Object System.Drawing.StringFormat
$heartFormat.Alignment = [System.Drawing.StringAlignment]::Center
$heartFormat.LineAlignment = [System.Drawing.StringAlignment]::Center
$heartRect = New-Object System.Drawing.RectangleF(130, 150, 764, 620)
$gIcon.DrawString([char]0x2665, $heartFont, [System.Drawing.Brushes]::White, $heartRect, $heartFormat)

$pillBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(230, 255, 255, 255))
$gIcon.FillEllipse($pillBrush, 350, 660, 324, 66)

$gIcon.Dispose()
$iconBrush.Dispose()
$path.Dispose()
$heartFont.Dispose()
$pillBrush.Dispose()

Save-Png -Bitmap $bmpIcon -Path (Join-Path $assetsDir 'finder_launcher_1024.png')

# Launcher foreground for adaptive icon
$bmpFg = New-Object System.Drawing.Bitmap($iconSize, $iconSize, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$gFg = [System.Drawing.Graphics]::FromImage($bmpFg)
$gFg.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$gFg.Clear([System.Drawing.Color]::Transparent)
$fgBrush = New-GradientBrush -Width 540 -Height 540 -HexA '#E11D48' -HexB '#FF6B6B'

$fgRect = New-Object System.Drawing.Rectangle(242, 212, 540, 540)
$fgPath = New-Object System.Drawing.Drawing2D.GraphicsPath
$fgRadius = 160
$fgD = $fgRadius * 2
$fgPath.AddArc($fgRect.X, $fgRect.Y, $fgD, $fgD, 180, 90)
$fgPath.AddArc($fgRect.Right - $fgD, $fgRect.Y, $fgD, $fgD, 270, 90)
$fgPath.AddArc($fgRect.Right - $fgD, $fgRect.Bottom - $fgD, $fgD, $fgD, 0, 90)
$fgPath.AddArc($fgRect.X, $fgRect.Bottom - $fgD, $fgD, $fgD, 90, 90)
$fgPath.CloseFigure()
$gFg.FillPath($fgBrush, $fgPath)

$fgHeartFont = New-Object System.Drawing.Font('Segoe UI Emoji', 280, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$fgHeartRect = New-Object System.Drawing.RectangleF(242, 235, 540, 420)
$fgHeartFormat = New-Object System.Drawing.StringFormat
$fgHeartFormat.Alignment = [System.Drawing.StringAlignment]::Center
$fgHeartFormat.LineAlignment = [System.Drawing.StringAlignment]::Center
$gFg.DrawString([char]0x2665, $fgHeartFont, [System.Drawing.Brushes]::White, $fgHeartRect, $fgHeartFormat)
$fgPillBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(230, 255, 255, 255))
$gFg.FillEllipse($fgPillBrush, 395, 585, 234, 50)

$gFg.Dispose()
$fgBrush.Dispose()
$fgPath.Dispose()
$fgHeartFont.Dispose()
$fgHeartFormat.Dispose()
$fgPillBrush.Dispose()
$heartFormat.Dispose()

Save-Png -Bitmap $bmpFg -Path (Join-Path $assetsDir 'finder_launcher_foreground.png')

# Feature graphic (1024x500)
$featureW = 1024
$featureH = 500
$bmpFeature = New-Object System.Drawing.Bitmap($featureW, $featureH, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$gFeature = [System.Drawing.Graphics]::FromImage($bmpFeature)
$gFeature.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias

$bgBrush = New-GradientBrush -Width $featureW -Height $featureH -HexA '#1F1633' -HexB '#40295E'
$gFeature.FillRectangle($bgBrush, 0, 0, $featureW, $featureH)

$glowA = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(60, 225, 29, 72))
$glowB = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(50, 96, 165, 250))
$gFeature.FillEllipse($glowA, -120, -70, 420, 420)
$gFeature.FillEllipse($glowB, 700, 120, 380, 380)

$bannerRect = New-Object System.Drawing.Rectangle(80, 86, 154, 154)
$bannerBrush = New-GradientBrush -Width $bannerRect.Width -Height $bannerRect.Height -HexA '#E11D48' -HexB '#FF8A65'
$bannerPath = New-Object System.Drawing.Drawing2D.GraphicsPath
$bannerRadius = 42
$bd = $bannerRadius * 2
$bannerPath.AddArc($bannerRect.X, $bannerRect.Y, $bd, $bd, 180, 90)
$bannerPath.AddArc($bannerRect.Right - $bd, $bannerRect.Y, $bd, $bd, 270, 90)
$bannerPath.AddArc($bannerRect.Right - $bd, $bannerRect.Bottom - $bd, $bd, $bd, 0, 90)
$bannerPath.AddArc($bannerRect.X, $bannerRect.Bottom - $bd, $bd, $bd, 90, 90)
$bannerPath.CloseFigure()
$gFeature.FillPath($bannerBrush, $bannerPath)

$titleFont = New-Object System.Drawing.Font('Segoe UI', 72, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$subFont = New-Object System.Drawing.Font('Segoe UI', 36, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$heartBannerFont = New-Object System.Drawing.Font('Segoe UI Emoji', 98, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)

$gFeature.DrawString([char]0x2665, $heartBannerFont, [System.Drawing.Brushes]::White, 95, 100)
$gFeature.DrawString('Finder', $titleFont, [System.Drawing.Brushes]::White, 270, 98)
$subBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(230, 240, 240, 255))
$gFeature.DrawString('Match, chat y conexiones reales cerca tuyo', $subFont, $subBrush, 272, 206)

$ctaBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(220, 255, 255, 255))
$ctaFont = New-Object System.Drawing.Font('Segoe UI', 28, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$gFeature.FillEllipse($ctaBrush, 272, 312, 368, 74)
$ctaTextBrush = New-Object System.Drawing.SolidBrush([System.Drawing.ColorTranslator]::FromHtml('#1F1633'))
$gFeature.DrawString('Descubre tu proximo match', $ctaFont, $ctaTextBrush, 318, 328)

$gFeature.Dispose()
$bgBrush.Dispose()
$glowA.Dispose()
$glowB.Dispose()
$bannerBrush.Dispose()
$bannerPath.Dispose()
$titleFont.Dispose()
$subFont.Dispose()
$heartBannerFont.Dispose()
$subBrush.Dispose()
$ctaBrush.Dispose()
$ctaFont.Dispose()
$ctaTextBrush.Dispose()

Save-Png -Bitmap $bmpFeature -Path (Join-Path $assetsDir 'finder_feature_graphic_1024x500.png')

Write-Host "Brand assets created in $assetsDir"
