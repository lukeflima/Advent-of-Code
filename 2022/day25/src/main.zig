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

    var lines = std.mem.split(u8, input, "\n");
    var sum: usize = 0;
    while (lines.next()) |line| {
        std.mem.reverse(u8, @constCast(line));
        var i: usize = 0;
        var num: i64 = 0;
        for (line) |c| {
            defer i += 1;
            const v: i64 = switch (c) {
                '-' => -1,
                '=' => -2,
                '0' => 0,
                '1' => 1,
                '2' => 2,
                else => unreachable,
            };
            const power: i64 = @intCast(std.math.pow(usize, 5, i));
            num += v * power;
        }
        sum += @intCast(num);
    }

    var snafu: []u8 = &[0]u8{};
    while (sum > 0) {
        const rem: u8 = @intCast(@rem(sum, 5));
        sum = @divTrunc(sum, 5);
        if (rem <= 2) {
            const b = [1]u8{'0' + rem};
            snafu = try std.mem.concat(allocator, u8, &[_][]const u8{ &b, snafu });
        } else {
            const b = switch (rem) {
                3 => "=",
                4 => "-",
                else => unreachable,
            };
            snafu = try std.mem.concat(allocator, u8, &[_][]const u8{ b, snafu });
            sum += 1;
        }
    }

    std.debug.print("Part 1: {s}\n", .{snafu});
}

pub fn main() !void {
    // const input_file = "sample.txt";
    const input_file = "input.txt";
    try part1(input_file);
}
