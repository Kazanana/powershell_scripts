#ROZPAKOWANIE
    #rozpakować, wygenerować raport, porównać raporty 
#wygenerować raport przy odpakowaniu
param (
    [Parameter(Mandatory=$true)]
    [string] $sciezka_pliku_do_rozpakowania, 
    [Parameter(Mandatory=$true)]
    [string] $sciezka_pliku_z_raportem, 
    [Parameter(Mandatory=$true)]
    [string] $sciezka_folderu_wyjsciowego
    )
#     if (!$sciezka_pliku_do_rozpakowania) {
#     throw @"
#     Nie podano sciezki do folderu ktory nalezy spakowac
#     przyklad poprawnej sciezki: 'C:\Users\Enio\Desktop\folder z raportami'
# "@
# }
Function Open-7ZipFile{
    Param(
        [Parameter(Mandatory=$true)]
        [string]$Source,
        [Parameter(Mandatory=$true)]
        [string]$Destination,
        [string]$Password,
        [switch]$Silent
    )
    # Look for the 7zip executable.
    $pathTo32Bit7Zip = "C:\Program Files (x86)\7-Zip\7z.exe"
    $pathTo64Bit7Zip = "C:\Program Files\7-Zip\7z.exe"
    $THIS_SCRIPTS_DIRECTORY = Split-Path $script:MyInvocation.MyCommand.Path
    $pathToStandAloneExe = Join-Path $THIS_SCRIPTS_DIRECTORY "7za.exe"
    if (Test-Path $pathTo64Bit7Zip) { $pathTo7ZipExe = $pathTo64Bit7Zip }
    elseif (Test-Path $pathTo32Bit7Zip) { $pathTo7ZipExe = $pathTo32Bit7Zip }
    elseif (Test-Path $pathToStandAloneExe) { $pathTo7ZipExe = $pathToStandAloneExe }
    else { throw "Nie znaleziono programu 7zip potrzebnego do rozpakowania plikow. Program mozna pobrać pod adresem: https://7-zip.org.pl/sciagnij.html" }

    $Command = "& `"$pathTo7ZipExe`" e -o`"$Destination`" -y" + $(if($Password.Length -gt 0){" -p`"$Password`""}) + " `"$Source`""
    If($Silent){
        Invoke-Expression $Command | out-null
    }else{
        "$Command"
        Invoke-Expression $Command
    }
}

#$sciezka_pliku_do_rozpakowania = "C:\Users\HP\powershell_scripts\XC 90_31-05-2017T0728.zip" C:\Users\HP\powershell_scripts\XC 90_31-05-2017T0728.zip
#$sciezka_folderu_wyjsciowego = "C:\Users\HP\powershell_scripts\rozpakowane" C:\Users\HP\powershell_scripts\rozpakowane
#C:\Users\HP\powershell_scripts\raport_pakowanie_22-05-2023T2349.txt
#Start-Process 'C:\Program Files\7-Zip\7z.exe' -ArgumentList  "e ""C:\Users\HP\powershell_scripts\XC 90_31-05-2017T0728.zip"" -oC:\Users\HP\powershell_scripts\rozpakowane -spe"
#if (Test-Path $sciezka_folderu_wyjsciowego) { throw "Folder o sciezce: $sciezka_folderu_wyjsciowego juz istnieje `n zmien nazwe folderu wyjsciowego" }
#$sciezka_pliku_z_raportem = 'C:\Users\HP\powershell_scripts\raport_pakowanie_22-05-2023T2312.txt'

