import os
def test(input_dir, file_name_pattern):
    for filename in os.listdir(input_dir):
        if file_name_pattern in filename:
            #get user id 
            user_id = filename.split('OpenMP_')[1].split('_',1)[0]
            print user_id


if __name__ == "__main__":
	input_dir =  './submission'
    	file_name_pattern = "k_means.c"
	test(input_dir, file_name_pattern)
