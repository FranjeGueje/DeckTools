#!/bin/bash

##############################################################################################################################################################
# AUTOR: Paco Guerrero <fjgj1@hotmail.com>
# ABOUT: Busca compatdata y shadercache en los dispositivos mostrando los nombres de los que se puedan utilizar y muesta como "Desconocido" los huérfanos.
#           perfecto para eliminarlos.
# REQUISITOS: Para una mejor salida de juego nonsteam se requiere Protontricks
# SALIDAS:
#   0: Todo correcto, llegamos al final.
#   1: Si hemos pulsado el botón de "Salir" a mitad.
#   2: Si salimos cancelando la eliminación.
#   33: Salimos si no tenemos protontricks.
##############################################################################################################################################################


VERSION="1.1"
NOMBRE="Steamapps Cleaner"
RUTASEXTRA="/run/media /run/media/$USER"

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
                    LISTAP+=("0" "$N" "${SALIDASC//$N/}" "$TAMANO")
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
        zenity --timeout 2 --info  --title="$NOMBRE" --width=250 \
            --text="Saliendo...\nDisfruta tu Deck o tu dispositivo Steam."
        salida
        exit 1
    fi

    echo "Seleccionados: ${RUN}"

    if [ "${RUN}" ]; then
        zenity --question \
            --title="**** ATENCION - CUIDADO **** " --width=500 --height=200 \
            --ok-label="Eliminar y Continuar" \
            --cancel-label="Salir" \
            --text="Eliminas los directorios con los siguientes IDs?\n\n${RUN}\n\n\nRecuerda que estan ubicados en:\n${DIR}"
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

    #Mostramos la versión
    zenity --timeout 2 --info --text "Bienvenido a $NOMBRE.\n\t\tVer: $VERSION" --width=300 --height=50

    IDPT=/tmp/PTsteamappsCleaner.tmp
    IDSC=/tmp/SCsteamappsCleaner.tmp

    rm -rf "$IDPT" "$IDSC" 2>/dev/null

    #Generamos los IDs de protontricks
    if flatpak run com.github.Matoking.pprotontricks -l 2>/dev/null >$IDPT; then
        echo protontricks encontrado en flatpak.
    else
        if protontricks -l 2>/dev/null >$IDPT; then
            echo protontricks encontrado como aplicación.
        else
            zenity --timeout 10 --error --text \
             "No se ha encontrado el ejecutable necesario protontricks.\n\n$NOMBRE no tiene todas las herramientas para mostrar todos los nombres de juegos y aplicaciones." \
             --width=300 --height=50
            
            zenity --question \
                --title="**** ATENCION **** " --width=500 --height=200 \
                --ok-label="Continuar, pero limitado" \
                --cancel-label="Salir" \
                --text="Se ha detectado que faltan herramientas necesarias para que $NOMBRE tenga toda su funcionalidad.\n\nDesea continuar con limitaciones?"
            ans=$?
            if [ ! $ans -eq 0 ]; then
                salida
                exit 33
            fi
        fi
    fi

    #Generamos los IDs de de los ficheros directamente
    grep -n "name" "$HOME"/.steam/root/steamapps/*.acf 2>/dev/null |
            sed -e 's/^.*_//;s/\.acf:.:/ /;s/name//;s/"//g;s/\t//g;s/ /-/' | awk -F"-" '{printf "%-40s %s\n", $2, $1}' | sort | tee -a $IDSC >/dev/null

    for j in $RUTASEXTRA; do
        LISTA=$(find "$j" -maxdepth 1 -mindepth 1 -type d)
        for SD in $LISTA; do
            grep -n "name" "$SD"/steamapps/*.acf 2>/dev/null |
                sed -e 's/^.*_//;s/\.acf:.:/ /;s/name//;s/"//g;s/\t//g;s/ /-/' | awk -F"-" '{printf "%-40s %s\n", $2, $1}' | sort | tee -a $IDSC >/dev/null
        done
    done
}

# Función para generar todos los IDs de Juegos
function salida() {
    rm -rf "$IDPT" "$IDSC" 2>/dev/null
}

#########################################
##      main
#########################################
#Hacemos las tareas iniciales
entrada

# Elimianmos los Compatdata
DIR="$HOME/.steam/root/steamapps/compatdata/"
TITLE="COMPATDATA"
lanzar

# Elimianmos los ShaderCache
DIR="$HOME/.steam/root/steamapps/shadercache/"
TITLE="SHADERCACHE"
lanzar

for j in $RUTASEXTRA; do
    LISTA=$(find "$j" -maxdepth 1 -mindepth 1 -type d)

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
done

salida

exit 0