if ( !($sciezka_folderu_wyjsciowego -match '\\$') ) { $sciezka_folderu_wyjsciowego = -join($sciezka_folderu_wyjsciowego,"\") } 
if ( Test-Path "${sciezka_folderu_wyjsciowego}*" ) { throw "Folder wyjsciowy musi byc pusty." } 

$hashObject_paczki = Get-FileHash $sciezka_pliku_do_rozpakowania
if ($hashObject_paczki.Hash -ne (-split (Get-Content -Path $sciezka_pliku_z_raportem -Tail 2)[0])[-1]) {
    Write-Host "UWAGA! suma kontrolna z raportu rozni się od sumy kontrolnej wygenerowanej przy rozpakowywaniu"
}

$password = Read-Host "Wprowadz haslo" 
Open-7ZipFile  -Source $sciezka_pliku_do_rozpakowania -Destination $sciezka_folderu_wyjsciowego -Password $password -Silent

if ((Get-ChildItem $sciezka_folderu_wyjsciowego | Measure-Object -Property Length -sum).Sum -eq 0){throw "Paczka nie zostala poprawnie rozpakowana"}

$sciezka_raport = "${sciezka_folderu_wyjsciowego}\raport_rozpakowanie_$(Get-Date -Format "dd-MM-yyyyTHHmm").txt"
if (Test-Path $sciezka_raport) { Remove-Item $sciezka_raport -Force }

New-Item $sciezka_raport | Out-Null
Add-Content $sciezka_raport "--------------------RAPORT Z ROZPAKOWANIA--------------------"
Add-Content $sciezka_raport "Czas wygenerowania raportu: $(Get-Date)"
Add-Content $sciezka_raport "Czas utworzenia paczki: $((Get-Item $sciezka_pliku_do_rozpakowania).CreationTime)"
Add-Content $sciezka_raport "Nazwa uzytkownika: $($Env:UserName)"
Add-Content $sciezka_raport "Nazwa komputera: $($Env:ComputerName)"
Add-Content $sciezka_raport "Haslo użyte do otworzenia paczki: $password"
Add-Content $sciezka_raport "Nazwa paczki: $($sciezka_pliku_do_rozpakowania | Split-Path -Leaf)"
Add-Content $sciezka_raport "Lista rozpakowanych plikow i ich sumy kontrolne: $(Get-ChildItem $sciezka_folderu_wyjsciowego | ForEach-Object { if ($_ -is [System.IO.FileInfo] -and $_ -notlike "raport_rozpakowanie*.txt")  {"`n$_ - $((Get-FileHash ${sciezka_folderu_wyjsciowego}$_).Hash) "} })"
Add-Content $sciezka_raport "Suma kontrolna dla paczki: $($hashObject_paczki.Hash)"
Add-Content $sciezka_raport "Algorytm użyty do wygenerowania sumy kontrolnej: $($hashObject_paczki.Algorithm)"


$lista = @()
if ( (Get-Content $sciezka_pliku_z_raportem | Measure-Object ).Count -ne (Get-Content $sciezka_raport  | Measure-Object ).Count ) {
    throw "Raporty nie maja tej samej ilosci linii. Listy spakowanych i rozpakowanych plikow sie roznia"
} elseif ( !((Get-Content $sciezka_pliku_z_raportem -Raw )  -match "Lista") ) {
    throw "W raporcie z pakowania brakuje slowa 'Lista' w 8 linijce"
} elseif ( !((Get-Content $sciezka_pliku_z_raportem -Raw )  -match "Suma") ) {
    throw "W raporcie z pakowania brakuje slowa 'Suma' w przedostatniej linijce"
}

for ($i = 1; $i -lt (Get-Content $sciezka_pliku_z_raportem  | Measure-Object ).Count +1 ; $i++)
{
    if ($i -eq 1) {continue}
    if ( (Get-Content $sciezka_pliku_z_raportem -Head $i)[-1] -match "Lista" ) {
        $i++
        while ( !((Get-Content $sciezka_pliku_z_raportem -Head $i)[-1] -match "Suma") )
        {
            if ( ( -split (Get-Content $sciezka_pliku_z_raportem  -Head $i)[-1] )[-1] -ne ( -split (Get-Content $sciezka_raport  -Head $i)[-1] )[-1]) {
                $lista += ,( -split (Get-Content $sciezka_raport -Head $i)[-1] )[0]
                #"DUPA"
                $i++
                continue
            }
            $i++
        }
    }
}

Add-Content $sciezka_raport "--------------------POROWNANIE SUM KONTROLNYCH--------------------"
# Write-Host "`n--------------------POROWNANIE SUM KONTROLNYCH--------------------"
if ($hashObject_paczki.Hash -ne (-split (Get-Content -Path $sciezka_pliku_z_raportem -Tail 2)[0])[-1]) {
    Add-Content $sciezka_raport "UWAGA! suma kontrolna calej paczki z raportu rozni sie od sumy kontrolnej wygenerowanej przy rozpakowywaniu."
}
Add-Content $sciezka_raport "Lista plików których sumy kontrolne różnią sie od tych z raportu pakowania: $($lista | ForEach-Object {"`n$_"}) "
# Write-Host "Lista plików których sumy kontrolne różnia sie od tych z raportu pakowania: $($lista | ForEach-Object {"`n$_"}) "
# Write-Host "--------------------PORÓWNANIE SUM KONTROLNYCH--------------------`n"
Write-Host "Poprawnie rozpakowano paczke. Wygenerowano raport."
Write-Host "Plik z raportem znajduje sie pod sciezka: $sciezka_raport "






