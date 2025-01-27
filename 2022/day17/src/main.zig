// This was generated using DeepSeek cus I couldn't be bothered.

const std = @import("std");
const Allocator = std.mem.Allocator;
const fs = std.fs;

const Rock = struct {
    points: []const [2]i8,
};

const rocks = [_]Rock{
    Rock{ .points = &.{ .{ 0, 0 }, .{ 1, 0 }, .{ 2, 0 }, .{ 3, 0 } } },
    Rock{ .points = &.{ .{ 1, 0 }, .{ 0, 1 }, .{ 1, 1 }, .{ 2, 1 }, .{ 1, 2 } } },
    Rock{ .points = &.{ .{ 0, 0 }, .{ 1, 0 }, .{ 2, 0 }, .{ 2, 1 }, .{ 2, 2 } } },
    Rock{ .points = &.{ .{ 0, 0 }, .{ 0, 1 }, .{ 0, 2 }, .{ 0, 3 } } },
    Rock{ .points = &.{ .{ 0, 0 }, .{ 1, 0 }, .{ 0, 1 }, .{ 1, 1 } } },
};

fn canMove2(shape: []const [2]i8, x: i32, y: i32, chamber: *std.ArrayList(u8)) bool {
    for (shape) |p| {
        const bx, const by = .{ x + p[0], y + p[1] };
        if (bx < 0 or bx >= 7 or by < 0) return false;
        const row: usize = @intCast(by);
        if (row < chamber.items.len and
            (chamber.items[row] & (@as(u8, 1) << @intCast(bx))) != 0) return false;
    }
    return true;
}

fn canMove(points: []const [2]i8, x: i32, y: i32, delta_x: i32, delta_y: i32, chamber: *const std.ArrayList(u8)) bool {
    const new_x = x + delta_x;
    const new_y = y + delta_y;

    for (points) |point| {
        const dx = point[0];
        const dy = point[1];

        const x_pos = new_x + dx;
        const y_pos = new_y + dy;

        if (x_pos < 0 or x_pos >= 7) {
            return false;
        }

        if (y_pos < 0) {
            return false;
        }

        const y_pos_usize: usize = @intCast(y_pos);
        if (y_pos_usize < chamber.items.len) {
            const row = chamber.items[y_pos_usize];
            const mask = @as(u8, 1) << @intCast(x_pos);
            if (row & mask != 0) {
                return false;
            }
        }
    }

    return true;
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

    const jet_pattern = std.mem.trim(u8, input, "\n");

    var chamber = std.ArrayList(u8).init(allocator);
    defer chamber.deinit();

    var current_height: usize = 0;
    var jet_index: usize = 0;
    var rock_count: usize = 0;

    while (rock_count < 2022) : (rock_count += 1) {
        const rock_type = rock_count % 5;
        const rock = rocks[rock_type];

        var x: i32 = 2;
        var y: i32 = @intCast(current_height + 3);

        while (true) {
            const jet = jet_pattern[jet_index];
            jet_index = (jet_index + 1) % jet_pattern.len;
            const dx: i32 = if (jet == '<') -1 else 1;

            if (canMove(rock.points, x, y, dx, 0, &chamber)) {
                x += dx;
            }

            if (canMove(rock.points, x, y, 0, -1, &chamber)) {
                y -= 1;
            } else {
                break;
            }
        }

        var max_block_y: i32 = 0;
        for (rock.points) |point| {
            const dx_point = point[0];
            const dy_point = point[1];
            const block_x = x + dx_point;
            const block_y = y + dy_point;

            if (block_y + 1 > max_block_y) {
                max_block_y = block_y + 1;
            }

            const block_y_usize: usize = @intCast(block_y);
            while (chamber.items.len <= block_y_usize) {
                try chamber.append(0);
            }

            const row = &chamber.items[block_y_usize];
            const mask = @as(u8, 1) << @intCast(block_x);
            row.* |= mask;
        }

        const new_height: usize = @intCast(max_block_y);
        if (new_height > current_height) {
            current_height = new_height;
        }
    }

    std.debug.print("Part 1: {d}\n", .{current_height});
}

fn part2(input_file_name: []const u8) !void {
    const allocator = std.heap.page_allocator;
    const input = std.mem.trim(u8, try read_input(input_file_name, allocator), "\n");
    defer allocator.free(input);

    const jets = std.mem.trim(u8, input, "\n");

    var chamber = std.ArrayList(u8).init(allocator);
    defer chamber.deinit();

    var seen = std.AutoHashMap(u128, struct { rocks: usize, height: usize }).init(allocator);
    defer seen.deinit();

    const TARGET: usize = 1_000_000_000_000;
    var jet_idx: usize, var height: usize, var added: usize = .{ 0, 0, 0 };
    var cycle_rocks: usize, var cycle_height: usize = .{ 0, 0 };
    var found_cycle: bool = false;

    for (0..TARGET) |rock_count| {
        const rock = rocks[rock_count % 5];
        var x: i32, var y: i32 = .{ 2, @intCast(height + 3) };

        // Rock movement
        while (true) {
            // Jet push
            const dx: i32 = if (jets[jet_idx] == '<') -1 else 1;
            jet_idx = (jet_idx + 1) % jets.len;
            if (canMove2(rock.points, x + dx, y, &chamber)) x += dx;

            // Fall down
            if (canMove2(rock.points, x, y - 1, &chamber)) y -= 1 else break;
        }

        // Add rock to chamber
        var max_y = y;
        for (rock.points) |p| {
            const bx, const by = .{ x + p[0], y + p[1] };
            while (chamber.items.len <= by) try chamber.append(0);
            chamber.items[@intCast(by)] |= @as(u8, 1) << @intCast(bx);
            if (by + 1 > max_y) max_y = by + 1;
        }
        const max_y_usize: usize = @intCast(max_y);
        height = @max(height, max_y_usize);

        // Cycle detection (look at top 30 rows)
        if (!found_cycle) {
            const top = blk: {
                var t: u128 = 0;
                const start = if (height > 30) height - 30 else 0;
                for (start..height) |row| {
                    t <<= 8;
                    t |= if (row < chamber.items.len) chamber.items[row] else 0;
                }
                break :blk t;
            };

            const key: u128 = (@as(u128, (rock_count % 5)) << 120) |
                (@as(u128, jet_idx) << 96) | top;

            if (seen.get(key)) |entry| {
                cycle_rocks, cycle_height = .{ rock_count - entry.rocks, height - entry.height };
                const remaining = TARGET - rock_count - 1;
                const cycles = remaining / cycle_rocks;
                added += cycles * cycle_height;
                found_cycle = true;
            } else {
                try seen.put(key, .{ .rocks = rock_count, .height = height });
            }
        } else if ((TARGET - rock_count - 1) % cycle_rocks == 0) {
            break; // Finished all complete cycles
        }
    }

    std.debug.print("Part 2: {d}\n", .{height + added});
}

pub fn main() !void {
    const input_file = "input.txt";
    // const input_file = "input.txt";
    try part1(input_file);
    try part2(input_file);
}
