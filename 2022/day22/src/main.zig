const Allocator = std.mem.Allocator;
const std = @import("std");
const fs = std.fs;

const Point = [2]i64;

fn add_point(a: Point, b: Point) Point {
    return .{ a[0] + b[0], a[1] + b[1] };
}

fn sub_point(a: Point, b: Point) Point {
    return .{ a[0] - b[0], a[1] - b[1] };
}

const CommandType = enum {
    num,
    turn_right,
    turn_left,
};

const Command = union(CommandType) {
    num: usize,
    turn_right: void,
    turn_left: void,
};

const Rect = struct {
    const Self = @This();

    x: i64,
    y: i64,
    w: i64,
    h: i64,

    left: usize,
    right: usize,
    top: usize,
    bottom: usize,

    invert_left: bool = false,
    invert_right: bool = false,
    invert_top: bool = false,
    invert_bottom: bool = false,

    pub fn contains(self: Self, p: Point) bool {
        return p[0] >= self.x and p[0] < self.x + self.h and p[1] >= self.y and p[1] < self.y + self.w;
    }
};

fn read_input(input_file_name: []const u8, allocator: Allocator) ![]u8 {
    const input_file = try fs.cwd().openFile(input_file_name, .{});
    defer input_file.close();
    return input_file.readToEndAlloc(allocator, 4 * 1024 * 1024);
}

fn print_grid(grid: *std.ArrayList(std.ArrayList(u8)), pos: Point, n_pos: Point) void {
    for (grid.items, 0..) |row, i| {
        for (row.items, 0..) |c, j| {
            if (pos[0] == i and pos[1] == j) {
                std.debug.print("@", .{});
            } else if (n_pos[0] == i and n_pos[1] == j) {
                std.debug.print("$", .{});
            } else std.debug.print("{c}", .{c});
        }
        std.debug.print("\n", .{});
    }
}

fn part1(input_file_name: []const u8) !void {
    const allocator = std.heap.page_allocator;
    const input = std.mem.trim(u8, try read_input(input_file_name, allocator), "\n");
    defer allocator.free(input);
    var blocks = std.mem.split(u8, input, "\n\n");
    var lines = std.mem.split(u8, blocks.next().?, "\n");
    const command_str = blocks.next().?;
    var grid = std.ArrayList(std.ArrayList(u8)).init(allocator);
    const first_line = lines.next().?;
    var start_y: usize = 0;
    for (first_line, 0..) |c, i| {
        if (c != ' ') {
            start_y = i;
            break;
        }
    }

    var row = std.ArrayList(u8).init(allocator);
    try row.appendSlice(first_line);
    try grid.append(row);
    while (lines.next()) |line| {
        row = std.ArrayList(u8).init(allocator);
        try row.appendSlice(line);
        try grid.append(row);
    }

    var commands = std.ArrayList(Command).init(allocator);
    var i: usize = 0;
    while (i < command_str.len) {
        if (command_str.ptr[i] >= '0' and command_str.ptr[i] <= '9') {
            var j = i + 1;
            while (j < command_str.len and command_str.ptr[j] >= '0' and command_str.ptr[j] <= '9') j += 1;
            try commands.append(.{ .num = try std.fmt.parseInt(usize, command_str.ptr[i..j], 10) });
            i = j;
        } else {
            if (command_str.ptr[i] == 'R') try commands.append(.{ .turn_right = {} });
            if (command_str.ptr[i] == 'L') try commands.append(.{ .turn_left = {} });
            i += 1;
        }
    }

    var dir_i: usize = 0;
    const dirs = [_]Point{ .{ 0, 1 }, .{ 1, 0 }, .{ 0, -1 }, .{ -1, 0 } };
    var pos = Point{ 0, @intCast(start_y) };
    for (commands.items) |command| {
        switch (command) {
            .num => |n| {
                const dir = dirs[dir_i];
                for (0..n) |_| {
                    var n_pos = add_point(pos, dir);

                    if (n_pos[0] < 0 or n_pos[0] >= grid.items.len or n_pos[1] < 0 or n_pos[1] >= grid.items[@intCast(n_pos[0])].items.len or grid.items[@intCast(n_pos[0])].items[@intCast(n_pos[1])] == ' ') {
                        n_pos = pos;
                        while (true) {
                            const nn_pos = sub_point(n_pos, dir);
                            if (nn_pos[0] < 0 or nn_pos[0] >= grid.items.len or nn_pos[1] < 0 or nn_pos[1] >= grid.items[@intCast(nn_pos[0])].items.len) break;
                            if (grid.items[@intCast(nn_pos[0])].items[@intCast(nn_pos[1])] == ' ') break;
                            n_pos = nn_pos;
                        }
                    }

                    if (grid.items[@intCast(n_pos[0])].items[@intCast(n_pos[1])] == '#') break;
                    pos = n_pos;
                }
            },
            .turn_left => dir_i = (dir_i + 4 - 1) % 4,
            .turn_right => dir_i = (dir_i + 1) % 4,
        }
    }

    const dir_i_i64: i64 = @intCast(dir_i);
    const res: usize = @intCast((pos[0] + 1) * 1000 + (pos[1] + 1) * 4 + dir_i_i64);

    std.debug.print("Part 1: {d}\n", .{res});
}

