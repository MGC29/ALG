# This function prints a header taking into account the terminal size. 
header(){
    NAME_SPACE=$(( $(echo $1 | wc -m) - 1 ))
    TERMINAL_SPACE=$(tput cols)
    COL_SPACE=$(( (($TERMINAL_SPACE - $NAME_SPACE) / 2) - 1 ))
    COLS=$(printf "%*s" $COL_SPACE | tr ' ' '=')
    echo $COLS $1 $COLS
}

# This function checks that the argument provided is correct. 
check_args(){
    if [[ -d $1 ]]; then 
        if [[ $DIR == $(pwd) ]]; then 
            if [[ -r $1 ]]; then
                DIR=$1
            else
                echo "I don't have permission to check this directory." >&2
                exit 1
            fi
        else echo "You have provided two directories to check. By default the first one will be used." >&2
        fi
    elif [[ "$1" == "-h" || "$1" == "--help" ]]; then 
        echo "Usage: fastascan [DIRECTORY] [LINES]"
        echo "By default the directory is the current working directory and the number of lines are 0."
        echo "Searches for all .fasta and .fa files in the directory and subdirectories and prints some information about them: "
        echo "  1. Total number of files."
        echo "  2. Total number of unique fasta IDs."
        echo "  3. If the file is a symlink or not."
        echo "  4. The total number of sequences in a file."
        echo "  5. The total sequence lenght and whether the file contains protein or DNA sequences."
        echo "  6. If specified, prints the first and last number of lines. If the file contains less than two times the number of lines, it just print the whole file."
        echo "WARNING! In case the file doesn't have permsisions or is empty, it will be skipped."
        exit 0    
    elif [[ $1 =~ ^[0-9]+$ ]]; then 
        if [[ $N_LINES -eq 0 ]]; then 
            N_LINES=$1 
        else echo "You have provided two number of lines to check. By default the first one will be used." >&2
        fi
    else 
        echo "The program only takes two arguments: the directory to check and the number of lines to print." >&2
        echo "The argument" $1 "is incorrect." >&2
        exit 1
    fi 
}

# This function checks if the file is a symlink.
check_symlink(){
    if [[ -h $1 ]]; then 
        echo "The file IS a symlink."
    else 
        echo "The file is NOT a symlink."
    fi
}

# This function counts the number of sequences in a file. 
number_sequences(){
    NUM_SEQ=$(grep -a ">" $FILE | wc -l)
    if [[ $NUM_SEQ -eq 1 ]]; then 
        echo "This file contains 1 sequence."
    else 
        echo "This file contains" $NUM_SEQ "sequences." 
    fi
}

# This function takes all the sequences (filtering any gaps, spaces...) and returns its total lenght and 
# whether it is a protein sequence, a DNA sequence or undeterminded. To do this last part, it filters letters 
# A,G,T,C,N which are the representations of the nucleotides. If the lenght of the filtered sequence is 0,
# most likely the sequence is DNA, as it would be strange for a protein to be composed of only 4/5 amino acids. 
DNA_or_prot_lenght(){
    SEQ=$(grep -v -a ">" $1 | sed 's/[^a-zA-Z]//g' | tr -d '\n')
    LENGHT=$(echo $SEQ | tr -d '\n' | wc -m)
    MOD_SEQ=$(echo $SEQ | sed 's/[ACGTNacgtn]//g')
    MOD_LENGHT=$(echo $MOD_SEQ | tr -d '\n' | wc -m)
    if [[ $MOD_LENGHT -eq 0 ]]; then 
        echo "This file most likely contains DNA sequences with a total lenght of" $LENGHT "nucleotides." 
    elif echo $MOD_SEQ | grep -a -q -i '^[RDEQHILKMFPSWYVUOX]*$'; then
        echo "This file most likely contains protein sequences with a total lenght of" $LENGHT "amino acids." 
    else 
        echo "It was not possible to determine if the file contains DNA or protein sequences."
        echo "The total sequence lenght is" $LENGHT "residues."
    fi
}

# This function prints the first and last number of lines in a file with three dots in between. 
print_lines(){
    TOTAL_LINES=$(cat $1 | wc -l)
    if [[ $TOTAL_LINES -le $(( 2 * $N_LINES )) ]]; then
        echo "Printing whole file"
        cat $FILE
    else
        echo "Printing first and last" $N_LINES "lines."
        head -n $N_LINES $1 
        echo "..."
        tail -n $N_LINES $1
    fi
}

DIR=$(pwd)
N_LINES=0

# Here we check that the provided arguments are adequate:
#   1. That there are no more than 2 arguments.
#   2. That the arguments are a directory and/or a number. 
if [[ $# -gt 2 ]]; then 
    echo "The program only takes two arguments: the directory to check and the number of lines to print."
    exit 1
    else
        for arg in $@; do
            check_args $arg
        done
fi

echo 
header FASTASCAN

# Here we print a small message that specifies the directory and number of lines.
echo 
echo "Analyzing FASTA files from directory" $DIR
echo "The number of lines that will be printed is" $N_LINES
echo

# Here we store the names of all the FASTA files we can access.
FIND_FILES=$(find $DIR -name "*.fasta" -or -name "*.fa" -type f -or -type l 2>/dev/null)

# Here we obtain the number of FASTA files in our directory. 
NUM_FILES=$(echo "$FIND_FILES"| wc -l) 
if [[ NUM_FILES -eq 0 ]]; then 
    echo "I haven't found any fasta files in this directory."
    exit 0
    elif [[ NUM_FILES -eq 1 ]]; 
        then echo "I have found 1 fasta file in this directory."
    else 
        echo "I have found" $NUM_FILES "fasta files in this directory."
fi

# Here we get the unique IDs from our files.
FASTA_ID=$(cat $FIND_FILES 2>/dev/null | grep ^">" -a | awk -F' ' '{print $1}' | sort | uniq -c | wc -l)
echo "There are a total of" $FASTA_ID "unique FASTA IDs."
echo

# Here we print the information for each file.
for FILE in $FIND_FILES; do
    header "ANALYZING $FILE"
    # Here we check that the file is readable. 
    if [[ ! -r $FILE ]]; then 
        echo "File" $FILE "can not be read and will be skipped." >&2
        echo "Please check permissions and try again." >&2
        echo 
        continue
    fi
    check_symlink $FILE
    # Here we check that the file is not empty. 
    if [[ ! -s $FILE ]]; then 
        echo "This file is empty. Following steps will be skipped." >&2
        echo 
        continue
    fi
    number_sequences $FILE
    DNA_or_prot_lenght $FILE
    # Here we check that the user wants to print some lines
    if [[ $N_LINES -gt 0 ]]; then print_lines $FILE; fi 
    echo 
done

header FASTASCAN
echo 