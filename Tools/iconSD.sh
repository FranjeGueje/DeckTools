#!/bin/bash

##############################################################################################################################################################
# AUTOR: Paco Guerrero <fjgj1@hotmail.com> - FranjeGueje
# LICENSE: GNU General Public License v3.0 (https://github.com/FranjeGueje/DeckTools/blob/master/LICENSE)
# ABOUT: Añade imágenes de nuestros juegos steam YA DESCARGADOS a los directorios COMPATDATA y SHADERCACHE
#        Add images of our ALREADY DOWNLOADED steam games to the COMPATDATA and SHADERCACHE directories
# SALIDAS/EXITs:
#   0: Todo correcto, llegamos al final. All correct, we have reached the end.
#   1: Error, argumentos incorrectos. Wrong args...
#   2: No se ha podido instalar o desinstalar. Can't install/uninstall
#   3: Error. Estás usando uninstall, install o removeicons juntos. Install and uninstall cannot be used together.
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
##       GET ARGUMENTS
#########################################

# Get help (--help)
function showhelp() {
    echo -e "IconSD: set images to your shadercache and compatdata directories\n\
    $(basename "$0") [-v]\t\t\tSet images on the shadercache and compatdata directories\n\
    $(basename "$0") --removeicons [-v]\tDelete all icons on your folders (compatdata and shadercache)\n\
    $(basename "$0") -i [-v]\t\t\tInstall this program to run on boot\n\
    $(basename "$0") -u [-v]\t\t\tUnnstall this program to run on boot\n\

[Options]\n\
    -h|--help\t\t\tThis help.\n\
    --version\t\t\tDisplays the version of the application.\n\
    -v|--verbose\t\tDisplays more detailed output.\n\
    -i|--install\t\tInstall this program to run on boot.\n\
    -u|--uninstall\t\tUninstall this program to run on boot.\n\
    --removeicons\t\tDelete all icons on your folders (compatdata and shadercache)."
}

# To get args
while [ $# -ne 0 ]; do
    case "$1" in
        -h | --help)
            showhelp
            exit 0
        ;;
        --version)
            echo -e "The version of $NOMBRE is $VERSION\n"; exit 0
        ;;
        -v | --verbose)
            VERBOSE=S
        ;;
        -i | --install)
            [ -n "${OPERATION+x}" ] && echo -e "You are using \"install\" option with others incompatible option." && exit 3
            INSTALL=S; OPERATION=S
        ;;
        -u | --uninstall)
            [ -n "${OPERATION+x}" ] && echo -e "You are using \"uninstall\" option with other incompatible option." && exit 3
            UNINSTALL=S; OPERATION=S
        ;;
        --removeicons)
            [ -n "${OPERATION+x}" ] && echo -e "You are using \"removeicons\" option with other incompatible option." && exit 3
            REMOVEICONS=S; OPERATION=S
        ;;
        *)
            echo -ne "Something is wrong... Check the arguments.\n\n"
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
        
        [ "$NAME" != 0 ] && for j in $DIRGRID; do
            # Seek until this deep
            MAXNIVEL=2
            for ((n=1; n <= MAXNIVEL; n++)) ; do
                m=$((n-1))
                IMAGEN=$(find "$j" -mindepth $m -maxdepth $n -type f -iname "*$NAME*ico*" -print -quit)
                [ "$IMAGEN" == "" ] && IMAGEN=$(find "$j" -mindepth $m -maxdepth $n -type f -iname "*$NAME*logo*" -print -quit) || break
                [ "$IMAGEN" == "" ] && IMAGEN=$(find "$j" -mindepth $m -maxdepth $n -type f -iname "*$NAME*hero*" -print -quit) || break
                [ "$IMAGEN" == "" ] && IMAGEN=$(find "$j" -mindepth $m -maxdepth $n -type f  \( -iname \*"$NAME"\*.jpg -o -iname \*"$NAME"\*.png -o -iname \*"$NAME"\*.ico \) -print -quit) || break
            done
        done

        if [ "$IMAGEN" != "" ];then
            echo -ne "$ENTRY""$IMAGEN" > "$i/$NAME_FILE" && [ -n "${VERBOSE+x}" ] && echo -e "[*]$NAME:\t[$(basename "$(dirname "$i")")] Set $IMAGEN on $i/$NAME_FILE"
        else
            [ -n "${VERBOSE+x}" ] && echo -e "[ ]$NAME:\t[$(basename "$(dirname "$i")")] Can't set image on $i"
        fi
    done
}

# Install IconSD on boot
function installIconSD(){
    [ ! -d "$HOME/.config/autostart" ] && mkdir "$HOME/.config/autostart"
    echo -ne "$CONTENT" > "$LINKDEST" && chmod +x "$LINKDEST" && [ -n "${VERBOSE+x}" ] && echo -e "IconSD has been installed on $LINKDEST."
    
    [ -f "$LINKDEST" ] && exit 0
    exit 2
}

# Uninstall IconSD from boot
function uninstallIconSD(){
    [ -f "$LINKDEST" ] && rm -f "$LINKDEST" && [ -n "${VERBOSE+x}" ] && echo -e "IconSD has been uninstalled from $LINKDEST."
    
    [ -f "$LINKDEST" ] && exit 2
    exit 0
}

# Remove the icons from the all folders
function removeIconSD(){
    [ -n "${VERBOSE+x}" ] && echo "Deleting icons on $COMPATDATA"
    [ -d "$COMPATDATA" ] && find "$COMPATDATA" -type f -name .directory -exec rm -f {} \;

    [ -n "${VERBOSE+x}" ] && echo "Deleting icons on $SHADERCACHE"
    [ -d "$SHADERCACHE" ] && find "$SHADERCACHE" -type f -name .directory -exec rm -f {} \;

    for i in $EXTERNAL; do
        [ -n "${VERBOSE+x}" ] && echo "Deleting icons on $i./compatdata/"
        [ -d "$i""compatdata/" ] && find "$i""compatdata/" -type f -name .directory -exec rm -f {} \;
        [ -n "${VERBOSE+x}" ] && echo "Deleting icons on $i./shadercache/"
        [ -d "$i""shadercache/" ] && find "$i""shadercache/" -type f -name .directory -exec rm -f {} \;
    done

    exit 0
}

#########################################
##      MAIN
#########################################
#

[ -n "${INSTALL+x}" ] && installIconSD 
[ -n "${UNINSTALL+x}" ] && uninstallIconSD 
[ -n "${REMOVEICONS+x}" ] && removeIconSD 

# Seek in compatdata of ssd
[ -d "$COMPATDATA" ] && DIR_EXEC="$COMPATDATA/*" && installImages

# Seek in shacercache of ssd
[ -d "$SHADERCACHE" ] && DIR_EXEC="$SHADERCACHE/*" && installImages

# Other disk or SD Card
for i in $EXTERNAL; do
    [ -d "$i""compatdata/" ] && [ "$(ls -A "$i""compatdata/")" ] && DIR_EXEC="$i""compatdata/*" && installImages
    [ -d "$i""shadercache/" ] && [ "$(ls -A "$i""shadercache/")" ] && DIR_EXEC="$i""shadercache/*" && installImages
done

exit 0
