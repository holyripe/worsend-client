@rem
@rem Gradle startup script for Windows
@rem
@if "%DEBUG%"=="" @echo off
if "%OS%"=="Windows_NT" setlocal

set DIRNAME=%~dp0
if "%DIRNAME%"=="" set DIRNAME=.
set APP_BASE_NAME=%~n0
set APP_HOME=%DIRNAME%

set DEFAULT_JVM_OPTS="-Xmx64m" "-Xms64m"

if defined JAVA_HOME goto findJavaFromJavaHome

set JAVA_EXE=java.exe
%JAVA_EXE% -version >NUL 2>&1
if "%ERRORLEVEL%" == "0" goto execute

echo ERROR: JAVA_HOME is not set and no 'java' command could be found in your PATH. 1>&2
goto fail

:findJavaFromJavaHome
set JAVA_HOME=%JAVA_HOME:"=%
set JAVA_EXE=%JAVA_HOME%/bin/java.exe
if exist "%JAVA_EXE%" goto execute
echo ERROR: JAVA_HOME is set to an invalid directory: %JAVA_HOME% 1>&2
goto fail

:execute
set CLASSPATH=%APP_HOME%\gradle\wrapper\gradle-wrapper.jar

if not exist "%CLASSPATH%" (
    echo. 1>&2
    echo ERROR: gradle-wrapper.jar was not found at: %CLASSPATH% 1>&2
    echo. 1>&2
    echo This is a binary Gradle generates itself, not source code - it can't 1>&2
    echo be shipped as text. FIX: install Gradle from https://gradle.org/install/ 1>&2
    echo then run "gradle wrapper" once in this folder to generate it, OR just 1>&2
    echo run "gradle" commands directly ^(e.g. "gradle build"^) instead of gradlew.bat. 1>&2
    echo. 1>&2
    goto fail
)

"%JAVA_EXE%" %DEFAULT_JVM_OPTS% %JAVA_OPTS% %GRADLE_OPTS% "-Dorg.gradle.appname=%APP_BASE_NAME%" -classpath "%CLASSPATH%" org.gradle.wrapper.GradleWrapperMain %*

if "%ERRORLEVEL%"=="0" goto mainEnd

:fail
exit /b 1

:mainEnd
if "%OS%"=="Windows_NT" endlocal