fn part2(input_file_name: []const u8) !void {
    const allocator = std.heap.page_allocator;
    const input = std.mem.trim(u8, try read_input(input_file_name, allocator), "\n");
    defer allocator.free(input);
    var blocks = std.mem.split(u8, input, "\n\n");
    var lines = std.mem.split(u8, blocks.next().?, "\n");
    const command_str = blocks.next().?;
    var grid = std.ArrayList(std.ArrayList(u8)).init(allocator);
    const first_line = lines.next().?;
    var start_y: usize = 0;
    for (first_line, 0..) |c, i| {
        if (c != ' ') {
            start_y = i;
            break;
        }
    }

    var row = std.ArrayList(u8).init(allocator);
    try row.appendSlice(first_line);
    try grid.append(row);
    while (lines.next()) |line| {
        row = std.ArrayList(u8).init(allocator);
        try row.appendSlice(line);
        try grid.append(row);
    }

    const rects = [_]Rect{
        .{ .x = 0, .y = 50, .w = 50, .h = 50, .left = 3, .right = 1, .top = 5, .bottom = 2, .invert_left = true },
        .{ .x = 0, .y = 100, .w = 50, .h = 50, .left = 0, .right = 4, .top = 5, .bottom = 2, .invert_right = true },
        .{ .x = 50, .y = 50, .w = 50, .h = 50, .left = 3, .right = 1, .top = 0, .bottom = 4 },
        .{ .x = 100, .y = 0, .w = 50, .h = 50, .left = 0, .right = 4, .top = 2, .bottom = 5, .invert_left = true },
        .{ .x = 100, .y = 50, .w = 50, .h = 50, .left = 3, .right = 1, .top = 2, .bottom = 5, .invert_right = true },
        .{ .x = 150, .y = 0, .w = 50, .h = 50, .left = 0, .right = 4, .top = 3, .bottom = 1 },
    };

    var commands = std.ArrayList(Command).init(allocator);
    var i: usize = 0;
    while (i < command_str.len) {
        if (command_str.ptr[i] >= '0' and command_str.ptr[i] <= '9') {
            var j = i + 1;
            while (j < command_str.len and command_str.ptr[j] >= '0' and command_str.ptr[j] <= '9') j += 1;
            try commands.append(.{ .num = try std.fmt.parseInt(usize, command_str.ptr[i..j], 10) });
            i = j;
        } else {
            if (command_str.ptr[i] == 'R') try commands.append(.{ .turn_right = {} });
            if (command_str.ptr[i] == 'L') try commands.append(.{ .turn_left = {} });
            i += 1;
        }
    }

    var dir_i: usize = 0;
    const dirs = [_]Point{ .{ 0, 1 }, .{ 1, 0 }, .{ 0, -1 }, .{ -1, 0 } };
    var pos = Point{ 0, @intCast(start_y) };
    for (commands.items) |command| {
        switch (command) {
            .num => |n| {
                for (0..n) |_| {
                    const dir = dirs[dir_i];
                    var n_dir_i = dir_i;
                    var n_pos = add_point(pos, dir);
                    if (n_pos[0] < 0 or n_pos[0] >= grid.items.len or n_pos[1] < 0 or n_pos[1] >= grid.items[@intCast(n_pos[0])].items.len or grid.items[@intCast(n_pos[0])].items[@intCast(n_pos[1])] == ' ') {
                        for (rects, 0..) |rect, r_i| {
                            if (rect.contains(pos)) {
                                var n_rect = rect;
                                var p: i64 = 0;
                                switch (dir_i) {
                                    0 => {
                                        n_rect = rects[rect.right];
                                        p = pos[0] - rect.x;
                                    },
                                    1 => {
                                        n_rect = rects[rect.bottom];
                                        p = pos[1] - rect.y;
                                    },
                                    2 => {
                                        n_rect = rects[rect.left];
                                        p = pos[0] - rect.x;
                                    },
                                    3 => {
                                        n_rect = rects[rect.top];
                                        p = pos[1] - rect.y;
                                    },
                                    else => unreachable,
                                }
                                std.debug.assert(p >= 0 and p < 50);
                                if (n_rect.right == r_i) {
                                    if (n_rect.invert_right) p = n_rect.w - p - 1;
                                    n_pos = .{ n_rect.x + p, n_rect.y + n_rect.w - 1 };
                                    n_dir_i = 2;
                                } else if (n_rect.left == r_i) {
                                    if (n_rect.invert_left) p = n_rect.w - p - 1;
                                    n_pos = .{ n_rect.x + p, n_rect.y };
                                    n_dir_i = 0;
                                } else if (n_rect.top == r_i) {
                                    if (n_rect.invert_top) p = n_rect.w - p - 1;
                                    n_pos = .{ n_rect.x, n_rect.y + p };
                                    n_dir_i = 1;
                                } else if (n_rect.bottom == r_i) {
                                    if (n_rect.invert_bottom) p = n_rect.w - p - 1;
                                    n_pos = .{ n_rect.x + n_rect.h - 1, n_rect.y + p };
                                    n_dir_i = 3;
                                } else {
                                    unreachable;
                                }
                                std.debug.assert(n_rect.contains(n_pos));
                                break;
                            }
                        }
                    }

                    if (grid.items[@intCast(n_pos[0])].items[@intCast(n_pos[1])] == '#') break;
                    dir_i = n_dir_i;
                    pos = n_pos;
                }
            },
            .turn_left => dir_i = (dir_i + 4 - 1) % 4,
            .turn_right => dir_i = (dir_i + 1) % 4,
        }
    }

    const dir_i_i64: i64 = @intCast(dir_i);
    const res: usize = @intCast((pos[0] + 1) * 1000 + (pos[1] + 1) * 4 + dir_i_i64);

    std.debug.print("Part 2: {d}\n", .{res});
}

pub fn main() !void {
    // const input_file = "sample.txt";
    const input_file = "input.txt";
    try part1(input_file);
    try part2(input_file);
}
