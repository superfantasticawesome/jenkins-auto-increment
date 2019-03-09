::
:: GROM - Generalized Relase Order Management
:: release.cmd - A script to test the various options and commands of 'release.cmd'.
:: Copyright (C) 2016  Gerold 'Geri' Broser
::
:: This program is free software: you can redistribute it and/or modify
:: it under the terms of the GNU General Public License as published by
:: the Free Software Foundation, either version 3 of the License, or
:: (at your option) any later version.
::
:: This program is distributed in the hope that it will be useful,
:: but WITHOUT ANY WARRANTY; without even the implied warranty of
:: MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
:: GNU General Public License for more details.
::
:: You should have received a copy of the GNU General Public License
:: along with this program.  If not, see <http://www.gnu.org/licenses/>.
::
:: @project     GROM - Generalized Relase Order Management
:: @name        testRelease.cmd
:: @author      Gerold 'Geri' Broser
:: @description A script to test the various options and commands of 'release.cmd'.
:: @version     16.06.10
:: @see         https://stackoverflow.com/questions/37701362/auto-increment-release-version-jenkins
:: @see         http://codereview.stackexchange.com/questions/131584/grom-generalized-release-order-management
::
@echo off
cls
setlocal
set prompt=%0$s$g$s

if "%1"=="" (
    echo( & echo   Enter the project argument on the command line, or type 'release help' at the prompt & goto noargs
) else (
    set project=%1
)

echo( & echo   %~nx0 starts...

set $scriptFileToTest=%~p0release.cmd
set $currentVersionBatchFile=%~p0setCurrentVersion.cmd
set $currentVersionBatchFileSave=%~p0setCurrentVersion.cmd.sav

if not exist %$scriptFileToTest% goto notExisting

set $separator=  ----------------------------------------------------------------------------

echo( & echo   Saving live version file '%$currentVersionBatchFile%' to '%$currentVersionBatchFileSave%'...
copy %$currentVersionBatchFile% %$currentVersionBatchFileSave%

echo( & echo   Creating test version file '%$currentVersionBatchFile%' with the following content:
(echo @set $currentMajorVersion=0) >  %$currentVersionBatchFile%
(echo @set $currentMinorVersion=0) >> %$currentVersionBatchFile%
(echo @set $currentPatchVersion=0) >> %$currentVersionBatchFile%
(echo @set $currentVersion=0.0.0) >> %$currentVersionBatchFile%
type %$currentVersionBatchFile%

echo( & echo %$separator% & echo   Test: Display help (2 times) ...
for %%s in ( ? h ) do (
    echo %$separator%
    echo on
    call %$scriptFileToTest% %%s
    )
@echo off

echo(  & echo   Test: Display current version (1 times)... & echo %$separator% & echo on
echo %$separator% & echo on
call %$scriptFileToTest% --dryrun --project %project% current
@echo off

echo( & echo %$separator% & echo   Test: Set version to 9.9.9... & echo %$separator% & echo on
call %$scriptFileToTest% --dryrun --project %project% 9.9.9
@echo off

echo( & echo %$separator% & echo   Test: Increase major version by 1, set minor.patch versions to '0.0'... & echo %$separator% & echo on
call %$scriptFileToTest% --dryrun --project %project% major
@echo off

echo( & echo %$separator% & echo   Test: Increase major version by 1, set minor version to 2, keep patch version & echo %$separator% & echo on
call %$scriptFileToTest% --dryrun --project %project% major 2
@echo off

echo( & echo %$separator% & echo   Test: Set major version to 6, keep minor.patch versions.. & echo %$separator% & echo on
call %$scriptFileToTest% --dryrun --project %project% setmajor 6
@echo off

echo( & echo %$separator% & echo   Test: Increase minor version by 1, keep major/patch versions... & echo %$separator% & echo on
call %$scriptFileToTest% --dryrun --project %project% minor
@echo off

echo( & echo %$separator% & echo   Test: Set minor version to 4, keep major/patch versions... & echo %$separator% & echo on
call %$scriptFileToTest% --dryrun --project %project% setMinor 4
@echo off

echo( & echo %$separator% & echo   Test: Increase patch version by 2, keep major.patch versions... & echo %$separator% & echo on
call %$scriptFileToTest% --dryrun --project %project% patch 2
@echo off

echo( & echo %$separator% & echo   Test: Set patch version to 4, keep major.minor versions... & echo %$separator% & echo on
call %$scriptFileToTest% --dryrun --project %project% setPatch 4
@echo off

goto end

:notExisting
echo( & echo   Script file to be tested ('%scriptFileToTest%') does not exist in '%~p0'!

:end
echo( & echo %$separator% & echo( & echo   Restoring live version file '%$currentVersionBatchFile%' from '%$currentVersionBatchFileSave%'...
copy %$currentVersionBatchFileSave% %$currentVersionBatchFile%
echo(

:noargs
echo( & echo   %~nx0 ends.
endlocal
