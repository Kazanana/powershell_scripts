#konwersja word do pdf

param (
    [Parameter(Mandatory=$true)]
    [string] $WordPath ,
    [Parameter(Mandatory=$true)]
    [string] $PdfPath 
    )

$wordApplication = New-Object -ComObject Word.Application
$document = $wordApplication.Documents.Open($WordPath)
$pdfFilePath = $PdfPath
$document.SaveAs([ref] $pdfFilePath, [ref] 17)
$document.Close()
$wordApplication.Quit()