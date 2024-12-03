#!/bin/bash

# This function prints a header taking into account the terminal size.
header() {
    local NAME_SPACE=$(( ${#1} ))
    local TERMINAL_SPACE=$(tput cols)
    local COL_SPACE=$(( (TERMINAL_SPACE - NAME_SPACE) / 2 - 1 ))
    local COLS=$(printf "%*s" $COL_SPACE | tr ' ' '=')
    echo "$COLS $1 $COLS"
}

usage() {
    echo "Usage: fastascan [DIRECTORY] [LINES]"
    echo "By default, the directory is the current working directory, and the number of lines is 0."
    echo "Searches for all .fasta and .fa files in the directory and subdirectories and prints some information about them: "
    echo "  1. Total number of files."
    echo "  2. Total number of unique fasta IDs."
    echo "  3. If the file is a symlink or not."
    echo "  4. The total number of sequences in a file."
    echo "  5. The total sequence length and whether the file contains protein or DNA sequences."
    echo "  6. If specified, prints the first and last number of lines. If the file contains less than two times the number of lines, it just prints the whole file."
    echo "WARNING! In case the file doesn't have permissions or is empty, it will be skipped."
}

# This function checks if the provided directory is valid and readable.
check_directory() {
    if [[ ! -d $1 ]]; then
        echo "Error: $1 is not a valid directory." >&2
        exit 1
    elif [[ ! -r $1 ]]; then
        echo "Error: $1 is not readable. Check permissions." >&2
        exit 1
    fi
}

# This function checks if the provided number of lines is a valid positive integer.
check_lines() {
    if ! [[ $1 =~ ^[0-9]+$ ]]; then
        echo "Error: $1 is not a valid number of lines." >&2
        exit 1
    fi
}

# This function checks if the file is a symlink.
check_symlink() {
    if [[ -h $1 ]]; then
        echo "The file IS a symlink."
    else
        echo "The file is NOT a symlink."
    fi
}

# This function counts the number of sequences in a file.
number_sequences() {
    local NUM_SEQ=$(grep -a ">" "$1" | wc -l)
    if [[ $NUM_SEQ -eq 1 ]]; then
        echo "This file contains 1 sequence."
    else
        echo "This file contains $NUM_SEQ sequences."
    fi
}

# This function takes all the sequences (filtering any gaps, spaces...) and returns its total length and
# whether it is a protein sequence, a DNA sequence, or undetermined.
DNA_or_prot_length() {
    local SEQ=$(grep -v -a ">" "$1" | tr -d -c 'a-zA-Z' | tr -d '\n')
    local LENGTH=${#SEQ}
    local DNA_ONLY_SEQ=$(echo "$SEQ" | tr -d 'ACGTNacgtn')
    local DNA_ONLY_LENGTH=${#DNA_ONLY_SEQ}
    if [[ $DNA_ONLY_LENGTH -eq 0 ]]; then
        echo "This file most likely contains DNA sequences with a total length of $LENGTH nucleotides."
    else
        # Check for presence of common protein residues to strengthen the identification
        local PROTEIN_RESIDUES=$(echo "$SEQ" | grep -o -i '[RKHLYQMNFWDEIVPSTC]' | wc -l)
        if [[ $PROTEIN_RESIDUES -gt 0 ]]; then
            echo "This file most likely contains protein sequences with a total length of $LENGTH amino acids."
        else
            echo "It was not possible to determine definitively if the file contains DNA or protein sequences."
            echo "The total sequence length is $LENGTH residues."
        fi
    fi
}

# This function prints the first and last number of lines in a file with three dots in between.
print_lines() {
    local TOTAL_LINES=$(wc -l < "$1")
    if [[ $TOTAL_LINES -le $(( 2 * $N_LINES )) ]]; then
        echo "Printing whole file"
        cat "$1"
    else
        echo "Printing first and last $N_LINES lines."
        head -n $N_LINES "$1"
        echo "..."
        tail -n $N_LINES "$1"
    fi
}

# Check that the provided arguments are adequate:
if [[ $# -gt 2 ]]; then
    echo "The program only takes two arguments: the directory to check and the number of lines to print."
    exit 1
fi

# Initialize flags to track if arguments have been set
DIR=$(pwd)
N_LINES=0
DIR_SET=0
LINES_SET=0

# This checks if the arguments provided are correct or not 
for arg in "$@"; do
    if [[ "$arg" == "-h" || "$arg" == "--help" ]]; then
        usage
        exit 0
    elif [[ -d "$arg" ]]; then
        if [[ $DIR_SET -eq 0 ]]; then
            check_directory "$arg"
            DIR="$arg"
            DIR_SET=1
        else
            echo "Warning: Multiple directories provided. Using the first one: $DIR" >&2
        fi
    elif [[ "$arg" =~ ^[0-9]+$ ]]; then
        if [[ $LINES_SET -eq 0 ]]; then
            check_lines "$arg"
            N_LINES="$arg"
            LINES_SET=1
        else
            echo "Warning: Multiple line numbers provided. Using the first one: $N_LINES" >&2
        fi
    else
        echo "Error: Invalid argument '$arg'" >&2
        echo "The script only takes two arguments: the directory to check and the number of lines to print."
        exit 1
    fi
done

echo
header "FASTASCAN"

# Print a small message that specifies the directory and number of lines.
echo
echo "Analyzing FASTA files from directory $DIR"
echo "The number of lines that will be printed is $N_LINES"
echo

# Store the names of all the FASTA files we can access.
FIND_FILES=$(find "$DIR" \( -name "*.fasta" -o -name "*.fa" \) -type f -o -type l 2>/dev/null)

# Obtain the number of FASTA files in our directory.
NUM_FILES=$(( $(echo "$FIND_FILES" | wc -l) - 1 ))

if [[ $NUM_FILES -eq 0 ]]; then
    echo "I haven't found any fasta files in this directory."
    exit 0
elif [[ $NUM_FILES -eq 1 ]]; then
    echo "I have found 1 fasta file in this directory."
else
    echo "I have found $NUM_FILES fasta files in this directory."
fi


# Get the unique IDs from our files.
FASTA_ID=$(grep -a ^">" $FIND_FILES 2>/dev/null | awk -F' ' '{print $1}' | sort | uniq -c | wc -l)
echo "There are a total of $FASTA_ID unique FASTA IDs."
echo

# Print the information for each file.
for FILE in $FIND_FILES; do
    header "ANALYZING $FILE"
    
    # Check that the file is readable.
    if [[ ! -r $FILE ]]; then
        echo "File $FILE cannot be read and will be skipped." >&2
        echo "Please check permissions and try again." >&2
        echo
        continue
    fi
    
    check_symlink "$FILE"
    
    # Check that the file is not empty.
    if [[ ! -s $FILE ]]; then
        echo "This file is empty. Following steps will be skipped." >&2
        echo
        continue
    fi
    
    number_sequences "$FILE"
    DNA_or_prot_length "$FILE"
    
    # Check that the user wants to print some lines.
    if [[ $N_LINES -gt 0 ]]; then
        print_lines "$FILE"
    fi
    
    echo
done

header "FASTASCAN"
echo
