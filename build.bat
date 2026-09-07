@echo off
setlocal EnableExtensions DisableDelayedExpansion
pushd "%~dp0"
if errorlevel 1 exit /b 1

where xelatex >nul 2>&1
if errorlevel 1 (
    echo Missing dependency: xelatex. Install TeX Live and reopen your terminal. 1>&2
    goto failed
)
where biber >nul 2>&1
if errorlevel 1 (
    echo Missing dependency: biber. Install TeX Live and reopen your terminal. 1>&2
    goto failed
)

if not exist "build\" mkdir "build"
if not exist "build\" goto failed
if not exist "output\pdf\" mkdir "output\pdf"
if not exist "output\pdf\" goto failed
if not exist "references.bib" (
    echo Missing file: references.bib 1>&2
    goto failed
)

set "entry=\input{main.tex}"
set "has_references=0"
findstr /r /c:"^[	 ]*@[a-zA-Z][a-zA-Z]*[	 ]*[{(]" "references.bib" >nul
if errorlevel 2 goto failed
if not errorlevel 1 (
    set "entry=\def\TemplateHasReferences{1}\input{main.tex}"
    set "has_references=1"
)

call :latex
if errorlevel 1 goto failed
if "%has_references%"=="1" (
    call biber --input-directory=build --output-directory=build main
    if errorlevel 1 goto failed
)
call :latex
if errorlevel 1 goto failed
call :latex
if errorlevel 1 goto failed

copy /y "build\main.pdf" "output\pdf\docs-cs-project-template.pdf" >nul
if errorlevel 1 goto failed
echo Built output\pdf\docs-cs-project-template.pdf
popd
exit /b 0

:latex
call xelatex -interaction=nonstopmode -halt-on-error -file-line-error -output-directory=build -jobname=main "%entry%"
exit /b %errorlevel%

:failed
echo Build failed. Review the messages above and build\main.log if available. 1>&2
popd
exit /b 1
