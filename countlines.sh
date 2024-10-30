# Choose a text file, then print its name and number of lines differentiating cases in which it has zero, one, or >1 line?
#     1. Make it into a script countlines.sh that takes one file as argument, put it in your github repo.
#     2. Update the script so that the user may provide any number of files as arguments (may need autonomous learning!)

FILE="/home/montse/Desktop/ALG/dataset1/scripts/firstlast_line.sh"
MESSAGE=$(echo "The file name is" $FILE)
LINES=$(cat $FILE | wc -l)
if [[ $LINES -eq 0 ]]; then echo $MESSAGE "and it is empty."
elif [[ $LINES -eq 1 ]]; then echo $MESSAGE "and it only has one line."
else echo $MESSAGE "and it has" $LINES "lines."
fi