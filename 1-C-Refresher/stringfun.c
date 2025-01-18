#include <stdio.h>
#include <stdlib.h>

#define BUFFER_SZ 50

//prototypes
void usage(char *);
void print_buff(char *, int);
int setup_buff(char *, char *, int);

//prototypes for functions to handle required functionality
int my_strlen(char *str);
int my_strncmp(char *str1, char *str2, int n);
int count_words(char *, int, int);
int  reverse_string(char *buff, int buff_len, int str_len);
int  word_print(char *buff, int buff_len, int str_len);
int replace_substring(char *buff, int *str_len, int buff_len,
                      char *old_sub, char *new_sub);


int setup_buff(char *buff, char *user_str, int len){
    if (!buff || !user_str || len <= 0){
        return -2;
    }

    int store_count = 0;
    int last_was_space = 1;

    while (*user_str != '\0') {
        if (*user_str == ' ' || *user_str == '\t') {
            if (!last_was_space) {
                if (store_count >= len) {
                    return -1;
                }
                buff[store_count++] = ' ';
                last_was_space = 1;
            }
        } else {
            if (store_count >= len) {
                return -1;
            }
            buff[store_count++] = *user_str;
            last_was_space = 0;
        }
        user_str++;
    }

    if (store_count > 0 && buff[store_count - 1] == ' ') {
        store_count--;
    }

    for (int i = store_count; i < len; i++) {
        buff[i] = '.';
    }

    return store_count;
}


void print_buff(char *buff, int len){
    printf("[Buffer:  ]");
    for (int i=0; i<len; i++){
        putchar(*(buff+i));
    }
    putchar('\n');
}

void usage(char *exename){
    printf("usage: %s [-h|c|r|w|x] \"string\" [other args]\n", exename);
}

int count_words(char *buff, int len, int str_len){
    if (!buff) {
        return -2;
    }

    int word_count = 0;
    int in_word = 0;

    for (int i = 0; i < str_len; i++) {
        char c = buff[i];
        if (c != ' ') {
            if (!in_word) {
                word_count++;
                in_word = 1;
            }
        } else {
            in_word = 0;
        }
    }

    return word_count;
}

int  reverse_string(char *buff, int buff_len, int str_len) {
    if (!buff) {
        return -1;
    }

    if (str_len < 2) {
        return 0;
    }

    int i = 0;
    int j = str_len - 1;
    while (i < j) {
        char temp = buff[i];
        buff[i] = buff[j];
        buff[j] = temp;
        i++;
        j--;
    }

    return 0;
}

int word_print(char *buff, int buff_len, int str_len) {
    if (!buff) {
        return -1;
    }

    printf("Word Print\n");
    printf("----------\n");

    int word_count = 0;
    int idx = 0;

    while (idx < str_len) {
        while (idx < str_len && buff[idx] == ' ') {
            idx++;
        }

        if (idx >= str_len) {
            break;
        }

        int start = idx;
        while (idx < str_len && buff[idx] != ' ') {
            idx++;
        }

        int wlen = idx - start;
        word_count++;

        printf("%d. ", word_count);
        for (int i = start; i < (start + wlen); i++) {
            putchar(buff[i]);
        }

        printf(" (%d)\n", wlen);
    }

    return word_count;
}

int my_strlen(char *str) {
    int len = 0;
    while (*str != '\0') {
        len++;
        str++;
    }

    return len;
}

int my_strncmp(char *str1, char *str2, int n){
    for (int i = 0; i < n; i++){
        if (str1[i] != str2[i]){
            return -1;
        }
    }

    return 0;
}

int replace_substring(char *buff, int *str_len, int buff_len,
                      char *old_sub, char *new_sub) {
    if (!buff || !str_len || !old_sub || !new_sub || buff_len <= 0){
        return -2;
    }

    int old_len = my_strlen(old_sub);
    int new_len = my_strlen(new_sub);

    if (old_len == 0){
        return -1;
    }

    int found_index = -1;

    int limit = (*str_len) - old_len;
    if (limit < 0){
        return -1;
    }

    for (int i = 0; i <= limit; i++){
        if (my_strncmp(buff + i, old_sub, old_len) == 0){
            found_index = i;
            break;
        }
    }

    if (found_index < 0){
        return -1;
    }

    if (new_len == old_len){
        for (int k = 0; k < new_len; k++){
            buff[found_index + k] = new_sub[k];
        }
    } else if (new_len < old_len) {
        int delta = old_len - new_len;
        for (int k = 0; k < new_len; k++){
            buff[found_index + k] = new_sub[k];
        }

        int i_src = found_index + old_len;
        int i_dst = found_index + new_len;
        while (i_src < *str_len){
            buff[i_dst++] = buff[i_src++];
        }

        *str_len = *str_len - delta;
        for (int i = *str_len; i < buff_len; i++){
            buff[i] = '.';
        }
    } else {
        int delta = new_len - old_len;
        if ((*str_len + delta) > buff_len) {
            return -2;
        }

        int i_src = (*str_len) - 1;
        int i_dst = i_src + delta;
        while (i_src >= (found_index + old_len)){
            buff[i_dst] = buff[i_src];
            i_src--;
            i_dst--;
        }

        for (int k = 0; k < new_len; k++){
            buff[found_index + k] = new_sub[k];
        }

        *str_len = *str_len + delta;
        for (int i = *str_len; i < buff_len; i++){
            buff[i] = '.';
        }
    }

    return 0;
}

