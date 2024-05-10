@echo off
title CHDMan Menu v1.3


set "chdFileCount=0"
set "cueFileCount=0"
set "gdiFileCount=0"
set "isoFileCount=0"
set "totalFileCount=0"

set "compressedFileCount=0"
set "decompressedFileCount=0"
set "deletedFileCount=0"
set "failureCount=0"

set "startTime=%time%"
set "endTime=%time%"
set "failureList=null"

set "deleteSourceFiles=1"



:Welcome
goto SelectOperation

:NoSourceFiles
cls
echo.
echo No valid files were found!
echo.
echo Place chadman.exe/bat in the same directory as your .CHD, .CUE, .GDI, or .ISO file(s).
echo.
pause
goto eof


:SelectOperation
echo.
echo ============ Main Menu ============
echo.
call :GetFileCounts
if %totalFileCount%==0 goto NoSourceFiles
echo.
echo Select which operation you'd like to perform.
echo.
echo    [1] Create CD CHD file(s) - PSX, Dreamcast, NeoGeo CD, (some) PS2
echo    [2] Create DVD CHD file(s) - (most) PS2 (default hunk size)
echo    [3] Create DVD CHD file(s) - PSP (2048 hunk size)
echo.
echo    [4] Extract DVD CHD to ISO
echo    [5] Extract CD CHD to CUE/BIN
echo    [6] Extract CD CHD to GDI
echo.
set /p "input=input->"
cls
echo.
echo ============ Main Menu ============
echo.
echo Delete source file(s) after compression/extraction?
echo.
echo    [1] NO
echo    [2] YES
echo.
echo Note: .bin files will not be destroyed.
echo.
set /p "deleteSourceFiles=input->"
set "startTime=%time%"
if %input%==1 goto CUE-GDI-ISO-to-CHD-CD
if %input%==2 goto CUE-GDI-ISO-to-CHD-DVD
if %input%==3 goto CUE-GDI-ISO-to-CHD-DVD-PSP
if %input%==4 goto Extract-DVD-CHD-to-ISO
if %input%==5 goto Extract-CD-CHD-to-CUE
if %input%==6 goto Extract-CD-CHD-to-GDI
goto SelectOperation


:CUE-GDI-ISO-to-CHD-CD
cls
set "startTime=%time%"
for /r %%i in (*.cue, *.gdi, *.iso) do (
    echo.
    call echo Progress: %%compressedFileCount%% of %%otherFileCount%%
    echo.
    set /a failureCount=failureCount+1
    chdman createcd -i "%%i" -o "%%~pi%%~ni.chd" && (
        set /a compressedFileCount=compressedFileCount+1
        set /a failureCount=failureCount-1

        if %deleteSourceFiles%==2 (
            del "%%i"
            set /a deletedFileCount=deletedFileCount+1
        )
    )
)
echo.
echo Progress: %compressedFileCount% of %otherFileCount%
echo.
goto Finished


:CUE-GDI-ISO-to-CHD-DVD
cls
for /r %%i in (*.cue,*.gdi, *.iso) do (
    echo.
    call echo Progress: %%compressedFileCount%% of %%otherFileCount%%
    echo.
    set /a failureCount=failureCount+1
    chdman createdvd -i "%%i" -o "%%~pi%%~ni.chd" && (
        set /a compressedFileCount=compressedFileCount+1
        set /a failureCount=failureCount-1

        if %deleteSourceFiles%==2 (
            del "%%i"
            set /a deletedFileCount=deletedFileCount+1
        )
    )
)
echo.
echo Progress: %compressedFileCount% of %otherFileCount%
echo.
goto Finished


:CUE-GDI-ISO-to-CHD-DVD-PSP
cls
for /r %%i in (*.cue, *.gdi, *.iso) do (
    echo.
    call echo Progress: %%compressedFileCount%% of %%otherFileCount%%
    echo.
    set /a failureCount=failureCount+1
    chdman createdvd -hs 2048 -i "%%i" -o "%%~pi%%~ni.chd" && (
        set /a compressedFileCount=compressedFileCount+1
        set /a failureCount=failureCount-1

        if %deleteSourceFiles%==2 (
            del "%%i"
            set /a deletedFileCount=deletedFileCount+1
        )
    )
)
echo.
echo Progress: %compressedFileCount% of %otherFileCount%
echo.
goto Finished


