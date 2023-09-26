#iteruj po plikach w folderze
#dla każdego pliku sprawdź czy jest o takiej nazwie na pendriveie
#jeśli jest i jest starszy niż plik na pendrive'ie  to pomiń
#jeśli jest i jest młodszy to podmień
#jeśli nie ma to skopiuj
#na końcu wyświetl jakie pliki skopiowano i jakie podmieniono
param (
    [Parameter(Mandatory=$true)]
    [string] $FolderPath 
    )

#handling inputu
if ( !($FolderPath -match '\\$') ) { $FolderPath = -join($FolderPath,"\") }
$pen_base_path = 'D:\'
$comp_base_path = 'C:\Users\HP\'
$test = $FolderPath.Replace($comp_base_path, $pen_base_path)
if (!(Test-Path -Path $test)) { throw "Folder $test nie istnieje na pendrivie"}
Write-Host "Nastapi backup $FolderPath do $test"




$pendrive_path = $test
$comp_path = $FolderPath

$pendrive_folder_items = Get-ChildItem -Path $pendrive_path -Recurse -File 
$comp_folder_items = Get-ChildItem -Path $comp_path -Recurse -File 

Write-Host "Liczba plikow na pendrivie $($pendrive_folder_items.Length) "
Write-Host "Liczba plikow na kompie $($comp_folder_items.Length) "
$flaga = $true
for ($i = 1; $i -lt $comp_folder_items.Length ; $i++) {
    $file = $comp_folder_items[$i]
    if (Test-Path -Path $file.FullName.Replace($comp_path, $pendrive_path)){
    #Write-Host dupa1
        if ( $file.LastWriteTime -gt  (Get-Item $file.FullName.Replace($comp_path, $pendrive_path)).LastWriteTime ) {
            # Write-Host $file.LastWriteTime  
            # Write-Host (Get-Item $file.FullName.Replace($comp_path, $pendrive_path)).LastWriteTime
            Write-Host "Kopiowanie istniejacego pliku : $($file.FullName) "
            Copy-Item $file.FullName -Destination $file.FullName.Replace($comp_path, $pendrive_path)
            if ($flaga -and $true){ $flaga = $false}
        }
        else {
            #Write-Host dupa2
            continue
        }
    }
    else {
        Write-Host "Kopiowanie nowego pliku: $($file.FullName) "
        Copy-Item $file.FullName -Destination $file.FullName.Replace($comp_path, $pendrive_path)
        if ($flaga -and $true){ $flaga = $false}
    }
}
if ($flaga){Write-Host Nie skopiowano zadnych plikow}


