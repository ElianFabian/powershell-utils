# Image.ConverterModule.psm1



# From repository: https://github.com/ElianFabian/powershell-utils



function Get-ColorAsText([System.Drawing.Color] $color)
{
    $redChar   = [char]$color.R
    $greenChar = [char]$color.G
    $blueChar  = [char]$color.B

    return "$redChar$greenChar$blueChar"
}

function Get-ColorAsTextWithAlpha([System.Drawing.Color] $color)
{
    $redChar   = [char]$color.R
    $greenChar = [char]$color.G
    $blueChar  = [char]$color.B
    $alphaChar = [char]$color.A

    return "$redChar$greenChar$blueChar$alphaChar"
}

function Get-Color([string] $text, [int] $pixelIndex)
{
    $red   = [byte]$text[$pixelIndex]
    $green = [byte]$text[$pixelIndex + 1]
    $blue  = [byte]$text[$pixelIndex + 2]

    $color = [System.Drawing.Color]::FromArgb($red, $green, $blue)

    return $color
}

function Get-ColorWithAlpha([string] $text, [int] $pixelIndex)
{
    $red   = [byte]$text[$pixelIndex]
    $green = [byte]$text[$pixelIndex + 1]
    $blue  = [byte]$text[$pixelIndex + 2]
    $alpha = [byte]$text[$pixelIndex + 3]

    $color = [System.Drawing.Color]::FromArgb($alpha, $red, $green, $blue)

    return $color
}



function Convert-ImageToAscii([string] $Path, [System.Drawing.Bitmap] $Image, [switch] $UseAlpha)
{
    if ($Path -and $Image)
    {
       Write-Error "Can't use both Path and Image"
       return
    }

    if ($Path)
    {
        $bitMap = [System.Drawing.Bitmap]::FromFile($Path)
    }
    elseif ($Image)
    {
        $bitMap = $Image
    }

    $pixelDataFromTextSB = [System.Text.StringBuilder]::new()

    $getColorAsTextFunction = $UseAlpha ? 'Get-ColorAsTextWithAlpha' : 'Get-ColorAsText'

    foreach ($y in (0..($bitMap.Height - 1)))
    {
        foreach ($x in (0..($bitMap.Width - 1)))
        {
            $color = $bitMap.GetPixel($x, $y)

            $colorAsText = & $getColorAsTextFunction $color

            $pixelDataFromTextSB.Append($colorAsText) > $null
        }
    }

    return $pixelDataFromTextSB.ToString().Replace("`0", '')
}

function Convert-AsciiToImage([string] $Path, [string] $Text, [switch] $UseAlpha)
{
    if ($Path -and $Text)
    {
        Write-Error "Can't use both Path and TexValue"
        return
    }

    $pixelDataFromText = ''

    if ($Text)
    {
        $pixelDataFromText = $Text
    }
    else { $pixelDataFromText = Get-Content -Path $Path -Raw }

    $charactersPerPixel = 3

    if ($UseAlpha) { $charactersPerPixel = 4 }

    $width  = [int][math]::Ceiling( [math]::Sqrt($pixelDataFromText.Length / $charactersPerPixel) )
    $height = [int]$width

    $imageFromText = [System.Drawing.Bitmap]::new($width, $height)

    $getColorFunction = $UseAlpha ? 'Get-ColorWithAlpha' : 'Get-Color'

    for ($y = 0; $y -lt $height; $y++)
    {
        for ($x = 0; $x -lt $width; $x++)
        {
            $pixelIndex = ($y * $width + $x) * $charactersPerPixel

            $color = & $getColorFunction $pixelDataFromText $pixelIndex

            $imageFromText.SetPixel($x, $y, $color)
        }
    }

    return $imageFromText
}



Export-ModuleMember -Function Convert-ImageToAscii
Export-ModuleMember -Function Convert-AsciiToImage
