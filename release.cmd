::
:: GROM - Generalized Release Order Management
:: release.cmd - A script to create a release with a version derived from 'setCurrentVersion.cmd'.
:: Copyright (C) 2016  Gerold 'Geri' Broser
::
:: Added by Gerard Ryan, 03/2019:
:: * Expanded MAJOR.MINOR versioning to include MAJOR.MINOR.PATCH level versioning 
:: * Added a command line switch to specify the project directory
:: * Added project-specfic versioning, saved in the respective project directory
:: * Added a workaround for the missing 'displayVersion' label
:: TODO:
:: * Cleanup/comments
:: * Jenkins integration with command line arguments to increase version
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
:: @project     GROM - Generalized Release Order Management
:: @name        release.cmd
:: @author      Gerold 'Geri' Broser
:: @description A script to create a release with a version derived from 'setCurrentVersion.cmd'.
::
::              NOTE: before using any of the release commands for the first time, you must specify: 
::                - the release command in '...\releaseCommand.cmd'
::                - the current version in '...\setCurrentVersion.cmd'
::              otherwise, the current version will be the default '0.0.0'.
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

if "%1"=="?" goto help else (
if /i "%1"=="h" goto help ) else (
if /i "%1"=="help" goto help ) else (
if "%~1"=="/?" goto help ) else (
if /i "%1"=="/h" goto help ) else (
if /i "%1"=="/help" goto help ) else (
if "%1"=="-?" goto help ) else (
if /i "%1"=="-h" goto help ) else (
if /i "%1"=="--help" goto help )

if /i "%1"=="--dryrun" (
    set $runType=dryRun
    set $projectArgPosition=%2
    shift
) else (
    set $projectArgPosition=%1
    set $runType=releaseRun
)   

if /i "%$projectArgPosition%"=="--project" goto setProject ) else (
if /i "%$projectArgPosition%"=="/p" goto setProject ) else (
if /i "%$projectArgPosition%"=="-p" goto setProject ) else ( goto help )

:setProject
set project=%2
echo   Retrieving project name from the command line...
echo   Project selected: %project%

set $currentVersionFile="%ProgramFiles(x86)%\Jenkins\workspace\%project%\setCurrentVersion.cmd"
set $defaultVersionFile=%~p0setCurrentVersion.cmd
set $releaseCommandFile=%~p0releaseCommand.cmd

if "%3"=="" set $goal=end & goto help else (
if /i "%3"=="current" set $goal=end & goto begin )

set $goal=setVersion

if /i "%3"=="major" set $goal=incMajor_setMinor_keepPatch 
if /i "%3"=="setMajor" set $goal=setMajor_keepMinor_keepPatch 
if /i "%3"=="minor" set $goal=keepMajor_incMinor_setPatch
if /i "%3"=="setMinor" set $goal=keepMajor_setMinor_keepPatch
if /i "%3"=="patch" set $goal=keepMajor_keepMinor_incPatch 
if /i "%3"=="setPatch" set $goal=keepMajor_keepMinor_setPatch

