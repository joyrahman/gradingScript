import subprocess
import os


'''
input : 
    user_id
    testcase_score
    output_file_name
output:
    write to the csv file

'''

os.environ['OMP_NUM_THREADS']="4"
dir_name='kkg575_working'
thread_count = 8

exec8 = 60
exec1 = 60

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

score = 0
if perf_val<=40:
    score = 20

elif perf_val>40 and perf_val<=50:
    score = 17
    
elif perf_val>50 and perf_val<=60:
    score = 14

elif perf_val>60 and perf_val<=70:
    score = 11

elif perf_val>70 and perf_val<=80:
    score = 8


elif perf_val>80 and perf_val<=90:
    score = 5
elif perf_val>90 and perf_val<=100:
    score = 2




# do the extra point calculation

extra_point = ( (1.9-exec8)*10 / (1.9-1.5) ) + 2 
if extra_point > 10:
    extra_point = 10
elif extra_point <2:
    extra_point =  2


# write the result to the file
test_case_score = 0

print("TestCase Score:{}, Performance_Score:{}, Extra_Points:{},Exec8:{},Exec1:{},Percentage:{}",test_case_score, score, extra_point,exec8, exec1,perf_val)
