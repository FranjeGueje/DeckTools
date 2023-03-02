#!/bin/bash

##############################################################################################################################################################
# AUTOR: Paco Guerrero <fjgj1@hotmail.com> - FranjeGueje
# LICENSE: GNU General Public License v3.0 (https://github.com/FranjeGueje/DeckTools/blob/master/LICENSE)
# ABOUT: Añade imágenes de nuestros juegos steam YA DESCARGADOS a los directorios COMPATDATA y SHADERCACHE
#        Add images of our ALREADY DOWNLOADED steam games to the COMPATDATA and SHADERCACHE directories
# SALIDAS/EXITs:
#   0: Todo correcto, llegamos al final. All correct, we have reached the end.
#   1: Error, argumentos incorrectos.
#   2: Error, no tenemos zenity y queremos abrir el gui.
#   3: No se ha podido instalar o desinstalar
#
##############################################################################################################################################################


#########################################
##      VARIABLES GLOBALES
#########################################
# Where is Steam, compatdata,shadercache, and grid
STEAM="$HOME/.local/share/Steam"
COMPATDATA="$STEAM/steamapps/compatdata"
SHADERCACHE="$STEAM/steamapps/shadercache"
DIRGRID="$STEAM/userdata/??*/config/grid/"

# Have SD Card on standar
EXTERNAL="/run/media/*/steamapps/"

# Icon on Steam Deck
NAME_FILE=.directory
ENTRY="[Desktop Entry]\nIcon="

# Startup content
CONTENT="[Desktop Entry]\n\
Name=IconSD\n\
Exec=\"$(readlink -f "$0")\"\n\
Terminal=false\n\
Type=Application\n"

# Install destination
LINKDEST="$HOME/.config/autostart/iconSD.desktop"

# Other
NOMBRE="IconSD"
VERSION=1.1

#########################################
##       GET ARGUMENTOS
#########################################

# Get help (--help)
function showhelp() {
    echo -e "$(basename "$0") [-h] [-v] [--gui] [-i] [-u]\n\
    [Opciones/Options]\n\
    \t-h|--help\t\tEsta ayuda. This help.\n\
    \t--version\t\tMuestra la versión de la aplicación.// Displays the version of the application.\n\
    \t-v|--verbose\t\tMuestra una salida más detallada.// Displays more detailed output\n\
    \t--gui\t\t\tIniciar modo asistente [WIP].// It'll runing the wizzard [WIP].\n\
    \t-i|--install\t\tInstala el script en el inicio.// Install this program to run on boot.\n\
    \t-u|--uninstall\t\tDesinstala el script.// Uninstall the script."
}

# To get args
while [ $# -ne 0 ]; do
    case "$1" in
        -h | --help)
            # No hacemos nada más, porque showhelp se saldrá del programa
            showhelp
            exit 0
        ;;
        --version)
            echo -e "The version of $NOMBRE is $VERSION\n"; exit 0
        ;;
        -v | --verbose)
            VERBOSE=S
        ;;
        -g |--gui)
            if  zenity --help >/dev/null ;then
                GUI=S
            else
                echo "zenity is not present. Exiting..." && exit 2
            fi
        ;;
        -i | --install)
            [ ! -d "$HOME/.config/autostart" ] && mkdir "$HOME/.config/autostart"
            echo -ne "$CONTENT" > "$LINKDEST" && chmod +x "$LINKDEST" && exit 0
            exit 3
        ;;
        -u | --uninstall)
            [ -f "$LINKDEST" ] && rm -f "$LINKDEST" && exit 0
            exit 3
        ;;
        *)
            echo "Argumento no válido.// Something is wrong..."
            showhelp
            exit 1
        ;;
    esac
    shift
done

#########################################
##       FUNCIONES GLOBALES
#########################################

