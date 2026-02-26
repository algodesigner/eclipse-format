@echo off
REM Eclipse Formatter CLI - Windows Batch Wrapper
REM This script helps Windows users run the Eclipse Formatter CLI

setlocal enabledelayedexpansion

REM Set colours (Windows 10+)
if not defined NO_COLOR (
    for /F %%a in ('echo prompt $E^| cmd') do set "ESC=%%a"
    set "RED=%ESC%[31m"
    set "GREEN=%ESC%[32m"
    set "YELLOW=%ESC%[33m"
    set "BLUE=%ESC%[34m"
    set "NC=%ESC%[0m"
)

set "VERSION=0.1"
set "SCRIPT_NAME=eclipse-format"
set "JAR_NAME=eclipse-format.jar"

REM Common JAR locations
set "LOCATIONS[0]=%~dp0%JAR_NAME%"
set "LOCATIONS[1]=%~dp0build\libs\%JAR_NAME%"
set "LOCATIONS[2]=%USERPROFILE%\.local\bin\%JAR_NAME%"
set "LOCATIONS[3]=%USERPROFILE%\bin\%JAR_NAME%"
set "LOCATIONS[4]=%PROGRAMFILES%\Eclipse Formatter\%JAR_NAME%"
set "LOCATIONS[5]=.\%JAR_NAME%"
set "LOCATIONS[6]=.\build\libs\%JAR_NAME%"

:print_help
if "%1"=="--help" goto help
if "%1"=="-h" goto help
if "%1"=="/?" goto help

:check_args
if "%1"=="--version" goto version
if "%1"=="--find-jar" goto find_jar
if "%1"=="--install-info" goto install_info
if "%1"=="--jar-path" goto jar_path_arg

:check_java
where java >nul 2>nul
if errorlevel 1 (
    echo %RED%Error: Java is not installed or not in PATH%NC%
    echo.
    echo Please install Java 15 or higher:
    echo   • Download from https://adoptium.net/
    echo   • Or use Chocolatey: choco install temurin
    echo.
    pause
    exit /b 1
)

REM Check Java version (simplified check)
for /f "tokens=3" %%i in ('java -version 2^>^&1 ^| findstr /i "version"') do (
    set "JAVA_VERSION=%%i"
    set "JAVA_VERSION=!JAVA_VERSION:"=!"
    for /f "tokens=1,2 delims=." %%a in ("!JAVA_VERSION!") do (
        set "MAJOR=%%a"
        set "MINOR=%%b"
    )
)

if "!MAJOR!" LSS "15" (
    echo %YELLOW%Warning: Java version !MAJOR!.!MINOR! detected%NC%
    echo Java 15 or higher is recommended.
    echo.
    set /p CONTINUE=Continue anyway? (y/N): 
    if /i not "!CONTINUE!"=="y" (
        exit /b 1
    )
)

:find_jar
REM Check environment variable first
if not "%ECLIPSE_FORMATTER_JAR%"=="" (
    if exist "%ECLIPSE_FORMATTER_JAR%" (
        set "JAR_FILE=%ECLIPSE_FORMATTER_JAR%"
        goto run_jar
    )
)

REM Check command line for --jar-path
set "args=%*"
set "jar_path="
for %%i in (%args%) do (
    if "!prev!"=="--jar-path" (
        set "jar_path=%%i"
        set "jar_path=!jar_path:"=!"
    )
    set "prev=%%i"
)

if not "!jar_path!"=="" (
    if exist "!jar_path!" (
        set "JAR_FILE=!jar_path!"
        goto run_jar
    ) else (
        echo %RED%Error: JAR file not found: !jar_path!%NC%
        exit /b 1
    )
)

REM Search common locations
echo %YELLOW%Searching for JAR file...%NC%
for /l %%i in (0,1,6) do (
    if defined LOCATIONS[%%i] (
        set "location=!LOCATIONS[%%i]!"
        if exist "!location!" (
            set "JAR_FILE=!location!"
            echo %GREEN%Found: !location!%NC%
            goto run_jar
        )
    )
)

echo %RED%Error: eclipse-format.jar not found%NC%
echo.
echo Please specify the JAR file using one of these methods:
echo 1. Set environment variable:
echo    set ECLIPSE_FORMATTER_JAR=C:\path\to\eclipse-format.jar
echo.
echo 2. Use --jar-path option:
echo    eclipse-format.bat --jar-path C:\path\to\jar [options]
echo.
echo 3. Build the project:
echo    gradlew.bat shadowJar
echo.
echo 4. Search for existing JAR files:
echo    eclipse-format.bat --find-jar
echo.
pause
exit /b 1

