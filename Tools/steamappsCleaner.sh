#!/bin/bash

# Función para todas las comprobaciones iniciales
function lanzar() {

    LISTAP=()
    LISTA=$(find "$DIR" -maxdepth 1 -mindepth 1 -type d)

    for i in $LISTA; do
        N=$(basename "$i")
        if [ "$N" -ne 0 ]; then

            TAMANO=$(du -h -d 0 "$i" | cut -f 1)

            if SALIDA=$(grep "$N" < "$TEMP"); then
                #Añadirlo a la lista pero no borrar.
                LISTAP+=("0" "$N" "$SALIDA" "$TAMANO")
            else
                LISTAP+=("1" "$N" "Desconocido" "$TAMANO")
            fi
        fi
    done

    RUN=$(zenity --list --title="*$TITLE* a Eliminar" --height=600 --width=900 \
        --ok-label="Aceptar" --cancel-label="Cancelar" \
        --text="Selecciona los $TITLE a eliminar de $DIR" --checklist \
        --column="" --column="ID" --column="Titulo" --column="Espacio en disco" --separator=" " \
        "${LISTAP[@]}")

    echo "Seleccionados: ${RUN}"

    if [ "${RUN}" ]; then
        zenity --question \
            --title="¿Seguro que desea continuar?" --width=1000 --height=300 \
            --ok-label="Continuar" \
            --cancel-label="Salir" \
            --text="Se eliminarán los direcotrio con IDs: ${RUN}"
        ans=$?
        if [ ! $ans -eq 0 ]; then
            exit 3
        fi

        for i in ${RUN}; do
            echo "--> Eliminando el ID: $i"
            rm -rf "$DIR/$i:?"
        done
    fi
}

TEMP=/tmp/steamappsCleaner.tmp
flatpak run com.github.Matoking.protontricks -l 2>/dev/null >$TEMP

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
    
    if [ -d "$SD/steamapps/compatdata/" ];then
        DIR="$SD/steamapps/compatdata/"
        TITLE="COMPATDATA"
        lanzar
    fi

    if [ -d "$SD/steamapps/shadercache/" ];then
        DIR="$SD/steamapps/shadercache/"
        TITLE="SHADERCACHE"
        lanzar
    fi

done

exit 0
