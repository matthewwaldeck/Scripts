#Directory to be scanned.
cd #DIRECTORY

#This will pipe all the files in your current directory
#into Rename-Item, and replace whatever is in the first
#set of quotes withwhatever is in the second.
Dir | Rename-Item –NewName { $_.name –replace “ “,”_” }