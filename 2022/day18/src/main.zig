const std = @import("std");
const Allocator = std.mem.Allocator;
const fs = std.fs;

const Point = [3]i32;

fn add_point(a: Point, b: Point) Point {
    return .{
        a[0] + b[0],
        a[1] + b[1],
        a[2] + b[2],
    };
}

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
    const dirs = [_]Point{
        .{ -1, 0, 0 },
        .{ 1, 0, 0 },
        .{ 0, -1, 0 },
        .{ 0, 1, 0 },
        .{ 0, 0, -1 },
        .{ 0, 0, 1 },
    };

    var cubes = std.AutoHashMap(Point, bool).init(allocator);
    defer cubes.deinit();

    var res: usize = 0;
    while (lines.next()) |line| {
        var numbers = std.mem.split(u8, line, ",");
        const x = try std.fmt.parseInt(i32, numbers.next().?, 10);
        const y = try std.fmt.parseInt(i32, numbers.next().?, 10);
        const z = try std.fmt.parseInt(i32, numbers.next().?, 10);
        const pos: Point = .{ x, y, z };

        try cubes.put(pos, true);

        res += 6;
        for (dirs) |dir| {
            const neighbour = add_point(pos, dir);
            if (cubes.contains(neighbour)) res -= 2;
        }
    }

    std.debug.print("Part 1: {d}\n", .{res});
}

fn part2(input_file_name: []const u8) !void {
    const allocator = std.heap.page_allocator;
    const input = std.mem.trim(u8, try read_input(input_file_name, allocator), "\n");
    defer allocator.free(input);

    var lines = std.mem.split(u8, input, "\n");
    const dirs = [_]Point{
        .{ -1, 0, 0 },
        .{ 1, 0, 0 },
        .{ 0, -1, 0 },
        .{ 0, 1, 0 },
        .{ 0, 0, -1 },
        .{ 0, 0, 1 },
    };

    var cubes = std.AutoHashMap(Point, bool).init(allocator);
    defer cubes.deinit();

    var min_x: i32 = std.math.maxInt(i32);
    var min_y: i32 = std.math.maxInt(i32);
    var min_z: i32 = std.math.maxInt(i32);
    var max_x: i32 = 0;
    var max_y: i32 = 0;
    var max_z: i32 = 0;

    while (lines.next()) |line| {
        var numbers = std.mem.split(u8, line, ",");
        const x = try std.fmt.parseInt(i32, numbers.next().?, 10);
        const y = try std.fmt.parseInt(i32, numbers.next().?, 10);
        const z = try std.fmt.parseInt(i32, numbers.next().?, 10);
        try cubes.put(.{ x, y, z }, true);
        min_x = @min(min_x, x);
        min_y = @min(min_y, y);
        min_z = @min(min_z, z);
        max_x = @max(max_x, x);
        max_y = @max(max_y, y);
        max_z = @max(max_z, z);
    }

    const start_x, const end_x = .{ min_x - 1, max_x + 1 };
    const start_y, const end_y = .{ min_y - 1, max_y + 1 };
    const start_z, const end_z = .{ min_z - 1, max_z + 1 };

    const start_pos = .{ start_x, start_y, start_z };
    var queue = std.ArrayList(Point).init(allocator);
    defer queue.deinit();
    try queue.append(start_pos);

    var visited = std.AutoHashMap(Point, bool).init(allocator);
    defer visited.deinit();
    try visited.put(start_pos, true);

    var res: usize = 0;

    while (queue.popOrNull()) |current| {
        for (dirs) |dir| {
            const new_pos = add_point(current, dir);
            if (new_pos[0] < start_x or new_pos[0] > end_x or new_pos[1] < start_y or new_pos[1] > end_y or new_pos[2] < start_z or new_pos[2] > end_z)
                continue;
            if (cubes.contains(new_pos)) {
                res += 1;
            } else if (!visited.contains(new_pos)) {
                try visited.put(new_pos, true);
                try queue.insert(0, new_pos);
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
