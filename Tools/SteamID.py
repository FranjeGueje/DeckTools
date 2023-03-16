from vdf import binary_load
from sys import argv, exit
from os import path
from os.path import isfile

def steam_id(shortcut_file_path:str, destination_file:str):
    """ Add to a file the tuple "Game Name"<tab>"IDAPP" 

    Args:
        shortcut_file_path (str): Full path to shortcuts.vdf
        destination_file (str): File to add the information "Game Name"<tab>"IDAPP" 
    """
    
    with open(shortcut_file_path, "rb") as f:
        shortcut = binary_load(f)
        shortcut =  {k.lower(): v for k, v in shortcut.items()}
    
    with open(destination_file, 'a') as f:
        for k, v in shortcut["shortcuts"].items():
            v =  {k.lower(): h for k, h in v.items()}
            appname= v.get("appname")
            appid=(int(v.get("appid")))+ 2**32

            f.write(f'{appname}\t{appid}\n')
            

if __name__ == '__main__':
    # * argv[1] --> shortcut_file from steam
    # * argv[2] --> file to add the information
    if len(argv) == 3:
        if isfile(argv[1]):
            steam_id(argv[1],argv[2])
        else:
            exit("SteamID: the vdf file doens't exists")
    else:
        exit("SteamID necessarily requires two arguments")        
