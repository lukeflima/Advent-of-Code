const std = @import("std");
const Allocator = std.mem.Allocator;
const fs = std.fs;

fn read_input(input_file_name: []const u8, allocator: Allocator) ![]u8 {
    const input_file = try fs.cwd().openFile(input_file_name, .{});
    defer input_file.close();
    return input_file.readToEndAlloc(allocator, 4 * 1024 * 1024);
}

fn part1() !void {
    const allocator = std.heap.page_allocator;
    const input = try read_input("input.txt", allocator);
    defer allocator.free(input);

    std.debug.print("Part 1: {d}\n", .{0});
}
fn part2() !void {
    const allocator = std.heap.page_allocator;
    const input = try read_input("input.txt", allocator);
    defer allocator.free(input);

    std.debug.print("Part 2: {d}\n", .{0});
}
pub fn main() !void {
    try part1();
    try part2();
}
