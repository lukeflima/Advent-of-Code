const std = @import("std");
const Allocator = std.mem.Allocator;
const fs = std.fs;
const set = @import("ziglangSet");

fn read_input(input_file_name: []const u8, allocator: Allocator) ![]u8 {
    const input_file = try fs.cwd().openFile(input_file_name, .{});
    defer input_file.close();
    return input_file.readToEndAlloc(allocator, 4 * 1024 * 1024);
}

const Point = [2]i64;

fn add_tuple(p1: Point, p2: Point) Point {
    return .{ p1[0] + p2[0], p1[1] + p2[1] };
}

fn is_neighbours(p1: Point, p2: Point) bool {
    return @abs(p1[0] - p2[0]) <= 1 and @abs(p1[1] - p2[1]) <= 1;
}

fn part1(input_file_name: []const u8) !void {
    const allocator = std.heap.page_allocator;
    const input = std.mem.trim(u8, try read_input(input_file_name, allocator), "\n");
    defer allocator.free(input);

    var head: Point = .{ 0, 0 };
    var tail: Point = .{ 0, 0 };
    var tail_positions = set.HashSetManaged(Point).init(allocator);
    _ = try tail_positions.add(.{ 0, 0 });
    var lines = std.mem.split(u8, input, "\n");
    while (lines.next()) |line| {
        var tokens = std.mem.split(u8, line, " ");
        const dir_char = tokens.next().?.ptr[0];
        const dist = try std.fmt.parseInt(usize, tokens.next().?, 10);
        for (0..dist) |_| {
            const dir: Point = switch (dir_char) {
                'U' => .{ 0, 1 },
                'D' => .{ 0, -1 },
                'L' => .{ -1, 0 },
                'R' => .{ 1, 0 },
                else => unreachable,
            };
            head = add_tuple(head, dir);
            if (!is_neighbours(head, tail)) {
                const move_dir = .{
                    std.math.sign(head[0] - tail[0]),
                    std.math.sign(head[1] - tail[1]),
                };
                tail = add_tuple(tail, move_dir);
            }
            _ = try tail_positions.add(tail);
        }
    }

    std.debug.print("Part 1: {d}\n", .{tail_positions.cardinality()});
}

fn part2(input_file_name: []const u8) !void {
    const allocator = std.heap.page_allocator;
    const input = std.mem.trim(u8, try read_input(input_file_name, allocator), "\n");
    defer allocator.free(input);

    var snake = [_]Point{.{ 0, 0 }} ** 10;
    var tail_positions = set.HashSetManaged(Point).init(allocator);
    _ = try tail_positions.add(.{ 0, 0 });
    var lines = std.mem.split(u8, input, "\n");
    while (lines.next()) |line| {
        var tokens = std.mem.split(u8, line, " ");
        const dir_char = tokens.next().?.ptr[0];
        const dist = try std.fmt.parseInt(usize, tokens.next().?, 10);
        for (0..dist) |_| {
            const dir: Point = switch (dir_char) {
                'U' => .{ 0, 1 },
                'D' => .{ 0, -1 },
                'L' => .{ -1, 0 },
                'R' => .{ 1, 0 },
                else => unreachable,
            };
            snake[0] = add_tuple(snake[0], dir);
            for (1..snake.len) |i| {
                if (!is_neighbours(snake[i - 1], snake[i])) {
                    const move_dir = .{
                        std.math.sign(snake[i - 1][0] - snake[i][0]),
                        std.math.sign(snake[i - 1][1] - snake[i][1]),
                    };
                    snake[i] = add_tuple(snake[i], move_dir);
                }
            }
            _ = try tail_positions.add(snake[9]);
        }
    }

    std.debug.print("Part 2: {d}\n", .{tail_positions.cardinality()});
}

pub fn main() !void {
    // const input_file = "sample.txt";
    const input_file = "input.txt";
    try part1(input_file);
    try part2(input_file);
}
