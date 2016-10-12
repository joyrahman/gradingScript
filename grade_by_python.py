import sys
import os 
import subprocess
#Assignment 3  OpenMP_wgu537_attempt_2016-10-03-15-44-00_k_means.c





def main(input_dir,target_file_name,source_zip,grade_file, file_name_pattern):

    datafile = ['example1_k2_m10.txt',\
        'example2_k3_m30.txt',\
        'example3_k5_m500.txt',\
        'example4_k8_m10000.txt',\
        'example5_k10_m10000.txt',\
        'example6_k11_m1000.txt',\
        'example7_k12_m1000.txt',\
        'example8_k13_m1000.txt'
    ]
    
    correct_output = ['example1.output.txt',\
        'example2.output.txt',\
        'example3.output.txt',\
        'example4.output.txt',\
        'example5.output.txt',\
        'example6.output.txt',\
        'example7.output.txt',\
        'example8.output.txt'
    ]
    
    test_output = ['test1.txt',\
        'test2.txt',\
        'test3.txt',\
        'test4.txt',\
        'test5.txt',\
        'test6.txt',\
        'test7.txt',\
        'test8.txt'
    ]
    test_k = [2,3,5,8,10,11,12,13]
    test_i = [100,100,100,10000,10000,10000,10000,10000]
    
    
    

    subprocess.call(["find -name \"* *\" -type f | rename 's/ /#/g'"], shell=True)
    
    for filename in os.listdir(input_dir):
        if file_name_pattern in filename:
            #get user id 
            user_id = filename.split('OpenMP_')[1].split('_',1)[0]
            print user_id

            #now unpack the folder
            output_dir="{}_working".format(user_id)
            #delete if exist
            subprocess.call(['rm -rf {}'.format(output_dir)], shell=True)
            #create it
            subprocess.call(['mkdir {}'.format(output_dir)], shell=True)
            # unzip the source
            subprocess.call(['unzip {} -d {}'.format(source_zip, output_dir)], shell=True)
            # now cp the source file to the source directory
            subprocess.call(['cp {}/{} {}/source'.format(input_dir,filename, output_dir)], shell=True)
            # remove the k_means.c
            subprocess.call(['rm {}/source/{}'.format(output_dir,target_file_name)], shell=True)
            # rename the file
            subprocess.call(['mv {}/source/{} {}/source/{}'.format(output_dir,filename, output_dir,target_file_name)], shell=True)
            
            # compile
            compilation_passed = False
            try:
                subprocess.check_call(['cd  {}/source/ && make'.format(output_dir)], shell=True)
                compilation_passed = True
                skip_output = subprocess.check_output(['echo'],shell=True,stderr=subprocess.STDOUT)
            
            except CalledProcessError as e:
                print "Compilation failed"
                print e
                # write this result to the csv
                print (user_id,0)
                sys.exit()

            
            
            # run the test cases  
            total_test = 8
            total_test_iteration = 20   
            num_thread = 8
            testcase_result =[True] * total_test



            #k = 2
            #i = 100
            #data_file = "example1_k2_m10.txt" 
            #output_file = "test1.txt"
            #result_file = "example1.output.txt"

            
            for q in range(0,total_test):
                k = test_k[q]
                i = test_i[q]
                data_file   = datafile[q]
                output_file = test_output[q]
                result_file = correct_output[q]
                print("Running Test:{}".format(q))
                
                for m in range(0,total_test_iteration):
                    temp_result = subprocess.check_output(['./run_test_cmd.sh \
                            {} {} {} {} {} {} {}'.format(num_thread, data_file, \
                        k, i ,output_file, result_file, output_dir)], shell=True)
                    
                    val = int(temp_result)
                    print ("Test Result:",val)
                    if (val==-1):
                        testcase_result[q] = [False]
                
            total_test_score  = 0
            print testcase_result 
            for id in range(0,total_test):
                if (testcase_result[id])==True:
                    total_test_score +=10


            #performance analysis
            
            exec8 = 60
            exec1 = 60
            dir_name = output_dir
            thread_count = num_thread 

            for i in range(0,1):
                output = subprocess.check_output(['./run_adhoc_cmd.sh {} {}'.format(thread_count, dir_name)],\
                        shell=True, stderr=subprocess.STDOUT)
                
                t_exec8=float(output.split('real')[1].split('user')[0].split('m')[1].split('s')[0])
                if t_exec8<exec8:
                    exec8 = t_exec8

            thread_count = 1
            for i in range(0,1):
                output = subprocess.check_output(['./run_adhoc_cmd.sh {} {}'.format(thread_count, dir_name)],\
                        shell=True, stderr=subprocess.STDOUT)
                
                t_exec1=float(output.split('real')[1].split('user')[0].split('m')[1].split('s')[0])
                if t_exec1<exec1:
                    exec1 = t_exec1


            #print exec8,exec1
            perf_val = exec8*100/exec1
            #print perf_val

            perf_score = 0
            if perf_val<=40:
                perf_score = 20

            elif perf_val>40 and perf_val<=50:
                perf_score = 17
                
            elif perf_val>50 and perf_val<=60:
                perf_score = 14

            elif perf_val>60 and perf_val<=70:
                perf_score = 11

            elif perf_val>70 and perf_val<=80:
                perf_score = 8


            elif perf_val>80 and perf_val<=90:
                perf_score = 5
            elif perf_val>90 and perf_val<=100:
                perf_score = 2




            # do the extra point calculation
            base = 1.9
            low_base = 1.5
            lower_val = 2
            upper_val = 10
            

            extra_point = ( (base-exec8)*10 / (base-low_base) ) + lower_val
            if extra_point > upper_val:
                extra_point = upper_val
            elif extra_point < lower_val:
                extra_point =  lower_val


            # write the result to the file
            
            final_result = "ID:{}, TestCase Score:{}, Performance_Score:{}, Extra_Points:{},Exec8:{},Exec1:{},Percentage:{}".format(user_id, total_test_score, perf_score, extra_point,exec8, exec1,perf_val)
            print(final_result)
            comments = "TestCase_Passed:{},TestCase_Score:{},Performance_Score:{},ExecTime_8thread:{},ExecTime_1thread:{},Percentage_Improvement:{}".format(testcase_result,total_test_score,perf_score,exec8,exec1,perf_val)
            total_score =  total_test_score + perf_score
            csv_result = "{}\t{}\t{}\t{}\t{}".format(user_id, total_score,comments, extra_point)
            with open(grade_file,'wa') as f:
                f.write(final_result)
                

            
            
            





            




if __name__ == "__main__":
    #define the global var here
    input_dir =  './submission'
    target_file_name = "k_means.c"
    source_zip  = "source.zip"
    grade_file = "assignment3.csv"
    file_name_pattern = "k_means.c"
    
    main(input_dir,target_file_name,source_zip,grade_file,file_name_pattern)