:begin
echo( & echo   Retrieving current version...
if not exist %$currentVersionFile% (
    copy %$defaultVersionFile% %$currentVersionFile% > NUL
)
call %$currentVersionFile%
set $currentVersion=%$currentMajorVersion%.%$currentMinorVersion%.%$currentPatchVersion%
echo   Current version: %$currentVersion%
if errorlevel 1 (
    goto releaseError 
) else (
    goto %$goal%
)

:setVersion
echo( & echo   Setting new version...
for /f "tokens=1,2,3 delims=." %%a in ("%3") do (
    set $newMajorVersion=%%a
    set $newMinorVersion=%%b
    set $newPatchVersion=%%c
)

set $newVersion=%$newMajorVersion%.%$newMinorVersion%.%$newPatchVersion%
echo   New version: %$newVersion%
goto release

:keepMajor_incMinor_keepPatch_0
echo( & echo   Keeping major version at '%$currentMajorVersion%', increasing minor version '%$currentMinorVersion%' by 1, keeping patch version at '%$currentPatchVersion%'...
set /a "$newMinorVersion=$currentMinorVersion+1"
set $newMajorVersion=%$currentMajorVersion%
set $newPatchVersion=%$currentPatchVersion%
set $newVersion=%$newMajorVersion%.%$newMinorVersion%.%$newPatchVersion%
echo   New version: %$newVersion%
goto release

:keepMajor_incMinor_setPatch
if "%4"=="" goto keepMajor_incMinor_keepPatch_0

echo( & echo   Keeping major version at '%$currentMajorVersion%', increasing minor version '%$currentMinorVersion%' by 1, setting patch version to '%4'...
set /a "$newMinorVersion=$currentMinorVersion+1"
set $newMajorVersion=%$currentMajorVersion%
set $newPatchVersion=%4
set $newVersion=%$newMajorVersion%.%$newMinorVersion%.%$newPatchVersion%
echo   New version: %$newVersion%
goto release

:incMajor_setMinor_keepPatch_0
echo( & echo   Increasing major version '%$currentMajorVersion%' by 1, setting minor.patch version to '0.0'...
set /a "$newMajorVersion=$currentMajorVersion+1"
set $newMinorVersion=0
set $newPatchVersion=0
set $newVersion=%$newMajorVersion%.%$newMinorVersion%.%$newPatchVersion%
echo   New version: %$newVersion%
goto release

:incMajor_setMinor_keepPatch
if "%4"=="" goto incMajor_setMinor_keepPatch_0

echo( & echo   Increasing major version '%$currentMajorVersion%' by 1, setting minor version to '%4', keeping patch version at '%$currentPatchVersion%'...
set /a "$newMajorVersion=$currentMajorVersion+1"
set $newMinorVersion=%4
set $newPatchVersion=%$currentPatchVersion%
set $newVersion=%$newMajorVersion%.%$newMinorVersion%.%$newPatchVersion%
echo   New version: %$newVersion%
goto release

:incMajor_setMinor_keepPatch
if "%4"=="" goto incMajor_setMinor_keepPatch_0

echo( & echo   Increasing major version '%$currentMajorVersion%' by 1, setting minor.patch version to '0.0'...
set /a "$newMajorVersion=$currentMajorVersion+1"
set $newMinorVersion=0
set $newPatchVersion=0
set $newVersion=%$newMajorVersion%.%$newMinorVersion%.%$newPatchVersion%
echo   New version: %$newVersion%
goto release

:keepMajor_keepMinor_incPatch_0
echo( & echo   Keeping major.minor version at '%$currentMajorVersion%.%$currentMinorVersion%', increasing patch version '%$currentPatchVersion%' by 1
set $newMajorVersion=%$currentMajorVersion%
set $newMinorVersion=%$currentMinorVersion%
set /a "$newPatchVersion=$currentPatchVersion+1"
set $newVersion=%$newMajorVersion%.%$newMinorVersion%.%$newPatchVersion%
echo   New version: %$newVersion%
goto release

:keepMajor_keepMinor_incPatch
if "%4"=="" goto keepMajor_keepMinor_incPatch_0
set $increment_value=%4
echo( & echo   Keeping major.minor version at '%$currentMajorVersion%.%$currentMinorVersion%', increasing patch version '%$currentPatchVersion%' by %4
set $newMajorVersion=%$currentMajorVersion%
set $newMinorVersion=%$currentMinorVersion%
set /a "$newPatchVersion=$currentPatchVersion+$increment_value"
set $newVersion=%$newMajorVersion%.%$newMinorVersion%.%$newPatchVersion%
echo   New version: %$newVersion%
goto release

:keepMajor_keepMinor_setPatch
if "%4"=="" echo( && echo   %~n0 setPatch ^<patch^> argument missing! && goto help

echo( & echo   Setting patch version to '%4', keeping major.minor version at '%$currentMajorVersion%.%$currentMinorVersion%'...
set $newMajorVersion=%$currentMajorVersion%
set $newMinorVersion=%$currentMinorVersion%
set $newPatchVersion=%4
set $newVersion=%$newMajorVersion%.%$newMinorVersion%.%$newPatchVersion%
echo   New version: %$newVersion%
goto release

:setMajor_keepMinor_keepPatch
if "%4"=="" echo( && echo   %~n0 setMajor ^<major^> argument missing! && goto help

echo( & echo   Setting major version number to '%4', keeping minor.patch version at '%$currentMinorVersion%.%$currentPatchVersion%'...
set $newMajorVersion=%4
set $newMinorVersion=%$currentMinorVersion%
set $newPatchVersion=%$currentPatchVersion%
set $newVersion=%$newMajorVersion%.%$newMinorVersion%.%$newPatchVersion%
echo   New version: %$newVersion%
goto release

:keepMajor_incMinor
echo( & echo   Keeping major version at '%$currentMajorVersion%', increasing minor version '%$currentMinorVersion%' by 1 and keeping patch version '%$currentPatchVersion%'
set $newMajorVersion=%$currentMajorVersion%
set /a "$newMinorVersion=$currentMinorVersion+1"
set $newPatchVersion=%$currentPatchVersion%
set $newVersion=%$newMajorVersion%.%$newMinorVersion%.%$newPatchVersion%
echo   New version: %$newVersion%
goto release

:keepMajor_setMinor_keepPatch
if "%4"=="" echo( && echo   %~n0 setMinor ^<minor^> argument missing! && goto help

echo( & echo   Keeping major version at '%$currentMajorVersion%', setting minor version to '%4' and keeping patch version '%$currentPatchVersion%'
set $newMajorVersion=%$currentMajorVersion%
set $newMinorVersion=%4
set $newPatchVersion=%$currentPatchVersion%
set $newVersion=%$newMajorVersion%.%$newMinorVersion%.%$newPatchVersion%
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
(echo @set $currentPatchVersion=%$newPatchVersion%) >> %$currentVersionFile%
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
:endfail

endlocal
