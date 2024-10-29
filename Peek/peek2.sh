# This file outputs the first and last number of required lines of a file with three dots in between.
# If the number of lines is not stated, it prints 3 lines by default 
# If the file is empty it just outputs the three dots.
# If the total number of lines is less than or equal to 2*number it just prints the whole file. 

#This function checks that the argument exists and is a readable file. 
check_if_file(){
if [ ! -e "$1" ]; then
    echo "Error: $1 does not exist." >&2
    exit 1
elif [ ! -f "$1" ]; then 
    echo "Error: $1 is not a file." >&2
    exit 1
elif [ ! -r "$1" ]; then 
    echo "Error: $1 is not readable. Check file permissions." >&2
    exit 1
fi
}

#This function checks that the argument is zero or a positive integer.
check_if_number(){
if [[ ! "$1" =~ ^[0-9]+$ ]]; then
    echo "The second argument has to be zero or a positive integer." >&2
    exit 1
fi
}

#This function checks that both arguments (file and number) are correct. 
check_input(){
if [ -z "$1" ]; then
    echo "Error: you are missing the first argument." >&2
    echo "Please provide a file to check." >&2
    exit 1
elif [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo "Usage: peek [FILE]"
    echo "Usage: peek [FILE] [NUMBER]"
    echo "Prints the first and last NUMBER of lines of the FILE with three dots in between."
    echo "If the NUMBER is not stated, it prints 3 lines by default."
    echo "If NUMBER is 0, it just prints the three dots." 
    echo "If the number of lines in FILE is less than or equal to 2*NUMBER, then it prints the whole file."
    exit 1
else
    check_if_file $1
fi
if [ ! -z "$2" ]; then
    check_if_number $2
fi 
}

check_input $1 $2

if [[ -z "$2" ]]; then
    head -n 3 $1 
    echo "..."
    tail -n 3 $1
elif [[ $(cat $1 | wc -l) -le $((2 * $2)) ]]; then
    cat $1
else
    head -n $2 $1 
    echo "..."
    tail -n $2 $1    
fi 




