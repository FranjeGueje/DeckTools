#!/bin/bash

##############################################################################################################################################################
# AUTOR: Paco Guerrero <fjgj1@hotmail.com> - FranjeGueje
# LICENSE: GNU General Public License v3.0 (https://github.com/FranjeGueje/DeckTools/blob/master/LICENSE)
# ABOUT: Busca compatdata y shadercache en los dispositivos mostrando los nombres de los que se puedan utilizar y muesta como "Desconocido" los huérfanos.
#           Perfecto para eliminar estos objetos "perdidos".
#        Search compatdata and shadercache on the devices showing the names of the usable ones and show as "Unknown" the orphans.
#           Perfect for removing these "missing" objects.
# REQUIREMENTS: No requisites
# SALIDAS/EXITs:
#   0: Todo correcto, llegamos al final. All correct, we have reached the end.
#   1: Si hemos pulsado el botón de "Salir" a mitad. If we have pressed the "Exit" button in the middle.
#   2: Si salimos cancelando la eliminación. If we exit by cancelling the deletion.
#   33: Error interno, SteamID not found.
#   88: No encuentra la ruta de Steam. Can't find the Steam path.
#   127: Salimos porque no se ha encontrao el software zenity. 127: We exit because the zenity software has not been found.
#
##############################################################################################################################################################

#########################################
##      VARIABLES GLOBALES
#########################################
# Versión de la aplicación
VERSION="3.0.1"
# Nombre de la aplicación
NOMBRE="Steamapps Cleaner"
# Ruta de Steam principal, instalación local
RUTASTEAM="$HOME/.steam/steam"
# Rutas extra que explorará Steamapps Cleaner
RUTASEXTRA=("/run/media" "/run/media/$USER")
# Fichero temporal para de otra función para recabar más info sobre juegos
IDDB=/tmp/DBsteamappsCleaner.tmp
# Ejecutable extra para guardar nombre e id
STEAMID=/tmp/SteamID


#########################################
##      FUNCIONES
#########################################

# Función con todas las traducciones
function fLanguage() {

    # establecemos los textos según idioma
    case "$LANG" in
    es_ES.UTF-8)
        lTEXTBIENVENIDA="Bienvenido a $NOMBRE.\nVersion: $VERSION.\n\nLicencia: GNU General Public License v3.0"
        lSALIR="Salir"
        lAELIMINAR="$NOMBRE $VERSION"
        lBOTONELIMINAR="Eliminar"
        lTEXTPRINCIPAL="Selecciona los objectos a eliminar de estas ubicaciones:"
        lID="ID"
        lTITULO="Titulo"
        lTIPO="Tipo"
        lTIPODISCO="Disco"
        lTAMANO="Espacio"
        lORDENAR="Ordenar"
        lANTES="Antes fue"
        lDESCONOCIDO="Desconocido"
        lTEXTSALIR="Saliendo...\nDisfruta tu Deck o tu dispositivo Steam."
        lTITLEATENCION="**** ATENCION - CUIDADO **** "
        lSALIRNOELIMINAR="Salir sin eliminar"
        lTEXTELIMINAR="Eliminas los directorios con los siguientes IDs?"
        lTEXTNOSTEAM="No se ha encontrado el directorio de Steam.\n\n$NOMBRE necesita esta ruta para continuar.\n\nAhora se va a lanzar un asistente para seleccionar manualmente la carpeta."
        lTEXTSELECTSTEAM="Selecciona el directorio donde tienes instalado Steam:"
        lTEXTSTEAMENCONTRADO="Se ha encontrado un directorio steamapps en la ruta seleccionada."
        lTEXTNOENCONTRADO="El directorio seleccionado no contiene una ruta de Steam correcta.\n\nVuelve a arrancar el programa y selecciona una ruta correcta."
        lTEXTNOENCONTRADOSID="Error interno. No se ha encontrado un componente necesario en $STEAMID"
        ;;
    *)
        lTEXTBIENVENIDA="Welcome to $NOMBRE.\nVersion: $VERSION.\n\nLicense: GNU General Public License v3.0"
        lSALIR="Exit"
        lAELIMINAR="$NOMBRE $VERSION"
        lBOTONELIMINAR="Delete"
        lTEXTPRINCIPAL="Select the objects to delete from these locations:"
        lID="ID"
        lTITULO="Title"
        lTIPO="Type"
        lTIPODISCO="Disk"
        lTAMANO="Use on disk"
        lORDENAR="Sort"
        lANTES="It was..."
        lDESCONOCIDO="Unknown"
        lTEXTSALIR="Exiting...Enjoy your Deck or your Steam device."
        lTITLEATENCION="**** WARNING - BE CAREFULL **** "
        lSALIRNOELIMINAR="Exit without deleting"
        lTEXTELIMINAR="Do you delete directories with the following IDs?"
        lTEXTNOSTEAM="The Steam directory was not found. $NOMBRE needs this path to continue. A wizard will now launch to manually select the folder."
        lTEXTSELECTSTEAM="Select the directory where you have Steam installed."
        lTEXTSTEAMENCONTRADO="A steamapps directory has been found in the selected path."
        lTEXTNOENCONTRADO="The selected directory does not contain a correct Steam path. Restart this program and select a correct path."
        lTEXTNOENCONTRADOSID="Error. Not found \"$STEAMID\""
        ;;
    esac
}

