#!/bin/bash

##############################################################################################################################################################
# AUTOR: Paco Guerrero <fjgj1@hotmail.com> - FranjeGueje
# LICENSE: GNU General Public License v3.0 (https://github.com/FranjeGueje/DeckTools/blob/master/LICENSE)
# ABOUT: Añade imágenes de nuestros juegos steam YA DESCARGADOS a los directorios COMPATDATA y SHADERCACHE
#        Add images of our ALREADY DOWNLOADED steam games to the COMPATDATA and SHADERCACHE directories
# SALIDAS/EXITs:
#   0: Todo correcto, llegamos al final. All correct, we have reached the end.
#
##############################################################################################################################################################

#########################################
##      VARIABLES GLOBALES
#########################################
# Where is Steam, compatdata,shadercache, and grid
STEAM="$HOME/.local/share/Steam"
COMPATDATA="$STEAM/steamapps/compatdata"
SHADERCACHE="$STEAM/steamapps/shadercache"
DIRGRID="$STEAM/userdata/*/config/grid/"

# Have SD Card on standar
EXTERNAL="/run/media/*/steamapps/"

# Icon on Steam Deck
NAME_FILE=.directory
ENTRY="[Desktop Entry]\nIcon="

# Other
NOMBRE="IconSD"
VERSION=1.0

# SEARCH and Install images
# REQUIRIMENTS:
#   $DIR_EXEC --> the directory to find coincidences
function installImages() {
    for i in $DIR_EXEC ;do
        NAME=$(basename "$i")

        [ "$NAME" != 0 ] && for j in $DIRGRID; do
            
            # Busca imagenes en el primer nivel
            IMAGEN=$(find "$j" -maxdepth 1 -type f -iname "*$NAME*ico*" -print -quit)
            [ "$IMAGEN" == "" ] && IMAGEN=$(find "$j" -maxdepth 1 -type f -iname "*$NAME*logo*" -print -quit)
            [ "$IMAGEN" == "" ] && IMAGEN=$(find "$j" -maxdepth 1 -type f -iname "*$NAME*hero*" -print -quit)
            [ "$IMAGEN" == "" ] && IMAGEN=$(find "$j" -maxdepth 1 -type f  \( -iname \*"$NAME"\*.jpg -o -iname \*"$NAME"\*.png -o -iname \*"$NAME"\*.ico \) -print -quit)

            # Busca imagenes en el segundo nivel
            IMAGEN=$(find "$j" -maxdepth 2 -type f -iname "*$NAME*ico*" -print -quit)
            [ "$IMAGEN" == "" ] && IMAGEN=$(find "$j" -maxdepth 2 -type f -iname "*$NAME*logo*" -print -quit)
            [ "$IMAGEN" == "" ] && IMAGEN=$(find "$j" -maxdepth 2 -type f -iname "*$NAME*hero*" -print -quit)
            [ "$IMAGEN" == "" ] && IMAGEN=$(find "$j" -maxdepth 1 -type f  \( -iname \*"$NAME"\*.jpg -o -iname \*"$NAME"\*.png -o -iname \*"$NAME"\*.ico \) -print -quit)

            if [ "$IMAGEN" != "" ];then
                echo -ne "$ENTRY""$IMAGEN" > "$i/$NAME_FILE"
            fi
        done
    done
}


# Wellcome message
function wellCome() {
    if  zenity --help >/dev/null ;then
        [ "$LANG" == "es_ES.UTF-8" ] && TEXTWC="Bienvenido a $NOMBRE.\nVersion: $VERSION.\n\nLicencia: GNU General Public License v3.0" || \
                TEXTWC="Welcome to $NOMBRE.\nVersion: $VERSION.\n\nLicense: GNU General Public License v3.0"
        zenity --timeout 2 --title="$NOMBRE $VERSION" --info --text "$TEXTWC" --width=300 --height=50
    fi
}


# Bye message
function bye() {
    if  zenity --help >/dev/null ;then
        [ "$LANG" == "es_ES.UTF-8" ] && TEXTWC="Se han creado todos los iconos.\n Gracias por usar el programa." || \
                TEXTWC="All icons have been created.\nThank you for using this software."
        zenity --timeout 2 --title="$NOMBRE $VERSION" --info --text "$TEXTWC" --width=300 --height=50
    fi
}

#########################################
##      MAIN
#########################################
#

# Wellcome message
wellCome

# Seek in compatdata of ssd
[ -d "$COMPATDATA" ] && DIR_EXEC="$COMPATDATA/*" && installImages

# Seek in shacercache of ssd
[ -d "$SHADERCACHE" ] && DIR_EXEC="$SHADERCACHE/*" && installImages

# Other disk or SD Card
for i in $EXTERNAL; do
    [ -d "$i""compatdata/" ] && [ "$(ls -A "$i""compatdata/")" ] && DIR_EXEC="$i""compatdata/*" && installImages
    [ -d "$i""shadercache/" ] && [ "$(ls -A "$i""shadercache/")" ] && DIR_EXEC="$i""shadercache/*" && installImages
done

bye

exit 0
