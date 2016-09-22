#!/bin/bash

# two parameters:
# $1: students list
# $2: directory of submissions

# BEGIN: configurations

# default grades
c_no_submission=1.0 # c file not submitted
c_not_compile=25.0 # c file not compiling
c_time_out=30.0 # c version time out
c_seg_fault=30.0 # c version segfault
c_wrong_result=40.0 # c version computation incorrect
c_success=50.0 # c version correct

# default grades
a_no_submission=1.0 # c file not submitted
a_not_compile=25.0 # c file not compiling
a_time_out=30.0 # c version time out
a_seg_fault=30.0 # c version segfault
a_wrong_result=30.0 # c version computation incorrect
a_success=40.0 # c version correct
a_perf_boost=0.97 # redunce student's time to account for run-time variation
a_perf_points=10.0 # 0~10 or more points based on performance; 
                  # compute equation:
                  # per_point = ($sse_base_time / (($student_time)) * $a_perf_boost)) * a_per_points
a_max_perf_points=20.0 # maximum perf points

# late times and panelties
late_times=( 20160225235900000 20160303235900000 )
late_panels=( 0.1 0.2 )

# good job comment threshold
good_job_threshold=93.0

# set the value to use
a=5  # values for v1
b=7  # values for v2

# grade dir
grade_dir="grades"

# END: configurations

# get command parameters
stud_list_file=$1
sub_dir=$2

# a function for compiling and running student submissions
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
   
    if [ $6 -eq "1" ]
    then
    	gcc -O3 -m32 -march=corei7 "$5/main.c" "$5/$1" -o "$5/$2" >"$5/$3" 2>&1
    else
    	gcc -m32 -march=corei7 "$5/main.c" "$5/$1" -o "$5/$2" >"$5/$3" 2>&1
    fi

    if [ ! -e "$5/$2" ]
    then
        # compile error
	return 1
    fi
    # run the program
    timeout 20s /usr/bin/time -f "elapsed %e" "$5/$2" $a $b >"$5/$4" 2>&1
    local ret=$?
    if [ $ret -eq "139" ] # segfault
    then
	return 3
    elif [ $ret -eq "124" ] # not finished in 20s, time out
    then
	return 2
    fi
    
    return 0
}


# get the SSE baseline (performance upper bound)
#sse_base_time=`/usr/bin/time -f "elapsed %e" ./solution/sse_version $a $b 2>&1 | grep elapsed | cut -f 2 -d ' '`
sse_base_time=0.66
echo "Baseline time for SSE version: $sse_base_time seconds"

# get the non-SSE baseline (performance lower bound)
#non_sse_base_time=`/usr/bin/time -f "elapsed %e" ./solution/base_version $a $b 2>&1 | grep elapsed | cut -f 2 -d ' '`
#echo "Baseline time for Non-SSE version: $non_sse_base_time seconds"

# get correct results
correct_result=`./solution/sse_version $a $b | cut -f 3 -d ' '`
echo "Correct result is $correct_result"

# clear previous grades
rm -r $grade_dir 2>/dev/null
rm grades.zip
mkdir $grade_dir
echo "Assembly Programming,Points" >"$grade_dir/grades.csv"
echo "" >>"$grade_dir/grades.csv"
echo "Display ID,ID,Last Name,First Name,grade" >>"$grade_dir/grades.csv"

# find all the submission dir
# dirs=()
# while IFS= read -r -d $'\n' dir; do
#   dirs+=("$dir")
# done < <(find . -type d -name "Submission attachment(s)")

# find students name
while IFS='' read -r line || [[ -n "$line" ]]; do
    line=`echo $line | sed "s/,\ /,/g"`
    last_name=`echo $line | cut -d ',' -f 1`
    first_name=`echo $line | cut -d ',' -f 2`
    comp_id=`echo $line | cut -d ',' -f 3`
    echo "Processing student: $last_name,$first_name,$comp_id"

    dir="$sub_dir/$last_name, $first_name($comp_id)/Submission attachment(s)/"
    name="$last_name, $first_name($comp_id)"

    #echo "dir is $dir"
    if [ ! -d "$dir" ]; then
	echo "no submission directory: $dir"
	continue
    fi

