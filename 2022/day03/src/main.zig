const std = @import("std");
const Allocator = std.mem.Allocator;
const fs = std.fs;

fn read_input(input_file_name: []const u8, allocator: Allocator) ![]u8 {
    const input_file = try fs.cwd().openFile(input_file_name, .{});
    defer input_file.close();
    return input_file.readToEndAlloc(allocator, 4 * 1024 * 1024);
}

fn part1(input_file_name: []const u8) !void {
    const allocator = std.heap.page_allocator;
    const input = std.mem.trim(u8, try read_input(input_file_name, allocator), "\n");
    defer allocator.free(input);

    var lines = std.mem.split(u8, input, "\n");
    var res: usize = 0;
    while (lines.next()) |line| {
        const middle: usize = line.len / 2;
        const left_rucksack = line[0..middle];
        const right_rucksack = line[middle..];
        outer: for (0..middle) |i| {
            for (0..middle) |j| {
                if (left_rucksack[i] == right_rucksack[j]) {
                    const item = left_rucksack[i];
                    if (item >= 'a' and item <= 'z') {
                        res += item - 'a' + 1;
                    } else {
                        res += item - 'A' + 27;
                    }
                    break :outer;
                }
            }
        }
    }

    std.debug.print("Part 1: {d}\n", .{res});
}
fn part2(input_file_name: []const u8) !void {
    const allocator = std.heap.page_allocator;
    const input = std.mem.trim(u8, try read_input(input_file_name, allocator), "\n");
    defer allocator.free(input);

    var lines = std.mem.split(u8, input, "\n");
    var res: usize = 0;
    while (true) {
        const elf_option = lines.next();
        if (elf_option == null) {
            break;
        }
        const elfs = [3][]const u8{ elf_option.?, lines.next().?, lines.next().? };
        const hashmap = std.AutoHashMap(u8, u8);
        var maps = std.ArrayList(hashmap).init(allocator);
        for (elfs) |elf| {
            var map = hashmap.init(allocator);
            for (elf) |c| {
                try map.put(c, 1);
            }
            try maps.append(map);
        }

        var norepeat = hashmap.init(allocator);
        defer norepeat.deinit();
        for (maps.items) |map| {
            var iterator = map.iterator();
            while (iterator.next()) |entry| {
                const item = entry.key_ptr.*;
                if (norepeat.contains(item)) {
                    try norepeat.put(item, norepeat.get(item).? + 1);
                } else {
                    try norepeat.put(item, 1);
                }
            }
        }
        var iterator = norepeat.iterator();
        while (iterator.next()) |entry| {
            if (entry.value_ptr.* == 3) {
                const item = entry.key_ptr.*;
                if (item >= 'a' and item <= 'z') {
                    res += item - 'a' + 1;
                } else {
                    res += item - 'A' + 27;
                }
            }
        }
    }

    std.debug.print("Part 2: {d}\n", .{res});
}
pub fn main() !void {
    // const input_file = "sample.txt";
    const input_file = "input.txt";
    try part1(input_file);
    try part2(input_file);
}
