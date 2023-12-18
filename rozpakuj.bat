@REM @ECHO OFF

@REM ECHO Hello World! Your first batch file was printed on the screen successfully. 

@REM PAUSE

@echo off

set currentdir=%cd%
if not exist "%currentdir%\rozpakowanie.ps1" (
    echo Skrypt rozpakowanie.ps1 musi znajdowac sie w tym samym folderze co plik rozpakuj.bat 
    goto endscript
)

:loop1
    set /p "sciezka_pliku_do_rozpakowania=Podaj sciezke folderu do rozpakowania(np.: C:\Users\Enio\paczka z raportami.zip , pamietaj aby sciezka konczyla sie rozszerzeniem .zip): "
    if not exist "%sciezka_pliku_do_rozpakowania%" (
        echo Podano niepoprawna sciezke
        goto loop1
    )

:loop2
    set /p "sciezka_folderu_wyjsciowego=Podaj sciezke do ktorej paczka ma byc rozpakowana(np.: C:\Users\Enio\zdarzenie_1_rozpakowane , folder musi byc pusty): "
    if not exist "%sciezka_folderu_wyjsciowego%" (
        echo Podano niepoprawna sciezke
        goto loop2
    )

:loop3
    set /p "sciezka_pliku_z_raportem=Podaj sciezke pliku z raportem ktory wygenerowano podczas tworzenia paczki(np.: C:\Users\Enio\zdarzenie_1\raport_pakowanie_02-04-2005T2137.txt , pamietaj aby plik konczyl sie rozszerzeniem .txt): "
    if not exist "%sciezka_pliku_z_raportem%" (
        echo Podano niepoprawna sciezke
        goto loop3
    )

powershell.exe ". '%currentdir%\rozpakowanie.ps1' -sciezka_pliku_do_rozpakowania '%sciezka_pliku_do_rozpakowania%' -sciezka_folderu_wyjsciowego '%sciezka_folderu_wyjsciowego%' -sciezka_pliku_z_raportem '%sciezka_pliku_z_raportem%' "

:endscript

PAUSE