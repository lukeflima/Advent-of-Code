#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#define NOB_IMPLEMENTATION
#define NOB_STRIP_PREFIX
#include "nob.h"

uint64_t svtou64(Nob_String_View input) {
    bool is_neg = input.data[0] == '-';
    uint64_t res = 0;
    for(size_t i = is_neg ? 1 : 0; i < input.count; i++) {
        if(input.data[i] < '0' && input.data[i] > '9') return 0;
        res = res * 10 + input.data[i] - '0';
    }
    return is_neg ? -res : res;
}

typedef struct {
    int64_t x;
    int64_t y;
    int64_t z;
} Box;

double boxes_distance(Box box1, Box box2) {
    return sqrt(pow(box1.x - box2.x, 2) + pow(box1.y - box2.y, 2) + pow(box1.z - box2.z, 2));
}

typedef struct {
    Box *items;
    size_t count;
    size_t capacity;
} Boxes;

typedef struct {
    size_t box1;
    size_t box2;
    double distance;
} Distance;

int compare_distances(const void *d1v, const void* d2v) {
    Distance *d1 = (Distance *) d1v;
    Distance *d2 = (Distance *) d2v;
    if(d1->distance < d2->distance) return -1;
    return 1;
}

typedef struct {
    Distance *items;
    size_t count;
    size_t capacity;
} Distances;

typedef struct {
    size_t *items;
    size_t count;
    size_t capacity;
} Parents;

size_t ufind(Parents *parents, size_t x) {
    if(parents->items[x] != x) return ufind(parents, parents->items[x]);
    return x;
}

void uunion(Parents *parents, size_t x, size_t y) {
    parents->items[ufind(parents, x)] = ufind(parents, y);
}

typedef struct {
    size_t *items;
    size_t count;
    size_t capacity;
} Circuit_Size;

int compare_sizet_reverse(const void *d1v, const void* d2v) {
    size_t *d1 = (size_t *) d1v;
    size_t *d2 = (size_t *) d2v;
    if(*d1 == *d2) return 0;
    if(*d1 < *d2) return 1;
    return -1;
}

void part1(Nob_String_View input) {
    Boxes boxes = {0};
    Parents parents = {0};
    Circuit_Size circuit_size = {0};
    while(input.count > 0) {
        Nob_String_View line = nob_sv_chop_by_delim(&input, '\n');
        Box box = {
            svtou64(nob_sv_chop_by_delim(&line, ',')),
            svtou64(nob_sv_chop_by_delim(&line, ',')),
            svtou64(nob_sv_chop_by_delim(&line, ','))
        };
        nob_da_append(&parents, boxes.count);
        nob_da_append(&boxes, box);
        nob_da_append(&circuit_size, 0);
    }

    Distances distances = {0};
    for(size_t i = 0; i < boxes.count; i++) {
        for(size_t j = i+1; j < boxes.count; j++) {
            Distance distance = {
                .box1 = i,
                .box2 = j,
                .distance =  boxes_distance(boxes.items[i], boxes.items[j]),
            };
            nob_da_append(&distances, distance);
        }
    }
    qsort(distances.items, distances.count, sizeof(Distance), compare_distances);
    
    for(size_t i = 0; i < 1000; i++) {
        Distance distance = distances.items[i];
        if(ufind(&parents, distance.box1) != ufind(&parents, distance.box2)) {
            uunion(&parents, distance.box1, distance.box2);
        }
    }

    for(size_t i = 0; i < boxes.count; i++) {
        circuit_size.items[ufind(&parents, i)] += 1;
    }
    qsort(circuit_size.items, circuit_size.count, sizeof(size_t), compare_sizet_reverse);
   
    uint64_t res = circuit_size.items[0] * circuit_size.items[1] * circuit_size.items[2];
    
    printf("Part 1: %zu\n", res);
}

void part2(Nob_String_View input) {
    Boxes boxes = {0};
    Parents parents = {0};
    while(input.count > 0) {
        Nob_String_View line = nob_sv_chop_by_delim(&input, '\n');
        Box box = {
            svtou64(nob_sv_chop_by_delim(&line, ',')),
            svtou64(nob_sv_chop_by_delim(&line, ',')),
            svtou64(nob_sv_chop_by_delim(&line, ','))
        };
        nob_da_append(&parents, boxes.count);
        nob_da_append(&boxes, box);
    }

    Distances distances = {0};
    for(size_t i = 0; i < boxes.count; i++) {
        for(size_t j = i+1; j < boxes.count; j++) {
            Distance distance = {
                .box1 = i,
                .box2 = j,
                .distance =  boxes_distance(boxes.items[i], boxes.items[j]),
            };
            nob_da_append(&distances, distance);
        }
    }
    qsort(distances.items, distances.count, sizeof(Distance), compare_distances);
    
    uint64_t res = 0;
    size_t unoins = 0;
    for(size_t i = 0; i < distances.count; i++) {
        Distance distance = distances.items[i];
        if(ufind(&parents, distance.box1) != ufind(&parents, distance.box2)) {
            uunion(&parents, distance.box1, distance.box2);
            unoins++;
            if(unoins + 1 == boxes.count){
                res = boxes.items[distance.box1].x * boxes.items[distance.box2].x;
                break;
            }
        }
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