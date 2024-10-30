# This program takes multiple files and outputs its name as well as the number of lines, differentiating between 0, 1 and more than 1 line. 

check_if_file(){
if [ ! -e $FILE ]; then
    echo "Error: $FILE does not exist." >&2
    return 1
elif [ ! -f $FILE ]; then 
    echo "Error: $FILE is not a file." >&2
    return 1
elif [ ! -r $FILE ]; then 
    echo "Error: $FILE is not readable. Check file permissions." >&2
    return 1
else
    return 0
fi
}

if [ -z "$1" ]; then
    echo "Error: you are missing the first argument." >&2
    echo "Please provide a file to check." >&2
    exit 1
fi

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo "Usage: countlines [FILE]..."
    echo "Takes multiple files and outputs its name as well as the number of lines, distinguishing between 0, 1 and more than 1 lines."
    exit 0
fi

for FILE in "$@"; do
check_if_file $FILE
RESULT=$?
if [[ $RESULT -eq 0 ]]; then
    MESSAGE=$(echo "The file name is" $FILE)
    LINES=$(cat $FILE | wc -l)
    if [[ $LINES -eq 0 ]]; then echo $MESSAGE "and it is empty."
    elif [[ $LINES -eq 1 ]]; then echo $MESSAGE "and it only has one line."
    else echo $MESSAGE "and it has" $LINES "lines."
    fi
fi 
done 