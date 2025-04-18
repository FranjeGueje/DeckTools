#!/bin/bash

##############################################################################################################################################################
# AUTOR: Paco Guerrero <fjgj1@hotmail.com>
# PROJECT: GE-Proton Rolling Releale installer
# ABOUT: Download and add the latest version of GE-Proton as a Steam compatibility tool by always using the same one
#
# PARAMS:
# --help --> help about this tool
# --no-gui --> unattended, without gui
# --debug --> create debug.log file with all operations
# --force --> the latest GE-Proton will be downloaded and installed forcibly
# --no-backup --> No backup the actual GE-Proton of compatibility folder
#
# DEBUG MODE: run 'DEBUG=Y path-to-this-script/thi-script.sh'
#
# REQUERIMENTS: which, curl, wget
#
# EXITs:
# 0 --> OK!!!
# 1 --> Missing required component
# 2 --> Cannot download the lastest file
# 3 --> Before the extracting: the file is not downloaded
# 4 --> Error extracting the tar.gz file
# 8 --> App upgraded
# 88 --> It seems that there is no need to install a new version of GE-Proton
# 253-> Invalid parameter
##############################################################################################################################################################

#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#!         FUNCTIONS
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
##
# Show the help
#
function show_help() {
    echo -e "[Usages]\n$0 -h|--help\
    \n$0 [-v] [-f] [--no-gui] [--no-backup]\
    \n$0 [-v] [--install]\
    \n$0 [-v] [--uninstall]\n\
    \n[Parameters]\n\
    \t-h|--help\t\tThis help.\n\
    \t-v|--debug|--verbose\tThis parameter will creating a file $DEBUGFILE with verbose info.\n\
    \t-f|--force\t\tThe latest GE-Proton will be downloaded and installed forcibly.\n\
    \t--no-gui\t\tRun $NOMBRE automatically.\n\
    \t--no-backup\t\tNo backup the actual GE-Proton of compatibility folder.\n\
    \t-i|--install\t\tInstall this app in silent mode on desktop's autostart.\n\
    \t-u|--uninstall\t\tUninstall this app from desktop's autostart."
}

##
# Initialize the script
#
pre_launch(){
    NOMBRE="GE-Proton Rolling Release"
    VERSION=5

    TOOLPATH=$(readlink -f "$(dirname "$0")")
    DEBUGFILE="$TOOLPATH/debug.log"
    OLDVERSION="$TOOLPATH/$(basename "$0").old"
    MYAPP_FILE_FROM_INTERNET="https://api.github.com/repos/FranjeGueje/GE-Proton-RR/releases/latest"
    DOWNLOADEDFILE="$TOOLPATH/GE-Proton.tar.gz"
    EXTRACTFOLDER="$TOOLPATH/.extract/"

    COMPATFOLDER="$HOME/.local/share/Steam/compatibilitytools.d/"
    INSTALLFOLDER="$COMPATFOLDER"GE-Proton/
    BACKUPFOLDER="$TOOLPATH"/GE-Proton_backup/
    CHECKURL="$INSTALLFOLDER""url_downloaded"

    # If DEBUGFILE has more of a size then we delete the file
    if [ -f "$DEBUGFILE" ];then
        local __tamano=__limite= 
        __tamano=$(stat -c%s "$DEBUGFILE")
        # 5 MB en bytes
        __limite=$((5 * 1024 * 1024))
        # Compara el tamaño del archivo con el límite de 5 MB
        [ "$__tamano" -gt "$__limite" ] && rm "$DEBUGFILE"
    fi
}

##
# Finish the script
#
post_launch(){    
    [ -f "$DOWNLOADEDFILE" ] && rm -f "$DOWNLOADEDFILE"
    [ -d "$EXTRACTFOLDER" ] && rm -Rf "$EXTRACTFOLDER"
    [ -n "$DEBUG" ] && to_debug_file "Exiting..."
    echo -e "[INFO] Exiting..."
}

