# DeckTools

## Steamapps Cleaner

### v2.3

![order by disk Column](https://raw.githubusercontent.com/FranjeGueje/DeckTools/master/Doc/ColumnaOrdenar.png)

Español:

- Nueva columna para ordenar por tamaño en disco.
- Mejora en la traducción al inglés.
- Definir la variable "DEBUG" para mostrar mensajes en la consola.

Inglés:

- New column to sort by disk size.
- Improved English translation.
- Define the variable "DEBUG" to show messages in the console.

### v2.2

Español:

- Cambio en la ruta por defecto de Steam. Ahora vuelve a ser "$HOME/.steam/steam". Esto da más compatibilidad entre sistemas fuera de Deck.
- Punto de control: chequea la ruta de instalación de Steam y si no la encuentra muestra un asistente para buscar la ruta.
- Punto de control: chequea si tenemos el gestor de ventanas "zenity" para arrancar. Si no sale.
- Optimización en el proceso de recarga de IDs de juegos.

Inglés:

- Change in Steam's default path. It is now back to "$HOME/.steam/steam/steam". This gives more compatibility between systems outside Deck.
- Checkpoint: checks the Steam installation path and if not found displays a wizard to find the path.
- Checkpoint: checks if we have the "zenity" window manager to start. If not, it exits.
- Optimisation in the process of reloading game IDs.

### v2.1

Español:

- Interfaz: ahora la cabecera con los discos se hace un poco más estrecha para que el foco sea la lista de juegos.
- Mejor búsqueda: Ahora también busca en el fichero screenshots.vdf y así intentar identificar más juegos.

Inglés:

- Interface: now the header with the discs is a bit narrower so that the focus is on the list of games.
- Better search: Now also searches the screenshots.vdf file and tries to identify more games.

### v2.0

Español:

- Pequeña cache de información recopilada de ids de juegos. Se encuentra en "/home/deck/.steam/root/steamapps/steamappsCleaner/" y podemos consultarla para conocer los ids de juegos y nombres.
- Gracias al punto anterior: soporte multitarjeta. Es decir, cada vez que abramos el programa recopilará información de IDs de juegos, de esta forma, cuando cambiemos de tarjeta (o eliminemos juegos) nos mostrará información de cual fue el último ID de juego.
- Soporte multiidioma: el programa revisa el idioma del sistema operativo y actualmente muestra los textos en español o inglés (para nuestros amigos anglosajones). También es fácil traducir los textos.
- Interfaz mejorada: en una única ventana se muestran todos los datos.
- Mejora en el código para hacerla más robusta.
- Instalador automático de la herramienta.
- Corrección de otros errores menores.

Inglés:

- Small cache of information collected from game ids. It is located in "/home/deck/.steam/root/steamapps/steamappsCleaner/" and can be queried for game ids and names.
- Thanks to the previous point: multi-card support. That is to say, every time we open the program it will collect game IDs information, so when we change cards (or delete games) it will show us information about which was the last game ID.
- Multi-language support: the program checks the language of the operating system and currently displays the texts in Spanish or English (for our English-speaking friends). It is also easy to translate the texts.
- Improved interface: all data is displayed in a single window.
- Improved code to make it more robust.
- Automatic installer of the tool.
- Correction of other minor bugs.
