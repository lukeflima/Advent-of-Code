const std = @import("std");
const Allocator = std.mem.Allocator;
const fs = std.fs;

const Point = [2]i64;
const Dir = enum { north, south, west, east };

const Elf = struct {
    pos: Point,
};

fn add_points(a: Point, b: Point) Point {
    return .{ a[0] + b[0], a[1] + b[1] };
}

fn read_input(input_file_name: []const u8, allocator: Allocator) ![]u8 {
    const input_file = try fs.cwd().openFile(input_file_name, .{});
    defer input_file.close();
    return input_file.readToEndAlloc(allocator, 4 * 1024 * 1024);
}

fn print_elf(elfs: *std.AutoHashMap(Elf, bool), allocator: Allocator) !void {
    var elfs_iter = elfs.keyIterator();
    var min_x: i64 = std.math.maxInt(i64);
    var min_y: i64 = std.math.maxInt(i64);
    var max_x: i64 = 0;
    var max_y: i64 = 0;

    var elfs_locations = std.AutoHashMap(Point, bool).init(allocator);
    defer elfs_locations.deinit();

    while (elfs_iter.next()) |elf| {
        try elfs_locations.put(elf.pos, true);
        min_x = @min(min_x, elf.pos[0]);
        min_y = @min(min_y, elf.pos[1]);
        max_x = @max(max_x, elf.pos[0]);
        max_y = @max(max_y, elf.pos[1]);
    }

    const dx: usize = @intCast(max_x - min_x + 1);
    const dy: usize = @intCast(max_y - min_y + 1);

    for (0..dx) |x| {
        const x_i64: i64 = @intCast(x);
        for (0..dy) |y| {
            const y_i64: i64 = @intCast(y);
            if (elfs_locations.contains(.{ min_x + x_i64, min_y + y_i64 })) {
                std.debug.print("#", .{});
            } else {
                std.debug.print(".", .{});
            }
        }
        std.debug.print("\n", .{});
    }
    std.debug.print("\n", .{});
}

fn part1(input_file_name: []const u8) !void {
    const allocator = std.heap.page_allocator;
    const input = std.mem.trim(u8, try read_input(input_file_name, allocator), "\n");
    defer allocator.free(input);

    var lines = std.mem.split(u8, input, "\n");
    var line_num: usize = 0;
    var elfs = std.AutoHashMap(Elf, bool).init(allocator);
    while (lines.next()) |line| {
        defer line_num += 1;
        for (line, 0..) |c, j| {
            if (c == '#') try elfs.put(.{ .pos = .{ @intCast(line_num), @intCast(j) } }, true);
        }
    }

    var proposed_locations = std.AutoHashMap(Point, std.ArrayList(*Elf)).init(allocator);
    var elfs_locations = std.AutoHashMap(Point, bool).init(allocator);
    var ii: usize = 0;
    const neighbours_8 = [8]Point{ .{ -1, -1 }, .{ -1, 0 }, .{ -1, 1 }, .{ 0, -1 }, .{ 0, 1 }, .{ 1, -1 }, .{ 1, 0 }, .{ 1, 1 } };
    var dirs = [4]Dir{ .north, .south, .west, .east };
    while (true) {
        defer ii += 1;

        defer {
            proposed_locations.clearRetainingCapacity();
            elfs_locations.clearRetainingCapacity();
        }

        var elfs_iter = elfs.keyIterator();
        while (elfs_iter.next()) |elf| {
            try elfs_locations.put(elf.pos, true);
        }

        elfs_iter = elfs.keyIterator();
        while (elfs_iter.next()) |elf| {
            var no_neighbours = true;
            for (neighbours_8) |neighbour_dir| {
                const neighbour = add_points(elf.pos, neighbour_dir);
                if (elfs_locations.contains(neighbour)) {
                    no_neighbours = false;
                    break;
                }
            }
            if (no_neighbours) continue;

            for (dirs) |dir| {
                const neighbours: [3]Point = switch (dir) {
                    .north => [3]Point{ .{ -1, -1 }, .{ -1, 0 }, .{ -1, 1 } },
                    .south => [3]Point{ .{ 1, -1 }, .{ 1, 0 }, .{ 1, 1 } },
                    .west => [3]Point{ .{ -1, -1 }, .{ 0, -1 }, .{ 1, -1 } },
                    .east => [3]Point{ .{ -1, 1 }, .{ 0, 1 }, .{ 1, 1 } },
                };
                var empty = true;
                for (neighbours) |neighbour_dir| {
                    const neighbour = add_points(elf.pos, neighbour_dir);
                    if (elfs_locations.contains(neighbour)) {
                        empty = false;
                        break;
                    }
                }
                if (empty) {
                    const new_pos: Point = switch (dir) {
                        .north => add_points(elf.pos, .{ -1, 0 }),
                        .south => add_points(elf.pos, .{ 1, 0 }),
                        .west => add_points(elf.pos, .{ 0, -1 }),
                        .east => add_points(elf.pos, .{ 0, 1 }),
                    };
                    if (!proposed_locations.contains(new_pos)) {
                        try proposed_locations.put(new_pos, std.ArrayList(*Elf).init(allocator));
                    }

                    try proposed_locations.getPtr(new_pos).?.append(elf);
                    break;
                }
            }
        }

        const aux = dirs[0];
        for (0..3) |d| {
            dirs[d] = dirs[d + 1];
        }
        dirs[3] = aux;

        if (proposed_locations.count() == 0) break;

        var proposed_locations_iter = proposed_locations.iterator();
        var moved: usize = 0;
        while (proposed_locations_iter.next()) |entry| {
            const list_elfs = entry.value_ptr;
            if (list_elfs.items.len > 1) continue;
            list_elfs.items[0].pos = entry.key_ptr.*;
            moved += 1;
        }

        if (ii == 9) break;
    }

    var elfs_iter = elfs.keyIterator();
    var min_x: i64 = std.math.maxInt(i64);
    var min_y: i64 = std.math.maxInt(i64);
    var max_x: i64 = 0;
    var max_y: i64 = 0;

    while (elfs_iter.next()) |elf| {
        try elfs_locations.put(elf.pos, true);
        min_x = @min(min_x, elf.pos[0]);
        min_y = @min(min_y, elf.pos[1]);
        max_x = @max(max_x, elf.pos[0]);
        max_y = @max(max_y, elf.pos[1]);
    }

    const dx: usize = @intCast(max_x - min_x + 1);
    const dy: usize = @intCast(max_y - min_y + 1);
    var res: usize = 0;
    for (0..dx) |x| {
        const x_i64: i64 = @intCast(x);
        for (0..dy) |y| {
            const y_i64: i64 = @intCast(y);
            if (!elfs_locations.contains(.{ min_x + x_i64, min_y + y_i64 })) {
                res += 1;
            }
        }
    }
    std.debug.print("Part 1: {d}\n", .{res});
}

