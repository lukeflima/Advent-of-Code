#include <stdint.h>
#include <stdio.h>
#define NOB_IMPLEMENTATION
#define NOB_STRIP_PREFIX
#include "nob.h"

void part1(Nob_String_View input) {
    int res = 0;
    while(input.count > 0) {
        Nob_String_View line = nob_sv_chop_by_delim(&input, '\n');

        int largest_jolt = 0;
        for(size_t i = 0; i < line.count; i++) {
            int num = (line.data[i] - '0') * 10;
            if(num < largest_jolt) continue;
            for(size_t j = i + 1; j < line.count; j++) {
                int new = num + line.data[j] - '0';
                if(new > largest_jolt) largest_jolt = new;
            }
        }
        
        res += largest_jolt;
    }

    printf("Part 1: %d\n", res);
}

void part2(Nob_String_View input) {
    uint64_t res = 0;
    while(input.count > 0) {
        Nob_String_View line = nob_sv_chop_by_delim(&input, '\n');

        uint64_t largest_jolt = 0;
        int last_digit_index = -1;
        for(size_t index = 0; index < 12; index++){
            uint64_t number = 0;
            for(size_t digit_index = last_digit_index + 1; digit_index < line.count - 12 + index + 1; digit_index++) {
                uint64_t n = line.data[digit_index] - '0';
                if(n > number) {
                    number = n;
                    last_digit_index = digit_index;
                }
            }
            largest_jolt = largest_jolt * 10 + number;
        }

        res += largest_jolt;
    }

    printf("Part 1: %zu\n", res);
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