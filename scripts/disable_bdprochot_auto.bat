@echo off

REM Codigo para desactivar el BDPROCHOT
REM Lee el valor del registro 0x1FC, le resta 1 y lo vuelve a escribir en el registro
REM Se debe ejecutar cada vez que el equipo se encienda y vuelva de suspension/hibernacion
REM https://github.com/rubnium/disable-bdprochot-win

setlocal EnableDelayedExpansion

REM Leer la salida del registro a un fichero temporal, y extraer edx y eax
C:\msr-cmd\msr-cmd.exe read 0x1FC > tempBDPROCHOT.txt

for /f "tokens=4,5" %%a in (tempBDPROCHOT.txt) do (
    set "edx_val=%%a"
    set "eax_val=%%b"
)

del tempBDPROCHOT.txt

echo EDX: !edx_val!
echo EAX: !eax_val!

REM Extraer a eax el "0x"
set "eax_val=!eax_val:~2!"

REM Convertir eax a decimal y restar 1
set /a "eax_dec"=0x%eax_val%
set /a "eax_dec=eax_dec - 1"

REM Convertir de nuevo a hexadecimal (gracias  Voodooman https://www.dostips.com/forum/viewtopic.php?t=2261) y añadir el "0x"
call cmd /c exit /b %eax_dec%
set eax_new_val=%=exitcode%
set "eax_new_val=0x!eax_new_val!"

echo NEW EAX: !eax_new_val!

REM Escribe en el registro el nuevo eax, desactivando asi el BDPROCHOT
C:\msr-cmd\msr-cmd.exe write 0x1FC %edx_val% %eax_new_val% > nul

endlocal