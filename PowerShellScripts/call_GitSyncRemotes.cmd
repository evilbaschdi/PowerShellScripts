echo off
set arg1=%1

set Remote1Name = "origin"
set Remote1Path = "https://github.com/evilbaschdi/"
set Remote2Name = "vsts"
set Remote2Path = "https://evilbaschdi.visualstudio.com/Main/_git/"

cd %1

    git fetch %Remote1Name% --tags
    git fetch %Remote2Name% --tags
    git push %Remote1Name% --all
    git push %Remote1Name% --tags
    git push %Remote2Name% --all
    git push %Remote2Name% --tags



