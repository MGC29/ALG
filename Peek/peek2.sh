# This file outputs the first and last number of required lines of a file with three dots in between. 
# In case the 

#This function checks that the argument exists and is a readable file. 
check_if_file(){
if [ ! -e "$1" ]; then
    echo "Error: $1 does not exist."
    exit 1
elif [ ! -f "$1" ]; then 
    echo "Error: $1 is not a file."
    exit 1
elif [ ! -r "$1" ]; then 
    echo "Error: $1 is not readable. Check file permissions."
    exit 1
fi
}

#This function checks that the argument is zero or a positive integer.
check_if_number(){
if [[ ! "$1" =~ ^[0-9]+$ ]]; then
    echo "The second argument has to be zero or a positive integer."
    exit 1
fi
}

#This function checks that both arguments (fle and number) are present and correct. 
check_input(){
if [ -z "$1" ]; then
    echo "Error: you are missing the first argument."
    echo "Please provide a file to check."
    exit 1
elif [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo "Usage: peek [FILE] [NUMBER]"
    echo "Prints the first and last NUMBER of lines of the FILE with three dots in between."
    echo "If NUMBER is 0, it just prints the three dots. If NUMBER is higher than the number of lines in FILE, it prints the maximum number of lines."
    exit 1
else
    check_if_file $1
fi

if [ -z "$2" ]; then
    echo "Error: you are missing the second argument."
    echo "Please provide a number of lines to print."
    exit 1
else 
    check_if_number $2
fi 
}

check_input $1 $2
head -n $2 $1 
echo "..."
tail -n $2 $1

#TO CHECK: it is not outputing the error messages as standard error but as standard output. 