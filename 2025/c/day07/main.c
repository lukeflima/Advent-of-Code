#include <assert.h>
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#define NOB_IMPLEMENTATION
#define NOB_STRIP_PREFIX
#include "nob.h"

typedef struct {
    char *items;
    size_t count;
    size_t capacity;
    int rows;
    int cols;
} Grid;

typedef struct {
    bool *items;
    size_t count;
    size_t capacity;
} Visited;

#define grid_index(grid, x, y) ((x) + (y)*((grid).cols))
#define grid_at(grid, x, y) ((grid).items[grid_index((grid), (x), (y))])
#define in_grid(grid, x, y) (((x) >= 0) && ((x) < (grid).rows) && ((y) >= 0) && ((y) < (grid).cols))
                                

void num_splits(Grid grid, int x, int y, Visited* visited, size_t *splits) {
    // printf("x=%d, y=%d\n",x, y);
    int nx = x, ny = y + 1;
    if(!in_grid(grid, nx, ny)) return;
    
    size_t nindex = grid_index(grid, x, y);
    if(visited->items[nindex]) return;
    visited->items[nindex] = true;

    if(grid_at(grid, nx, ny) == '^') {
        // printf("split\n");
        *splits += 1;
        num_splits(grid, nx + 1, ny, visited, splits);
        num_splits(grid, nx - 1, ny, visited, splits);
    } else {
        num_splits(grid, nx, ny, visited, splits);
    }
}

void part1(Nob_String_View input) {
    Grid grid = {0};
    Visited visited = {0};
    while(input.count > 0) {
        Nob_String_View line = nob_sv_chop_by_delim(&input, '\n');
        nob_da_append_many(&grid, line.data, line.count);
        grid.cols = (int)line.count;
        grid.rows += 1;
        for(size_t i = 0; i < line.count; i++) nob_da_append(&visited, false);
    }

    int emitter_x = -1;
    for(int i = 0; i < grid.cols; i++) {
        if(grid_at(grid, i, 0) == 'S') {
            emitter_x = i;
            break;
        }
    }
    assert(emitter_x != -1);
    
    size_t splits = 0;
    num_splits(grid, emitter_x, 1, &visited, &splits);
    
    printf("Part 1: %zu\n", splits);
}

typedef struct {
    uint64_t *items;
    size_t count;
    size_t capacity;
} Cache;

uint64_t num_timelines(Grid grid, int x, int y, Visited *visited, Cache *cache) {
    size_t nindex = grid_index(grid, x, y);
    if(visited->items[nindex]) return cache->items[nindex];

    int nx = x, ny = y + 1;
    if(!in_grid(grid, nx, ny)) return 1;
    
    if(grid_at(grid, nx, ny) == '^') {
        cache->items[nindex] = num_timelines(grid, nx + 1, ny, visited, cache) 
                                + num_timelines(grid, nx - 1, ny, visited, cache);
    } else {
        cache->items[nindex] = num_timelines(grid, nx, ny, visited, cache);
    }
    
    visited->items[nindex] = true;
    return cache->items[nindex];
}

void part2(Nob_String_View input) {
    Grid grid = {0};
    Visited visited = {0};
    Cache cache = {0};
    while(input.count > 0) {
        Nob_String_View line = nob_sv_chop_by_delim(&input, '\n');
        nob_da_append_many(&grid, line.data, line.count);
        grid.cols = (int)line.count;
        grid.rows += 1;
        for(size_t i = 0; i < line.count; i++) {
            nob_da_append(&visited, false);
            nob_da_append(&cache, 0);
        }
    }

    int emitter_x = -1;
    for(int i = 0; i < grid.cols; i++) {
        if(grid_at(grid, i, 0) == 'S') {
            emitter_x = i;
            break;
        }
    }
    assert(emitter_x != -1);

    uint64_t res =  num_timelines(grid, emitter_x, 1, &visited, &cache);

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