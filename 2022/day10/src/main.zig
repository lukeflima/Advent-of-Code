const std = @import("std");
const Allocator = std.mem.Allocator;
const fs = std.fs;

fn read_input(input_file_name: []const u8, allocator: Allocator) ![]u8 {
    const input_file = try fs.cwd().openFile(input_file_name, .{});
    defer input_file.close();
    return input_file.readToEndAlloc(allocator, 4 * 1024 * 1024);
}

fn check_cycle(cycle: i64) bool {
    return std.mem.containsAtLeast(i64, &[_]i64{ 20, 60, 100, 140, 180, 220 }, 1, &.{cycle});
}

fn part1(input_file_name: []const u8) !void {
    const allocator = std.heap.page_allocator;
    const input = std.mem.trim(u8, try read_input(input_file_name, allocator), "\n");
    defer allocator.free(input);

    var lines = std.mem.split(u8, input, "\n");
    var cycle: i64 = 0;
    var x: i64 = 1;
    var res: i64 = 0;
    while (lines.next()) |line| {
        if (std.mem.eql(u8, line, "noop")) {
            cycle += 1;
            if (check_cycle(cycle)) res += cycle * x;

            continue;
        }
        var tokens = std.mem.split(u8, line, " ");
        _ = tokens.next().?;
        const arg = try std.fmt.parseInt(i64, tokens.next().?, 10);
        for (0..2) |_| {
            cycle += 1;
            if (check_cycle(cycle)) res += cycle * x;
        }
        x += arg;
        // std.debug.print("{s} {d}\n", .{ op, arg });
    }
    std.debug.print("Part 1: {d}\n", .{res});
}

fn draw_pixel(x: i64, cycle: i64) void {
    const x_mod = @mod(x, 40);
    const cycle_mod = @mod(cycle - 1, 40);
    if (cycle_mod == x_mod or cycle_mod == x_mod - 1 or cycle_mod == x_mod + 1) {
        std.debug.print("#", .{});
    } else {
        std.debug.print(".", .{});
    }
    if (@mod(cycle, 40) == 0) {
        std.debug.print("\n", .{});
    }
}

fn part2(input_file_name: []const u8) !void {
    const allocator = std.heap.page_allocator;
    const input = std.mem.trim(u8, try read_input(input_file_name, allocator), "\n");
    defer allocator.free(input);

    var lines = std.mem.split(u8, input, "\n");
    var cycle: i64 = 0;
    var x: i64 = 1;
    std.debug.print("Part 2: \n", .{});
    while (lines.next()) |line| {
        if (std.mem.eql(u8, line, "noop")) {
            cycle += 1;
            draw_pixel(x, cycle);
            continue;
        }
        var tokens = std.mem.split(u8, line, " ");
        _ = tokens.next().?;
        const arg = try std.fmt.parseInt(i64, tokens.next().?, 10);
        for (0..2) |_| {
            cycle += 1;
            draw_pixel(x, cycle);
        }
        x += arg;
    }
}

pub fn main() !void {
    // const input_file = "sample.txt";
    const input_file = "input.txt";
    try part1(input_file);
    try part2(input_file);
}
