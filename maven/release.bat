@echo off

REM Check parameter number
IF "%1"=="" GOTO MISSING_PARAMETERS
IF "%2"=="" GOTO MISSING_PARAMETERS
IF "%3"=="" GOTO MISSING_PARAMETERS

SET DIR=%1
SET RELEASE_VERSION=%2
SET DEV_VERSION=%3

cd %DIR%

REM Delete old temporary release branch
git branch -D "tmp/Release%RELEASE_VERSION%" >nul 2>&1

REM Check for clean repo
for /f "delims=" %%i in ('git status -s ^| find /v /c ""') do set UNCOMMITTED_CHANGE_COUNT=%%i
if %UNCOMMITTED_CHANGE_COUNT% NEQ 0 goto REPO_NOT_CLEAN

REM Remember current branch
for /f "delims=" %%i in ('git rev-parse --abbrev-ref HEAD') do set BRANCH=%%i

echo Operating on branch: %BRANCH%
echo Release version:     %RELEASE_VERSION%
echo Development version: %DEV_VERSION%

timeout 5

@echo on
git checkout -b tmp/Release%RELEASE_VERSION% || goto COMMAND_ERROR
call mvn org.eclipse.tycho:tycho-versions-plugin:1.1.0-SNAPSHOT:update-pom -Dtycho.mode=maven -Ptycho-snapshots
if %errorlevel% NEQ 0 goto COMMAND_ERROR
@echo on
call mvn org.eclipse.tycho:tycho-versions-plugin:1.1.0-SNAPSHOT::set-version -Dtycho.mode=maven -DupdateVersionRangeMatchingBounds=true -DnewVersion=%RELEASE_VERSION% -Ptycho-snapshots
if %errorlevel% NEQ 0 goto COMMAND_ERROR
@echo on
git commit -am "[Release Process] Set release version to %RELEASE_VERSION%" || goto COMMAND_ERROR
call mvn clean verify
if %errorlevel% NEQ 0 goto COMMAND_ERROR
@echo on
git tag "releases/%RELEASE_VERSION%" || goto COMMAND_ERROR
call mvn org.eclipse.tycho:tycho-versions-plugin:1.1.0-SNAPSHOT::set-version -Dtycho.mode=maven -DupdateVersionRangeMatchingBounds=true -DnewVersion=%DEV_VERSION% -Ptycho-snapshots
if %errorlevel% NEQ 0 goto COMMAND_ERROR
@echo on
git commit -am "[Release Process] Set development version to %DEV_VERSION%" || goto COMMAND_ERROR
call mvn clean verify
if %errorlevel% NEQ 0 goto COMMAND_ERROR
@echo on
git checkout %BRANCH% || goto COMMAND_ERROR
git merge "tmp/Release%RELEASE_VERSION%" || goto COMMAND_ERROR
git branch -d "tmp/Release%RELEASE_VERSION%" || goto COMMAND_ERROR
git clean -f || goto COMMAND_ERROR
@echo off

echo Changes have not been pushed or deployed yet but only have been verified.
echo.  
echo In order to push the changes use
echo  * git push
echo  * git push --tags
echo.
echo To deploy manually use mvn clean deploy

exit /b 0

:MISSING_PARAMETERS
@echo off
echo Not enough arguments given. We need the directory, release and next development version number.
exit /b 1

:REPO_NOT_CLEAN
@echo off
echo The repository contains uncommitted changes. Commit them before starting the release process.
exit /b 2

:COMMAND_ERROR
@echo off
timeout 5
echo An error occurred during the release processing (see above)
exit /b 3