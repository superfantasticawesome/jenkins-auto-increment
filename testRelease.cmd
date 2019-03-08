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
echo( & echo   %~nx0 starts...

set $scriptFileToTest=%~p0release.cmd
set $currentVersionBatchFile=%~p0setCurrentVersion.cmd
set $currentVersionBatchFileSave=%~p0setCurrentVersion.cmd.sav

if not exist %$scriptFileToTest% goto notExisting

set $separator=  ----------------------------------------------------------------------------

echo( & echo   Saving live version number file '%$currentVersionBatchFile%' to '%$currentVersionBatchFileSave%'...
copy %$currentVersionBatchFile% %$currentVersionBatchFileSave%

echo( & echo   Creating test version number file '%$currentVersionBatchFile%' with the following content:
(echo @set $currentMajorVersion=0) >  %$currentVersionBatchFile%
(echo @set $currentMinorVersion=0) >> %$currentVersionBatchFile%
(echo @set $currentVersion=0.0) >> %$currentVersionBatchFile%
type %$currentVersionBatchFile%

echo( & echo %$separator% & echo   Test: Display help (8 times) ...
for %%s in ( ? h help "/?" /h /help -h --help ) do (
    echo %$separator%
    echo on
    call %$scriptFileToTest% %%s
    )
@echo off

echo(  & echo   Test: Display current version (2 times)... & echo %$separator% & echo on
call %$scriptFileToTest%
@echo off
echo %$separator% & echo on
call %$scriptFileToTest% current
@echo off

echo( & echo %$separator% & echo   Test: Set version number... & echo %$separator% & echo on
call %$scriptFileToTest% -dryrun 9.9
@echo off

echo( & echo %$separator% & echo   Test: Increase major version number, set minor version number to '0'... & echo %$separator% & echo on
call %$scriptFileToTest% -dryrun major
@echo off

echo( & echo %$separator% & echo   Test: Increase major version number, set minor version number... & echo %$separator% & echo on
call %$scriptFileToTest% -dryrun major 2
@echo off

echo( & echo %$separator% & echo   Test: Set major version number, keep minor version number the same... & echo %$separator% & echo on
call %$scriptFileToTest% -dryrun setmajor 4
@echo off

echo( & echo %$separator% & echo   Test: Increase minor version number... & echo %$separator% & echo on
call %$scriptFileToTest% -dryrun minor
@echo off

echo( & echo %$separator% & echo   Test: Set minor version number... & echo %$separator% & echo on
call %$scriptFileToTest% -dryrun setminor 4
@echo off

goto end

:notExisting
echo( & echo   Script file to be tested ('%scriptFileToTest%') does not exist in '%~p0'!

:end
echo( & echo %$separator% & echo( & echo   Restoring live version number file '%$currentVersionBatchFile%' from '%$currentVersionBatchFileSave%'...
copy %$currentVersionBatchFileSave% %$currentVersionBatchFile%
echo(

echo( & echo   %~nx0 ends.
endlocal