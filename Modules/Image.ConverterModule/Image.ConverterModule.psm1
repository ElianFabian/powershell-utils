# Image.ConverterModule.psm1



# From repository: https://github.com/ElianFabian/powershell-utils



function Convert-ColorToChars([System.Drawing.Color] $color)
{
    $redChar   = [char]$color.R
    $greenChar = [char]$color.G
    $blueChar  = [char]$color.B

    return "$redChar$greenChar$blueChar"
}

function Convert-ColorToCharsWithAlpha([System.Drawing.Color] $color)
{
    $redChar   = [char]$color.R
    $greenChar = [char]$color.G
    $blueChar  = [char]$color.B
    $alphaChar = [char]$color.A

    return "$redChar$greenChar$blueChar$alphaChar"
}

#region As passing arrays as parameters is too slow it's not worth to use these functions

# function Get-Color([byte[]] $PixelBytes, [int] $Index)
# {
#     $red   = $PixelBytes[$Index]
#     $green = $PixelBytes[$Index + 1]
#     $blue  = $PixelBytes[$Index + 2]

#     $color = [System.Drawing.Color]::FromArgb($red, $green, $blue)

#     return $color
# }

# function Get-ColorWithAlpha([string] $PixelBytes, [int] $Index)
# {
#     $red   = [byte]$PixelBytes[$Index]
#     $green = [byte]$PixelBytes[$Index + 1]
#     $blue  = [byte]$PixelBytes[$Index + 2]
#     $alpha = [byte]$PixelBytes[$Index + 3]

#     $color = [System.Drawing.Color]::FromArgb($alpha, $red, $green, $blue)

#     return $color
# }

#endregion



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

    $getColorAsTextFunction = $UseAlpha ? 'Convert-ColorToCharsWithAlpha' : 'Convert-ColorToChars'

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
        Write-Error "Can't use both Path and Text"
        return
    }

    [byte[]] $pixelBytesFromText = $null

    if ($Text)
    {
        $encoding = [system.Text.Encoding]::ASCII
        $pixelBytesFromText = $encoding.GetBytes($Text)
    }
    else { $pixelBytesFromText = [System.IO.File]::ReadAllBytes($Path) }

    $charactersPerPixel = 3

    if ($UseAlpha) { $charactersPerPixel = 4 }

    $width  = [int][math]::Ceiling( [math]::Sqrt($pixelBytesFromText.Length / $charactersPerPixel) )
    $height = [int]$width

    $imageFromText = [System.Drawing.Bitmap]::new($width, $height)

    if ($UseAlpha)
    {
        for ($y = 0; $y -lt $height; $y++)
        {
            for ($x = 0; $x -lt $width; $x++)
            {
                $pixelIndex = ($y * $width + $x) * $charactersPerPixel

                $red   = $pixelBytesFromText[$pixelIndex]
                $green = $pixelBytesFromText[$pixelIndex + 1]
                $blue  = $pixelBytesFromText[$pixelIndex + 2]
                $alpha = $pixelBytesFromText[$pixelIndex + 3]
            
                $color = [System.Drawing.Color]::FromArgb($alpha, $red, $green, $blue)

                $imageFromText.SetPixel($x, $y, $color)
            }
        }
    }
    else
    {
        for ($y = 0; $y -lt $height; $y++)
        {
            for ($x = 0; $x -lt $width; $x++)
            {
                $pixelIndex = ($y * $width + $x) * $charactersPerPixel

                $red   = $pixelBytesFromText[$pixelIndex]
                $green = $pixelBytesFromText[$pixelIndex + 1]
                $blue  = $pixelBytesFromText[$pixelIndex + 2]

                $color = [System.Drawing.Color]::FromArgb($red, $green, $blue)

                $imageFromText.SetPixel($x, $y, $color)
            }
        }
    }

    return $imageFromText
}



Export-ModuleMember -Function Convert-ImageToAscii
Export-ModuleMember -Function Convert-AsciiToImage
