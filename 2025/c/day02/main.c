#include <math.h>
#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#define NOB_IMPLEMENTATION
#define NOB_STRIP_PREFIX
#include "nob.h"

typedef struct {
    uint64_t low;
    uint64_t high;
} Range;

typedef struct {
    Range *items;
    size_t count;
    size_t capacity;

} Ranges;

uint64_t svtou64(Nob_String_View input) {
    bool is_neg = input.data[0] == '-';
    uint64_t res = 0;
    for(size_t i = is_neg ? 1 : 0; i < input.count; i++) {
        if(input.data[i] < '0' && input.data[i] > '9') return 0;
        res = res * 10 + input.data[i] - '0';
    }
    return is_neg ? -res : res;
}

void part1(Nob_String_View input) {
    Ranges ranges = {0};
    while(input.count > 0) {    
        Nob_String_View range_sv = nob_sv_chop_by_delim(&input, ',');
        Nob_String_View low_sv = nob_sv_chop_by_delim(&range_sv, '-');

        Range r = {.low = svtou64(low_sv), .high = svtou64(range_sv)};
        nob_da_append(&ranges, r);
    }
    
    uint64_t res = 0;
    for(size_t i = 0; i < ranges.count; i++) {
        Range range = ranges.items[i];
        for(uint64_t num = range.low; num <= range.high; num++){
            int num_digits = (int) ceil(log10((double) num));
            if(num_digits % 2 != 0) continue;

            int mod = pow(10, (double) num_digits/2);
            if(num/mod == num%mod) {
                res += num;
            }
        }
    }

    printf("Part 1: %zu\n", res);
}

void part2(Nob_String_View input) {
    Ranges ranges = {0};
    while(input.count > 0) {    
        Nob_String_View range_sv = nob_sv_chop_by_delim(&input, ',');
        Nob_String_View low_sv = nob_sv_chop_by_delim(&range_sv, '-');

        Range r = {.low = svtou64(low_sv), .high = svtou64(range_sv)};
        nob_da_append(&ranges, r);
    }
    
    uint64_t res = 0;
    for(size_t i = 0; i < ranges.count; i++) {
        Range range = ranges.items[i];
        for(uint64_t num = range.low; num <= range.high; num++){
            int num_digits = (int) ceil(log10((double) num));
            for(int pred_size = 1; pred_size <= num_digits/2; pred_size ++) {
                if(num_digits % pred_size != 0) continue;

                int mod = pow(10, (double) pred_size);
                uint64_t pred = num % mod;
                uint64_t n = num/mod;
                while(n > 0) {
                    if(n%mod != pred) break;
                    n = n / mod;
                }

                if(n == 0) {
                    res += num;
                    break;
                }
            }
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
    part2(input);

    nob_sb_free(input_sb);

    return 0;
}