int main(int argc, char *argv[]){

    char *buff;             //placehoder for the internal buffer
    char *input_string;     //holds the string provided by the user on cmd line
    char opt;               //used to capture user option from cmd line
    int  rc;                //used for return codes
    int  user_str_len;      //length of user supplied string

    //TODO:  #1. WHY IS THIS SAFE, aka what if arv[1] does not exist?
    /*
       Because the `if ((argc < 2) || (*argv[1] != '-'))` check ensures that we
       won't attempt to access argv[1] (or *argv[1]) unless there is at least
       one argument (beyond argv[0]). If argc < 2, we exit before using argv[1].
    */
    if ((argc < 2) || (*argv[1] != '-')){
        usage(argv[0]);
        exit(1);
    }

    opt = (char)*(argv[1]+1);   //get the option flag

    //handle the help flag and then exit normally
    if (opt == 'h'){
        usage(argv[0]);
        exit(0);
    }

    //WE NOW WILL HANDLE THE REQUIRED OPERATIONS

    //TODO:  #2 Document the purpose of the if statement below
    /*
       This check ensures that a second argument (the user string) is provided.
       Our utility expects at least:
         argv[0] = program name
         argv[1] = option flag (e.g., "-c")
         argv[2] = "string"
       If argc < 3, then argv[2] doesn't exist, so we show usage and exit.
    */
    if (argc < 3){
        usage(argv[0]);
        exit(1);
    }

    input_string = argv[2]; //capture the user input string

    //TODO:  #3 Allocate space for the buffer using malloc and
    //          handle error if malloc fails by exiting with a 
    //          return code of 99
    buff = (char*)malloc(BUFFER_SZ);
    if (!buff) {
        fprintf(stderr, "error: could not allocate memory\n");
        exit(99);
    }


    user_str_len = setup_buff(buff, input_string, BUFFER_SZ);     //see todos

    if (user_str_len == -1){
        fprintf(stderr, "error: Provided input string is too long!\n");
        free(buff);
        exit(3);
    }

    if (user_str_len < 0){
        fprintf(stderr, "error: Unknown error setting up buffer (code=%d)\n", user_str_len);
        free(buff);
        exit(3);
    }

    switch (opt){
        case 'c': {
            rc = count_words(buff, BUFFER_SZ, user_str_len);  //you need to implement
            if (rc < 0){
                printf("Error counting words, rc = %d", rc);
                free(buff);
                exit(2);
            }
            printf("Word Count: %d\n", rc);
            break;
        }

        case 'r': {
            rc = reverse_string(buff, BUFFER_SZ, user_str_len);
            if (rc < 0){
                printf("Error reversing string, rc = %d\n", rc);
                free(buff);
                exit(3);
            }

            printf("Reversed String: ");
            for (int i = 0; i < user_str_len; i++){
                putchar(buff[i]);
            }
            putchar('\n');
            break;
        }

        case 'w': {
            rc = word_print(buff, BUFFER_SZ, user_str_len);
            if (rc < 0){
                printf("Error printing words, rc = %d\n", rc);
                free(buff);
                exit(3);
            }
            break;
        }

        case 'x': {
            if (argc < 5) {
                usage(argv[0]);
                free(buff);
                exit(1);
            }

            char *old_sub = argv[3];
            char *new_sub = argv[4];

            rc = replace_substring(buff, &user_str_len, BUFFER_SZ, old_sub, new_sub);
            if (rc < 0) {
                if (rc == -1) {
                    printf("'%s' not found; no replacement made.\n", old_sub);
                } else if (rc == -2) {
                    fprintf(stderr, "error: new substring would exceed buffer capacity!\n");
                    free(buff);
                    exit(3);
                }
            } else {
                printf("Modified String: ");
                for (int i = 0; i < user_str_len; i++) {
                    putchar(buff[i]);
                }
                putchar('\n');
            }

            break;
        }

        default:
            usage(argv[0]);
            exit(1);
    }

    //TODO:  #6 Dont forget to free your buffer before exiting
    print_buff(buff,BUFFER_SZ);
    free(buff);

    exit(0);
}

//TODO:  #7  Notice all of the helper functions provided in the 
//          starter take both the buffer as well as the length.  Why
//          do you think providing both the pointer and the length
//          is a good practice, after all we know from main() that 
//          the buff variable will have exactly 50 bytes?
//  
/* Even if we know in main that the buffer size is 50 bytes, it's safer and
 * more flexible to pass the size of the buffer along with the pointer. This
 * makes the function more robust, prevent accidental buffer overruns, and
 * makes the code easier to maintain and reuse in the future. Passing the
 * buffer size can avoid potential vulnerabilities and logic errors.
 */