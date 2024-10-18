files=$(find . -type f -name "*.fasta" -or -name "*.fa")
grep -h ">" $files
