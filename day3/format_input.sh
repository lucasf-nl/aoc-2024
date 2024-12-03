xxd -i input.txt > input.c
sed 's/unsigned char /.byte /g' input.c | sed 's/,//g' | sed 's/ input_txt\[\] = {//g' | tr -d '\n' | sed 's/};unsigned int input_txt_len = 18668;//g' > input.asm