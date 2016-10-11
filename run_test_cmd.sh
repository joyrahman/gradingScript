#!/bin/bash 
# $1 = num_threads
# $2 = input_file_name
# $3 = k
# $4 = i
# $7 = input_dir_name 
# $5 = output_file_name
# $6 = correct result file to compare
export OMP_NUM_THREADS=$1 
#echo $1, $2, $3, $4, $5, $6, $7

cd $7/source
./k_means -f data/$2 -k $3 -i $4 > $5_unsorted
sort -o $5 $5_unsorted
sort data/$6 > $6

DIFF=$(diff $6 $5)

if [ $? -eq 0 ]; then
    echo "0"
else 
    echo "-1"
fi

