function Get-ProgramPath([string] $ProgId)
{
    return ((Get-ItemProperty "HKLM:\SOFTWARE\Classes\$ProgId\shell\open\command").'(Default)' -split '"')[1]
}

function Get-DefaultBrowserProgId
{
    return (Get-ItemProperty HKCU:\Software\Microsoft\windows\Shell\Associations\UrlAssociations\http\UserChoice).ProgId
}

function Open-WebPage($Url)
{
    (New-Object -com Shell.Application).Open($Url)
}


function Get-CurrentDateInMilliseconds
{
    return [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
}


# https://superuser.com/questions/1669700/take-screenshot-on-command-prompt-powershell
function Invoke-ScreenShot([string] $Path = ".", [string] $Name)
{
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    $Screen = [System.Windows.Forms.SystemInformation]::VirtualScreen
    $Width  = $Screen.Width
    $Height = $Screen.Height
    $Left   = $Screen.Left
    $Top    = $Screen.Top

    $bitmap  = New-Object System.Drawing.Bitmap $Width, $Height
    $graphic = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphic.CopyFromScreen($Left, $Top, 0, 0, $bitmap.Size)

    $newPath = Join-Path -Path $Path -ChildPath "$Name.jpg"

    if (-not $Name)
    {
        $newPath = "$(Resolve-Path $Path)/screenshot $(Get-Date -Format 'yyyy-MM-dd, hh-mm-ss.ff').jpg"
    }

    $bitmap.Save($newPath)
}



https://superuser.com/questions/1324007/setting-window-size-and-position-in-powershell-5-and-6