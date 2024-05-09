@echo off
title CHDMan Menu v1.1


set "chdFileCount=0"
set "otherFileCount=0"
set "compressedFileCount=0"
set "decompressedFileCount=0"
set "deletedFileCount=0"
set "failureCount=0"

set "startTime=%time%"
set "endTime=%time%"

set "deleteSourceFiles=0"


:Welcome
for /r %%i in (*.cue, *.gdi, *.iso) do (
    set /a otherFileCount=fileCount+1
)
for /r %%i in (*.chd) do (
    set /a chdFileCount=chdFileCount+1
)
if %otherFileCount% GTR 0 goto SelectOperation
if %chdFileCount% GTR 0 goto SelectOperation
goto NoSourceFiles


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
cls
echo.
echo %otherFileCount% file(s) found
echo %chdFileCount% .CHD file(s) found
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
echo Delete source file(s) after compression/extraction?
echo.
echo    [1] NO
echo    [2] YES
echo.
echo Note: .bin files will not be destroyed.
echo.
set /p "deleteSourceFiles=input->"
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
for /r %%i in (*.cue,*.gdi, *.iso) do (
    echo.
    echo Progress: %compressedFileCount% of %otherFileCount%
    echo.
    chdman createcd -i "%%i" -o "%%~pi%%~ni.chd"
    set /a compressedFileCount=compressedFileCount+1

    if %deleteSourceFiles%==1 (
        del "%%i"
        set /a deletedFileCount=deletedFileCount+1
    )

    echo Progress: %compressedFileCount% of %otherFileCount%
)
goto Finished


:CUE-GDI-ISO-to-CHD-DVD
cls
set "startTime=%time%"
for /r %%i in (*.cue,*.gdi, *.iso) do (
    echo.
    echo Progress: %compressedFileCount% of %otherFileCount%
    echo.
    chdman createdvd -i "%%i" -o "%%~pi%%~ni.chd" && (
        set /a compressedFileCount=compressedFileCount+1

        if %deleteSourceFiles%==2 (
            del "%%i"
            set /a deletedFileCount=deletedFileCount+1
        )
        echo.
        echo Progress: %compressedFileCount% of %otherFileCount%
        echo.
    ) else (
        set /a failureCount=failureCount+1
    )
)
goto Finished


:CUE-GDI-ISO-to-CHD-DVD-PSP
cls
set "startTime=%time%"
for /r %%i in (*.cue,*.gdi, *.iso) do (
    echo.
    echo Progress: %compressedFileCount% of %otherFileCount%
    echo.
    chdman createdvd -hs 2048 -i "%%i" -o "%%~pi%%~ni.chd" && (
        set /a compressedFileCount=compressedFileCount+1

        if %deleteSourceFiles%==2 (
            del "%%i"
            set /a deletedFileCount=deletedFileCount+1
        )
    ) else (
        set /a failureCount=failureCount+1
    )
)
goto Finished


:Extract-DVD-CHD-to-ISO
cls
set "startTime=%time%"
for /r %%i in (*.chd) do (
    echo.
    echo Progress: %decompressedFileCount% of %chdFileCount%
    echo.
    chdman extractdvd -i "%%i" -o "%%~pi%%~ni.iso" && (
        set /a decompressedFileCount=decompressedFileCount+1

        if %deleteSourceFiles%==2 (
            del "%%i"
            set /a deletedFileCount=deletedFileCount+1
        )
    ) else (
        set /a failureCount=failureCount+1
    )
)
goto Finished


:Extract-CD-CHD-to-CUE
cls
set "startTime=%time%"
for /r %%i in (*.chd) do (
    echo.
    echo Progress: %decompressedFileCount% of %chdFileCount%
    echo.
    chdman extractcd -i "%%i" -o "%%~pi%%~ni.cue" && (
        set /a decompressedFileCount=decompressedFileCount+1
        
        if %deleteSourceFiles%==2 (
            del "%%i"
            set /a deletedFileCount=deletedFileCount+1
        ) else (
            set /a failureCount=failureCount+1
        )
    ) else (
        set /a failureCount=failureCount+1
    )
)
goto Finished


:Extract-CD-CHD-to-GDI
cls
set "startTime=%time%"
for /r %%i in (*.chd) do (
    echo.
    echo Progress: %decompressedFileCount% of %chdFileCount%
    echo.
    chdman extractcd -i "%%i" -o "%%~pi%%~ni.gdi" && (
        if %deleteSourceFiles%==2 (
            del "%%i"
            set /a deletedFileCount=deletedFileCount+1
        )
    ) else (
        set /a failureCount=failureCount+1
    )
)
goto Finished


:Finished
set "endTime=%time%"
echo.
echo Done!
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