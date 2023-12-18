@echo off

set currentdir=%cd%
if not exist "%currentdir%\pakowanie.ps1" (
    echo Skrypt pakowanie.ps1 musi znajdowac sie w tym samym folderze co plik spakuj.bat 
    goto endscript
)
:loop1
    set /p "sciezka_do_folderu=Podaj sciezke folderu do spakowania(np.: C:\Users\Enio\folder z raportami):"
    if not exist "%sciezka_do_folderu%" (
        echo Podano niepoprawna sciezke
        goto loop1
    )

:loop2
    set /p "sciezka_do_zapisu=Podaj sciezke do ktorego ma byc zapisana paczka wyjsciowa(np.: C:\Users\Enio\zdarzenie_1):"
    if not exist "%sciezka_do_zapisu%" (
        echo Podano niepoprawna sciezke.
        goto loop2
    )

powershell.exe ". '%currentdir%\pakowanie.ps1' -sciezka_do_folderu '%sciezka_do_folderu%' -sciezka_do_zapisu '%sciezka_do_zapisu%' "

:endscript

PAUSE