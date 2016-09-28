#!/bin/bash

#open each file in the directory
#extract user_id from file_name
#copy the file to build_dir
#do the build
#compare the result
#give the score
#append the score to a csv file


## remove white space in file name
#  find -name "* *" -type f | rename 's/ /_/g'

function compile_and_run
{
    # take two parameters:
    #    $1: the source file to compile
    #    $2: the output binary file name
    #    $3: the compile log file name
    #    $4: the execution output file name
    #    $5: the working directory
    #    $6: O3 or note 0: no ; 1: yes
    # Return values:
    #    0: success
    #    1: compilation failed
    #    2: time out during execution
    #    3: segmentation fault
    
    #   1: $output_file
    #   2: $exec_file
    #   3: $user_id
    total_score=0
    score_file="$3.log"
    make

    if [ ! -e $2 ]
    then
        # compile error
	return 1
    fi
    
    #echo "+ Compilation passed: 10 points" >> ${score_file}
    echo "+ Compilation passed: 10 points" 
    
    total_score=$(($total_score+10))
    # run the program
    # test1
    ./$2 -f data/example1_k2_m10.txt -k 2 -i 100 > test1_unsorted 2>&1
    echo "run test1"
    sort test1_unsorted > test1
    echo "result test1 sorted"
    #DIFF=$(diff ./test1 ../../correct_output/test1 >>${score_file})
    DIFF=$(diff ./test1 ../../correct_output/test1)

    if [ $? -eq 0 ]; then
       echo "+ Test1 passed: 15 points"
       #echo "+ Test1 passed: 15 points" >> ${score_file}
       total_score=$(($total_score+15))
    
    fi
    #test2
    ./$2 -f data/example2_k3_m30.txt -k 3 -i 100 > test2_unsorted 2>&1
    sort test2_unsorted > test2
    
    DIFF=$(diff ./test2 ../../correct_output/test2 >>${score_file})
    if [ $? -eq 0 ]; then
       echo "+ Test2 passed: 15 points" >> ${score_file}
       total_score=$(($total_score+15))
    
    fi
    #test3
    
    ./$2 -f data/example3_k5_m500.txt -k 5 -i 100 > test3_unsorted 2>&1
    sort test3_unsorted > test3
    DIFF=$(diff ./test3 ../../correct_output/test3 >>${score_file})
    
    if [ $? -eq 0 ]; then
       echo "+ Test3 passed: 15 points" >> ${score_file}
       total_score=$(($total_score+15))
    
    fi
    #test4
    ./$2 -f data/example4_*.txt -k 5 -i 100 > test4_unsorted 2>&1
    sort test4_unsorted > test4
    DIFF=$(diff ./test4 ../../correct_output/test4 >>${score_file})
    if [ $? -eq 0 ]; then
       echo "+ Test4 passed: 15 points" >> ${score_file}
       total_score=$(($total_score+15))
    
    fi
    
    #test5
    ./$2 -f data/example5_*.txt -k 4 -i 100 > test5_unsorted 2>&1
    sort test5_unsorted > test5
    DIFF=$(diff ./test5 ../../correct_output/test5 >>${score_file})
    if [ $? -eq 0 ]; then
       echo "+ Test5 passed: 15 points" >> ${score_file}
       total_score=$(($total_score+15))
    
    fi
    
    
    #test6
    ./$2 -f data/example6_*.txt -k 5 -i 100 > test6_unsorted 2>&1
    sort test6_unsorted > test6
    DIFF=$(diff ./test6 ../../correct_output/test6 >>${score_file})
    if [ $? -eq 0 ]; then
       echo "+ Test6 passed: 15 points" >> ${score_file}
       total_score=$(($total_score+15))
    
    fi

    
    
    local ret=$?
    
    if [ $ret -eq "139" ] # segfault
    then
	return 3
    elif [ $ret -eq "124" ] # not finished in 20s, time out
    then
	return 2
    fi
    
    echo "Total: $total_score"
    #return total_score
    return $total_score
}


### define the global vars

source_zip="source.zip"

### for each file in the submission dir

dir_name="submission"
for file in $dir_name/*.c; do
    echo "orig file:${file}"
    input_file=$(echo $file | cut -d '/' -f 2)
    student_id=$(echo $input_file | cut -d '_' -f 7)
    #src_file="${student_id}_k_means.c"
    #cp  $file "${dir_name}/${src_file}"
    echo "$student_id"
    output_file="$student_id.out"
    output_dir="${student_id}_working"
    echo "input_file: $input_file"
    echo "output_file: $output_file"
    echo "output_dir: $output_dir"
    
    # grade for performance
    perf_grade=0.0
    
    # make a working dir
    
    mkdir -p $output_dir
    unzip $source_zip -d $output_dir
    
    #copy the file to $output_dir
    
    cp "${file}" "${output_dir}/source"
    
    cd $output_dir/source/
    #ls -la
    rm "k_means.c"
    mv "${input_file}" "k_means.c"

    
    #compile and run
    compile_and_run $output_file "k_means" $student_id
	ret=$?
    #write down the total and the student id in a csv file
    
    
	#echo "\t\t C version result: $ret"
    if [ $ret -eq "1" ]
	then
	    echo -e "\t compilation failed" 
    
    else 
        #perf_grade=$(( $perf_grade + 10.0 ))
        echo $student_id,$ret >> ../../grading.csv
    fi


    
    
    #clean_up_before_exit 
    cd ../../
    echo "rm -r $output_dir"

    
done



