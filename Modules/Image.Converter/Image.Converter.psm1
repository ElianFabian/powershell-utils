# Image.Converter.psm1



function Convert-ImageToAscii(
    [Parameter(ParameterSetName="A")]
    [string] $Path,
    [Parameter(ParameterSetName="B")]
    [System.Drawing.Bitmap] $Image,
    [switch] $UseAlpha
) {
    $bitMap = if ($Path)
    {
        [System.Drawing.Bitmap]::FromFile((Resolve-Path $Path))
    }
    else { $Image }

    $pixelDataFromTextSB = [System.Text.StringBuilder]::new()

    if ($UseAlpha)
    {
        foreach ($y in (0..($bitMap.Height - 1)))
        {
            foreach ($x in (0..($bitMap.Width - 1)))
            {
                $color = $bitMap.GetPixel($x, $y)

                $redChar   = [char]$color.R
                $greenChar = [char]$color.G
                $blueChar  = [char]$color.B
                $alphaChar = [char]$color.A

                $colorAsText = "$redChar$greenChar$blueChar$alphaChar"

                $pixelDataFromTextSB.Append($colorAsText) > $null
            }
        }
    }
    else
    {
        foreach ($y in (0..($bitMap.Height - 1)))
        {
            foreach ($x in (0..($bitMap.Width - 1)))
            {
                $color = $bitMap.GetPixel($x, $y)

                $redChar   = [char]$color.R
                $greenChar = [char]$color.G
                $blueChar  = [char]$color.B

                $colorAsText = "$redChar$greenChar$blueChar"

                $pixelDataFromTextSB.Append($colorAsText) > $null
            }
        }
    }

    return $pixelDataFromTextSB.ToString().Replace("`0", '')
}

function Convert-AsciiToImage(
    [Parameter(ParameterSetName="A")]
    [string] $Path,
    [Parameter(ParameterSetName="B")]
    [string] $Text,
    [switch] $UseAlpha
) {
    [byte[]] $pixelBytesFromText = if ($Text)
    {
        [System.Text.Encoding]::ASCII.GetBytes($Text)
    }
    else { [System.IO.File]::ReadAllBytes((Resolve-Path $Path)) }

    $charactersPerPixel = $UseAlpha ? 4 : 3

    $width  = [int][math]::Ceiling( [math]::Sqrt($pixelBytesFromText.Length / $charactersPerPixel) )
    $height = [int]$width

    $imageFromText = [System.Drawing.Bitmap]::new($width, $height)

    if ($UseAlpha)
    {
        for ($y = 0; $y -lt $height; $y++)
        {
            $yTimesWidth = $y * $width

            for ($x = 0; $x -lt $width; $x++)
            {
                $pixelIndex = ($yTimesWidth + $x) * $charactersPerPixel

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
            $yTimesWidth = $y * $width

            for ($x = 0; $x -lt $width; $x++)
            {
                $pixelIndex = ($yTimesWidth + $x) * $charactersPerPixel

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



Export-ModuleMember -Function *-*
