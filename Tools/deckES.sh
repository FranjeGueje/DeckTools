#! /bin/bash

##############################################################################################################################################################
# AUTOR: Paco Guerrero <fjgj1@hotmail.com> - FranjeGueje
# LICENSE: GNU General Public License v3.0 (https://github.com/FranjeGueje/DeckTools/blob/master/LICENSE)
# ABOUT: Instala los locales es_ES.UTF-8 y los pone activos. Es decir, pone el SteamOS como lenguaje favorito el español.
# REQUISITOS: Se tiene que ejecutar con permisos de root o sudo 
# REQUIREMENTS: Must run with root privileges
# SALIDAS/EXITs:
#   0: Todo correcto, llegamos al final. All correct, we have reached the end.
#   1: Error. No se está ejecutando el script con permisos de root
#
##############################################################################################################################################################

#
# Chequeamos que corremos el script como root
#[ "$EUID" -ne 0 ] && echo "(Error) --> Ejecuta el script con privilegios de root o con sudo." && exit 1 

# Quitamos el solo lectura de la particion rootfs de SteamOS
sudo steamos-readonly disable

#
# Añadimos el locale ES como idioma permitido si no está añadido. Se descomenta la línea
grep "#es_ES.UTF-8 UTF-8" </etc/locale.gen && echo "¡Se necesita cambiar el locale!" && sudo sed -i 's/\#es_ES.UTF-8\ UTF-8/es_ES.UTF-8\ UTF-8/' /etc/locale.gen

#
# Reinstalamos glibc para poder generar nuestro locale
sudo pacman-key --init
sudo pacman-key --populate archlinux
sudo pacman -S glibc --noconfirm
sudo locale-gen

#
# Indicamos que el idioma POR DEFECTO del sistema es en Español
[ "$(cat /etc/locale.conf)" == "LANG=es_ES.UTF-8" ] || sudo localectl set-locale LANG=es_ES.UTF-8

# Volvemos a cerrar SteamOS como solo lectura
sudo steamos-readonly enable

#
# Ponemos el formato es_ES a la moneda y hora en nuestro usuario deck de Plasma/KDE
echo -ne "[Formats]\nLANG=es_ES.UTF-8" | tee /home/deck/.config/plasma-localerc > /dev/null
chmod 600 /home/deck/.config/plasma-localerc && chown 1000:1000 /home/deck/.config/plasma-localerc

exit 0
