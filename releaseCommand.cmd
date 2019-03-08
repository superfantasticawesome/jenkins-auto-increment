::
:: GROM - Generalized Relase Order Management
:: releaseCommand.cmd - A script containing the release command to be called from 'release.cmd'.
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
:: @name        releaseCommand.cmd
:: @author      Gerold 'Geri' Broser
:: @description A script containing the release command to be called from 'release.cmd'.
:: @version     16.06.10
:: @see         https://stackoverflow.com/questions/37701362/auto-increment-release-version-jenkins
:: @see         http://codereview.stackexchange.com/questions/131584/grom-generalized-release-order-management
::
@echo off
setlocal
set prompt=$s$s$g$s
echo( & echo   %~nx0 starts...

if not "%$parent%"=="release.cmd" goto help

:: ---------------------------------------------------------------------------
:: Enter your release command below. You can use the following variables:
::
::   %$currentMajorVersion%
::   %$currentMinorVersion%
::   %$currentPatchVersion%
::   %$currentVersion% ... the above three separated by a '.'
::
::   %$newMajorVersion%
::   %$newMinorVersion%
::   %$newPatchVersion%
::   %$newVersion% ... the above three separated by a '.'
:: ---------------------------------------------------------------------------

:: set $releaseCommand=C:\Octopus\Octo.exe create-release --project APP --version %$newVersion% --packageversion=%$newVersion%
:: Gerard Ryan - Added 'dotnet publish' release command, 03/2019
::
set $releaseCommand="%ProgramFiles%\dotnet\dotnet.exe" publish -c Release /p:Version=%$newVersion% -r win10-x64
:: End modification

:: ---------------------------------------------------------------------------

if "%$runType%"=="releaseRun" goto releaseRun
goto dryRun

:releaseRun
echo on
:: Gerard Ryan - Added project-specfic versioning, saved in the respective project directory, 03/2019
::
cd "%ProgramFiles(x86)%\Jenkins\workspace\%project%\techoAgentCore\techoAgentCore"
:: End modification
%$releaseCommand% 1> nul

@echo off
goto end

:dryRun
echo( & echo   DRY RUN - just displaying the release command(s):
echo( & echo     cd "%ProgramFiles(x86)%\Jenkins\workspace\%project%\techoAgentCore\techoAgentCore"
echo( & echo     %$releaseCommand%
goto end

:help
echo( & echo   This script is NOT meant to be run standalone, but from within '%~p0release.cmd'.
%~p0%release.cmd help
goto end

:end
::echo( & echo   %~nx0 ends.
endlocal