:Extract-DVD-CHD-to-ISO
cls
for /r %%i in (*.chd) do (
    echo.
    call echo Progress: %%decompressedFileCount%% of %%chdFileCount%%
    echo.
    set /a failureCount=failureCount+1
    chdman extractdvd -i "%%i" -o "%%~pi%%~ni.iso" && (
        set /a decompressedFileCount=decompressedFileCount+1
        set /a failureCount=failureCount-1

        if %deleteSourceFiles%==2 (
            del "%%i"
            set /a deletedFileCount=deletedFileCount+1
        )
    )
)
echo.
echo Progress: %decompressedFileCount% of %chdFileCount%
echo.
goto Finished


:Extract-CD-CHD-to-CUE
cls
for /r %%i in (*.chd) do (
    echo.
    call echo Progress: %%decompressedFileCount%% of %%chdFileCount%%
    echo.
    set /a failureCount=failureCount+1
    chdman extractcd -i "%%i" -o "%%~pi%%~ni.cue" && (
        set /a decompressedFileCount=decompressedFileCount+1
        set /a failureCount=failureCount-1
        
        if %deleteSourceFiles%==2 (
            del "%%i"
            set /a deletedFileCount=deletedFileCount+1
        )
    )
)
echo.
echo Progress: %decompressedFileCount% of %chdFileCount%
echo.
goto Finished


:Extract-CD-CHD-to-GDI
cls
for /r %%i in (*.chd) do (
    echo.
    call echo Progress: %%decompressedFileCount%% of %%chdFileCount%%
    echo.
    set /a failureCount=failureCount+1
    chdman extractcd -i "%%i" -o "%%~pi%%~ni.gdi" && (
        set /a decompressedFileCount=decompressedFileCount+1
        set /a failureCount=failureCount-1

        if %deleteSourceFiles%==2 (
            del "%%i"
            set /a deletedFileCount=deletedFileCount+1
        )
    )
)
echo.
echo Progress: %decompressedFileCount% of %chdFileCount%
echo.
goto Finished


:GetFileCounts
set "cueFileCount=0"
set "gdiFileCount=0"
set "isoFileCount=0"
set "chdFileCount=0"
for /r %%i in (*.cue) do (
    set /a cueFileCount=cueFileCount+1
)
for /r %%i in (*.gdi) do (
    set /a gdiFileCount=gdiFileCount+1
)
for /r %%i in (*.iso) do (
    set /a isoFileCount=isoFileCount+1
)
for /r %%i in (*.chd) do (
    set /a chdFileCount=chdFileCount+1
)
set /a otherFileCount=cueFileCount+gdiFileCount+isoFileCount
set /a totalFileCount=otherFileCount+chdFileCount
echo Checking files...
echo.
echo    Found %cueFileCount% .CUE file(s)
echo    Found %gdiFileCount% .GDI file(s)
echo    Found %isoFileCount% .ISO file(s)
echo    Found %chdFileCount% .CHD file(s)
echo.
echo Total: %totalFileCount% valid file(s)
echo.
goto eof


:Finished
set "chdFileCount=0"
set "otherFileCount=0"
for /r %%i in (*.cue, *.gdi, *.iso) do (
    set /a otherFileCount=otherFileCount+1
)
for /r %%i in (*.chd) do (
    set /a chdFileCount=chdFileCount+1
)
set "endTime=%time%"
echo.
echo Done!
echo.
echo %chdFileCount% .CHD file(s) remaining
echo %otherFileCount% .CUE/.GDI/.ISO file(s) remaining
echo.
echo %compressedFileCount% files were compressed.
echo %decompressedFileCount% files were decompressed.
echo %deletedFileCount% files were deleted.
echo %failureCount% files failed to process.
echo.
echo Start time: %startTime%
echo End time:   %endTime%
echo.
pause
goto eof
