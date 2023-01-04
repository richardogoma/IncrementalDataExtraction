@echo off

set cwd=%CD%

SETLOCAL
set algorithm="SHA256"
echo The current working directory is %cwd%; Hashing algorithm is %algorithm% 

if exist %cwd%\Bitcoin* (
    echo Running program for incremental data extraction ...
    pwsh.exe -File "%cwd%\Extract-IncrementalDatav1.2.2.ps1" -algorithm %algorithm% -cwd %cwd%
) else (
    echo Running program for full batch data extraction ...
    pwsh.exe -File "%cwd%\Extract-FullDatav1.2.2.ps1" -algorithm %algorithm% -cwd %cwd%
)

timeout 10
ENDLOCAL