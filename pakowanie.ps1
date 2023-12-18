#PAKOWANIE
    #ścieżka jako argument, spakować, wygenerować hasło i je zapisać do raportu, wygenerować raport
#wygenerować raport z pakowania
    #jakie pliki, suma kontrolna, czas utworzenia paczki, hasło do paczki w raporcie, 

#ROZPAKOWANIE
    #rozpakować, wygenerować raport, porównać raporty 
#wygenerować raport przy odpakowaniu

#dodać do raportu nazwę komputera i info o systemie
param ([string] $sciezka_do_folderu, [string] $sciezka_do_zapisu=$((Get-Location).Path))
if (!$sciezka_do_folderu) {
    throw @"
    Nie podano sciezki do folderu ktory nalezy spakowac
    przyklad poprawnej sciezki: 'C:\Users\Enio\Desktop\folder z raportami'
"@
}
#FUNKCJA DO PAKOWANIA 7zipem
function Write-ZipUsing7Zip([array]$FilesToZip, [string]$ZipOutputFilePath, [string]$Password, [ValidateSet('7z','zip','gzip','bzip2','tar','iso','udf')][string]$CompressionType = 'zip', [switch]$HideWindow)
{
    # Look for the 7zip executable.
    $pathTo32Bit7Zip = "C:\Program Files (x86)\7-Zip\7z.exe"
    $pathTo64Bit7Zip = "C:\Program Files\7-Zip\7z.exe"
    $THIS_SCRIPTS_DIRECTORY = Split-Path $script:MyInvocation.MyCommand.Path
    $pathToStandAloneExe = Join-Path $THIS_SCRIPTS_DIRECTORY "7za.exe"
    if (Test-Path $pathTo64Bit7Zip) { $pathTo7ZipExe = $pathTo64Bit7Zip }
    elseif (Test-Path $pathTo32Bit7Zip) { $pathTo7ZipExe = $pathTo32Bit7Zip }
    elseif (Test-Path $pathToStandAloneExe) { $pathTo7ZipExe = $pathToStandAloneExe }
    else { throw "Nie znaleziono programu 7zip potrzebnego do spakowania plikow. Program mozna pobrać pod adresem: https://7-zip.org.pl/sciagnij.html" }

    # Delete the destination zip file if it already exists (i.e. overwrite it).
    if (Test-Path $ZipOutputFilePath) { Remove-Item $ZipOutputFilePath -Force }

    $windowStyle = "Normal"
    if ($HideWindow) { $windowStyle = "Hidden" }

    # Create the arguments to use to zip up the files.
    # Command-line argument syntax can be found at: http://www.dotnetperls.com/7-zip-examples
    $arguments = "a -t$CompressionType ""$ZipOutputFilePath"" ""$FilesToZip"" -mx9"
    if (!([string]::IsNullOrEmpty($Password))) { $arguments += " -p$Password" }

    # Zip up the files.
    $p = Start-Process $pathTo7ZipExe -ArgumentList $arguments -Wait -PassThru -WindowStyle $windowStyle

    # If the files were not zipped successfully.
    if (!(($p.HasExited -eq $true) -and ($p.ExitCode -eq 0)))
    {
        throw "Wystapil problem ze stowrzeniem pliku zip."
    }
}

#$sciezka_do_folderu = 'C:\Users\HP\pracaDyplomowa\CDR\XC 90\'
#$sciezka_do_zapisu = 'C:\Users\HP\powershell_scripts\'
$nazwa_folderu = $sciezka_do_folderu | Split-Path -leaf
if ( !(Test-Path "${sciezka_do_folderu}*.CDRx") ) {throw "W podanej sciezce nie ma pliku .CDRx"}
$surowy_plik = Get-Item "${sciezka_do_folderu}*.CDRx"
$data_ostatniego_dostepu = Get-Date $surowy_plik.LastWriteTime -Format "dd-MM-yyyyTHHmm"
$sciezka_do_finalnej_paczki = "${sciezka_do_zapisu}${nazwa_folderu}_${data_ostatniego_dostepu}"

$length = Get-Random -Minimum 10 -Maximum 19
$characters = @(
        "a", "b", "c", "d", "e", "f", "g", "h", "i", "j",
        "k", "l", "m", "n", "o", "p", "q", "r", "s", "t",
        "u", "v", "w", "x", "y", "z", "A", "B", "C", "D",
        "E", "F", "G", "H", "I", "J", "K", "L", "M", "N",
        "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X",
        "Y", "Z", "0", "1", "2", "3", "4", "5", "6", "7",
        "8", "9", "!", "@", "#", "%", "^", "&", "*",
        "(", ")", "_", "-", "+", "=", "<", ">", ",", ".",
        "?", "/", ":", ";", "{", "}", "[", "]", "|", "~"
    )
$randomPassword = -join (Get-Random -InputObject $characters -Count $length)
$CompressionType = 'zip'

Write-ZipUsing7Zip -FilesToZip $sciezka_do_folderu -ZipOutputFilePath $sciezka_do_finalnej_paczki -Password $randomPassword  -CompressionType $CompressionType -HideWindow 

#if (!(Test-Path $sciezka_do_finalnej_paczki)) {Write-Host "Wystapil problem z pakowaniem plikow."} else {
    $sciezka_raport = "${sciezka_do_zapisu}raport_pakowanie_$(Get-Date -Format "dd-MM-yyyyTHHmm").txt"
    if (Test-Path $sciezka_raport) { Remove-Item $sciezka_raport -Force }

    New-Item $sciezka_raport | Out-Null
    Add-Content $sciezka_raport "--------------------RAPORT ZE SPAKOWANIA--------------------"
    Add-Content $sciezka_raport "Czas wygenerowania raportu(data pobierana jest z systemu komputera): $(Get-Date)"
    Add-Content $sciezka_raport "Czas utworzenia paczki(data pobierana jest z systemu komputera): $((Get-Item (-join("$sciezka_do_finalnej_paczki", ".", "$CompressionType"))).CreationTime)"
    Add-Content $sciezka_raport "Nazwa uzytkownika: $($Env:UserName)"
    Add-Content $sciezka_raport "Nazwa komputera: $($Env:ComputerName)"
    Add-Content $sciezka_raport "Haslo do paczki: $randomPassword"
    Add-Content $sciezka_raport "Nazwa folderu po spakowaniu: $( "$($sciezka_do_finalnej_paczki | Split-Path -Leaf).$CompressionType" )"
    Add-Content $sciezka_raport "Lista spakowanych plikow i ich sumy kontrolne: $(Get-ChildItem $sciezka_do_folderu | ForEach-Object {"`n$_ - $((Get-FileHash ${sciezka_do_folderu}$_).Hash) "})"
    Add-Content $sciezka_raport "Suma kontrolna dla paczki: $($(Get-FileHash (-join("$sciezka_do_finalnej_paczki", ".", "$CompressionType"))).Hash)"
    Add-Content $sciezka_raport "Algorytm użyty do wygenerowania sumy kontrolnej: $($(Get-FileHash (-join("$sciezka_do_finalnej_paczki", ".", "$CompressionType"))).Algorithm)"
    Write-Host "Proces zakonczyl sie poprawnie, wygenerowano raport z pakowania."
    Write-Host "Plik z raportem znajduje sie pod sciezka: $sciezka_raport "
#
#}










