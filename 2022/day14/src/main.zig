const std = @import("std");
const Allocator = std.mem.Allocator;
const fs = std.fs;

const Point = [2]i64;
const Stone = [2]Point;

fn read_input(input_file_name: []const u8, allocator: Allocator) ![]u8 {
    const input_file = try fs.cwd().openFile(input_file_name, .{});
    defer input_file.close();
    return input_file.readToEndAlloc(allocator, 4 * 1024 * 1024);
}

fn parse_point(point_str: []const u8) !Point {
    var ints_str = std.mem.split(u8, point_str, ",");
    return .{ try std.fmt.parseInt(i64, ints_str.next().?, 10), try std.fmt.parseInt(i64, ints_str.next().?, 10) };
}

fn add_points(a: Point, b: Point) Point {
    return .{ a[0] + b[0], a[1] + b[1] };
}

fn print_grid(grid: std.ArrayList(std.ArrayList(u8))) void {
    for (grid.items) |row| {
        for (row.items) |cell| {
            std.debug.print("{c}", .{cell});
        }
        std.debug.print("\n", .{});
    }
}

fn grid_at(grid: std.ArrayList(std.ArrayList(u8)), point: Point, min_x: i64, min_y: i64) u8 {
    return grid.items[@intCast(point[0] - min_x)].items[@intCast(point[1] - min_y)];
}

fn grid_at2(grid: std.ArrayList(std.ArrayList(u8)), point: Point, min_x: i64, min_y: i64, max_y: i64) u8 {
    if (point[1] == max_y) return '#';
    return grid.items[@intCast(point[0] - min_x)].items[@intCast(point[1] - min_y)];
}

fn part1(input_file_name: []const u8) !void {
    const allocator = std.heap.page_allocator;
    const input = std.mem.trim(u8, try read_input(input_file_name, allocator), "\n");
    defer allocator.free(input);

    const start: Point = .{ 500, 0 };
    var stones_lines = std.ArrayList(Stone).init(allocator);
    defer stones_lines.deinit();
    var lines = std.mem.split(u8, input, "\n");
    var min_x: i64 = start[0];
    var max_x: i64 = start[0];
    var min_y: i64 = start[1];
    var max_y: i64 = start[1];
    while (lines.next()) |line| {
        var points_str = std.mem.split(u8, line, " -> ");
        var prev: ?Point = null;
        while (points_str.next()) |point_str| {
            const point = try parse_point(point_str);
            max_x = @max(max_x, point[0]);
            max_y = @max(max_y, point[1]);
            min_x = @min(min_x, point[0]);
            min_y = @min(min_y, point[1]);
            if (prev != null) try stones_lines.append(.{ prev.?, point });
            prev = point;
        }
    }
    //created grid
    var grid = std.ArrayList(std.ArrayList(u8)).init(allocator);
    defer grid.deinit();
    for (@intCast(min_x)..@intCast(max_x + 1)) |_| {
        var row = std.ArrayList(u8).init(allocator);
        for (@intCast(min_y)..@intCast(max_y + 1)) |_| {
            try row.append('.');
        }
        try grid.append(row);
    }
    // add stones
    for (stones_lines.items) |stone| {
        const start_x = @min(stone[0][0], stone[1][0]);
        const end_x = @max(stone[0][0], stone[1][0]);
        const start_y = @min(stone[0][1], stone[1][1]);
        const end_y = @max(stone[0][1], stone[1][1]);
        var x = start_x;
        while (x <= end_x) : (x += 1) {
            var y = start_y;
            while (y <= end_y) : (y += 1) {
                grid.items[@intCast(x - min_x)].items[@intCast(y - min_y)] = '#';
            }
        }
    }
    grid.items[@intCast(start[0] - min_x)].items[@intCast(start[1] - min_y)] = '+';

    var res: usize = 0;
    outer: while (true) {
        const dir = .{ 0, 1 };
        var sand = start;
        while (true) {
            const next_sand = add_points(sand, dir);
            if (next_sand[0] < min_x or next_sand[0] > max_x or next_sand[1] < min_y or next_sand[1] > max_y) {
                break :outer;
            }
            if (grid_at(grid, next_sand, min_x, min_y) != '.') {
                const diag_left = add_points(next_sand, .{ -1, 0 });
                if (diag_left[0] < min_x or diag_left[0] > max_x or diag_left[1] < min_y or diag_left[1] > max_y) {
                    break :outer;
                }
                if (grid_at(grid, diag_left, min_x, min_y) == '.') {
                    sand = diag_left;
                } else {
                    const diag_right = add_points(next_sand, .{ 1, 0 });
                    if (diag_right[0] < min_x or diag_right[0] > max_x or diag_right[1] < min_y or diag_right[1] > max_y) {
                        break :outer;
                    }
                    if (grid_at(grid, diag_right, min_x, min_y) == '.') {
                        sand = diag_right;
                    } else {
                        break;
                    }
                }
            } else {
                sand = next_sand;
            }
        }
        grid.items[@intCast(sand[0] - min_x)].items[@intCast(sand[1] - min_y)] = 'o';
        res += 1;
    }
    // print_grid(grid);
    std.debug.print("Part 1: {d}\n", .{res});
}