# Función para mostrar el mensaje de bienvenida
function fMensajeBienvenida() {

    if ! zenity --help >/dev/null ;then
        [ -n "$DEBUG" ] && echo "(log) No se encuentra el programa zenity, necesario para esta aplicación"
        exit 127
    fi

    #Mostramos la versión
    zenity --timeout 2 --title="$NOMBRE $VERSION" --info --text "$lTEXTBIENVENIDA" --width=300 --height=50
}

# Comprueba los requisitos de la herramienta
function fRequisitos() {

    # Borramos los temporales
    rm -rf "$IDDB" "$STEAMID" 2>/dev/null

    if ! zenity --help >/dev/null ;then
        [ -n "$DEBUG" ] && echo "(log) No se encuentra el programa zenity, necesario para esta apliación"
        exit 127
    fi

    # Si no encontramos la ruta de Steam, avisamos.
    if [ ! -d "$RUTASTEAM" ];then
        zenity --error --text "$lTEXTNOSTEAM" --width=300 --height=50
        DIRECT=$(zenity --file-selection \
            --title="$NOMBRE $VERSION" \
            --width=1000 --height=300 \
            --text="$lTEXTSELECTSTEAM" \
            --directory)
        
        if [ -d "$DIRECT"/steamapps ];then
            zenity --timeout 5 --title="$NOMBRE $VERSION" --info --text "$lTEXTSTEAMENCONTRADO" --width=300 --height=50
            RUTASTEAM="$DIRECT"
        else
            zenity --timeout 10 --error --text "$lTEXTNOENCONTRADO" --width=300 --height=50
            exit 88
        fi
    fi

    # VARIABLES GLOBALES
    # Nombre de la carpeta cache de nombres de juegos
    NOMCACHE="$RUTASTEAM/steamapps/steamappsCleaner"

    STEAMID_LINE=$(awk '/^__STEAMID_BEGINS__/ { print NR + 1; exit 0; }' "$0")
    tail -n +"${STEAMID_LINE}" "$0" | base64 -d > "$STEAMID"
    chmod +x "$STEAMID"

    # Comprobamos que esté nuestro ejecutable SteamID
    if [ ! -f "$STEAMID" ];then
        zenity --timeout 10 --error --text "$lTEXTNOENCONTRADOSID" --width=300 --height=50
        exit 33
    fi

}

# Función para generar todos los IDs de Juegos
function fRecargaID() {

    #Generamos los IDs de de los ficheros directamente
    grep -n "name" "$DIR"/*.acf 2>/dev/null |
        sed -e 's/^.*_//;s/\.acf:.:/ /;s/name//;s/"//g;s/\t//g;s/ /-/' | awk -F"-" '{printf "%s\t%s\n", $2, $1}' | sort | tee -a $IDDB >/dev/null
}

# Funcion principal para recargar IDs
function fEncontrarIDs() {

    SHORTCUTS="$RUTASTEAM/userdata/??*/config/shortcuts.vdf"
    for i in $SHORTCUTS ; do
        $STEAMID "$i" "$IDDB"
    done

    if [ -d "$RUTASTEAM/steamapps" ]; then
        DIR="$RUTASTEAM/steamapps"
        fRecargaID
    fi

    for j in "${RUTASEXTRA[@]}"; do
        if [ -d "$j" ]; then
            for SD in "$j"/*/; do
                if [ -d "$SD/steamapps/" ] || [ -d "$SD/steamapps/" ]; then
                    DIR="$SD"steamapps
                    fRecargaID
                fi

            done
        fi
    done
}

# Función para tratar un directorio steamapps
function fPreparaSteamapps() {

    # Restricciones de ID para steamapps
    re='^[0-9]+$'

    # Subdirectorios
    SUBD="compatdata shadercache"

    # Nombramos el Disco
    [ "$(dirname "$DIR")" == "$RUTASTEAM" ] && DISCO="SSD" || DISCO="$(basename "$(dirname "$DIR")")"
    [ -d "$NOMCACHE" ] || mkdir "$NOMCACHE"

    UBICACIONES+="\n\t$DISCO)-|--> $DIR"

    ## Seleccionamos subelemento (compatdata o shadercache)
    for SUBDIR in $SUBD; do
        for i in "$DIR"/"$SUBDIR"/*/; do
            N=$(basename "$i")
            if [[ $N =~ $re ]] && [[ "$N" -ne 0 ]]; then

                TAMANO=$(du -h -d 0 "$i" | cut -f 1)
                REALTAMANO=$(du -d 0 "$i" | cut -f 1)
                ORDERBYDISK=$(tr 0123456789 abcdefghij <<< "${#REALTAMANO}")"${REALTAMANO:0:2}"

                if SALIDA=$(grep -w -m1 "$N" <"$IDDB"); then
                    SALIDA=$(echo "$SALIDA" | cut -d$'\t' -f1)
                    LISTAP+=("0" "$i" "$N" "$SALIDA" "$TAMANO" "$DISCO" "$ORDERBYDISK" "${SUBDIR:0:6}" "N/A")
		    echo "$SALIDA" | tee "$NOMCACHE/$N.txt" >/dev/null
                else
                    if [ -f "$NOMCACHE/$N.txt" ]; then
                        LISTAP+=("1" "$i" "$N" "$lDESCONOCIDO" "$TAMANO" "$DISCO" "$ORDERBYDISK" "${SUBDIR:0:6}" "$(cat "$NOMCACHE/$N.txt")")
                    else
                        LISTAP+=("1" "$i" "$N" "$lDESCONOCIDO" "$TAMANO" "$DISCO" "$ORDERBYDISK" "${SUBDIR:0:6}" "¿?")
                    fi
                fi
            fi
        done
    done
}

