$Array = @()
$Processes = Get-Process

Foreach($Proc in $Processes)
{
    if($Proc.ws/1mb -gt 100)
    {
        $Array += New-Object psobject -Property @{'ProcessName' = $Proc.name; 'WorkingSet' = $Proc.ws}
    } 
}
$Array | select 'ProcessName', 'WorkingSet' | Export-Csv ./plik.csv -NoTypeInformation

$CSVImport = @()
$CSVImport = Import-Csv .\plik.csv

ForEach($obj in $CSVImport){Write-Host "ProcessName:" $obj.processname " Working Set:" $obj.workingset}

$CSVImport | Format-Table -AutoSize
$CSVImport[1].ProcessName
###################################
###################################
