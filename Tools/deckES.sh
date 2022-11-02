#! /bin/bash
# Instala los locales es_ES.UTF-8 y los pone activos
# RECORDATORIO: Las variables del Script anterior se heredan. TAMBIÉN: NO podemos salir del script con ningún exit

##############################################################################################################################################################
# AUTOR: Paco Guerrero <fjgj1@hotmail.com>
# ABOUT: Instala los locales es_ES.UTF-8 y los pone activos
# REQUISITOS: Las variables del Script anterior se heredan. TAMBIÉN: NO podemos salir del script con ningún exit
##############################################################################################################################################################


# Funcion encargada de cambiar el locale a ES descomentando la línea.
function changeLocal() {
    sudo steamos-readonly disable
    sudo sed -i 's/\#es_ES.UTF-8\ UTF-8/es_ES.UTF-8\ UTF-8/' /etc/locale.gen
    sudo steamos-readonly enable
}

echo "### Buscamos si está el locale es_ES-UTF8 activo o si se necesita cambiar.  ###"
grep "#es_ES.UTF-8 UTF-8" </etc/locale.gen && echo "¡Se necesita cambiar el locale!" && changeLocal

sudo steamos-readonly disable
sudo pacman-key --init
sudo pacman-key --populate archlinux
sudo pacman -S glibc --noconfirm
sudo locale-gen

# Ponemos el idioma del sistema en Español
[ "$(cat /etc/locale.conf)" == "LANG=es_ES.UTF-8" ] || sudo localectl set-locale LANG=es_ES.UTF-8
sudo steamos-readonly enable

# Ponemos el formato es_ES a la moneda y hora en KDE
echo -ne "[Formats]\nLANG=es_ES.UTF-8" | tee /home/deck/.config/plasma-localerc
chmod 600 /home/deck/.config/plasma-localerc
chown 1000:1000 /home/deck/.config/plasma-localerc