# Encuentra los posibles Steamapps
function fGestionarDirSteamapps() {

    # Gestionar directorio steamapps principal
    [ -d "$RUTASTEAM/steamapps" ] && DIR="$RUTASTEAM/steamapps" && fPreparaSteamapps

    # Gestionar rutas extras para encontrar steamapps
    for j in "${RUTASEXTRA[@]}"; do
        if [ -d "$j" ]; then
            for SD in "$j"/*/; do
                if [ -d "$SD/steamapps/compatdata/" ] || [ -d "$SD/steamapps/shadercache/" ]; then
                    DIR="$SD"steamapps
                    fPreparaSteamapps
                fi

            done
        fi
    done
}

# Muestra el dialogo principal
function fMostrarDialogo() {

    RUN=$(zenity --list --title="$lAELIMINAR" --height=600 --width=900 \
        --ok-label="$lBOTONELIMINAR" --cancel-label="$lSALIR" --text="$lTEXTPRINCIPAL\n$UBICACIONES\n" --checklist \
        --column="" --column="Ubicacion" --column="$lID" --column="$lTITULO" --column="$lTAMANO" --column="$lTIPODISCO" --column="$lORDENAR" --column="$lTIPO" --column="$lANTES" \
        --separator="|" --hide-column=2 "${LISTAP[@]}")

    ans=$?
    if [ ! $ans -eq 0 ]; then
        [ -n "$DEBUG" ] && echo "(log) No quiere continuar. Salimos"
        zenity --timeout 2 --info --title="$NOMBRE" --width=250 --text="$lTEXTSALIR"
        salida
        exit 1
    fi
}

# Función para ejecutar borrado delo seleccionado
function fEliminar() {

    [ -n "$DEBUG" ] && echo -ne "(log) Seleccionados:\n ${RUN}\n"
    textparse="${RUN//"|"/"\n"}"

    if [ "${RUN}" ]; then
        zenity --question \
            --title="$lTITLEATENCION" --width=500 --height=200 --ok-label="$lBOTONELIMINAR" --cancel-label="$lSALIRNOELIMINAR" \
            --text="$lTEXTELIMINAR\n\n${textparse}"
        ans=$?
        if [ ! $ans -eq 0 ]; then
            salida
            exit 2
        fi

        IFS="|"
        for i in ${RUN}; do
            [ -n "$DEBUG" ] && echo -ne "(log) --> Eliminando el directorio: $i\n"
            rm -rf "$i"
            [ -f "${NOMCACHE:?}/$(basename "$i").txt" ] && rm -f "${NOMCACHE:?}/$(basename "$i").txt"
        done
        unset IFS
    fi
}

# Función para que llama para las ultimas tareas antes de salir
function salida() {

    rm -rf "$IDDB" "$STEAMID" 2>/dev/null
}

#########################################
##      MAIN
#########################################
#
# INICIAL
#
# Establecemos language
fLanguage
# Mostramos mensaje inicial
fMensajeBienvenida
# Requisitos de la aplicación
fRequisitos

#
# PROCESO DE RECARGA: Recargamos todos los IDs que podamos
#
[ -n "$DEBUG" ] && echo "(log) Cargando IDs de juegos"
fEncontrarIDs

#
# PROCESO DE MONTAJE DE LISTA: Creamos la lista de directorios
#
# Lista de juegos principal
LISTAP=()
[ -n "$DEBUG" ] && echo "(log) Gestionando bibliotecas de Steam"
fGestionarDirSteamapps

#
# MOSTRAMOS DIALOGO AL USUARIO: mostramos la lista que hemos ido preparando
#
[ -n "$DEBUG" ] && echo "(log) Mostrando resultados"
fMostrarDialogo

#
# VAMOS A ELIMINAR: Proceso de eliminación
#
fEliminar

salida
exit 0
# shellcheck disable=SC2317
__STEAMID_BEGINS__
