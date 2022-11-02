#!/bin/bash

# Función para ejecutar asistente y borrar
function lanzar() {

    LISTAP=()
    LISTA=$(find "$DIR" -maxdepth 1 -mindepth 1 -type d)

    for i in $LISTA; do
        N=$(basename "$i")
        if [ "$N" -ne 0 ]; then

            TAMANO=$(du -h -d 0 "$i" | cut -f 1)

            if SALIDA=$(grep "$N" <"$IDPT"); then
                #Añadirlo a la lista pero no borrar.
                LISTAP+=("0" "$N" "$SALIDA" "$TAMANO")
            else
                if SALIDASC=$(grep "$N" <"$IDSC"); then
                    LISTAP+=("0" "$N" "${SALIDASC//$N}" "$TAMANO")
                else
                    LISTAP+=("1" "$N" "Desconocido" "$TAMANO")
                fi
            fi
        fi
    done

    RUN=""

    RUN=$(zenity --list --title="*$TITLE* a Eliminar" --height=600 --width=900 \
        --ok-label="Continuar..." --cancel-label="Salir" \
        --text="Selecciona los $TITLE a eliminar de $DIR" --checklist \
        --column="" --column="ID" --column="Titulo" --column="Espacio en disco" --separator=" " \
        "${LISTAP[@]}")

    ans=$?
    if [ ! $ans -eq 0 ]; then
        echo "No quiere continuar. Salimos"
        zenity --info \
            --title="SteamApps Cleaner" \
            --width=250 \
            --text="Saliendo del programa.\nDisfruta tu Deck."
        salida
        exit 1
    fi

    echo "Seleccionados: ${RUN}"

    if [ "${RUN}" ]; then
        zenity --question \
            --title="Eliminar carpetas" --width=500 --height=200 \
            --ok-label="Eliminar y Continuar" \
            --cancel-label="Salir" \
            --text="Eliminas los directorios con los siguientes IDs?\n${RUN}"
        ans=$?
        if [ ! $ans -eq 0 ]; then
            salida
            exit 2
        fi

        for i in ${RUN}; do
            echo "--> Eliminando el ID: $i"
            rm -rf "${DIR:?}"/"$i"
        done
    fi
}

# Función para generar todos los IDs de Juegos
function entrada() {
    IDPT=/tmp/PTsteamappsCleaner.tmp
    IDSC=/tmp/SCsteamappsCleaner.tmp

    rm -rf "$IDPT" "$IDSC" 2> /dev/null

    #Generamos los IDs de protontricks
    flatpak run com.github.Matoking.protontricks -l 2>/dev/null >$IDPT
    
    #Generamos los IDs de de los ficheros directamente
    grep -n "name" "$HOME"/.steam/root/steamapps/*.acf 2>/dev/null \
      | sed -e 's/^.*_//;s/\.acf:.:/ /;s/name//;s/"//g;s/\t//g;s/ /-/' | awk -F"-" '{printf "%-40s %s\n", $2, $1}' | sort | tee -a $IDSC >/dev/null
        
    LISTA=$(find /run/media -maxdepth 1 -mindepth 1 -type d)
    for SD in $LISTA; do
        grep -n "name" "$SD"/steamapps/*.acf 2>/dev/null \
           | sed -e 's/^.*_//;s/\.acf:.:/ /;s/name//;s/"//g;s/\t//g;s/ /-/' | awk -F"-" '{printf "%-40s %s\n", $2, $1}' | sort | tee -a $IDSC >/dev/null
    done
}

# Función para generar todos los IDs de Juegos
function salida() {
    rm -rf "$IDPT" "$IDSC" 2> /dev/null
}

#########################################
##      main
#########################################
#Hacemos las tareas iniciales
entrada

# Elimianmos los Compatdata
DIR=/home/deck/.steam/root/steamapps/compatdata/
TITLE="COMPATDATA"
lanzar

# Elimianmos los ShaderCache
DIR=/home/deck/.steam/root/steamapps/shadercache/
TITLE="SHADERCACHE"
lanzar

LISTA=$(find /run/media -maxdepth 1 -mindepth 1 -type d)

for SD in $LISTA; do

    if [ -d "$SD/steamapps/compatdata/" ]; then
        DIR="$SD/steamapps/compatdata/"
        TITLE="COMPATDATA"
        lanzar
    fi

    if [ -d "$SD/steamapps/shadercache/" ]; then
        DIR="$SD/steamapps/shadercache/"
        TITLE="SHADERCACHE"
        lanzar
    fi

done

salida

exit 0
