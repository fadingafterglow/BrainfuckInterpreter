#! /bin/bash
# builds an *.asm file passed as argument

# Check if no arguments are provided
if [ "$#" -eq 0 ]; then
    echo "Usage: $0 <filename1> <filename2> ..."
    exit 1
fi

# Iterate through each provided filename
for filename in "$@"; do
    # Check if the file exists
    if [ ! -f "$filename" ]; then
        echo "File '$filename' not found."
        continue
    fi

    # Extract the file extension
    extension="${filename##*.}"

    # Check if the file has a .asm extension
    if [ "$extension" != "asm" ]; then
        echo "File '$filename' is not a NASM assembly file (.asm)."
        continue
    fi

    # Extract the filename without extension
    file_without_extension="${filename%.*}"

    # Build the NASM assembly file
    nasm -f elf32 "$filename" -o "$file_without_extension.o"

    # Check if the compilation was successful
    if [ $? -eq 0 ]; then
        echo "Build successful for '$filename'. Object file: '$file_without_extension.o'"
	echo "Linking..."
   	ld -m elf_i386 -s "$file_without_extension.o" -o "$file_without_extension"
	
	if [ $? -eq 0 ]; then
	    echo "Linking successful. Executable file: '$file_without_extension'"	       
	else
   	    echo "Linking failed."
  	fi
    else
        echo "Build failed for '$filename'."
    fi
done
