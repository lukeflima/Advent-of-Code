#include <math.h>
#include <stdio.h>
#define NOB_IMPLEMENTATION
#define NOB_STRIP_PREFIX
#include "nob.h"

void part1(Nob_String_View input) {
    int pointer = 50;
    size_t res = 0;

    Nob_String_Builder number = {0};
    while(input.count > 0) {
        Nob_String_View line = nob_sv_chop_by_delim(&input, '\n');
        
        number.count = 0;
        nob_sb_append_buf(&number, line.data+1, line.count-1);
        nob_sb_append_null(&number);
        int rotation = atoi(number.items);
        
        if(line.data[0] == 'L') rotation = -rotation;
        
        pointer = (pointer + rotation) % 100;
        if(pointer == 0) res += 1;
    }
    
    nob_sb_free(number);

    printf("Part 1: %zu\n", res);
}

void divmod(int x, int y, int *d, int *m) {
    *d = (int)floor((double)x / y);
    *m = x - *d * y;
}

void part2(Nob_String_View input) {
    int pointer = 50;
    int revolutions = 0;
    size_t res = 0;

    Nob_String_Builder number = {0};
    while(input.count > 0) {
        Nob_String_View line = nob_sv_chop_by_delim(&input, '\n');
        
        number.count = 0;
        nob_sb_append_buf(&number, line.data+1, line.count-1);
        nob_sb_append_null(&number);
        int rotation = atoi(number.items);
        
        if(line.data[0] == 'L') rotation = -rotation;
        
        divmod(pointer + rotation, 100, &revolutions, &pointer);
        res += abs(revolutions);
    }
    nob_sb_free(number);

    printf("Part 2: %zu\n", res);
}


int main(int argc, char **argv) {
    if(argc != 2) {
        printf("Usage: %s file_name\n", argv[0]);
        return -1;
    }

    const char * file_path = argv[1];

    Nob_String_Builder input_sb = {0};
    nob_read_entire_file(file_path, &input_sb);
    Nob_String_View input = nob_sv_from_parts(input_sb.items, input_sb.count);
    input = nob_sv_trim(input);
    
    part1(input);
    part2(input);

    nob_sb_free(input_sb);

    return 0;
}