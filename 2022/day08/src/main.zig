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
    var trees = std.ArrayList([]const u8).init(allocator);
    var lines = std.mem.split(u8, input, "\n");
    while (lines.next()) |line| {
        try trees.append(line);
    }
    var visibles: usize = 0;
    for (trees.items, 0..) |tree, i| {
        for (tree, 0..) |c, j| {
            if (i == 0 or i == trees.items.len - 1 or j == 0 or j == tree.len - 1) {
                visibles += 1;
                continue;
            }

            var maxTop: u8 = 0;
            for (0..i) |ii| {
                maxTop = @max(maxTop, trees.items[ii][j]);
            }
            var maxBot: u8 = 0;
            for (i + 1..trees.items.len) |ii| {
                maxBot = @max(maxBot, trees.items[ii][j]);
            }
            var maxLeft: u8 = 0;
            for (0..j) |jj| {
                maxLeft = @max(maxLeft, tree[jj]);
            }
            var maxRight: u8 = 0;
            for (j + 1..tree.len) |jj| {
                maxRight = @max(maxRight, tree[jj]);
            }
            if (maxRight < c or maxLeft < c or maxBot < c or maxTop < c) {
                visibles += 1;
            }
        }
    }

    std.debug.print("Part 1: {d}\n", .{visibles});
}

fn part2(input_file_name: []const u8) !void {
    const allocator = std.heap.page_allocator;
    const input = std.mem.trim(u8, try read_input(input_file_name, allocator), "\n");
    defer allocator.free(input);
    var trees = std.ArrayList([]const u8).init(allocator);
    var lines = std.mem.split(u8, input, "\n");
    while (lines.next()) |line| {
        try trees.append(line);
    }
    var highest_scenic: usize = 0;
    for (trees.items, 0..) |tree, i| {
        for (tree, 0..) |c, j| {
            var topDist: usize = 0;
            var ii: i32 = @intCast(i);
            ii -= 1;
            while (ii >= 0) : (ii -= 1) {
                topDist += 1;
                if (trees.items[@intCast(ii)][j] >= c) {
                    break;
                }
            }
            var bottomDist: usize = 0;
            ii = @intCast(i + 1);
            while (ii < trees.items.len) : (ii += 1) {
                bottomDist += 1;
                if (trees.items[@intCast(ii)][j] >= c) {
                    break;
                }
            }
            var leftDist: usize = 0;
            var jj: i32 = @intCast(j);
            jj -= 1;
            while (jj >= 0) : (jj -= 1) {
                leftDist += 1;
                if (tree[@intCast(jj)] >= c) {
                    break;
                }
            }
            var rightDist: usize = 0;
            jj = @intCast(j + 1);
            while (jj < tree.len) : (jj += 1) {
                rightDist += 1;
                if (tree[@intCast(jj)] >= c) {
                    break;
                }
            }
            highest_scenic = @max(highest_scenic, topDist * bottomDist * rightDist * leftDist);
        }
    }

    std.debug.print("Part 2: {d}\n", .{highest_scenic});
}

pub fn main() !void {
    // const input_file = "sample.txt";
    const input_file = "input.txt";
    try part1(input_file);
    try part2(input_file);
}
