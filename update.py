import os
import glob
import shutil

def main():
    with open("files.txt") as f:
        lines = f.read().splitlines()
        lines = [l.strip() for l in lines]
        
        for l in lines:
            print(l)
            
            for fl in glob.glob(os.path.expanduser(l)):
                if not os.path.isfile(fl):
                    listOfFiles = []
                    for (dirpath, dirnames, filenames) in os.walk(fl):
                        listOfFiles += [os.path.join(dirpath, fx) for fx in filenames]
                else:
                    listOfFiles = [fl]
                
                for n in listOfFiles:
                    copy(n)


def copy(l):
    original_file = l
    
    if l.startswith(os.path.expanduser('~') + "/"):
        l = "./" + l.removeprefix(os.path.expanduser('~') + "/")
    else:
        l = "fakeroot/" + l.removeprefix("/")
    
    l = l.strip()
    directory = os.path.dirname(l)
    
    if directory != ".":
        os.makedirs(directory, exist_ok=True)
    
    shutil.copy(original_file, directory)


main()
