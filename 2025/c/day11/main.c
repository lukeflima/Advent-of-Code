#include <assert.h>
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#define NOB_IMPLEMENTATION
#define NOB_STRIP_PREFIX
#include "nob.h"
#define HT_IMPLEMENTATION
#include "ht.h"

typedef struct {
    uint64_t* items;
    size_t count;
    size_t capacity;
} DeviceList;

typedef Ht(uint64_t, DeviceList) Devices;

uint64_t name_to_id(Nob_String_View sv) {
    assert(sv.count == 3);
    return sv.data[0] + sv.data[1]*26 + sv.data[2]*26*26;
}

size_t paths(uint64_t cur, uint64_t target, Devices *devices) {
    if(cur == target) return 1;
    
    size_t res = 0;

    DeviceList *list =  ht_find(devices, cur);
    assert(list);
    for(size_t i = 0; i < list->count; i++) {
        res += paths(list->items[i], target,devices);
    }

    return res;
}

void part1(Nob_String_View input) {
    Devices devices = {0};
    while(input.count > 0) {
        Nob_String_View line = nob_sv_chop_by_delim(&input, '\n');
        Nob_String_View device_name = nob_sv_chop_by_delim(&line, ':');
        line = nob_sv_trim(line);

        DeviceList device_list = {0};
        uint64_t device_id = name_to_id(device_name);
        while(line.count > 0) {
            Nob_String_View num_sv = nob_sv_chop_by_delim(&line, ' ');
            uint64_t id = name_to_id(num_sv);
            nob_da_append(&device_list, id);
        }
        *ht_put(&devices, device_id) = device_list;
    }

    uint64_t start = name_to_id(nob_sv_from_cstr("you"));
    uint64_t finish = name_to_id(nob_sv_from_cstr("out"));

    size_t count = paths(start, finish, &devices);

    printf("Part 1: %zu\n", count);
}

static uint64_t OUT;
static uint64_t FFT;
static uint64_t DAC;

typedef struct {
    uint64_t cur;
    bool found_fft;
    bool found_dac;
} State;

typedef Ht(State, size_t) Cache;

size_t dfs(State state, Devices *devices, Cache *cache) {
    size_t *cached = ht_find(cache, state);
    if(cached) return *cached;

    if(state.cur == OUT) {
        if(state.found_fft && state.found_dac) return 1;
        return 0;
    }

    size_t total = 0;
    DeviceList *list = ht_find(devices, state.cur); 
    assert(list);
    for(size_t i = 0; i < list->count; i++) {
        uint64_t next = list->items[i];
        State next_state = {next, state.found_fft || next == FFT, state.found_dac || next == DAC};
        total += dfs(next_state, devices, cache);
    }

    return *ht_put(cache, state) = total;
}


void part2(Nob_String_View input) {
    Devices devices = {0};
    while(input.count > 0) {
        Nob_String_View line = nob_sv_chop_by_delim(&input, '\n');
        Nob_String_View device_name = nob_sv_chop_by_delim(&line, ':');
        line = nob_sv_trim(line);

        DeviceList device_list = {0};
        uint64_t device_id = name_to_id(device_name);
        while(line.count > 0) {
            Nob_String_View num_sv = nob_sv_chop_by_delim(&line, ' ');
            uint64_t id = name_to_id(num_sv);
            nob_da_append(&device_list, id);
        }
        *ht_put(&devices, device_id) = device_list;
    }


    OUT = name_to_id(nob_sv_from_cstr("out"));
    FFT = name_to_id(nob_sv_from_cstr("fft"));
    DAC = name_to_id(nob_sv_from_cstr("dac"));

    Cache cache = {0};
    State start_state = {name_to_id(nob_sv_from_cstr("svr")), false, false};
    uint64_t res = dfs(start_state, &devices, &cache);

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
