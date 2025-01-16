const std = @import("std");
const Allocator = std.mem.Allocator;
const fs = std.fs;

const Point = [2]i64;

fn read_input(input_file_name: []const u8, allocator: Allocator) ![]u8 {
    const input_file = try fs.cwd().openFile(input_file_name, .{});
    defer input_file.close();
    return input_file.readToEndAlloc(allocator, 4 * 1024 * 1024);
}

fn add_tuple(p1: Point, p2: Point) Point {
    return .{ p1[0] + p2[0], p1[1] + p2[1] };
}

fn part1(input_file_name: []const u8) !void {
    const allocator = std.heap.page_allocator;
    const input = std.mem.trim(u8, try read_input(input_file_name, allocator), "\n");
    defer allocator.free(input);

    var grid = std.ArrayList(std.ArrayList(u8)).init(allocator);
    defer grid.deinit();
    defer {
        for (grid.items) |row| {
            row.deinit();
        }
    }
    var lines = std.mem.split(u8, input, "\n");
    var start_position = Point{ 0, 0 };
    var end_position = Point{ 0, 0 };
    var i: usize = 0;
    while (lines.next()) |line| : (i += 1) {
        var row = std.ArrayList(u8).init(allocator);
        for (line, 0..) |char, j| {
            if (char == 'S') {
                start_position = .{ @intCast(i), @intCast(j) };
                try row.append('a');
            } else if (char == 'E') {
                end_position = .{ @intCast(i), @intCast(j) };
                try row.append('z');
            } else {
                try row.append(char);
            }
        }
        try grid.append(row);
    }

    var queue = std.ArrayList(struct { distance: i64, position: Point }).init(allocator);
    defer queue.deinit();
    try queue.append(.{ .distance = 0, .position = start_position });
    var res: i64 = 0;
    const dirs = [_]Point{ .{ 0, 1 }, .{ 0, -1 }, .{ 1, 0 }, .{ -1, 0 } };
    var seen = std.AutoHashMap(Point, bool).init(allocator);
    while (queue.items.len > 0) {
        const item = queue.pop();
        const distance = item.distance;
        const position = item.position;
        if (seen.contains(position)) {
            continue;
        }
        try seen.put(position, true);
        if (position[0] == end_position[0] and position[1] == end_position[1]) {
            res = distance;
            break;
        }
        const row = grid.items[@intCast(position[0])];
        const char = row.items[@intCast(position[1])];
        for (dirs) |dir| {
            const new_position = add_tuple(position, dir);
            if (new_position[0] < 0 or new_position[0] >= grid.items.len) {
                continue;
            }
            const new_row = grid.items[@intCast(new_position[0])];
            if (new_position[1] < 0 or new_position[1] >= new_row.items.len) {
                continue;
            }
            const new_char = new_row.items[@intCast(new_position[1])];
            if (new_char <= char + 1) {
                try queue.insert(0, .{ .distance = distance + 1, .position = new_position });
            }
        }
    }

    std.debug.print("Part 1: {d}\n", .{res});
}

fn part2(input_file_name: []const u8) !void {
    const allocator = std.heap.page_allocator;
    const input = std.mem.trim(u8, try read_input(input_file_name, allocator), "\n");
    defer allocator.free(input);
    var grid = std.ArrayList(std.ArrayList(u8)).init(allocator);
    defer grid.deinit();
    defer {
        for (grid.items) |row| {
            row.deinit();
        }
    }
    var lines = std.mem.split(u8, input, "\n");
    var start_positions = std.ArrayList(Point).init(allocator);
    var end_position = Point{ 0, 0 };
    var i: usize = 0;
    while (lines.next()) |line| : (i += 1) {
        var row = std.ArrayList(u8).init(allocator);
        for (line, 0..) |char, j| {
            if (char == 'S') {
                try start_positions.append(.{ @intCast(i), @intCast(j) });
                try row.append('a');
            } else if (char == 'E') {
                end_position = .{ @intCast(i), @intCast(j) };
                try row.append('z');
            } else {
                if (char == 'a') {
                    try start_positions.append(.{ @intCast(i), @intCast(j) });
                }
                try row.append(char);
            }
        }
        try grid.append(row);
    }

    var shortest_distance: i64 = std.math.maxInt(i64);
    for (start_positions.items) |start_position| {
        var queue = std.ArrayList(struct { distance: i64, position: Point }).init(allocator);
        defer queue.deinit();
        try queue.append(.{ .distance = 0, .position = start_position });
        var res: i64 = std.math.maxInt(i64);
        const dirs = [_]Point{ .{ 0, 1 }, .{ 0, -1 }, .{ 1, 0 }, .{ -1, 0 } };
        var seen = std.AutoHashMap(Point, bool).init(allocator);
        while (queue.items.len > 0) {
            const item = queue.pop();
            const distance = item.distance;
            const position = item.position;
            if (seen.contains(position)) {
                continue;
            }
            try seen.put(position, true);
            if (position[0] == end_position[0] and position[1] == end_position[1]) {
                res = distance;
                break;
            }
            const row = grid.items[@intCast(position[0])];
            const char = row.items[@intCast(position[1])];
            for (dirs) |dir| {
                const new_position = add_tuple(position, dir);
                if (new_position[0] < 0 or new_position[0] >= grid.items.len) {
                    continue;
                }
                const new_row = grid.items[@intCast(new_position[0])];
                if (new_position[1] < 0 or new_position[1] >= new_row.items.len) {
                    continue;
                }
                const new_char = new_row.items[@intCast(new_position[1])];
                if (new_char <= char + 1) {
                    try queue.insert(0, .{ .distance = distance + 1, .position = new_position });
                }
            }
        }
        shortest_distance = @min(shortest_distance, res);
    }
    std.debug.print("Part 2: {d}\n", .{shortest_distance});
}

pub fn main() !void {
    // const input_file = "sample.txt";
    const input_file = "input.txt";
    try part1(input_file);
    try part2(input_file);
}