# grade for this student's c version
    c_grade=0.0
    
    # grade for this student's assembly version
    a_grade=0.0

    # grade for performance
    perf_grade=0.0
    
    # clear time and result
    student_time="NaN"
    boosted_time="NaN"
    student_result="NaN"

    # make a working dir
    mkdir -p "$dir/working"
    touch "$dir/working/comments.txt"
    rm "$dir/working/comments.txt" 2>/dev/null

    # Grade C version if dot_product.c is there
    if [ ! -e "$dir/dot_product.c" ]
    then
	echo -e "\t C file not submitted"
	c_grade=$c_no_submission
    else
	# check C version, basically make sure the output is correct
	cp "$dir/dot_product.c" "$dir/working/"
	cp ./solution/main.c "$dir/working/"
	
	compile_and_run "dot_product.c" "c_bin" "c_compile.log" "c_run.log" "$dir/working" "1"
	ret=$?
	#echo "\t\t C version result: $ret"
	
	if [ $ret -eq "1" ]
	then
	    echo -e "\t C version failed to compile." | tee -a "$dir/working/comments.txt"
	    c_grade=$c_not_compile
	elif [ $ret -eq "2" ]
	then
	    echo -e "\t C version time ou.t" | tee -a "$dir/working/comments.txt"
	    c_grade=$c_time_out
	elif [ $ret -eq "3" ]
	then
	    echo -e "\t C version seg fault." | tee -a "$dir/working/comments.txt"
	    c_grade=$c_seg_fault
	elif [ $ret -eq "0" ]
	then
	    student_result=`grep "result" "$dir/working/c_run.log" | cut -f 3 -d ' '` 
	    if [ $student_result == $correct_result ]
	    then
		echo -e "\t C version correct." | tee -a "$dir/working/comments.txt"
		c_grade=$c_success
	    else
		echo -e "\t C version incorrect result." | tee -a "$dir/working/comments.txt"
		echo -e "\t Student C result is $student_result." | tee -a "$dir/working/comments.txt"
		c_grade=$c_wrong_result
	    fi
	else
	    echo -e "\t ****C: Unknown return value from compile_and_run: $ret"
	fi
    fi

    echo -e "\t C grade is $c_grade." | tee -a "$dir/working/comments.txt"

    # Grade assembly version if dot_product.s is there
    if [ ! -e "$dir/dot_product.s" ]
    then
	echo -e "\t Assembly file not submitted." | tee -a "$dir/working/comments.txt"
	a_grade=$a_no_submission
    else
	# check C version, basically make sure the output is correct
	cp "$dir/dot_product.s" "$dir/working/"
	cp ./solution/main.c "$dir/working/"
	
	compile_and_run "dot_product.s" "a_bin" "a_compile.log" "a_run.log" "$dir/working" "0"
	ret=$?
	echo -e "\t Assembly version result: $ret"
	
	if [ $ret -eq "1" ]
	then
	    echo -e "\t Assembly version failed to compile." | tee -a "$dir/working/comments.txt"
	    a_grade=$a_not_compile
	elif [ $ret -eq "2" ]
	then
	    echo -e "\t Assembly version time out." | tee -a "$dir/working/comments.txt"
	    a_grade=$a_time_out
	elif [ $ret -eq "3" ]
	then
	    echo -e "\t Assembly version seg fault." | tee -a "$dir/working/comments.txt"
	    a_grade=$a_seg_fault
	elif [ $ret -eq "0" ]
	then
	    student_result=`grep "result" "$dir/working/a_run.log" | cut -f 3 -d ' '`
	    if [ $student_result == $correct_result ]
	    then
		echo -e "\t Assembly version correct." | tee -a "$dir/working/comments.txt"
		a_grade=$a_success
		# now get the time
		student_time=`grep "elapse" "$dir/working/a_run.log" | cut -f 2 -d ' '` 
		# reduce the time to account for variation
		boosted_time=`echo "scale=1;$student_time*$a_perf_boost" | bc`
		# compute the performance score
		perf_grade=`echo "scale=1;$a_perf_points * $sse_base_time * 2/$boosted_time" | bc`
		# maximum extra points
		if [ $student_time == "0.00" ]
		then
		    echo -e "\t A 0 time student!!!" 
		    perf_grade=$a_max_perf_points
		fi
		if [ $(echo "$perf_grade > $a_max_perf_points" | bc) -eq  1 ]
		then
		    perf_grade=$a_max_perf_points
		fi
	    else
		echo -e "\t Assembly version incorrect result." | tee -a "$dir/working/comments.txt"
		echo -e "\t Student Assembly result is $student_result." | tee -a "$dir/working/comments.txt"
		a_grade=$a_wrong_result
	    fi
	else
	    echo -e "\t ****A: Unknown return value from compile_and_run: $ret" 
	fi

    fi
    # get late panelty
    timestamp=`cat "$dir"/../timestamp.txt`
    echo "timestamp is $timestamp"
    late_panel=0
    for ((i=0;i<${#late_times[@]};i++))
    do
        #echo ${late_times[$i]} ${late_panels[$i]};
        if [ $timestamp -gt ${late_times[$i]} ]
        then
        	late_panel=${late_panels[$i]}
	fi
    done


    echo -e "\t Assembly grade is $a_grade." | tee -a "$dir/working/comments.txt"
    echo -e "\t Performance grade is $perf_grade." | tee -a "$dir/working/comments.txt"

    total_grade=`echo "scale=1;($a_grade+$c_grade+$perf_grade)*(1.0-$late_panel)" | bc`
    echo -e "\t Late penalty is $late_panel." | tee -a "$dir/working/comments.txt"
    echo -e "\t Total grade is $total_grade." | tee -a "$dir/working/comments.txt"
    echo -e "\t student execution time used for grading is $boosted_time seconds (97% of actually execution time $student_time)." | tee -a "$dir/working/comments.txt"
    echo -e "\t SSE baseline execution time used for grading is (2 * $sse_base_time) seconds." | tee -a "$dir/working/comments.txt"

    # generate grades to grade file
    echo "$comp_id,$comp_id,$last_name,$first_name,$total_grade" >> "$grade_dir/grades.csv"

    if [ $(echo "$total_grade >= $good_job_threshold" | bc) -eq  1 ]
    then
	echo -e "\t good job!" | tee -a "$dir/working/comments.txt"
    fi

    # make feedback dir
    feedback_dir="$grade_dir/$name/Feedback Attachment(s)/"
    mkdir -p "$feedback_dir"
    
    # copy comments 
    cp "$dir/working/comments.txt" "$grade_dir/$name/"

    # copy outputs
    if [ $(echo "$total_grade == 2.0" | bc) -eq  1 ]
    then
	# 0 points mean no files to copy
	continue
    fi
    cp "$dir/working/a_run.log" "$feedback_dir"
    cp "$dir/working/c_run.log" "$feedback_dir"
    cp "$dir/working/a_compile.log" "$feedback_dir"
    cp "$dir/working/c_compile.log" "$feedback_dir"
    
done < "$stud_list_file"

# generate the zip file for upload
zip -r grades.zip $grade_dir
