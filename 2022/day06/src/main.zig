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

    var unique_sequence: usize = 0;
    for (0..input.len - 4) |i| {
        const chars = input[i .. i + 4];
        var unique = true;
        for (0..4) |x| {
            for (0..4) |y| {
                if (x == y) continue;
                if (chars[x] == chars[y]) {
                    unique = false;
                }
            }
        }
        if (unique) {
            unique_sequence = i + 4;
            break;
        }
    }

    std.debug.print("Part 1: {d}\n", .{unique_sequence});
}

fn part2(input_file_name: []const u8) !void {
    const allocator = std.heap.page_allocator;
    const input = std.mem.trim(u8, try read_input(input_file_name, allocator), "\n");

    var unique_sequence: usize = 0;
    for (0..input.len - 14) |i| {
        const chars = input[i .. i + 14];
        var unique = true;
        for (0..14) |x| {
            for (0..14) |y| {
                if (x == y) continue;
                if (chars[x] == chars[y]) {
                    unique = false;
                }
            }
        }
        if (unique) {
            unique_sequence = i + 14;
            break;
        }
    }

    std.debug.print("Part 2: {d}\n", .{unique_sequence});
}

pub fn main() !void {
    // const input_file = "sample.txt";
    const input_file = "input.txt";
    try part1(input_file);
    try part2(input_file);
}
