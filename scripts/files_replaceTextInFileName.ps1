# replace_text_in_fileName.ps1

# Replaces one string with another in a all file names from current directory

echo ' '

if ($args) 
{
	$text_to_replace = $args[0]
	$text_to_replace_the_previous_one = $args[1]
}
else
{
	$text_to_replace = Read-Host 'Introduce the text you want to be replaced'
	$text_to_replace_the_previous_one = Read-Host 'Introduce the text to replace the previous one'
}

get-childitem *.* | foreach { rename-item $_ $_.Name.Replace($text_to_replace, $text_to_replace_the_previous_one) }

echo ' '
