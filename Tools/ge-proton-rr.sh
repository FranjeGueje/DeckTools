#!/bin/bash

##############################################################################################################################################################
# AUTOR: Paco Guerrero <fjgj1@hotmail.com>
# PROJECT: GE-Proton Rolling Releale installer
# ABOUT: Download and add the latest version of GE-Proton as a Steam compatibility tool by always using the same one
#
# PARAMS:
# --no-gui --> unattended
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
    \n$0 [-v] [-f] [--no-gui] [--no-backup]\n\
    \n[Parameters]\n\
    \t-h|--help\t\tThis help.\n\
    \t-v|--debug|--verbose\tThis parameter will creating a file $DEBUGFILE with verbose info.\n\
    \t-f|--force\t\tThe latest GE-Proton will be downloaded and installed forcibly.\n\
    \t--no-gui\t\tRun $NOMBRE automatically.\n\
    \t--no-backup\t\tNo backup the actual GE-Proton of compatibility folder."
}

##
# Initialize the script
#
pre_launch(){
    NOMBRE="GE-Proton Rolling Release"
    VERSION=0.1

    TOOLPATH=$(readlink -f "$(dirname "$0")")
    DEBUGFILE="$TOOLPATH/debug.log"
    DOWNLOADEDFILE="$TOOLPATH/GE-Proton.tar.gz"
    EXTRACTFOLDER="$TOOLPATH/.extract/"

    COMPATFOLDER="$HOME/.local/share/Steam/compatibilitytools.d/"
    INSTALLFOLDER="$COMPATFOLDER"GE-Proton/
    BACKUPFOLDER="$TOOLPATH"/GE-Proton_backup/

    [ -n "$DEBUG" ] && echo -e "--------------------------------BEGIN-----------------------------------------------" >>"$DEBUGFILE"
}

##
# Finish the script
#
post_launch(){    
    [ -f "$DOWNLOADEDFILE" ] && rm -f "$DOWNLOADEDFILE"
    [ -d "$EXTRACTFOLDER" ] && rm -Rf "$EXTRACTFOLDER"
    [ -n "$DEBUG" ] && to_debug_file "Exiting..."
    echo -e "Exiting..."
    exit 0
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
# Print the title and version
#
show_title(){
    echo -e "Launching \"$NOMBRE\" - $VERSION ver.\nThis script will download and install the lastest GE-Proton from Internet."
}

##
# Launch on Gui mode
#
gui_gep(){
    [ -n "$GEP_NOGUI" ] && return 0

    [ -n "$DEBUG" ] && to_debug_file "[INFO] GUI: Launching on gui mode."
    
    local __lTEXTBIENVENIDA="Welcome to $NOMBRE.\nVersion: $VERSION.\n\nLicense: GNU General Public License v3.0\n\nby FranjeGueje\tfjgj1_hotmail.com"
    zenity --timeout 3 --title="$NOMBRE $VERSION" --info --text "$__lTEXTBIENVENIDA" --width=300 --height=80

    local __title="$NOMBRE - $VERSION ver."
 
    if [ -d "$INSTALLFOLDER" ];then
        local __version_installed= ; local __file_version=
        __file_version=$(basename "$(find /home/deck/.local/share/Steam/compatibilitytools.d/GE-Proton/ -type f -name "version-*")")
        __version_installed="\nIt appears that the current version installed for $NOMBRE is ${__file_version//"version-"/}\n"
    else
        __version_installed="\nIt appears that you do not have any GE-Proton Rolling Release version installed.\n"
    fi

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
        --hide-column=2 )

    local __response=$?
    [ -n "$DEBUG" ] && to_debug_file "[INFO] GUI: The values of options are: $__checkboxes"
    if [ $__response -eq 0 ]; then
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
        "$0" "${__parameters[@]}" &
        PID=$!
        zenity --timeout 10 --title="$NOMBRE $VERSION" --info --text "Please wait until a completion message appears." --width=300 --height=80
        wait $PID
        zenity --timeout 5 --question --title="$NOMBRE $VERSION" --text="Remember to restart Steam so that it recognizes this compatility tool.\nDo you want to do it now?" --width=300 --height=80
        if [ $? -eq 0 ]; then
            # Yes
            pkill steam
        fi
    else
        [ -n "$DEBUG" ] && to_debug_file "[INFO] GUI: Canceling...Exiting from gui mode."
    fi
    
    zenity --timeout 2 --title="$NOMBRE $VERSION" --info --text "Finish. Thank you!" --width=300 --height=80
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
            echo "Missing required component $i" && exit 1
        fi
    done

    if [ ! -d "$COMPATFOLDER" ];then
        [ -n "$DEBUG" ] && to_debug_file "[ERROR] REQUIREMENTS: Missing Steam folder"
        echo "Missing Steam folder" && exit 1
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
    local __url=

    __url=$(curl -s https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/latest | grep browser_download_url | cut -d '"' -f 4 | grep ".tar.gz")
    [ -n "$DEBUG" ] && to_debug_file "[INFO] DOWNLOADER: The url to download GE-Proton is $__url"
    
    [ -f "$DOWNLOADEDFILE" ] && rm "$DOWNLOADEDFILE" && [ -n "$DEBUG" ] && to_debug_file "[WARNING] DOWNLOADER: Removing the file $DOWNLOADEDFILE before download the new file."

    [ -n "$DEBUG" ] && to_debug_file "[INFO] DOWNLOADER: Starting to download the file"
    if ! wget -O "$DOWNLOADEDFILE" -q --show-progress "$__url" ;then
        [ -n "$DEBUG" ] && to_debug_file "[ERROR] DOWNLOADER: Cannot download the latest GE-Proton version."
        echo "Cannot download the latest GE-Proton version." && exit 2
    fi
    [ -n "$DEBUG" ] && to_debug_file "[INFO] DOWNLOADER: File downloaded from $__url"
}

##
# Extract the lastest GE-Proton from the DOWNLOADEDFILE
#
extract_gep(){
    [ -d "$EXTRACTFOLDER" ] && rm -Rf "$EXTRACTFOLDER"

    if [ ! -f "$DOWNLOADEDFILE" ];then
        [ -n "$DEBUG" ] && to_debug_file "[ERROR] EXTRACTOR: Unable to continue, file not found."
        echo "Unable to continue, file not found." && exit 3
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
        echo "Error extracting the GE-Proton file." && exit 4
    fi
    # Creating a personalize version name
    touch "$__name"/version-"$(basename "$__name")"
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
    *)
        echo -e "Parameter $1 is incorrect. Showing the help"
        [ -n "$DEBUG" ] && to_debug_file "[ERROR] PARAM: Parameter $1 is incorrect."
        show_help
        exit 253
        ;;
    esac
    shift
done

show_title
check_requisites
gui_gep
download_lastest_GE-Proton
extract_gep
should_be_installed
install_gep

post_launch
