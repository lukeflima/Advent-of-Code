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
    uint64_t low;
    uint64_t high;
} Range;

bool in_range(Range range, uint64_t value) {
    return value >= range.low && value <= range.high;
}

uint64_t range_len(Range range) {
    if(range.low > range.high) return 0;
    return range.high - range.low + 1;
}

typedef struct {
    Range *items;
    size_t count;
    size_t capacity;
} Ranges;

typedef struct {
    uint64_t *items;
    size_t count;
    size_t capacity;
} Ingredients_IDS;


void part1(Nob_String_View input) {
    Ranges ranges = {0};
    for(;;) {
        Nob_String_View line = nob_sv_chop_by_delim(&input, '\n');
        if(line.count == 0) break;
        
        Nob_String_View low_sv = nob_sv_chop_by_delim(&line, '-');
        Range range = {.low = svtou64(low_sv), .high = svtou64(line)};
        nob_da_append(&ranges, range);
    }
    
    Ingredients_IDS ingredients_ids = {0};
    while(input.count > 0) {
        Nob_String_View line = nob_sv_chop_by_delim(&input, '\n');
        nob_da_append(&ingredients_ids, svtou64(line));
    }

    size_t res = 0;
    for(size_t i = 0; i < ingredients_ids.count; i++) {
        for(size_t i = 0; i < ranges.count; i++) {
            if(in_range(ranges.items[i], ingredients_ids.items[i])) {
                res += 1;
                break;
            }
        }
    }

    printf("Part 1: %zu\n", res);
}

void part2(Nob_String_View input) {
    Ranges ranges = {0};
    for(;;) {
        Nob_String_View line = nob_sv_chop_by_delim(&input, '\n');
        if(line.count == 0) break;
        
        Nob_String_View low_sv = nob_sv_chop_by_delim(&line, '-');
        Range range = {.low = svtou64(low_sv), .high = svtou64(line)};
        nob_da_append(&ranges, range);
    }
    
    Ingredients_IDS ingredients_ids = {0};
    while(input.count > 0) {
        Nob_String_View line = nob_sv_chop_by_delim(&input, '\n');
        nob_da_append(&ingredients_ids, svtou64(line));
    }

    for(size_t i = 0; i < ranges.count; i++) {
        Range *range1 = &ranges.items[i];
        for(size_t j = 0; j < ranges.count; j++) {
            if(i == j) continue;
            Range range2 = ranges.items[j];
            if(in_range(range2, range1->low))  range1->low = range2.high + 1;
            if(in_range(range2, range1->high)) range1->high = range2.low - 1;
        }
    }

    uint64_t res = 0;
    for(size_t i = 0; i < ranges.count; i++) {
        res += range_len(ranges.items[i]);
    }

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