fn part2(input_file_name: []const u8) !void {
    const allocator = std.heap.page_allocator;
    const input = std.mem.trim(u8, try read_input(input_file_name, allocator), "\n");
    defer allocator.free(input);

    const start: Point = .{ 500, 0 };
    var stones_lines = std.ArrayList(Stone).init(allocator);
    defer stones_lines.deinit();
    var lines = std.mem.split(u8, input, "\n");
    var min_x: i64 = start[0];
    var max_x: i64 = start[0];
    var min_y: i64 = start[1];
    var max_y: i64 = start[1];
    while (lines.next()) |line| {
        var points_str = std.mem.split(u8, line, " -> ");
        var prev: ?Point = null;
        while (points_str.next()) |point_str| {
            const point = try parse_point(point_str);
            max_x = @max(max_x, point[0]);
            max_y = @max(max_y, point[1]);
            min_x = @min(min_x, point[0]);
            min_y = @min(min_y, point[1]);
            if (prev != null) try stones_lines.append(.{ prev.?, point });
            prev = point;
        }
    }
    max_y += 2;
    min_x -= 200;
    max_x += 200;
    //created grid
    var grid = std.ArrayList(std.ArrayList(u8)).init(allocator);
    defer grid.deinit();
    for (@intCast(min_x)..@intCast(max_x + 1)) |_| {
        var row = std.ArrayList(u8).init(allocator);
        for (@intCast(min_y)..@intCast(max_y + 1)) |_| {
            try row.append('.');
        }
        try grid.append(row);
    }
    // add stones
    for (stones_lines.items) |stone| {
        const start_x = @min(stone[0][0], stone[1][0]);
        const end_x = @max(stone[0][0], stone[1][0]);
        const start_y = @min(stone[0][1], stone[1][1]);
        const end_y = @max(stone[0][1], stone[1][1]);
        var x = start_x;
        while (x <= end_x) : (x += 1) {
            var y = start_y;
            while (y <= end_y) : (y += 1) {
                grid.items[@intCast(x - min_x)].items[@intCast(y - min_y)] = '#';
            }
        }
    }
    grid.items[@intCast(start[0] - min_x)].items[@intCast(start[1] - min_y)] = '+';
    var res: usize = 0;
    outer: while (true) {
        const dir = .{ 0, 1 };
        var sand = start;
        while (true) {
            const next_sand = add_points(sand, dir);
            if (next_sand[0] < min_x or next_sand[0] > max_x or next_sand[1] < min_y or next_sand[1] > max_y) {
                break :outer;
            }
            if (grid_at2(grid, next_sand, min_x, min_y, max_y) != '.') {
                const diag_left = add_points(next_sand, .{ -1, 0 });
                if (diag_left[0] < min_x or diag_left[0] > max_x or diag_left[1] < min_y or diag_left[1] > max_y) {
                    break :outer;
                }
                if (grid_at2(grid, diag_left, min_x, min_y, max_y) == '.') {
                    sand = diag_left;
                } else {
                    const diag_right = add_points(next_sand, .{ 1, 0 });
                    if (diag_right[0] < min_x or diag_right[0] > max_x or diag_right[1] < min_y or diag_right[1] > max_y) {
                        break :outer;
                    }
                    if (grid_at2(grid, diag_right, min_x, min_y, max_y) == '.') {
                        sand = diag_right;
                    } else {
                        break;
                    }
                }
            } else {
                sand = next_sand;
            }
        }
        grid.items[@intCast(sand[0] - min_x)].items[@intCast(sand[1] - min_y)] = 'o';
        res += 1;
        if (sand[0] == start[0] and sand[1] == start[1]) {
            break;
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
