FILE="/home/montse/Desktop/ALG/dataset1/scripts/firstlast_line.sh"
MESSAGE=$(echo "The file name is" $FILE)
LINES=$(cat $FILE | wc -l)
if [[ $LINES -eq 0 ]]; then echo $MESSAGE "and it is empty."
elif [[ $LINES -eq 1 ]]; then echo $MESSAGE "and it only has one line."
else echo $MESSAGE "and it has" $LINES "lines."
fi
