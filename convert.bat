@echo off
set FOLDER=%~d0%~p0
set FFMPEG_BIN=bin\ffmpeg.exe
set INPUT_FILE=%1
set OUT_PUT_TYPE=video
set SIZE=640x360
set FFMPEG_ARGS=-b:v 1500k -b:a 128k -s %SIZE%


:: init window
REM chcp 65001
title html5 video/audio converter
color 37
REM mode con cols=80 lines=25

:: display info
echo.
echo ===============================================================================
echo.
echo                           html5 video/audio converter
echo                         fisker Cheung lionkay@gmail.com
echo.
echo ===============================================================================

:: check drag
IF "%INPUT_FILE%"=="" (
  echo.
  echo.
  echo.
  echo  ERROR:
  echo       please DRAG video/audio file and DROP in this file
  echo       exit in 5 seconds ...
  ping 127.0.0.1 -n 5 > nul
  exit
)

:: chose output type
REM echo.
REM echo output file type:
REM echo       [1] video (default)
REM echo       [2] audio (not supported yet)
REM set /p choice="input your choice and press ENTER:"
REM IF "%choice%"=="2"(
REM   set OUT_PUT_TYPE=video
REM )
REM ffmpeg -i input.mp3 -acodec aac -ab 128 output.aac

:: chose output type
set OUTPUT_FILES_MP4=true
choice /T 10 /C YN /D Y /M "generate MP4 file?"
IF "%ERRORLEVEL%"=="2" (
  set OUTPUT_FILES_MP4=false
)

set OUTPUT_FILES_WEBM=true
choice /T 10 /C YN /D Y /M "generate WEBM file?"
IF "%ERRORLEVEL%"=="2" (
  set OUTPUT_FILES_WEBM=false
)

set OUTPUT_FILES_OGV=true
choice /T 10 /C YN /D Y /M "generate OGV file?"
IF "%ERRORLEVEL%"=="2" (
  set OUTPUT_FILES_OGV=false
)

set OUTPUT_FILES_POSTER=true
choice /T 10 /C YN /D Y /M "generate POSTER image file?"
IF "%ERRORLEVEL%"=="2" (
  set OUTPUT_FILES_POSTER=false
)

set OUTPUT_FILES_HTML=true
choice /T 10 /C YN /D Y /M "generate HTML file?"
IF "%ERRORLEVEL%"=="2" (
  set OUTPUT_FILES_HTML=false
)

:: generate files
REM mp4  (H.264 / ACC)
IF "%OUTPUT_FILES_MP4%"=="true" (
  "%FOLDER%%FFMPEG_BIN%" -i "%INPUT_FILE%" %FFMPEG_ARGS% -vcodec libx264 "%INPUT_FILE%.mp4"
)

REM webm (VP8 / Vorbis)
IF "%OUTPUT_FILES_WEBM%"=="true" (
  "%FOLDER%%FFMPEG_BIN%" -i "%INPUT_FILE%" %FFMPEG_ARGS% -vcodec libvpx -acodec libvorbis -f webm "%INPUT_FILE%.webm"
)

REM ogv  (Theora / Vorbis)
IF "%OUTPUT_FILES_OGV%"=="true" (
  "%FOLDER%%FFMPEG_BIN%" -i "%INPUT_FILE%" %FFMPEG_ARGS% -vcodec libtheora -acodec libvorbis "%INPUT_FILE%.ogv"
)

REM jpeg (screenshot at 10 seconds)
IF "%OUTPUT_FILES_POSTER%"=="true" (
  "%FOLDER%%FFMPEG_BIN%" -i "%INPUT_FILE%" -ss 00:10 -vframes 1 -r 1 -s %SIZE% -f image2 "%INPUT_FILE%.jpg"
)

REM html
IF "%OUTPUT_FILES_HTML%"=="true" (
  echo ^<!DOCTYPE html^> > "%INPUT_FILE%.html"
  echo ^<html^> >> "%INPUT_FILE%.html"
  echo ^<head^> >> "%INPUT_FILE%.html"
  echo  ^<title^>%~nx1^</title^> >> "%INPUT_FILE%.html"
  echo ^</head^> >> "%INPUT_FILE%.html"
  echo ^<body^> >> "%INPUT_FILE%.html"
  >>"%INPUT_FILE%.html" set /p="<video " <nul
  IF exist "%INPUT_FILE%.jpg" (
    >>"%INPUT_FILE%.html" set /p="poster="%~nx1.jpg" " <nul
  )
  >>"%INPUT_FILE%.html" set /p="autoplay controls preload loop playsinline webkit-playsinline" <nul
  echo ^> >> "%INPUT_FILE%.html"
  IF exist "%INPUT_FILE%.mp4" (
    echo   ^<source src="%~nx1.mp4" type="video/mp4; codecs=&quot;avc1.42E01E, mp4a.40.2&quot;"^> >> "%INPUT_FILE%.html"
  )
  IF exist "%INPUT_FILE%.ogv" (
    echo   ^<source src="%~nx1.ogv" type="video/ogg; codecs=&quot;theora, vorbis&quot;"^> >> "%INPUT_FILE%.html"
  )
  IF exist "%INPUT_FILE%.webm" (
    echo   ^<source src="%~nx1.webm" type="video/webm; codecs=&quot;vp8.0, vorbis&quot;"^> >> "%INPUT_FILE%.html"
  )
  echo ^</video^> >> "%INPUT_FILE%.html"
  echo ^<p^>html5 video/audio converter by fisker Cheung^</p^> >> "%INPUT_FILE%.html"
  echo ^</body^> >> "%INPUT_FILE%.html"
  echo ^</html^> >> "%INPUT_FILE%.html"
  "%INPUT_FILE%.html"
)

echo ==========================================================================done.
pause