##
# Save a msg to debug
#
#* PARAMETERS
# $1 = Text to Debub file
#
function to_debug_file() {
    echo -e "$(date +"%Y-%m-%d %H:%M:%S") - $1" >>"$DEBUGFILE"
}

##
# Install or Uninstall the software on autostart
#
function inst_unins_autostart() {
    if [ "$GEP_AUTOSTART" == "Y" ];then
        do_install
        post_launch
        exit 0
    elif [ "$GEP_AUTOSTART" == "N" ];then
        do_uninstall
        post_launch
        exit 0
    fi
}

##
# Install the software on autostart
#
function do_install() {
    local __fichero=
    __fichero=$(readlink -f "$0")
    echo -e "[Desktop Entry]
Name=GE-Proton-RR
Comment=Create a compatibility tool in Rolling Release format from the official GE-Proton
Exec=$__fichero --no-gui -v
Terminal=false
Type=Application" > "$HOME/.config/autostart/ge-proton-rr.desktop"
}

##
# Uninstall the software on autostart
#
function do_uninstall() {
    if [ -f "$HOME/.config/autostart/ge-proton-rr.desktop" ];then
        rm -f "$HOME/.config/autostart/ge-proton-rr.desktop"
        [ -n "$DEBUG" ] && to_debug_file "[INFO] GUI: Removed the autoupdate from the file $HOME/.config/autostart/ge-proton-rr.desktop"
    else
        [ -n "$DEBUG" ] && to_debug_file "[WARNING] : The file $HOME/.config/autostart/ge-proton-rr.desktop not found."
    fi
}

##
# Print the title and version
#
show_title(){
    echo -e "[INFO] Launching \"$NOMBRE\" - ver.$VERSION\nThis script will download and install the lastest GE-Proton from Internet."
}

