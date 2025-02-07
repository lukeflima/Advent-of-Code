const std = @import("std");
const Allocator = std.mem.Allocator;
const fs = std.fs;

const Point = [2]i64;
const Dir = enum { up, down, left, right };
const Blizzard = struct {
    pos: Point,
    dir: Dir,
};

fn add_point(p1: Point, p2: Point) Point {
    return .{ p1[0] + p2[0], p1[1] + p2[1] };
}

fn sub_point(p1: Point, p2: Point) Point {
    return .{ p1[0] - p2[0], p1[1] - p2[1] };
}

fn scl_point(p1: Point, scl: i64) Point {
    return .{ p1[0] * scl, p1[1] * scl };
}

fn mod_point(p1: Point, p2: Point) Point {
    return .{ @mod(p1[0], p2[0]), @mod(p1[1], p2[1]) };
}

fn eq_point(p1: Point, p2: Point) bool {
    return p1[0] == p2[0] and p1[1] == p2[1];
}

const State = struct { p: Point, time: usize };
const State2 = struct { p: Point, time: usize, stage: usize };

fn read_input(input_file_name: []const u8, allocator: Allocator) ![]u8 {
    const input_file = try fs.cwd().openFile(input_file_name, .{});
    defer input_file.close();
    return input_file.readToEndAlloc(allocator, 4 * 1024 * 1024);
}

const neighbours = [4]Point{ .{ -1, 0 }, .{ 0, 1 }, .{ 1, 0 }, .{ 0, -1 } };
const neighbours_dirs = [4]Dir{ .up, .right, .down, .left };

fn colide(p: Point, time: usize, blizards: *std.AutoHashMap(Blizzard, bool), rows: usize, cols: usize) bool {
    for (neighbours, neighbours_dirs) |d, dir| {
        const pos_time = mod_point(sub_point(p, scl_point(d, @intCast(time))), .{ @intCast(rows), @intCast(cols) });
        if (blizards.contains(.{ .pos = pos_time, .dir = dir })) {
            return true;
        }
    }
    return false;
}

fn part1(input_file_name: []const u8) !void {
    const allocator = std.heap.page_allocator;
    const input = std.mem.trim(u8, try read_input(input_file_name, allocator), "\n");
    defer allocator.free(input);

    var lines = std.mem.split(u8, input, "\n");
    var blizards = std.AutoHashMap(Blizzard, bool).init(allocator);
    var cols: usize = 0;
    var rows: usize = 0;
    _ = lines.next();
    while (lines.next()) |line| {
        cols = 0;
        for (line[1..], 0..) |c, j| {
            cols += 1;
            if (c != '.' and c != '#') {
                const pos: Point = .{ @intCast(rows), @intCast(j) };
                switch (c) {
                    '^' => try blizards.put(.{ .pos = pos, .dir = .up }, true),
                    'v' => try blizards.put(.{ .pos = pos, .dir = .down }, true),
                    '<' => try blizards.put(.{ .pos = pos, .dir = .left }, true),
                    '>' => try blizards.put(.{ .pos = pos, .dir = .right }, true),
                    else => unreachable,
                }
            }
        }
        rows += 1;
    }
    cols -= 1;
    rows -= 1;

    const start: Point = .{ -1, 0 };
    const end: Point = .{ @intCast(rows), @intCast(cols - 1) };

    var queue = std.ArrayList(State).init(allocator);
    try queue.append(.{ .p = start, .time = 0 });

    var seen = std.AutoHashMap(State, bool).init(allocator);
    const lcm: usize = @divTrunc(rows * cols, std.math.gcd(rows, cols));

    var res: usize = 0;
    outer: while (queue.popOrNull()) |state| {
        const next_time = state.time + 1;
        const s = @rem(next_time, lcm);

        for ([_]Point{ .{ -1, 0 }, .{ 0, 1 }, .{ 1, 0 }, .{ 0, -1 }, .{ 0, 0 } }) |d| {
            const new_pos = add_point(state.p, d);
            if (eq_point(new_pos, end)) {
                res = next_time;
                break :outer;
            }

            if ((new_pos[0] < 0 or new_pos[1] < 0 or new_pos[0] >= rows or new_pos[1] >= cols) and !eq_point(new_pos, start)) continue;
            if (colide(new_pos, next_time, &blizards, rows, cols)) continue;

            if (seen.contains(.{ .p = new_pos, .time = s })) continue;
            try seen.put(.{ .p = new_pos, .time = s }, true);
            try queue.insert(0, .{ .p = new_pos, .time = next_time });
        }
    }
    std.debug.print("Part 1: {d}\n", .{res});
}

fn part2(input_file_name: []const u8) !void {
    const allocator = std.heap.page_allocator;
    const input = std.mem.trim(u8, try read_input(input_file_name, allocator), "\n");
    defer allocator.free(input);
    var lines = std.mem.split(u8, input, "\n");
    var blizards = std.AutoHashMap(Blizzard, bool).init(allocator);
    var cols: usize = 0;
    var rows: usize = 0;
    _ = lines.next();
    while (lines.next()) |line| {
        cols = 0;
        for (line[1..], 0..) |c, j| {
            cols += 1;
            if (c != '.' and c != '#') {
                const pos: Point = .{ @intCast(rows), @intCast(j) };
                switch (c) {
                    '^' => try blizards.put(.{ .pos = pos, .dir = .up }, true),
                    'v' => try blizards.put(.{ .pos = pos, .dir = .down }, true),
                    '<' => try blizards.put(.{ .pos = pos, .dir = .left }, true),
                    '>' => try blizards.put(.{ .pos = pos, .dir = .right }, true),
                    else => unreachable,
                }
            }
        }
        rows += 1;
    }
    cols -= 1;
    rows -= 1;

    const start: Point = .{ -1, 0 };
    const ends = [_]Point{ .{ @intCast(rows), @intCast(cols - 1) }, .{ -1, 0 } };

    var queue = std.ArrayList(State2).init(allocator);
    try queue.append(.{ .p = start, .time = 0, .stage = 0 });

    var seen = std.AutoHashMap(State2, bool).init(allocator);
    const lcm: usize = @divTrunc(rows * cols, std.math.gcd(rows, cols));

    var res: usize = 0;
    outer: while (queue.popOrNull()) |state| {
        const next_time = state.time + 1;
        const s = @rem(next_time, lcm);
        const end = ends[state.stage % ends.len];

        for ([_]Point{ .{ -1, 0 }, .{ 0, 1 }, .{ 1, 0 }, .{ 0, -1 }, .{ 0, 0 } }) |d| {
            const new_pos = add_point(state.p, d);
            var new_stage = state.stage;
            if (eq_point(new_pos, end)) {
                if (state.stage == 2) {
                    res = next_time;
                    break :outer;
                }
                new_stage += 1;
            }

            if ((new_pos[0] < 0 or new_pos[1] < 0 or new_pos[0] >= rows or new_pos[1] >= cols) and !eq_point(new_pos, ends[0]) and !eq_point(new_pos, ends[1])) continue;
            if (colide(new_pos, next_time, &blizards, rows, cols)) continue;

            if (seen.contains(.{ .p = new_pos, .time = s, .stage = new_stage })) continue;
            try seen.put(.{ .p = new_pos, .time = s, .stage = new_stage }, true);
            try queue.insert(0, .{ .p = new_pos, .time = next_time, .stage = new_stage });
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
