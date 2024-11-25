# The script must take two optional arguments (DONE, more or less)
    # 1. the folder X where to search files (default: current folder); 
    # 2. a number of lines, here called N (default: 0)
# The report should include this information:
    # how many such files there are (DONE)
    # how many unique fasta IDs (i.e. the first words of fasta headers) they contain in total 
    # for each file:
    # print a nice header including filename; and:
        # whether the file is a symlink or not
        # how many sequences there are inside
        # the total sequence length in each file, i.e. the total number of amino acids or nucleotides of all sequences in the file. NOTE: gaps "-", spaces, newline characters should not be counted
        # Extra points: determine if the file is nucleotide or amino acids based on their content, and print a label to indicate this in this header
        # next, if the file has 2N lines or fewer, then display its full content; if not, show the first N lines, then "...", then the last N lines. If N is 0, skip this step.

if [[ $# -gt 2 ]]; then 
echo "The program only takes two arguments: the directory to check and the number of lines to print."
exit 3
fi

DIR="."
N_LINES=0

if [[ -n $1 ]]; then
    if [[ -d $1 ]]; then 
        DIR=$1
    else 
        echo "The first argument has to be the directory to check." >&2
        exit 3
    fi 
fi 

if [[ -n $2 ]]; then
    if [[ "$2" =~ ^[0-9]+$ ]]; then 
        N_LINES=$2 
    else 
        echo "The second argument has to be the number of lines to check." >&2
        exit 3
    fi 
fi

NUM_FILES=$(find $DIR -name "*.fasta" -or -name "*.fa" -type f 2>/dev/null| wc -l) 
if [[ NUM_FILES == 0 ]]; then echo "I haven't found any fasta files in this directory."
elif [[ NUM_FILES == 1 ]]; then echo "I have found 1 fasta file in this directory."
else echo "I have found" $NUM_FILES "fasta files in this directory."
fi