:run_jar
REM Remove --jar-path argument if present
set "clean_args="
set "skip_next="
for %%i in (%*) do (
    if "%%i"=="--jar-path" (
        set "skip_next=1"
    ) else if defined skip_next (
        set "skip_next="
    ) else (
        set "clean_args=!clean_args! %%i"
    )
)

if "!clean_args!"=="" (
    java -jar "!JAR_FILE!" --help
) else (
    java -jar "!JAR_FILE!" !clean_args!
)
exit /b %errorlevel%

:help
echo %BLUE%Eclipse Formatter CLI Wrapper%NC%
echo %GREEN%Version: %VERSION%%NC%
echo.
echo This wrapper script helps you run the Eclipse Formatter CLI tool on Windows.
echo.
echo Usage:
echo   %SCRIPT_NAME% [options] ^<file^|directory^>
echo   %SCRIPT_NAME% --jar-path C:\path\to\jar [options] ^<file^|directory^>
echo.
echo Options:
echo   --help, -h              Show this help message
echo   --version               Show version information
echo   --jar-path ^<path^>       Specify the JAR file path explicitly
echo   --find-jar              Search for JAR files and show locations
echo   --install-info          Show installation information
echo.
echo Examples:
echo   %SCRIPT_NAME% MyClass.java
echo   %SCRIPT_NAME% -r src\
echo   %SCRIPT_NAME% --jar-path C:\tools\eclipse-format.jar -v src\
echo.
pause
exit /b 0

:version
echo Eclipse Formatter CLI Wrapper v%VERSION%
echo Project: https://github.com/algodesigner/eclipse-format
pause
exit /b 0

:find_jar_menu
echo %YELLOW%Searching for Eclipse Formatter JAR files...%NC%
echo.
set "found=0"
for /l %%i in (0,1,6) do (
    if defined LOCATIONS[%%i] (
        set "location=!LOCATIONS[%%i]!"
        if exist "!location!" (
            echo %GREEN%Found: !location!%NC%
            for /f %%s in ('dir "!location!" ^| findstr /c:"!location!"') do (
                echo    Size: %%s
            )
            set /a found+=1
        )
    )
)
echo.
if %found%==0 (
    echo %RED%No JAR files found%NC%
    echo.
    echo You need to build the project first:
    echo   gradlew.bat shadowJar
    echo Or download a pre-built JAR from the releases page.
) else (
    echo %GREEN%Found %found% JAR file(s)%NC%
)
pause
exit /b 0

:install_info
echo %BLUE%Eclipse Formatter CLI Installation Information%NC%
echo.
REM Check if Java is installed
where java >nul 2>nul
if errorlevel 1 (
    echo %RED%Java: Not installed%NC%
) else (
    for /f "tokens=3" %%i in ('java -version 2^>^&1 ^| findstr /i "version"') do (
        set "ver=%%i"
        set "ver=!ver:"=!"
        echo %GREEN%Java: !ver!%NC%
    )
)
echo.
echo %YELLOW%Installation Methods:%NC%
echo 1. %GREEN%Using gradlew%NC%
echo    gradlew.bat shadowJar
echo    copy build\libs\eclipse-format.jar "%%USERPROFILE%%\bin\"
echo.
echo 2. %GREEN%Manual wrapper creation%NC%
echo    Create eclipse-format.bat with:
echo    @echo off
echo    java -jar "%%~dp0eclipse-format.jar" %%*
echo.
echo 3. %GREEN%Add to PATH%NC%
echo    Add the directory containing eclipse-format.bat to your PATH
echo.
echo %YELLOW%Current JAR Search Locations:%NC%
for /l %%i in (0,1,6) do (
    if defined LOCATIONS[%%i] (
        set "location=!LOCATIONS[%%i]!"
        if exist "!location!" (
            echo   %GREEN%✓ !location!%NC%
        ) else (
            echo   %RED%✗ !location!%NC%
        )
    )
)
pause
exit /b 0

:jar_path_arg
echo %RED%Error: --jar-path requires a file path%NC%
echo Usage: %SCRIPT_NAME% --jar-path C:\path\to\jar [options]
pause
exit /b 1