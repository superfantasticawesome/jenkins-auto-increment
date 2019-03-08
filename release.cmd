::
:: GROM - Generalized Relase Order Management
:: release.cmd - A script to create a release with a version derived from 'setCurrentVersion.cmd'.
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
:: @name        release.cmd
:: @author      Gerold 'Geri' Broser
:: @description A script to create a release with a version derived from 'setCurrentVersion.cmd'.
::
::              Specify:
::                - the release command in '...\releaseCommand.cmd'
::                - the current version in '...\setCurrentVersion.cmd'
::              before using one of the release commands for the first time.
::              Otherwise the current version will be the default '0.0'.
::               
::              Run 'release help' for more.
::
:: @version     16.06.10
:: @see         https://stackoverflow.com/questions/37701362/auto-increment-release-version-jenkins
:: @see         http://codereview.stackexchange.com/questions/131584/grom-generalized-release-order-management
::
@echo off
setlocal
set prompt=$s$s$g$s
::echo   %~nx0 starts...

set $currentVersionFile=%~p0setCurrentVersion.cmd
set $releaseCommandFile=%~p0releaseCommand.cmd

if "%1"=="?" goto help else (
if /i "%1"=="h" goto help ) else (
if /i "%1"=="help" goto help ) else (
if "%~1"=="/?" goto help ) else (
if /i "%1"=="/h" goto help ) else (
if /i "%1"=="/help" goto help ) else (
if "%1"=="-?" goto help ) else (
if /i "%1"=="-h" goto help ) else (
if /i "%1"=="--help" goto help )

if /i "%1"=="-dryrun" (
    set $runType=dryRun
    shift
    ) else (
    set $runType=releaseRun
    )   

if "%1"=="" set $goal=end & goto displayVersion else (
if /i "%1"=="current" set $goal=end & goto displayVersion )

set $goal=setVersion
if /i "%1"=="major" set $goal=incMajor_setMinor else (
if /i "%1"=="setMajor" set $goal=setMajor_keepMinor  ) else (
if /i "%1"=="minor" set $goal=keepMajor_incMinor ) else (
if /i "%1"=="setMinor" set $goal=keepMajor_setMinor )


:begin
echo( & echo   Retrieving current version...
call %$currentVersionFile%
set $currentVersion=%$currentMajorVersion%.%$currentMinorVersion%
echo   Current version: %$currentVersion%

goto %$goal%

:setVersion
echo( & echo   Setting new version...
for /f "tokens=1,2 delims=." %%a in ("%1") do (
    set $newMajorVersion=%%a
    set $newMinorVersion=%%b
    )
set $newVersion=%$newMajorVersion%.%$newMinorVersion%
echo   New version: %$newVersion%
goto release

:incMajor_setMinor_0
echo( & echo   Increasing major version number '%$currentMajorVersion%' by 1, setting minor version number to '0'...
set /a "$newMajorVersion=$currentMajorVersion+1"
set $newMinorVersion=0
set $newVersion=%$newMajorVersion%.%$newMinorVersion%
echo   New version: %$newVersion%
goto release

:incMajor_setMinor
if "%2"=="" goto incMajor_setMinor_0

echo( & echo   Increasing major version number '%$currentMajorVersion%' by 1, setting minor version number to '%2'...
set /a "$newMajorVersion=$currentMajorVersion+1"
set $newMinorVersion=%2
set $newVersion=%$newMajorVersion%.%$newMinorVersion%
echo   New version: %$newVersion%
goto release

:setMajor_keepMinor
if "%2"=="" echo( && echo   %~n0 setMajor ^<major^> argument missing! && goto help

echo( & echo   Setting major version number to '%2', keeping minor version number at '%$currentMinorVersion%'...
set $newMajorVersion=%2
set $newMinorVersion=%$currentMinorVersion%
set $newVersion=%$newMajorVersion%.%$newMinorVersion%
echo   New version: %$newVersion%
goto release

:keepMajor_incMinor
echo( & echo   Keeping major version number at '%$currentMajorVersion%', increasing minor version number '%$currentMinorVersion%' by 1
set $newMajorVersion=%$currentMajorVersion%
set /a "$newMinorVersion=$currentMinorVersion+1"
set $newVersion=%$newMajorVersion%.%$newMinorVersion%
echo   New version: %$newVersion%
goto release

:keepMajor_setMinor
if "%2"=="" echo( && echo   %~n0 setMinor ^<minor^> argument missing! && goto help

echo( & echo   Keeping major version number at '%$currentMajorVersion%', setting minor version number to '%2'
set $newMajorVersion=%$currentMajorVersion%
set $newMinorVersion=%2
set $newVersion=%$newMajorVersion%.%$newMinorVersion%
echo   New version: %$newVersion%
goto release

:release
echo( & echo   Creating release %$newVersion%...
echo   Calling %$releaseCommandFile%...
set $parent=release.cmd
call %$releaseCommandFile%
if errorlevel 1 goto releaseError

if "%$runType%"=="dryRun" goto end

echo( & echo   Saving new version '%$newVersion%' in '%$currentVersionFile%'...
(echo @set $currentMajorVersion=%$newMajorVersion%) > %$currentVersionFile%
(echo @set $currentMinorVersion=%$newMinorVersion%) >> %$currentVersionFile%
(echo @set $currentVersion=%$newVersion%) >> %$currentVersionFile%
goto end

:releaseError
echo( & echo   An error occurred. Version remains at '%$currentVersion%'.
goto end

:help
type %~p0releaseHelp.txt
goto end

:end
::echo   %~nx0 ends.
endlocal