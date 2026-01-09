#include <assert.h>
#include <stddef.h>
#include <stdio.h>
#include <stdint.h>
#include <inttypes.h>
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
    uint64_t x;
    uint64_t y;
} Point;

uint64_t abs_diff(uint64_t a, uint64_t b) {
    if(a > b) return a - b;
    return b - a;
}

uint64_t rect_area(Point t1, Point t2) {
    return (abs_diff(t1.x, t2.x) + 1)*(abs_diff(t1.y, t2.y) + 1);
}

uint64_t max(uint64_t a, uint64_t b) {
    if(a > b) return a;
    return b;
}

uint64_t min(uint64_t a, uint64_t b) {
    if(a < b) return a;
    return b;
}


typedef struct {
    Point *items;
    size_t count;
    size_t capacity;
} Points;

void part1(Nob_String_View input) {
    Points tiles = {0};
    while(input.count > 0) {
        Nob_String_View line = nob_sv_chop_by_delim(&input, '\n');
        Point tile = {
            svtou64(nob_sv_chop_by_delim(&line, ',')),
            svtou64(nob_sv_chop_by_delim(&line, ',')),
        };
        nob_da_append(&tiles, tile);
    }


    uint64_t bigest_area = 0;
    for(size_t i = 0; i < tiles.count; i++) {
        for(size_t j = i+1; j < tiles.count; j++) {
            bigest_area = max(bigest_area, rect_area(tiles.items[i], tiles.items[j]));
        }
    }

    printf("Part 1: %"PRId64"\n", bigest_area);
}
typedef struct{
    uint64_t *items;
    size_t count;
    size_t capacity;
} Ints;

typedef struct{
    bool *items;
    size_t count;
    size_t capacity;
} Bools;

int compare_uint64t(const void* v1v, const void* v2v) {
    size_t v1 = *(uint64_t*)v1v, v2 = *(uint64_t*)v2v;
    if(v1 == v2) return 0;
    if(v1 < v2) return -1;
    return 1;
}

int find_index(Ints ints, uint64_t v) {
    for(size_t i = 0; i < ints.count; i++)
        if(ints.items[i] == v) 
            return i;
    
    return -1;
}

bool point_in_polygon(Points *polygon, double px, double py) {
    for(size_t i = 0; i < polygon->count-1; i++) {
        Point p1 = polygon->items[i];
        Point p2 = polygon->items[i + 1];
        if((p1.x == p2.x) && (px == p1.x) && min(p1.y, p2.y) <= py && py <= max(p1.y, p2.y)) {
            return true;
        }
        if((p1.y == p2.y) && (py == p1.y) && min(p1.x, p2.x) <= px && px <= max(p1.x, p2.x)) {
            return true;
        }
    }

    bool inside = false;
    for(size_t i = 0; i < polygon->count-1; i++) {
        Point p1 = polygon->items[i];
        Point p2 = polygon->items[i + 1];
        if((p1.y > py) != (p2.y > py) && (px < (double)(p2.x - p1.x) * (py - p1.y) / (p2.y - p1.y) + p1.x)) {
            inside = !inside;
        }
    }

    return inside;
}

uint64_t calc_actual_area(Ints *prefix_sum, size_t w, uint64_t x1, uint64_t y1, uint64_t x2, uint64_t y2) {
    return prefix_sum->items[x2 + y2*(w + 1)] 
           - prefix_sum->items[x1 + y2*(w + 1)] 
           - prefix_sum->items[x2 + y1*(w + 1)] 
           + prefix_sum->items[x1 + y1*(w + 1)];
}

void part2(Nob_String_View input) {
    Points tiles = {0};
    Points polygon = {0};
    Ints xs = {0};
    Ints ys = {0};
    while(input.count > 0) {
        Nob_String_View line = nob_sv_chop_by_delim(&input, '\n');
        Point tile = {
            svtou64(nob_sv_chop_by_delim(&line, ',')),
            svtou64(nob_sv_chop_by_delim(&line, ',')),
        };
        nob_da_append(&tiles, tile);
        nob_da_append(&polygon, tile);
        if(find_index(xs, tile.x) == -1) nob_da_append(&xs, tile.x);
        if(find_index(ys, tile.y) == -1) nob_da_append(&ys, tile.y);
    }
    nob_da_append(&polygon, tiles.items[0]);
    qsort(xs.items, xs.count, sizeof(uint64_t), compare_uint64t);
    qsort(ys.items, ys.count, sizeof(uint64_t), compare_uint64t);
    
    size_t w = xs.count - 1;
    size_t h = ys.count - 1;

    Bools inside_grid = {0};
    for(size_t i = 0; i < w; i++) {
        for(size_t j = 0; j < h; j++) {
            nob_da_append(&inside_grid, false);
        }
    }
    for(size_t i = 0; i < w; i++) {
        for(size_t j = 0; j < h; j++) {
            double cx = (double)(xs.items[i] + xs.items[i + 1]) / 2;
            double cy = (double)(ys.items[j] + ys.items[j + 1]) / 2;
            inside_grid.items[i + j*w] = point_in_polygon(&polygon, cx, cy);
        }
    }

    Ints prefix_sum = {0};
    for(size_t i = 0; i < w + 1; i++) {
        for(size_t j = 0; j < h + 1; j++) {
            nob_da_append(&prefix_sum, 0);
        }
    }

    for (size_t i = 0; i < w; ++i) {
        for (size_t j = 0; j < h; ++j) {
            prefix_sum.items[(i + 1) + (j + 1) * (w + 1)] = 
                                    prefix_sum.items[(i + 1) + j * (w + 1)] 
                                    + prefix_sum.items[i + (j + 1) * (w + 1)] 
                                    - prefix_sum.items[i + j * (w + 1)] 
                                    + (inside_grid.items[i + j * w] ? 1 : 0);
        }
    }

    uint64_t biggest_area_rec = 0;
    for(size_t i = 0; i < tiles.count; i++) {
        Point tile = tiles.items[i];
        size_t idx1_x = find_index(xs, tile.x);
        size_t idx1_y = find_index(ys, tile.y);

        for(size_t j = 0; j < tiles.count; j++) {
            Point tile2 = tiles.items[j];
            size_t idx2_x = find_index(xs, tile2.x);
            size_t idx2_y = find_index(ys, tile2.y);

            uint64_t min_idx_x = min(idx1_x, idx2_x);
            uint64_t max_idx_x = max(idx1_x, idx2_x);
            uint64_t min_idx_y = min(idx1_y, idx2_y);
            uint64_t max_idx_y = max(idx1_y, idx2_y);

            uint64_t expected_area = (max_idx_x - min_idx_x) * (max_idx_y - min_idx_y);
            uint64_t actual_area = calc_actual_area(&prefix_sum, w, min_idx_x, min_idx_y, max_idx_x, max_idx_y);
            if(actual_area == expected_area) {
                biggest_area_rec = max(biggest_area_rec, rect_area(tile, tile2));
            }
        }
    }
    
    printf("Part 2: %"PRIu64"\n", biggest_area_rec);
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