fn part2(input_file_name: []const u8) !void {
    const allocator = std.heap.page_allocator;
    const input = std.mem.trim(u8, try read_input(input_file_name, allocator), "\n");
    defer allocator.free(input);

    var lines = std.mem.split(u8, input, "\n");
    var line_num: usize = 0;
    var elfs = std.AutoHashMap(Elf, bool).init(allocator);
    while (lines.next()) |line| {
        defer line_num += 1;
        for (line, 0..) |c, j| {
            if (c == '#') try elfs.put(.{ .pos = .{ @intCast(line_num), @intCast(j) } }, true);
        }
    }

    var proposed_locations = std.AutoHashMap(Point, std.ArrayList(*Elf)).init(allocator);
    var elfs_locations = std.AutoHashMap(Point, bool).init(allocator);
    var ii: usize = 0;
    const neighbours_8 = [8]Point{ .{ -1, -1 }, .{ -1, 0 }, .{ -1, 1 }, .{ 0, -1 }, .{ 0, 1 }, .{ 1, -1 }, .{ 1, 0 }, .{ 1, 1 } };
    var dirs = [4]Dir{ .north, .south, .west, .east };
    while (true) {
        defer ii += 1;
        defer {
            proposed_locations.clearRetainingCapacity();
            elfs_locations.clearRetainingCapacity();
        }

        var elfs_iter = elfs.keyIterator();
        while (elfs_iter.next()) |elf| {
            try elfs_locations.put(elf.pos, true);
        }

        elfs_iter = elfs.keyIterator();
        while (elfs_iter.next()) |elf| {
            var no_neighbours = true;
            for (neighbours_8) |neighbour_dir| {
                const neighbour = add_points(elf.pos, neighbour_dir);
                if (elfs_locations.contains(neighbour)) {
                    no_neighbours = false;
                    break;
                }
            }
            if (no_neighbours) continue;

            for (dirs) |dir| {
                const neighbours: [3]Point = switch (dir) {
                    .north => [3]Point{ .{ -1, -1 }, .{ -1, 0 }, .{ -1, 1 } },
                    .south => [3]Point{ .{ 1, -1 }, .{ 1, 0 }, .{ 1, 1 } },
                    .west => [3]Point{ .{ -1, -1 }, .{ 0, -1 }, .{ 1, -1 } },
                    .east => [3]Point{ .{ -1, 1 }, .{ 0, 1 }, .{ 1, 1 } },
                };
                var empty = true;
                for (neighbours) |neighbour_dir| {
                    const neighbour = add_points(elf.pos, neighbour_dir);
                    if (elfs_locations.contains(neighbour)) {
                        empty = false;
                        break;
                    }
                }
                if (empty) {
                    const new_pos: Point = switch (dir) {
                        .north => add_points(elf.pos, .{ -1, 0 }),
                        .south => add_points(elf.pos, .{ 1, 0 }),
                        .west => add_points(elf.pos, .{ 0, -1 }),
                        .east => add_points(elf.pos, .{ 0, 1 }),
                    };
                    if (!proposed_locations.contains(new_pos)) {
                        try proposed_locations.put(new_pos, std.ArrayList(*Elf).init(allocator));
                    }

                    try proposed_locations.getPtr(new_pos).?.append(elf);
                    break;
                }
            }
        }

        const aux = dirs[0];
        for (0..3) |d| {
            dirs[d] = dirs[d + 1];
        }
        dirs[3] = aux;

        if (proposed_locations.count() == 0) break;

        var proposed_locations_iter = proposed_locations.iterator();
        var moved: usize = 0;
        while (proposed_locations_iter.next()) |entry| {
            const list_elfs = entry.value_ptr;
            if (list_elfs.items.len > 1) continue;
            list_elfs.items[0].pos = entry.key_ptr.*;
            moved += 1;
        }
        if (moved == 0) break;
    }

    std.debug.print("Part 2: {d}\n", .{ii});
}

pub fn main() !void {
    //     const input_file = "sample.txt";
    const input_file = "input.txt";
    try part1(input_file);
    try part2(input_file);
}
