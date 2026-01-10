#include <math.h>
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <inttypes.h>
#define NOB_IMPLEMENTATION
#define NOB_STRIP_PREFIX
#include "nob.h"
#include "interfaces/highs_c_api.h"

size_t svtozs(Nob_String_View input) {
    bool is_neg = input.data[0] == '-';
    size_t res = 0;
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
} Buttons;

void part1(Nob_String_View input) {
    uint64_t res = 0;
    Buttons buttons = {0};
    while(input.count > 0) {
        Nob_String_View end = nob_sv_chop_by_delim(&input, ']');
        Nob_String_View pattern_sv = nob_sv_from_parts(end.data + 1, end.count - 1);
        uint64_t pattern = 0;
        for(size_t i = pattern_sv.count; i > 0; i--) {
            pattern = (pattern << 1) | (pattern_sv.data[i - 1] == '#' ? 1 : 0);
        }
        
        buttons.count = 0;
        Nob_String_View buttons_sv = nob_sv_trim(nob_sv_chop_by_delim(&input, '{'));
        while(buttons_sv.count > 0) {
            Nob_String_View button_sv = nob_sv_chop_by_delim(&buttons_sv, ')');
            
            button_sv = nob_sv_from_parts(button_sv.data + 1, button_sv.count - 1);
            uint64_t button = 0;
            
            while(button_sv.count > 0) {
                size_t num = svtozs(nob_sv_chop_by_delim(&button_sv, ','));
                button |= (1 << num);
            }
            nob_da_append(&buttons, button);
                    
            buttons_sv = nob_sv_trim(buttons_sv);
        }
        (void) nob_sv_trim(nob_sv_chop_by_delim(&input, '\n'));

        uint64_t least_presses = UINT64_MAX;
        for(size_t i = 1; i < (size_t)pow(2, buttons.count); i++) {
            uint64_t p = 0;
            uint64_t presses = 0;
            for(size_t j = 0; j < buttons.count; j++) {
                if(i & (1 << j)) {
                    p ^= buttons.items[j];
                    presses += 1;
                }
            }
            if(p == pattern && presses < least_presses) {
                least_presses =  presses;
            }
        }
        res += least_presses;        
    }

    printf("Part 1: %"PRIu64"\n", res);
}

typedef struct {
    uint64_t *items;
    size_t count;
    size_t capacity;
} Joltages;

typedef struct {
    double *items;
    size_t count;
    size_t capacity;
} Row;

typedef struct {
    HighsInt *items;
    size_t count;
    size_t capacity;
} RowHighsInt;

typedef struct {
    Row *items;
    size_t count;
    size_t capacity;
} Matrix;

void part2(Nob_String_View input) {
    uint64_t res = 0;
    Buttons buttons = {0};
    Joltages joltages = {0};

    const HighsInt a_format = kHighsMatrixFormatRowwise;
    Row row_bound = {0};
    RowHighsInt a_index = {0};
    Row a_value = {0};
    RowHighsInt a_start = {0};
    Row col_cost = {0};
    Row col_lower = {0};
    Row col_upper = {0};
    RowHighsInt integrality = {0};
    while(input.count > 0) {
        (void) nob_sv_chop_by_delim(&input, ']');
        
        buttons.count = 0;
        Nob_String_View buttons_sv = nob_sv_trim(nob_sv_chop_by_delim(&input, '{'));
        while(buttons_sv.count > 0) {
            Nob_String_View button_sv = nob_sv_chop_by_delim(&buttons_sv, ')');
            
            button_sv = nob_sv_from_parts(button_sv.data + 1, button_sv.count - 1);
            uint64_t button = 0;
            
            while(button_sv.count > 0) {
                size_t num = svtozs(nob_sv_chop_by_delim(&button_sv, ','));
                button |= (1 << num);
            }
            nob_da_append(&buttons, button);
                    
            buttons_sv = nob_sv_trim(buttons_sv);
        }
        Nob_String_View joltages_sv = nob_sv_trim(nob_sv_chop_by_delim(&input, '}'));
        joltages.count = 0;
        while(joltages_sv.count > 0) {
            size_t num = svtozs(nob_sv_chop_by_delim(&joltages_sv, ','));
            nob_da_append(&joltages, num);
        }
        
        (void)nob_sv_trim(nob_sv_chop_by_delim(&input, '\n'));

        row_bound.count = 0;
        a_index.count = 0;
        a_value.count = 0;
        a_start.count = 0;
        col_cost.count = 0;
        col_lower.count = 0;
        col_upper.count = 0;
        integrality.count = 0;

        // crafting a and row_bound (= contrains aka lower == upper )
        for(size_t i = 0; i < joltages.count; i++) {
            nob_da_append(&a_start, a_index.count);
            for(size_t j = 0; j < buttons.count; j++) {
                uint64_t button = buttons.items[j];
                uint64_t coef = button & (1 << i) ? 1 : 0;
                if(coef == 1) {
                    nob_da_append(&a_index, j);
                    nob_da_append(&a_value, 1);
                }
            }
            uint64_t joltage = joltages.items[i];
            nob_da_append(&row_bound, joltage);
        }

        // setting bound and col bound and cost function
        for(size_t j = 0; j < buttons.count; j++) {
            nob_da_append(&col_cost, 1);
            nob_da_append(&integrality, 1);
            nob_da_append(&col_lower, 0);
            nob_da_append(&col_upper, 1.0e30);
        }        

        const HighsInt num_col = buttons.count;
        const HighsInt num_row = row_bound.count;
        const HighsInt num_nz = a_index.count;
        const double offset = 0;

        double objective_value;
        double* col_value = (double*)malloc(sizeof(double) * num_col);
        double* row_value = (double*)malloc(sizeof(double) * num_row);
        
        HighsInt sense = kHighsObjSenseMinimize;

        HighsInt model_status;
        HighsInt run_status =
            Highs_mipCall(num_col, num_row, num_nz, a_format, sense, offset, col_cost.items,
                   col_lower.items, col_upper.items, row_bound.items, row_bound.items, a_start.items, a_index.items,
                   a_value.items, integrality.items, col_value, row_value, &model_status);
        
        assert(run_status == kHighsStatusOk);
        assert(model_status == kHighsModelStatusOptimal);

        objective_value = offset;
        for (HighsInt i = 0; i < num_col; i++) {
            objective_value += col_value[i] * col_cost.items[i];
        }

        res += objective_value;
    }

    printf("Part 2: %"PRIu64"\n", res);
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