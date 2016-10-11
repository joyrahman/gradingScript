#!/bin/bash 
export OMP_NUM_THREADS=$1 
echo "Threads:"
echo $OMP_NUM_THREADS
cd $2/source
time ./k_means -f data/example4_k8_m10000.txt -k 8 -i 10000

