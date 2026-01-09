#include <assert.h>
#include <stdint.h>
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
} Ints;

typedef struct {
    Ints *items;
    size_t count;
    size_t capacity;
} IntsInts;

typedef enum {
    ADD,
    MUL
} Op_type ;

typedef struct {
    Op_type *items;
    size_t count;
    size_t capacity;
} Ops;

void part1(Nob_String_View input) {
    IntsInts numbers = {0};
    Ops ops = {0};
    while(input.count > 0) {
        Nob_String_View line = nob_sv_chop_by_delim(&input, '\n');
        if(input.count == 0) {
            while(line.count > 0) {
                line = nob_sv_trim(line);
                Nob_String_View op_sv = nob_sv_chop_by_delim(&line, ' ');
                assert(op_sv.count == 1);
                switch (op_sv.data[0]) {
                    case '+':
                        nob_da_append(&ops, ADD);
                        break;
                    case '*':
                        nob_da_append(&ops, MUL);
                        break;
                    default:
                        printf("Unknow optype: %c", op_sv.data[0]);
                        exit(1);
                        break;
                }
            }
            break;
        }
        Ints ints = {0};
        while(line.count > 0) {
            line = nob_sv_trim(line);
            Nob_String_View num_sv = nob_sv_chop_by_delim(&line, ' ');
            uint64_t num = svtou64(num_sv);
            nob_da_append(&ints, num);
        }
        nob_da_append(&numbers, ints);
    }

    uint64_t res = 0;
    for(size_t i = 0; i < ops.count; i++) {
        Op_type op = ops.items[i];
        uint64_t op_result = 0;
        switch (op) {
        case ADD: {
            for(size_t j = 0; j < numbers.count; j++) {
                op_result += numbers.items[j].items[i];
            }
        } break;
        case MUL: {
            op_result = 1;
            for(size_t j = 0; j < numbers.count; j++) {
                op_result *= numbers.items[j].items[i];
            }
        } break;
        default:{
            printf("Unknow optype: %d", op);
            exit(1);
        }
        }
        
        res += op_result;
    }

    printf("Part 1: %zu\n", res);
}

typedef struct {
    Nob_String_View *items;
    size_t count;
    size_t capacity;
} Lines;

void part2(Nob_String_View input) {
    Lines lines = {0};
    while(input.count > 0) {
        Nob_String_View line = nob_sv_chop_by_delim(&input, '\n');
        nob_da_append(&lines, line);
    }

    Ints nums = {0};
    int i = lines.items[0].count - 1;
    uint64_t res = 0;
    while(i > 0) {
        nums.count = 0;
        char op = '\0';
        for(;;) {
            size_t num = 0;
            for(size_t j = 0; j < lines.count-1; j++) {
                char c = lines.items[j].data[i];
                if(c != ' ') num = num * 10 + c - '0';
            }
            nob_da_append(&nums, num);
            
            char c = lines.items[lines.count - 1].data[i];
            if(c != ' ') {
                op = c;
                i -= 2;
                break;
            } else {
                i -= 1;
            }
        }

        assert(op != '\0');

        uint64_t op_result = 0;
        if(op == '+') {
            for(size_t j = 0; j < nums.count; j++) {
                op_result += nums.items[j];
            }
        } else {
            op_result = 1;
            for(size_t j = 0; j < nums.count; j++) {
                op_result *= nums.items[j];
            }
        }

        res += op_result;
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
    
    part1(nob_sv_trim(input));
    part2(input);

    nob_sb_free(input_sb);

    return 0;
}