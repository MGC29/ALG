# The script must take two optional arguments (DONE)
    # 1. the folder X where to search files (default: current folder); 
    # 2. a number of lines, here called N (default: 0)
# The report should include this information:
    # how many such files there are (DONE)
    # how many unique fasta IDs (i.e. the first words of fasta headers) they contain in total (DONE? ASK)
    # for each file:
    # print a nice header including filename; and:
        # whether the file is a symlink or not (DONE, must check if original file has access)
        # how many sequences there are inside (DONE? ask if all fata ids will have a sequence)
        # the total sequence length in each file, i.e. the total number of amino acids or nucleotides of all sequences in the file. NOTE: gaps "-", spaces, newline characters should not be counted
        # Extra points: determine if the file is nucleotide or amino acids based on their content, and print a label to indicate this in this header
        # next, if the file has 2N lines or fewer, then display its full content; if not, show the first N lines, then "...", then the last N lines. If N is 0, skip this step.

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

# Here we print a small message that specifies the directory and number of lines 
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

# Here we get the unique IDs from our files 
FASTA_ID=$(cat $FIND_FILES 2>/dev/null | grep ">" | sort | uniq -c | wc -l)
echo "There are a total of" $FASTA_ID "unique FASTA IDs."
echo

# Here we print the information for each file 
for FILE in $FIND_FILES; do
    echo "=== *** ANALIZING" $FILE "*** ===" 
    if [[ -r $FILE ]]; then
        if [[ -h $FILE ]]; then 
            echo $FILE "is a symlink."
        else 
            echo $FILE "is not a symlink."
        fi
        NUM_SEQ=$(grep ">" $FILE | wc -l)
        echo "This file contains a total of" $NUM_SEQ "sequences."
    else
        echo "File" $FILE "can not be read and will be skipped." >&2
        echo "Please check permissions and try again." >&2
    fi
    echo 
done
