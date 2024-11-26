# The script must take two optional arguments (DONE)
    # 1. the folder X where to search files (default: current folder); 
    # 2. a number of lines, here called N (default: 0)
# The report should include this information:
    # how many such files there are (DONE)
    # how many unique fasta IDs (i.e. the first words of fasta headers) they contain in total (DONE? ASK)
    # for each file:
    # print a nice header including filename; and:
        # whether the file is a symlink or not
        # how many sequences there are inside
        # the total sequence length in each file, i.e. the total number of amino acids or nucleotides of all sequences in the file. NOTE: gaps "-", spaces, newline characters should not be counted
        # Extra points: determine if the file is nucleotide or amino acids based on their content, and print a label to indicate this in this header
        # next, if the file has 2N lines or fewer, then display its full content; if not, show the first N lines, then "...", then the last N lines. If N is 0, skip this step.

check_args(){
    if [[ -d $1 ]]; then 
        if [[ $DIR == '.' ]]; then 
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
        echo "The program only takes two arguments: the directory to check and the number of lines to print. "
        echo "The argument" $1 "is incorrect."
        exit 1
    fi 
}

DIR="."
N_LINES=0
FILE_NAMES=""

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

# Here we obtain the number of FASTA files in our directory. 
NUM_FILES=$(find $DIR -name "*.fasta" -or -name "*.fa" -type f 2>/dev/null | wc -l) 
if [[ NUM_FILES -eq 0 ]]; then 
    echo "I haven't found any fasta files in this directory."
    exit 0
    elif [[ NUM_FILES -eq 1 ]]; 
        then echo "I have found 1 fasta file in this directory."
    else 
        echo "I have found" $NUM_FILES "fasta files in this directory."
fi

# Here we obtain a list with the names of the readable FASTA files 
for FILE in $(find $DIR -name "*.fasta" -or -name "*.fa" -type f 2>/dev/null); do 
    if [[ -r $FILE ]]; then 
        FILE_NAMES+="$FILE "
    fi 
done 

# Here we get the unique IDs from our files 
FASTA_ID=$(cat $FILE_NAMES | grep ">" | sort | uniq -c | wc -l)
echo "There are a total of" $FASTA_ID "unique FASTA IDs"