##
# Should be updated? - check the last stable version on The Internet
#
should_be_updated(){
    local __file=
    __file=$(basename "$0").lastversion && [ -f "$__file" ] && rm "$__file"

    if curl -s --head --request GET https://api.github.com --max-time 3 | grep "HTTP/" 2>/dev/null >/dev/null; then
        local sha_web
        sha_web=$(curl -L "$(curl -s "$MYAPP_FILE_FROM_INTERNET" | grep browser_download_url | cut -d '"' -f 4 | grep sha512sum 2>/dev/null)" 2>/dev/null)
        if diff <(sha512sum "$0" | cut -d ' ' -f1) <(echo "$sha_web" | cut -d ' ' -f1) >/dev/null 2>&1; then
            to_debug_file "[INFO] Is the same version"
        else
            to_debug_file "[WARING] Updating $NOMBRE"
            local URL
            URL=$(curl -s "$MYAPP_FILE_FROM_INTERNET" | grep browser_download_url | cut -d '"' -f 4 | grep x86_64| grep -w ge-proton-rr.sh)
            wget -O "$0".bak -q --show-progress "$URL" >/dev/null 2>&1
            # shellcheck disable=SC2181
            if [ $? -eq 0 ]; then
                echo "[WARNING] $NOMBRE is updated. Please, rerun this tool!"
                cp "$0" "$OLDVERSION" && mv "$0".bak "$0" && chmod +x "$0"
                [ "$GEP_NOGUI" != "Y" ] && zenity --title="$NOMBRE - ver.$VERSION" --info --text "$NOMBRE is updated. Please, rerun this tool!" --width=300 --height=80
                [ -n "$DEBUG" ] && to_debug_file "[INFO] UPDATER: $NOMBRE updated to $VERSION_UPDATE Exiting"
                post_launch
                exit 8
            else
                to_debug_file "[ERROR] Cannot download the latest version."
            fi
        fi
    else
        to_debug_file "[WARNING] You don't have Internet"
    fi

    [ -f "$__file" ] && rm "$__file"
}

##
# Launch on Gui mode
#
gui_gep(){
    [ -n "$GEP_NOGUI" ] && return 0

    [ -n "$DEBUG" ] && to_debug_file "[INFO] GUI: Launching on gui mode."
    
    local __title="$NOMBRE - ver.$VERSION"
    local __lTEXTBIENVENIDA="Welcome to $NOMBRE.\nVersion: $VERSION.\n\nLicense: GNU General Public License v3.0\n\nby FranjeGueje\tfjgj1_hotmail.com"
    zenity --timeout 3 --title="$__title" --info --text "$__lTEXTBIENVENIDA" --width=300 --height=80
 
    if [ -d "$INSTALLFOLDER" ];then
        local __version_installed= ; local __file_version=
        __file_version=$(basename "$(find /home/deck/.local/share/Steam/compatibilitytools.d/GE-Proton/ -type f -name "version-*")")
        __version_installed="\nIt appears that the current version installed for $NOMBRE is ${__file_version//"version-"/}\n"
    else
        __version_installed="\nIt appears that you do not have any GE-Proton Rolling Release version installed.\n"
    fi

    local __buttonInstall="Install Autostart" __buttonRemove="Remove Autostart"
    local __checkboxes=
    __checkboxes=$(zenity --list --checklist \
        --title="$__title" \
        --text="Download the latest version of GE-Proton in Rolling Release mode and add it to Steam as a compatibility tool.\n\
After restarting Steam, the compatility tool will appear as \"GE-Proton\".\n$__version_installed\n\
Would you like to check if you can install or upgrade to the latest version of GE-Proton?\nYou can also choose from the following options:" \
        --column="" --column="ID" --column="Options" \
        FALSE "force" "Forcing the (re)installation of last version of GE-Proton from Internet" \
        FALSE "no-backup" "NOT back up the actual GE-Proton in case of upgrading current version" \
        FALSE "debug" "Collecting logs of all operations in debug.log file" \
        --separator="|" \
        --width=300 \
        --height=350 \
        --hide-column=2 \
        --extra-button="$__buttonInstall" \
        --extra-button="$__buttonRemove" )

    local __response=$?
    [ -n "$DEBUG" ] && to_debug_file "[INFO] GUI: The values of options are: $__checkboxes"

    if [ "$__checkboxes" == "$__buttonInstall" ];then
        [ -n "$DEBUG" ] && to_debug_file "[INFO] GUI: Installing the autostart desktop."
        do_install
        zenity --title="$__title" --info \
        --text "Installed the autoupdate file for $NOMBRE.\n$NOMBRE will now attempt to update automatically and silently every time the Desktop is started." \
        --width=300 --height=80
        [ -n "$DEBUG" ] && to_debug_file "[INFO] GUI: Installed in $HOME/.config/autostart/ge-proton-rr.desktop"
    elif [ "$__checkboxes" == "$__buttonRemove" ];then
        [ -n "$DEBUG" ] && to_debug_file "[INFO] GUI: Removing the autostart desktop."
        do_uninstall
        zenity --title="$__title" --info --text "Removed the autoupdate from the file $HOME/.config/autostart/ge-proton-rr.desktop" --width=300 --height=80
    elif [ $__response -eq 0 ]; then
        local __parameters=("--no-gui")
        if [ -z "$__checkboxes" ]; then
            [ -n "$DEBUG" ] && to_debug_file "[INFO] GUI: No option has been selected."
        else
            IFS='|' read -r -a selected_options <<< "$__checkboxes"
            for option in "${selected_options[@]}"; do
                __parameters+=("--$option")
            done
        fi
        [ -n "$DEBUG" ] && to_debug_file "[INFO] GUI: Running..."
        if curl -s https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/latest | grep browser_download_url >/dev/null 2>&1; then
            [ -f "$INSTALLFOLDER"version ] && PRE_version=$(cat "$INSTALLFOLDER"version)
            "$0" "${__parameters[@]}" &
            PID=$!
            (
            i=0
            while ps -p $PID > /dev/null 2>&1; do
                echo $i
                sleep 0.05
                ((i++))
                [ $i -eq 99 ] && i=0
            done
            ) | zenity --progress --title="$__title" --text="Please wait until $NOMBRE has finished ..." --percentage=0 --auto-close --no-cancel
            wait $PID
            EXIT_CODE=$?
            if [ "$EXIT_CODE" = 88 ]; then
                echo -e "[INFO] It seems that there is no need to install a new version."
                zenity --title="$__title" --info --text "It seems that there is no need to install a new version" --width=300 --height=80 --no-wrap
                post_launch
                exit 88
            fi
            [ -f "$INSTALLFOLDER"version ] && POST_version=$(cat "$INSTALLFOLDER"version)
            if [ "$PRE_version" != "$POST_version" ]; then
                if zenity --timeout 8 --question --title="$__title" --text="Remember to restart Steam so that it recognizes this compatility tool.\nDo you want to do it now?" --width=300 --height=80 ; then
                    # Yes
                    pkill steam
                fi
            fi
        else
            zenity --title="$__title" --error --text "You don't seem to have internet" --width=300 --height=80
        fi
    else
        [ -n "$DEBUG" ] && to_debug_file "[INFO] GUI: Canceling...Exiting from gui mode."
    fi
    
    zenity --timeout 2 --title="$__title" --info --text "Finish. Thank you!\n\nMade with love." --width=300 --height=80
    exit 0
}

##
# Check system requirements
#
check_requisites(){
    local __requisites=("wget" "curl")
    local __test=

    for i in "${__requisites[@]}"; do
        if ! __test=$(which "$i" 2>/dev/null); then
            [ -n "$DEBUG" ] && to_debug_file "[ERROR] REQUIREMENTS: Missing required component $i"
            echo "[ERROR] Missing required component $i" && exit 1
        fi
    done

    if [ ! -d "$COMPATFOLDER" ];then
        [ -n "$DEBUG" ] && to_debug_file "[ERROR] REQUIREMENTS: Missing Steam folder"
        echo "[ERROR] Missing Steam folder" && exit 1
    fi

     # Has zenity this machine?
    if ! which zenity >/dev/null 2>&1; then
        [ -n "$DEBUG" ] && to_debug_file "[WARNING] REQUIREMENTS: Missing zenity program. Running on bash"
        GEP_NOGUI=Y
    fi

    [ -n "$DEBUG" ] && to_debug_file "[INFO] REQUIREMENTS: Requirements is OK."
}

##
# Download the lastest GE-Proton from web
#
download_lastest_GE-Proton(){
    URL=$(curl -s https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/latest | grep browser_download_url | cut -d '"' -f 4 | grep ".tar.gz")
    [ -n "$DEBUG" ] && to_debug_file "[INFO] DOWNLOADER: The url to download GE-Proton is $URL"

    if [ -f "$CHECKURL" ] && [ "$URL" = "$(cat "$CHECKURL")" ] && [ "$GEP_INSTALLING" != 'Y' ];then
        [ -n "$DEBUG" ] && to_debug_file "[INFO] DOWNLOADER: It seems that there is no need to install a new version. The download url is the same as last time."
        post_launch
        exit 88
    fi

    [ -n "$DEBUG" ] && to_debug_file "[INFO] DOWNLOADER: There is a new url to download a new version or it need install a new version."
    
    [ -f "$DOWNLOADEDFILE" ] && rm "$DOWNLOADEDFILE" && [ -n "$DEBUG" ] && to_debug_file "[WARNING] DOWNLOADER: Removing the file $DOWNLOADEDFILE before download the new file."

    [ -n "$DEBUG" ] && to_debug_file "[INFO] DOWNLOADER: Starting to download the file"
    if ! wget -O "$DOWNLOADEDFILE" -q --show-progress "$URL" ;then
        [ -n "$DEBUG" ] && to_debug_file "[ERROR] DOWNLOADER: Cannot download the latest GE-Proton version."
        echo "[ERROR] Cannot download the latest GE-Proton version." && exit 2
    fi
    [ -n "$DEBUG" ] && to_debug_file "[INFO] DOWNLOADER: File downloaded from $URL"
}

##
# Extract the lastest GE-Proton from the DOWNLOADEDFILE
#
extract_gep(){
    [ -d "$EXTRACTFOLDER" ] && rm -Rf "$EXTRACTFOLDER"

    if [ ! -f "$DOWNLOADEDFILE" ];then
        [ -n "$DEBUG" ] && to_debug_file "[ERROR] EXTRACTOR: Unable to continue, file not found."
        echo "[ERROR] Unable to continue, file not found." && exit 3
    fi

    # Extract the tar.gz file
    [ -n "$DEBUG" ] && to_debug_file "[INFO] EXTRACTOR: Extracting the file $DOWNLOADEDFILE"
    if [ -n "$DEBUG" ];then
        (mkdir -p "$EXTRACTFOLDER" && cd "$EXTRACTFOLDER" && tar -xvzf "$DOWNLOADEDFILE" >>"$DEBUGFILE" 2>&1)
    else
        (mkdir -p "$EXTRACTFOLDER" && cd "$EXTRACTFOLDER" && tar -xvzf "$DOWNLOADEDFILE" >>/dev/null 2>&1)
    fi

    # Check if there are any folder
    local __count= ; local __name=
    __count=$(find "$EXTRACTFOLDER" -mindepth 1 -maxdepth 1 -type d | wc -l)
    __name=$(find "$EXTRACTFOLDER" -mindepth 1 -maxdepth 1 -type d )
    if [ "$__count" -ne 1 ]; then
        [ -n "$DEBUG" ] && to_debug_file "[ERROR] EXTRACTOR: The result of extract the tar.gz file is not a element."
        echo "[ERROR] Error extracting the GE-Proton file." && exit 4
    fi
    # Creating a personalize version name
    touch "$__name"/version-"$(basename "$__name")"
    echo "$URL" > "$__name"/url_downloaded
    [ -n "$DEBUG" ] && to_debug_file "[INFO] EXTRACTOR: Extraction complete and OK."
}

##
# Check if the downloaded file must be installed
#
should_be_installed(){
    [ -n "$GEP_INSTALLING" ] && return 0 # Check it should be installed if "force mode" is not present.
    
    [ -n "$DEBUG" ] && to_debug_file "[INFO] CHK_INSTALL: Checking if it must be installed."

    if [ ! -f "$INSTALLFOLDER"version ];then
        GEP_INSTALLING=Y
        [ -n "$DEBUG" ] && to_debug_file "[INFO] CHK_INSTALL: GE-Proton is not installed. It must be installed."
    else
        local __encontrado=
        __encontrado=$(find "$EXTRACTFOLDER" -maxdepth 2 -type f -name version)
        if [ -n "$__encontrado" ];then
            if diff "$INSTALLFOLDER"version "$__encontrado" > /dev/null; then
                [ -n "$DEBUG" ] && to_debug_file "[INFO] CHK_INSTALL: GE-Proton is the same version that the download file."
            else
                GEP_INSTALLING=Y
                [ -n "$DEBUG" ] && to_debug_file "[INFO] CHK_INSTALL: GE-Proton is a DIFFERENT version that the download file."
            fi
        fi
    fi
}

##
# Install the lastest GE-Proton to INSTALLFOLDER
#
install_gep(){
    [ -z "$GEP_INSTALLING" ] && return 0

    if [ -d "$INSTALLFOLDER" ];then
        [ -n "$DEBUG" ] && to_debug_file "[WARNING] INSTALLER: found other installation."
        if [ -z "$GEP_NOBACKUP" ];then
            [ -n "$DEBUG" ] && to_debug_file "[INFO] BACKUP: Creating a backup on $BACKUPFOLDER."
            [ -d "$BACKUPFOLDER" ] && rm -Rf "$BACKUPFOLDER"
            mkdir -p "$BACKUPFOLDER"
            mv "$INSTALLFOLDER" "$BACKUPFOLDER".
        else
            [ -n "$DEBUG" ] && to_debug_file "[INFO] BACKUP: NOT Create a backup."
            rm -Rf "$INSTALLFOLDER"
        fi
    fi
    [ -n "$DEBUG" ] && to_debug_file "[INFO] INSTALLER: Creating and preparing the directory $INSTALLFOLDER."
    mkdir -p "$INSTALLFOLDER"

    [ -n "$DEBUG" ] && to_debug_file "[INFO] INSTALLER: Moving the lastest files from $EXTRACTFOLDER to $INSTALLFOLDER"
    mv "$EXTRACTFOLDER"*/* "$INSTALLFOLDER"

    [ -n "$DEBUG" ] && to_debug_file "[INFO] INSTALLER: Creating the compatibilitytool.vdf on $INSTALLFOLDER"
    echo '"compatibilitytools"
{
  "compat_tools"
  {
    "GE-Proton" // Internal name of this tool
    {
      // Can register this tool with Steam in two ways:
      //
      // - The tool can be placed as a subdirectory in compatibilitytools.d, in which case this
      //   should be '.'
      //
      // - This manifest can be placed directly in compatibilitytools.d, in which case this should
      //   be the relative or absolute path to the tool s dist directory.
      "install_path" "."

      // For this template, we re going to substitute the display_name key in here, e.g.:
      "display_name" "GE-Proton"

      "from_oslist"  "windows"
      "to_oslist"    "linux"
    }
  }
}' > "$INSTALLFOLDER"compatibilitytool.vdf
    [ -n "$DEBUG" ] && to_debug_file "[INFO] INSTALLER: compatibilitytool.vdf file created"
}

#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#!         MAIN
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
pre_launch

#!GET PARAMETERS
while [ $# -ne 0 ]; do
    case "$1" in
    -h | --help)
        show_help
        exit 0
        ;;
    -f | --force)
        [ -n "$DEBUG" ] && to_debug_file "[INFO] PARAM: Force mode. The latest GE-Proton will be downloaded and installed even if it is the same one."
        GEP_INSTALLING=Y
        ;;
    -v | --debug | --verbose)
        DEBUG=Y
        [ -n "$DEBUG" ] && to_debug_file "[INFO] PARAM: Debug mode."
        ;;
    --no-gui)
        [ -n "$DEBUG" ] && to_debug_file "[INFO] PARAM: Silent and quiet mode. Automatically."
        GEP_NOGUI=Y
        ;;
    --no-backup)
        [ -n "$DEBUG" ] && to_debug_file "[INFO] PARAM: no backup of actual GE-Proton compatibility tool."
        GEP_NOBACKUP=Y
        ;;
    -i | --install)
        [ -n "$DEBUG" ] && to_debug_file "[INFO] PARAM: Install mode. Installing $NOMBRE in desktop's autostart."
        if [ "$GEP_AUTOSTART" == "N" ];then
            [ -n "$DEBUG" ] && to_debug_file "[ERROR] PARAM: You have selected --uninstall option before."
            show_help
            exit 253
        fi
        GEP_AUTOSTART=Y
        ;;
    -u | --uninstall)
        [ -n "$DEBUG" ] && to_debug_file "[INFO] PARAM: Install mode. Uninstalling $NOMBRE from desktop's autostart."
        if [ "$GEP_AUTOSTART" == "Y" ];then
            [ -n "$DEBUG" ] && to_debug_file "[ERROR] PARAM: You have selected --install option before."
            show_help
            exit 253
        fi
        GEP_AUTOSTART=N
        ;;
    *)
        echo -e "[ERROR] Parameter $1 is incorrect. Showing the help"
        [ -n "$DEBUG" ] && to_debug_file "[ERROR] PARAM: Parameter $1 is incorrect."
        show_help
        exit 253
        ;;
    esac
    shift
done

# Instalamos o no
inst_unins_autostart

show_title
check_requisites
should_be_updated
gui_gep
download_lastest_GE-Proton
extract_gep
should_be_installed
install_gep

post_launch
exit 0
