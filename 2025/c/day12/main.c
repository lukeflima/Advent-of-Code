#include <stdint.h>
#include <inttypes.h>
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#define NOB_IMPLEMENTATION
#define NOB_STRIP_PREFIX
#include "nob.h"

uint64_t svtou64(Nob_String_View input) {
    bool is_neg = input.data[0] == '-';
    uint64_t res = 0;
    for(size_t i = is_neg ? 1 : 0; i < input.count; i++) {
        if(input.data[i] < '0' || input.data[i] > '9') return 0;
        res = res * 10 + input.data[i] - '0';
    }
    return is_neg ? -res : res;
}

typedef struct {
    uint64_t *items;
    size_t count;
    size_t capacity;
} Nums;

void part1(Nob_String_View input) {
    (void) nob_sv_chop_by_delim(&input, 'x');
    input = nob_sv_from_parts(input.data - 2, input.count + 2);
    Nums nums = {0};
    size_t res = 0;
    while(input.count > 0) {
        Nob_String_View line = nob_sv_chop_by_delim(&input, '\n');
        Nob_String_View height_sv = nob_sv_chop_by_delim(&line, 'x');
        Nob_String_View width_sv = nob_sv_chop_by_delim(&line, ':');
        uint64_t height = svtou64(height_sv);
        uint64_t width = svtou64(width_sv);
        
        input = nob_sv_trim(input);
        nums.count = 0;
        while(line.count > 0) {
            Nob_String_View num_sv = nob_sv_chop_by_delim(&line, ' ');
            uint64_t num = svtou64(num_sv);
            nob_da_append(&nums, num);
        }

        uint64_t area = width * height;
        uint64_t area_presents = 0;
        for(size_t i = 0; i < nums.count; i++) {
            area_presents += 3*3*nums.items[i];
        }

        if(area_presents <= area) {
            res += 1;
        }
        
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

    nob_sb_free(input_sb);

    return 0;
}