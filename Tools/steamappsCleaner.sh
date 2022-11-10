#!/bin/bash

##############################################################################################################################################################
# AUTOR: Paco Guerrero <fjgj1@hotmail.com>
# LICENSE: GNU General Public License v3.0 (https://github.com/FranjeGueje/DeckTools/blob/master/LICENSE)
# ABOUT: Busca compatdata y shadercache en los dispositivos mostrando los nombres de los que se puedan utilizar y muesta como "Desconocido" los huérfanos.
#           perfecto para eliminarlos.
# REQUISITOS: Para una mejor salida de juego nonsteam se requiere Protontricks
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
# Ruta de Steam
RUTASTEAM="$HOME/.local/share/Steam"
# Rutas que explorará el fichero
RUTASEXTRA="/run/media /run/media/$USER"
# Fichero temporal para ProtonTricks
IDPT=/tmp/PTsteamappsCleaner.tmp
# Fichero temporal para otro script
IDSC=/tmp/SCsteamappsCleaner.tmp
# Nombre de fichero cache de nombre
NOMCACHE="$RUTASTEAM/steamapps/steamappsCleaner"

#########################################
##      FUNCIONES
#########################################

# Función con todas las traducciones
function fLanguage() {
    # establecemos las traducciones según idioma
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
        ;;
    *)
        lTEXTBIENVENIDA="Wellcome to $NOMBRE.\nVersion: $VERSION.\n\nLicense: GNU General Public License v3.0"
        lTEXTNOPROTON="I can't find protontricks.\n\n$NOMBRE don't have the necesary tools to show all names of games."
        lATENCION="**** WARNING ****"
        lCONTINLIMIT="Continue but limited"
        lSALIR="Exit"
        lTEXTLIMIT="It has been detected that tools necessary for $NAME to have full functionality are missing.\n\nDo you want to continue with limitations?"
        lAELIMINAR="$NOMBRE $VERSION"
        lBOTONELIMINAR="Delete"
        lTEXTPRINCIPAL="Select the objects to delete from this locations:"
        lID="ID"
        lTITULO="Title"
        lTIPO="Type"
        lTIPODISCO="Disk"
        lTAMANO="Use on disk"
        lANTES="Antes fue"
        ;;
    esac

    #export $lBIENVENIDA
}

# Función para generar todos los IDs de Juegos
function fMensajeBienvenida() {

    #Mostramos la versión
    zenity --timeout 2 --title="$NOMBRE $VERSION" --info --text "$lTEXTBIENVENIDA" --width=300 --height=50

}

# Comprueba los requisitos de la herramienta
function fRequisitos() {

    # Borramos los temporales
    rm -rf "$IDPT" "$IDSC" 2>/dev/null

    #Generamos los IDs de protontricks
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

}

# Función para generar todos los IDs de Juegos
function fRecargaID() {

    #Generamos los IDs de de los ficheros directamente
    grep -n "name" "$DIR"/*.acf 2>/dev/null |
        sed -e 's/^.*_//;s/\.acf:.:/ /;s/name//;s/"//g;s/\t//g;s/ /-/' | awk -F"-" '{printf "%-40s %s\n", $2, $1}' | sort | tee -a $IDSC >/dev/null

}

# Función para ejecutar limpieza de un directorio steamapps
function fPreparaSteamapps() {
    # Subdirectorios
    SUBD="compatdata shadercache"

    # Disco
    [ "$(dirname "$DIR")" == "$RUTASTEAM" ] && DISCO="SSD" || DISCO="$(basename "$(dirname "$DIR")")"
    [ -d "$NOMCACHE" ] || mkdir "$NOMCACHE"

    UBICACIONES+="\n\t$DISCO)\n\t\t|--> $DIR\n"

    ## Seleccionamos subelemento
    for SUBDIR in $SUBD; do
        LISTA=$(find "$DIR/$SUBDIR" -maxdepth 1 -mindepth 1 -type d)

        for i in $LISTA; do
            N=$(basename "$i")
            if [ "$N" -ne 0 ]; then

                TAMANO=$(du -h -d 0 "$i" | cut -f 1)

                if SALIDA=$(grep -w "$N" <"$IDPT"); then
                    LISTAP+=("0" "$i" "$N" "$SALIDA" "$TAMANO" "$DISCO" "${SUBDIR^}" "N/A")
                    echo "$SALIDA" | tee "$NOMCACHE/$N.txt" >/dev/null
                else
                    if SALIDASC=$(grep -w "$N" <"$IDSC"); then
                        LISTAP+=("0" "$i" "$N" "${SALIDASC//$N/}" "$TAMANO" "$DISCO" "${SUBDIR^}" "N/A")
                        echo "${SALIDASC//$N/}" | tee "$NOMCACHE/$N.txt" >/dev/null
                    else
                        if [ -f "$NOMCACHE/$N.txt" ]; then
                            LISTAP+=("1" "$i" "$N" "Desconocido" "$TAMANO" "$DISCO" "${SUBDIR^}" "$(cat "$NOMCACHE/$N.txt")")
                        else
                            LISTAP+=("1" "$i" "$N" "Desconocido" "$TAMANO" "$DISCO" "${SUBDIR^}" "¿?")
                        fi
                    fi
                fi
            fi
        done
    done

}

# Gestiona los posibles Steamapps
function fGestionarDirSteamapps() {
    # Gestionar directorio steamapps principal
    [ -d "$RUTASTEAM/steamapps" ] && DIR="$RUTASTEAM/steamapps" && fPreparaSteamapps

    # Gestionar rutas extras para encontrar steamapps
    for j in $RUTASEXTRA; do
        if [ -d "$j" ]; then

            LISTA=$(find "$j" -maxdepth 1 -mindepth 1 -type d)

            for SD in $LISTA; do

                if [ -d "$SD/steamapps/compatdata/" ] || [ -d "$SD/steamapps/shadercache/" ]; then
                    DIR="$SD/steamapps"
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
        --column="" --column="Ubicacion" --column="$lID" --column="$lTITULO" --column="$lTAMANO" --column="$lTIPODISCO" --column="$lTIPO" --column="$lANTES" --separator="\n" \
        --hide-column=2 "${LISTAP[@]}")

    ans=$?
    if [ ! $ans -eq 0 ]; then
        echo "(log) No quiere continuar. Salimos"
        zenity --timeout 2 --info --title="$NOMBRE" --width=250 \
            --text="Saliendo...\nDisfruta tu Deck o tu dispositivo Steam."
        salida
        exit 1
    fi

}

# Función para ejecutar asistente y borrar
function fEliminar() {

    echo "(log) Seleccionados: ${RUN}"

    if [ "${RUN}" ]; then
        zenity --question \
            --title="**** ATENCION - CUIDADO **** " --width=500 --height=200 \
            --ok-label="Eliminar y Continuar" \
            --cancel-label="Salir" \
            --text="Eliminas los directorios con los siguientes IDs?\n\n${RUN}"
        ans=$?
        if [ ! $ans -eq 0 ]; then
            salida
            exit 2
        fi

        for i in ${RUN}; do
            echo "(log)--> Eliminando el directorio: $i"
            rm -rf "$i"
            [ -f "${NOMCACHE:?}/$(basename "$i").txt" ] && rm -f "${NOMCACHE:?}/$(basename "$i").txt"
        done
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
[ -d "$RUTASTEAM/steamapps" ] && DIR="$RUTASTEAM/steamapps" && fRecargaID
for j in $RUTASEXTRA; do
    [ -d "$j/steamapps" ] && DIR="$j/steamapps" && fRecargaID
done

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
