#!/bin/bash

##############################################################################################################################################################
# AUTOR: Paco Guerrero <fjgj1@hotmail.com> - FranjeGueje
# LICENSE: GNU General Public License v3.0 (https://github.com/FranjeGueje/DeckTools/blob/master/LICENSE)
# ABOUT: Busca compatdata y shadercache en los dispositivos mostrando los nombres de los que se puedan utilizar y muesta como "Desconocido" los huérfanos.
#           perfecto para eliminarlos.
# REQUISITOS: Para una mejor salida de juegos nonsteam se requiere Protontricks
# SALIDAS:
#   0: Todo correcto, llegamos al final.
#   1: Si hemos pulsado el botón de "Salir" a mitad.
#   2: Si salimos cancelando la eliminación.
#   33: Salimos si no tenemos protontricks.
##############################################################################################################################################################

#########################################
##      VARIABLES GLOBALES
#########################################
VERSION="2.0"
NOMBRE="Steamapps Cleaner"
# Ruta de Steam principal, instalación local
RUTASTEAM="$HOME/.local/share/Steam"
# Rutas extra que explorará Steamapps Cleaner
RUTASEXTRA=("/run/media" "/run/media/$USER")
# Fichero temporal para ProtonTricks para buscar información de juegos
IDPT=/tmp/PTsteamappsCleaner.tmp
# Fichero temporal para de otra función para recabar más info sobre juegos
IDSC=/tmp/SCsteamappsCleaner.tmp
# Nombre de la carpeta cache de nombres de juegos
NOMCACHE="$RUTASTEAM/steamapps/steamappsCleaner"

#########################################
##      FUNCIONES
#########################################

# Función con todas las traducciones
function fLanguage() {

    # establecemos los textos según idioma
    case "$LANG" in
    es_ES.UTF-8)
        lTEXTBIENVENIDA="Bienvenido a $NOMBRE.\nVersion: $VERSION.\n\nLicencia: GNU General Public License v3.0"
        lTEXTNOPROTON="No se ha encontrado el ejecutable necesario protontricks.\n\n$NOMBRE no tiene todas las herramientas para mostrar todos los nombres de juegos y aplicaciones."
        lATENCION="**** ATENCION ****"
        lCONTINLIMIT="Continuar, pero limitado"
        lSALIR="Salir"
        lTEXTLIMIT="Se ha detectado que faltan herramientas necesarias para que $NOMBRE tenga toda su funcionalidad.\n\nDesea continuar con limitaciones?"
        lAELIMINAR="$NOMBRE $VERSION"
        lBOTONELIMINAR="Eliminar"
        lTEXTPRINCIPAL="Selecciona los objectos a eliminar de estas ubicaciones:"
        lID="ID"
        lTITULO="Titulo"
        lTIPO="Tipo"
        lTIPODISCO="Disco"
        lTAMANO="Espacio"
        lANTES="Antes fue"
        lTEXTSALIR="Saliendo...\nDisfruta tu Deck o tu dispositivo Steam."
        lTITLEATENCION="**** ATENCION - CUIDADO **** "
        lSALIRNOELIMINAR="Salir sin eliminar"
        lTEXTELIMINAR="Eliminas los directorios con los siguientes IDs?"
        ;;
    *)
        lTEXTBIENVENIDA="Welcome to $NOMBRE.\nVersion: $VERSION.\n\nLicense: GNU General Public License v3.0"
        lTEXTNOPROTON="The required executable protontricks has not been found.\n\n$NOMBRE don't have all the tools to display all game and application names."
        lATENCION="**** WARNING ****"
        lCONTINLIMIT="Continue, but limited"
        lSALIR="Exit"
        lTEXTLIMIT="It has been detected that tools necessary for $NAME to have full functionality are missing.\n\nDo you want to continue with limitations?"
        lAELIMINAR="$NOMBRE $VERSION"
        lBOTONELIMINAR="Delete"
        lTEXTPRINCIPAL="Select the objects to delete from these locations:"
        lID="ID"
        lTITULO="Title"
        lTIPO="Type"
        lTIPODISCO="Disk"
        lTAMANO="Use on disk"
        lANTES="Previously"
        lTEXTSALIR="Exiting...Enjoy your Deck or your Steam device."
        lTITLEATENCION="**** WARNING - BE CAREFULL **** "
        lSALIRNOELIMINAR="Exit without deleting"
        lTEXTELIMINAR="Do you delete directories with the following IDs?"
        ;;
    esac
}

# Función para mostrar el mensaje de bienvenida
function fMensajeBienvenida() {

    #Mostramos la versión
    zenity --timeout 2 --title="$NOMBRE $VERSION" --info --text "$lTEXTBIENVENIDA" --width=300 --height=50
}

