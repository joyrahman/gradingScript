import sys
import os 
import subprocess
#Assignment 3  OpenMP_wgu537_attempt_2016-10-03-15-44-00_k_means.c





def main(input_dir):
    target_file_name = "k_means.c"
    source_zip  = "source.zip"
    
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
        if 'k_means.c' in filename:
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

            
            testcase_result =[True] * 8
            total_score = 0

            #testcase1
            print ("Test1")
            num_thread = 8
            #k = 2
            #i = 100
            #data_file = "example1_k2_m10.txt" 
            #output_file = "test1.txt"
            #result_file = "example1.output.txt"
            total_test = 8
            total_test_iteration = 20
            
            for q in range(0,total_test):
                k = test_k[q]
                i = test_i[q]
                data_file   = datafile[q]
                output_file = correct_output[q]
                result_file = test_output[q]
                
                for m in range(0,total_test_iteration):
                    temp_result = subprocess.check_output(['./run_test_cmd.sh \
                            {} {} {} {} {} {} {}'.format(num_thread, data_file, \
                        k, i ,output_file, result_file, output_dir)], shell=True)
                    
                    val = int(temp_result)
                    if (val==-1):
                        testcase_result[q] = [False]

            print testcase_result 
            #DIFF=$(diff ./test1 ../../correct_output/test1)
            #target_dir = ouput_dir + "/source"
            #subprocess.call(['diff {}/data/{} {} {}/{}'.format(target_dir, result_file, \
            #        target_dir, output_file)],shell=True)
            #DIFF = su


            #testcase2





            




if __name__ == "__main__":
    #define the global var here
    input_dir =  './submission'
    main(input_dir)
