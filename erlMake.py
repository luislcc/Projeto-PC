import os
import subprocess

baseFolder = os.getcwd() + "/Server"
tgtFolder = "build"

try: 
    os.chdir(baseFolder)
    print("Directory changed")
except OSError:
    print("Can't change the Current Working Directory")   


print(os.getcwd())
erlFiles = [file for file in os.listdir(os.getcwd()) if file.endswith(".erl")]


print(f"compiling - {erlFiles}:\n")
p = subprocess.Popen(['ubuntu', 'run', 'erlc'] + erlFiles)
ret = p.wait()
p = subprocess.Popen(['ubuntu', 'run', 'mv', '*.beam', tgtFolder])
ret += p.wait()
	
	
if ret:
	print(f"\nCompilation Error\n")
else:
	print(f"Compilation Successfull\n")

