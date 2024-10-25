#this program outputs the first and last 3 lines of a file with three dots in between. 
#if the file is empty or there are less than 3 lines, it just outputs a space or the total number of lines.

#check if the argument is provided and if it is that it is a readable file. 
check_input(){
if [ -z "$1" ]; then
    echo "Error: you are missing the first argument." >&2
    echo "Please provide a file to check." >&2
    exit 1; 
elif [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo "Usage: peek [FILE]" >&2
    echo "Prints the first and last three lines of a file with three dots in between." >&2
    exit 1; 
elif [ ! -e "$1" ]; then
    echo "Error: $1 does not exist." >&2
    exit 1;
elif [ ! -f "$1" ]; then 
    echo "Error: $1 is not a file." >&2
    exit 1;
elif [ ! -r "$1" ]; then 
    echo "Error: $1 is not readable. Check file permissions." >&2
    exit 1;
fi
}

check_input "$1"
head -n 3 $1 
echo "..."
tail -n 3 $1 
