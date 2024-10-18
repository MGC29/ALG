#This file outputs the required number of lines on each end of a file. 
head -n $2 $1 
echo "..."
tail -n $2 $1
