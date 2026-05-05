@echo off
title Lexia - Subir para GitHub
cd /d "%~dp0"
set LOG=%~dp0git-log.txt
echo Iniciando deploy... > "%LOG%"
echo Pasta: %CD% >> "%LOG%"
echo. >> "%LOG%"

REM Configura identidade do git diretamente (sobrescreve se ja existe — sem problema)
echo --- Setando identidade do git --- >> "%LOG%"
git config --global user.email "rafaelfreitassadv@gmail.com" >> "%LOG%" 2>&1
git config --global user.name "Rafael Freitas" >> "%LOG%" 2>&1
git config --global init.defaultBranch main >> "%LOG%" 2>&1

REM Garante .gitignore
(
  echo desktop.ini
  echo Thumbs.db
  echo .DS_Store
  echo git-log.txt
  echo kill-git.bat
) > .gitignore

REM Remove desktop.ini do index se ja foi adicionado
git rm --cached desktop.ini >> "%LOG%" 2>&1
git rm --cached git-log.txt >> "%LOG%" 2>&1

echo. >> "%LOG%"
echo --- git config validacao --- >> "%LOG%"
git config user.name >> "%LOG%" 2>&1
git config user.email >> "%LOG%" 2>&1

echo. >> "%LOG%"
echo --- git add --- >> "%LOG%"
git add . >> "%LOG%" 2>&1

echo. >> "%LOG%"
echo --- git status apos add --- >> "%LOG%"
git status --short >> "%LOG%" 2>&1

echo. >> "%LOG%"
echo --- git commit --- >> "%LOG%"
git commit -m "feat: modulo Publicacoes via DJEN/CNJ + importacao tarefas Astrea + APIs recomendadas" >> "%LOG%" 2>&1

echo. >> "%LOG%"
echo --- git log (ultimo commit) --- >> "%LOG%"
git log -1 --oneline >> "%LOG%" 2>&1

echo. >> "%LOG%"
echo --- git push --- >> "%LOG%"
echo Atencao: pode aparecer popup do GitHub para autenticar. >> "%LOG%"
git push -u origin main >> "%LOG%" 2>&1

echo. >> "%LOG%"
echo === Concluido. Confira em https://rafaelfreitasadv.github.io/lexia/ === >> "%LOG%"

type "%LOG%"
echo.
pause