# SEARCH and Install images
# REQUIRIMENTS:
#   $DIR_EXEC --> the directory to find coincidences
function installImages() {
    for i in $DIR_EXEC ;do
        NAME=$(basename "$i")
        
        if [ "$NAME" != 0 ];then
            for j in $DIRGRID; do

                # Busca imagenes en el primer nivel
                IMAGEN=$(find "$j" -maxdepth 1 -type f -iname "*$NAME*ico*" -print -quit)
                [ "$IMAGEN" == "" ] && IMAGEN=$(find "$j" -maxdepth 1 -type f -iname "*$NAME*logo*" -print -quit)
                [ "$IMAGEN" == "" ] && IMAGEN=$(find "$j" -maxdepth 1 -type f -iname "*$NAME*hero*" -print -quit)
                [ "$IMAGEN" == "" ] && IMAGEN=$(find "$j" -maxdepth 1 -type f  \( -iname \*"$NAME"\*.jpg -o -iname \*"$NAME"\*.png -o -iname \*"$NAME"\*.ico \) -print -quit)
                
                # Busca imagenes en el segundo nivel
                [ "$IMAGEN" == "" ] && IMAGEN=$(find "$j" -mindepth 1 -maxdepth 2 -type f -iname "*$NAME*ico*" -print -quit)
                [ "$IMAGEN" == "" ] && IMAGEN=$(find "$j" -mindepth 1 -maxdepth 2 -type f -iname "*$NAME*logo*" -print -quit)
                [ "$IMAGEN" == "" ] && IMAGEN=$(find "$j" -mindepth 1 -maxdepth 2 -type f -iname "*$NAME*hero*" -print -quit)
                [ "$IMAGEN" == "" ] && IMAGEN=$(find "$j" -mindepth 1 -maxdepth 1 -type f  \( -iname \*"$NAME"\*.jpg -o -iname \*"$NAME"\*.png -o -iname \*"$NAME"\*.ico \) -print -quit)

                if [ "$IMAGEN" != "" ];then
                    echo -ne "$ENTRY""$IMAGEN" > "$i/$NAME_FILE" && [ -n "${VERBOSE+x}" ] && echo -e "[*]$NAME:\t[$(basename "$(dirname "$i")")] Set $IMAGEN on $i/$NAME_FILE"
                else
                    [ -n "${VERBOSE+x}" ] && echo -e "[ ]$NAME:\t[$(basename "$(dirname "$i")")] Can't set image on $i"
                fi
            done
        fi
    done
}

# Wellcome message
function wellCome() {
    [ "$LANG" == "es_ES.UTF-8" ] && TEXTWC="Bienvenido a $NOMBRE.\nVersion: $VERSION.\n\nLicencia: GNU General Public License v3.0" || \
        TEXTWC="Welcome to $NOMBRE.\nVersion: $VERSION.\n\nLicense: GNU General Public License v3.0"
    zenity --timeout 2 --title="$NOMBRE $VERSION" --info --text "$TEXTWC" --width=300 --height=50
}


# Bye message
function bye() {
    [ "$LANG" == "es_ES.UTF-8" ] && TEXTWC="Se han creado todos los iconos.\n Gracias por usar el programa." || \
        TEXTWC="All icons have been created.\nThank you for using this software."
    
    zenity --timeout 2 --title="$NOMBRE $VERSION" --info --text "$TEXTWC" --width=300 --height=50
}

#########################################
##      MAIN
#########################################
#

# Wellcome message
[ -n "${GUI+x}" ] && wellCome

# Seek in compatdata of ssd
[ -d "$COMPATDATA" ] && DIR_EXEC="$COMPATDATA/*" && installImages

# Seek in shacercache of ssd
[ -d "$SHADERCACHE" ] && DIR_EXEC="$SHADERCACHE/*" && installImages

# Other disk or SD Card
for i in $EXTERNAL; do
    [ -d "$i""compatdata/" ] && [ "$(ls -A "$i""compatdata/")" ] && DIR_EXEC="$i""compatdata/*" && installImages
    [ -d "$i""shadercache/" ] && [ "$(ls -A "$i""shadercache/")" ] && DIR_EXEC="$i""shadercache/*" && installImages
done

[ -n "${GUI+x}" ] && bye

exit 0
