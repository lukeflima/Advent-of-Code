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
        var elfs_iter = std.mem.split(u8, line, ",");
        var elf1_iter = std.mem.split(u8, elfs_iter.next().?, "-");
        var elf2_iter = std.mem.split(u8, elfs_iter.next().?, "-");
        const elf1_min = try std.fmt.parseInt(usize, elf1_iter.next().?, 10);
        const elf1_max = try std.fmt.parseInt(usize, elf1_iter.next().?, 10);
        const elf2_min = try std.fmt.parseInt(usize, elf2_iter.next().?, 10);
        const elf2_max = try std.fmt.parseInt(usize, elf2_iter.next().?, 10);

        if ((elf1_min >= elf2_min and elf1_max <= elf2_max) or (elf2_min >= elf1_min and elf2_max <= elf1_max)) {
            res += 1;
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
    while (lines.next()) |line| {
        var elfs_iter = std.mem.split(u8, line, ",");
        var elf1_iter = std.mem.split(u8, elfs_iter.next().?, "-");
        var elf2_iter = std.mem.split(u8, elfs_iter.next().?, "-");
        const elf1_min = try std.fmt.parseInt(usize, elf1_iter.next().?, 10);
        const elf1_max = try std.fmt.parseInt(usize, elf1_iter.next().?, 10);
        const elf2_min = try std.fmt.parseInt(usize, elf2_iter.next().?, 10);
        const elf2_max = try std.fmt.parseInt(usize, elf2_iter.next().?, 10);

        if ((elf2_min >= elf1_min and elf2_min <= elf1_max) or (elf2_max >= elf1_min and elf2_max <= elf1_max) or
            (elf1_min >= elf2_min and elf1_min <= elf2_max) or (elf1_max >= elf2_min and elf1_max <= elf2_max))
        {
            res += 1;
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
