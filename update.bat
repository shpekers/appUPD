@echo off
chcp 65001 >nul
:: 65001 - UTF-8

set "arg=%1"
if "%arg%" == "admin" (
    goto :restarted
) else (
    powershell -Command "Start-Process 'cmd.exe' -ArgumentList '/c \"\"%~f0\" admin\"'" -Verb RunAs
    exit /b
)

:restarted
set SRVCNAME=SkyLab

:: Удаление служб
echo Остановка и удаление службы %SRVCNAME%...
net stop %SRVCNAME% >nul 2>&1
sc delete %SRVCNAME% >nul 2>&1

echo Остановка и удаление службы WinDivert...
net stop "WinDivert" >nul 2>&1
sc delete "WinDivert" >nul 2>&1

echo Остановка и удаление службы WinDivert14...
net stop "WinDivert14" >nul 2>&1
sc delete "WinDivert14" >nul 2>&1

echo Остановка и удаление службы SkyService...
net stop "SkyService" >nul 2>&1
sc delete "SkyService" >nul 2>&1

echo Остановка и удаление службы SkyDiscord...
net stop "SkyDiscord" >nul 2>&1
sc delete "SkyDiscord" >nul 2>&1

:: Пауза перед скачиванием файлов
echo.
echo Все службы были успешно остановлены и удалены.
timeout /t 5 /nobreak >nul

:: Скачивание и распаковка файлов из GitHub
set "URL=https://github.com/shpekers/appUPD/archive/refs/heads/main.zip"
set "ZIPFILE=appUPD.zip"
set "TEMP_DIR=%~dp0temp"
set "EXTRACTDIR=%~dp0scripts"

:: Скачивание zip-файла с помощью PowerShell
echo Скачивание файла %ZIPFILE% с %URL%...
powershell -Command "(New-Object Net.WebClient).DownloadFile('%URL%', '%ZIPFILE%')"

:: Проверка успешности скачивания
if exist "%ZIPFILE%" (
    echo Файл скачан успешно.
) else (
    echo Ошибка при скачивании файла.
    exit /b 1
)

:: Пауза перед распаковкой файлов
timeout /t 3 /nobreak >nul

:: Создание временной директории для распаковки
mkdir "%TEMP_DIR%" >nul 2>&1

:: Распаковка zip-файла во временную директорию с помощью PowerShell
echo Распаковка файла %ZIPFILE% в временную директорию %TEMP_DIR%...
powershell -Command "Expand-Archive -Path '%ZIPFILE%' -DestinationPath '%TEMP_DIR%' -Force"

:: Проверка существования папки scripts, если нет — создание её
if not exist "%EXTRACTDIR%" (
    echo Папка %EXTRACTDIR% не найдена. Создание новой папки...
    mkdir "%EXTRACTDIR%"
)

:: Удаление всех файлов и папок из целевой директории scripts перед перемещением новых данных
echo Удаление всех файлов и папок из %EXTRACTDIR%...
rmdir /s /q "%EXTRACTDIR%" 

:: Создание новой пустой папки scripts после удаления содержимого (если нужно)
mkdir "%EXTRACTDIR%" 

:: Перемещение содержимого из временной директории в целевую директорию scripts, включая подкаталоги и файлы
echo Перемещение файлов и папок из временной директории в %EXTRACTDIR%...
xcopy "%TEMP_DIR%\appUPD-main\*" "%EXTRACTDIR%\" /E /I /Y

:: Проверка успешности перемещения файлов и папок
if exist "%EXTRACTDIR%\*" (
    echo Файлы и папки перемещены успешно.
) else (
    echo Ошибка при перемещении файлов.
    exit /b 1
)

:: Удаление временной директории после завершения работы
rmdir /s /q "%TEMP_DIR%"
del "%ZIPFILE%" 

pause
exit /b 0