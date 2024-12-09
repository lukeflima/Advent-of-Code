def get_disk_map(input: str):
    input = input.strip()
    cur_id = 0
    disk_map = []
    for i in range(len(input)):
        if i % 2 == 0:
            disk_map.append((cur_id, int(input[i])))
            cur_id += 1
        else:
            disk_map.append((-1, int(input[i])))
    return disk_map, cur_id - 1

def part1(input: str):
    disk_map, _ = get_disk_map(input)
    c = len(disk_map) - 2 if len(disk_map) % 2 == 0 else len(disk_map) - 1
    free_space_index = 1
    new_disk_map = [disk_map[0]]
    while True:
        free_space = disk_map[free_space_index]
        file = disk_map[c]
        if file[1] > free_space[1]:
            new_disk_map.append((file[0], free_space[1]))
            disk_map[c] = (file[0], file[1] - free_space[1])
            new_disk_map.append(disk_map[free_space_index+1])
            free_space_index += 2
        elif file[1] == free_space[1]:
            new_disk_map.append((file[0], file[1]))
            c -= 2
            new_disk_map.append(disk_map[free_space_index+1])
            free_space_index += 2
        else:
            new_disk_map.append((file[0], file[1]))
            disk_map[free_space_index] = (None, free_space[1] - file[1])
            c -= 2
        if free_space_index > c or free_space_index > len(disk_map) - 1:
            break
    
    checksum = 0
    cur = 0
    for (id, size) in new_disk_map:
        n1 = cur
        n2 = cur + size
        cur += size
        checksum += id * ((n2 + n1 - 1)*(n2 - n1)/2)
    
    print("Part 1:", int(checksum))
    return 0

def part2(input: str):
    disk_map, last_id = get_disk_map(input)
    id = last_id
    while id > 0:
        c = len(disk_map) - 1
        while c < len(disk_map):
            if disk_map[c][0] == id: break
            c -= 1
        id -= 1
        moved = False
        for free_space_index, free_space in enumerate(disk_map):
            if free_space[0] != -1:
                continue
            if free_space_index > c:
                break
            file = disk_map[c]
            if file[1] < free_space[1]:
                disk_map[free_space_index] = (-1, free_space[1] - file[1])
                disk_map[c] = (-1, file[1])
                disk_map.insert(free_space_index, file)
                moved = True
                break
            elif file[1] == free_space[1]:
                disk_map[free_space_index] = file
                disk_map[c] = (-1, file[1])
                moved = True
                break

        #colapse free_space:
        if not moved: continue
        i = 1
        while i < len(disk_map) - 1:
            prev, next = disk_map[i], disk_map[i + 1]
            if prev[0] == -1 and next[0] == -1:
                disk_map[i] = (-1, prev[1] + next[1])
                del disk_map[i+1]
            else:
                i += 1
    checksum = 0
    cur = 0
    # print(disk_map)
    for (id, size) in disk_map:
        if id == -1: 
            cur += size
            continue
        n1 = cur
        n2 = cur + size
        cur += size
        checksum += id * ((n2 + n1 - 1)*(n2 - n1)/2)
    
    print("Part 2:", int(checksum))
    return 0

def main():
    # with open("inputtest.txt") as input:
    with open("input.txt") as input:
        input = input.read()
    if ret := part1(input): return ret
    if ret := part2(input): return ret

if __name__ == "__main__":
    raise SystemExit(main())