# Comprueba los requisitos de la herramienta
function fRequisitos() {

    # Borramos los temporales
    rm -rf "$IDPT" "$IDSC" 2>/dev/null

    # Generamos los IDs de protontricks a la vez que comprobamos si tenemos protontricks
    if flatpak run com.github.Matoking.protontricks -l 2>/dev/null >$IDPT; then
        echo "(log) protontricks encontrado en flatpak."
    else
        if protontricks -l 2>/dev/null >$IDPT; then
            echo "(log)protontricks encontrado como aplicación."
        else
            zenity --timeout 10 --error --text "$lTEXTNOPROTON" --width=300 --height=50
            zenity --question --title="$lATENCION" --width=500 --height=200 --ok-label="$lCONTINLIMIT" --cancel-label="$lSALIR" --text="$lTEXTLIMIT"

            ans=$?
            if [ ! $ans -eq 0 ]; then
                salida
                exit 33
            fi
        fi
    fi
    sed -i 's/team shortcut//' "$IDPT"
}

# Función para generar todos los IDs de Juegos (que se pueda...)
function fRecargaID() {

    #Generamos los IDs de de los ficheros directamente
    grep -n "name" "$DIR"/*.acf 2>/dev/null |
        sed -e 's/^.*_//;s/\.acf:.:/ /;s/name//;s/"//g;s/\t//g;s/ /-/' | awk -F"-" '{printf "%-40s %s\n", $2, $1}' | sort | tee -a $IDSC >/dev/null
}

# Funcion principal para recargar IDs
function fEncontrarIDs() {

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

    UBICACIONES+="\n\t$DISCO)\n\t\t|--> $DIR\n"

    ## Seleccionamos subelemento (compatdata o shadercache)
    for SUBDIR in $SUBD; do
        for i in "$DIR"/"$SUBDIR"/*/; do
            N=$(basename "$i")
            if [[ $N =~ $re ]] && [[ "$N" -ne 0 ]]; then

                TAMANO=$(du -h -d 0 "$i" | cut -f 1)

                if SALIDA=$(grep -w "$N" <"$IDPT"); then
                    SALIDA=$(echo "$SALIDA" | sed -E 's/\ \([0-9]+\)//g')
                    LISTAP+=("0" "$i" "$N" "$SALIDA" "$TAMANO" "$DISCO" "${SUBDIR:0:6}" "N/A")
                    echo "$SALIDA" | tee "$NOMCACHE/$N.txt" >/dev/null
                else
                    if SALIDASC=$(grep -w "$N" <"$IDSC"); then
                        LISTAP+=("0" "$i" "$N" "${SALIDASC//$N/}" "$TAMANO" "$DISCO" "${SUBDIR:0:6}" "N/A")
                        echo "${SALIDASC//$N/}" | tee "$NOMCACHE/$N.txt" >/dev/null
                    else
                        if [ -f "$NOMCACHE/$N.txt" ]; then
                            LISTAP+=("1" "$i" "$N" "Desconocido" "$TAMANO" "$DISCO" "${SUBDIR:0:6}" "$(cat "$NOMCACHE/$N.txt")")
                        else
                            LISTAP+=("1" "$i" "$N" "Desconocido" "$TAMANO" "$DISCO" "${SUBDIR:0:6}" "¿?")
                        fi
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
        --column="" --column="Ubicacion" --column="$lID" --column="$lTITULO" --column="$lTAMANO" --column="$lTIPODISCO" --column="$lTIPO" --column="$lANTES" --separator="|" \
        --hide-column=2 "${LISTAP[@]}")

    ans=$?
    if [ ! $ans -eq 0 ]; then
        echo "(log) No quiere continuar. Salimos"
        zenity --timeout 2 --info --title="$NOMBRE" --width=250 --text="$lTEXTSALIR"
        salida
        exit 1
    fi
}

# Función para ejecutar borrado delo seleccionado
function fEliminar() {

    echo -ne "(log) Seleccionados:\n ${RUN}\n"
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
            echo -ne "(log)--> Eliminando el directorio: $i\n"
            rm -rf "$i"
            [ -f "${NOMCACHE:?}/$(basename "$i").txt" ] && rm -f "${NOMCACHE:?}/$(basename "$i").txt"
        done
        unset IFS
    fi
}

# Función para que llama para las ultimas tareas antes de salir
function salida() {

    rm -rf "$IDPT" "$IDSC" 2>/dev/null
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
fEncontrarIDs

#
# PROCESO DE MONTAJE DE LISTA: Creamos la lista de directorios
#
# Lista de juegos principal
LISTAP=()
fGestionarDirSteamapps

#
# MOSTRAMOS DIALOGO AL USUARIO: mostramos la lista que hemos ido preparando
#
fMostrarDialogo
fEliminar

salida
exit 0
