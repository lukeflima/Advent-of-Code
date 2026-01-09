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

#define grid_at(grid, x, y) (((x) >= 0) && ((x) < (grid).rows) && ((y) >= 0) && ((y) < (grid).cols) ? \
                                ((grid).items[(x) + (y)*((grid).cols)]) : -1)


void part1(Nob_String_View input) {
    Grid grid = {0};
    while(input.count > 0) {
        Nob_String_View line = nob_sv_chop_by_delim(&input, '\n');
        nob_da_append_many(&grid, line.data, line.count);
        grid.cols = (int)line.count;
        grid.rows += 1;
    }

    size_t res = 0;
    for(int y = 0; y < (int)grid.cols; y++) {
        for(int x = 0; x < (int)grid.rows; x++) {
            if(grid_at(grid, x, y) != '@') continue;

            size_t num_neighbours = 0;
            if(grid_at(grid, x + 1, y + 1) == '@') num_neighbours += 1;
            if(grid_at(grid, x + 1, y    ) == '@') num_neighbours += 1;
            if(grid_at(grid, x + 1, y - 1) == '@') num_neighbours += 1;
            if(grid_at(grid, x    , y + 1) == '@') num_neighbours += 1;
            if(grid_at(grid, x    , y - 1) == '@') num_neighbours += 1;
            if(grid_at(grid, x - 1, y + 1) == '@') num_neighbours += 1;
            if(grid_at(grid, x - 1, y    ) == '@') num_neighbours += 1;
            if(grid_at(grid, x - 1, y - 1) == '@') num_neighbours += 1;

            if(num_neighbours < 4) res += 1;
        }
    }

    printf("Part 1: %zu\n", res);
}

typedef struct{
    int x;
    int y;
} Point;

typedef struct {
    Point *items;
    size_t count;
    size_t capacity;
} Points;

void part2(Nob_String_View input) {
    Grid grid = {0};
    while(input.count > 0) {
        Nob_String_View line = nob_sv_chop_by_delim(&input, '\n');
        nob_da_append_many(&grid, line.data, line.count);
        grid.cols = (int)line.count;
        grid.rows += 1;
    }

    size_t res = 0;
    Points points_to_remove = {0};
    for (;;) {
        points_to_remove.count = 0;
        for(int y = 0; y < (int)grid.cols; y++) {
            for(int x = 0; x < (int)grid.rows; x++) {
                if(grid_at(grid, x, y) != '@') continue;

                size_t num_neighbours = 0;
                if(grid_at(grid, x + 1, y + 1) == '@') num_neighbours += 1;
                if(grid_at(grid, x + 1, y    ) == '@') num_neighbours += 1;
                if(grid_at(grid, x + 1, y - 1) == '@') num_neighbours += 1;
                if(grid_at(grid, x    , y + 1) == '@') num_neighbours += 1;
                if(grid_at(grid, x    , y - 1) == '@') num_neighbours += 1;
                if(grid_at(grid, x - 1, y + 1) == '@') num_neighbours += 1;
                if(grid_at(grid, x - 1, y    ) == '@') num_neighbours += 1;
                if(grid_at(grid, x - 1, y - 1) == '@') num_neighbours += 1;
                
                if(num_neighbours < 4) {
                    Point point = {x ,y};
                    nob_da_append(&points_to_remove, point);
                }
            }
        }
        if(points_to_remove.count == 0) break;

        for(size_t i = 0; i < points_to_remove.count; i++) {
            Point p = points_to_remove.items[i];
            grid.items[p.x + p.y*grid.rows] = '.';
        }
        
        res += points_to_remove.count;
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