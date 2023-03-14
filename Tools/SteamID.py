import vdf
import sys
import os

def steam_id(shortcut_file_path:str, destination_file:str):
    """ Add to a file the tuple "Game Name"<tab>"IDAPP" 

    Args:
        shortcut_file_path (str): Full path to shortcuts.vdf
        destination_file (str): File to add the information "Game Name"<tab>"IDAPP" 
    """
    
    with open(shortcut_file_path, "rb") as f:
        shortcut = vdf.binary_load(f)
    
    with open(destination_file, 'a') as f:
        for k, v in shortcut["shortcuts"].items():
            appname= v.get("appname")
            appid=(int(v.get("appid")))+ 2**32

            f.write(f'{appname}\t{appid}\n')
            

if __name__ == '__main__':
    # * argv[1] --> shortcut_file from steam
    # * argv[2] --> file to add the information
    if len(sys.argv) == 3:
        if os.path.isfile(sys.argv[1]):
            steam_id(sys.argv[1],sys.argv[2])
        else:
            sys.exit("\"SteamID\" the vdf file doens't exists")
    else:
        sys.exit("\"SteamID\" necessarily requires two arguments")        
