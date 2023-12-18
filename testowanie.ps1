# Parameters
#$zipfileName = "C:\Users\HP\powershell_scripts\testy\XC 90.zip"
$zipfileName = "C:\Users\HP\powershell_scripts\testy\XC 90_31-05-2017T0728.zip"

$fileToRead = "YV1LFBABDG1038949_ACM.CSV"


# Open zip and find the particular file (assumes only one inside the Zip file)
Add-Type -assembly  System.IO.Compression.FileSystem
$zip =  [System.IO.Compression.ZipFile]::Open($zipfileName,"Update")

$csvFileRead = $zip.Entries.Where({$_.name -eq $fileToRead})
$csvFileReadDate = $zip.Entries.Where({$_.name -eq $fileToRead}).LastWriteTime
# $csvFileReadDate | Set-ItemProperty -Name LastWriteTime -Value '04.02.2005 21:37:00'

# Update the contents of the file
# $desiredFileEdit = [System.IO.StreamWriter]($csvFileEdit).Open()
# $desiredFileEdit.BaseStream.SetLength(0)
# $desiredFileEdit.Write($contents)
# $desiredFileEdit.Flush()s
# $desiredFileEdit.Close()

# Read the contents of the file
$desiredFileRead = [System.IO.StreamReader]($csvFileRead).Open()
$text = $desiredFileRead.ReadToEnd()

# Output the contents
$text
$csvFileReadDate

$desiredFileRead.Close()
$desiredFileRead.Dispose()

# Write the changes and close the zip file
$zip.Dispose()
#Write-Host "zip file updated"