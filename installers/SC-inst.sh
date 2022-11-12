#!/bin/bash

##############################################################################################################################################################
# AUTOR: Paco Guerrero <fjgj1@hotmail.com> - FranjeGueje
# LICENSE: GNU General Public License v3.0 (https://github.com/FranjeGueje/DeckTools/blob/master/LICENSE)
# ABOUT: instala Steamapps Cleaner
# REQUISITOS:
# SALIDAS:
#   0: Todo correcto, llegamos al final.
#   1: Si hemos pulsado el botón de "Salir" a mitad.
#   2: Error al guardar.
##############################################################################################################################################################

#########################################
##      MAIN
#########################################

DIRECT=$(zenity --file-selection \
    --title="Steaapps Cleaner Installer" \
    --width=1000 --height=300 \
    --text="Selecciona el directorio donde quieres que se instale Steamapps Cleaner:" \
    --directory)

ans=$?
if [ ! $ans -eq 0 ]; then
    exit 1
fi

cd "$DIRECT" || exit 2
wget https://raw.githubusercontent.com/FranjeGueje/DeckTools/master/Tools/steamappsCleaner.sh -O steamappsCleaner.sh && chmod +x steamappsCleaner.sh

zenity --question --width=300 --height=100 --ok-label="Si" --cancel-label="No" \
    --text="Instalado con exito.\nQuieres agregarlo a Steam?"
ans=$?
if [ ! $ans -eq 0 ]; then
    exit 0
fi

encodedUrl="steam://addnonsteamgame/$(python3 -c "import urllib.parse;print(urllib.parse.quote(\"$DIRECT/steamappsCleaner.sh\", safe=''))")"
touch /tmp/addnonsteamgamefile
xdg-open $encodedUrl

ext 0
