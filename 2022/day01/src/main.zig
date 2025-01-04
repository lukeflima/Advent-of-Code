const std = @import("std");
const Allocator = std.mem.Allocator;
const fs = std.fs;

fn read_input(input_file_name: []const u8, allocator: Allocator) ![]u8 {
    const input_file = try fs.cwd().openFile(input_file_name, .{});
    defer input_file.close();
    return input_file.readToEndAlloc(allocator, 4096 * 1024);
}

fn part1() !void {
    const allocator = std.heap.page_allocator;
    const input = try read_input("input.txt", allocator);
    defer allocator.free(input);

    var blocks = std.mem.split(u8, input, "\n\n");
    var max_calories: usize = 0;
    while (blocks.next()) |elf| {
        var lines = std.mem.split(u8, std.mem.trim(u8, elf, "\n"), "\n");
        var elf_calories: usize = 0;
        while (lines.next()) |calories_str| {
            const calories = try std.fmt.parseInt(usize, calories_str, 10);
            elf_calories += calories;
        }
        max_calories = @max(max_calories, elf_calories);
    }
    std.debug.print("Part 1: {d}\n", .{max_calories});
}
fn part2() !void {
    const allocator = std.heap.page_allocator;
    const input = try read_input("input.txt", allocator);
    defer allocator.free(input);

    var blocks = std.mem.split(u8, input, "\n\n");
    var elfs = std.ArrayList(usize).init(allocator);
    defer elfs.deinit();
    while (blocks.next()) |elf| {
        var lines = std.mem.split(u8, std.mem.trim(u8, elf, "\n"), "\n");
        var elf_calories: usize = 0;
        while (lines.next()) |calories_str| {
            const calories = try std.fmt.parseInt(usize, calories_str, 10);
            elf_calories += calories;
        }
        try elfs.append(elf_calories);
    }
    std.mem.sort(usize, elfs.items, {}, comptime std.sort.desc(usize));
    const res = elfs.items[0] + elfs.items[1] + elfs.items[2];
    std.debug.print("Part 2: {d}\n", .{res});
}
pub fn main() !void {
    try part1();
    try part2();
}
