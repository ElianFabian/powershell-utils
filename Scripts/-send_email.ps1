$EmailFrom = "from_someone.com"
# https://myaccount.google.com/lesssecureapps
# https://www.youtube.com/watch?v=cJnNv_rDTe4
$EmailTo = "to_someone@gmail.com"

$Subject = "Test"

$Body = "Correo enviado desde PowerShell"

$SMTPServer = "smtp.gmail.com"

$SMTPClient = New-Object Net.Mail.SmtpClient($SmtpServer, 587)

$SMTPClient.EnableSsl = $true
$Creds = (Get-Credential -Credential $EmailFrom)
$SMTPClient.Credentials = New-Object System.Net.NetworkCredential($Creds.UserName, $Creds.Password);
$SMTPClient.Send($EmailFrom, $EmailTo, $Subject, $Body)


$scriptBlock =
{
	Write-Host "hola"
}
