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
        var strat = std.mem.split(u8, line, " ");
        const oponnet: u8 = strat.next().?[0] - 'A';
        const play: u8 = strat.next().?[0] - 'X';
        res += play + 1;
        if (oponnet == play) {
            //draw
            res += 3;
        } else if ((oponnet + 1) % 3 == play) {
            //win
            res += 6;
        } else {
            //lose
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
        var strat = std.mem.split(u8, line, " ");
        const oponnet: u8 = strat.next().?[0] - 'A';
        const outcome = strat.next().?[0];
        res += 1;
        if (outcome == 'X') {
            res += (oponnet + 3 - 1) % 3;
            //lose
        } else if (outcome == 'Y') {
            res += oponnet + 3;
        } else {
            //win
            res += 6 + (oponnet + 1) % 3;
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
