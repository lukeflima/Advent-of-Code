const std = @import("std");
const Allocator = std.mem.Allocator;
const fs = std.fs;

fn read_input(input_file_name: []const u8, allocator: Allocator) ![]u8 {
    const input_file = try fs.cwd().openFile(input_file_name, .{});
    defer input_file.close();
    return input_file.readToEndAlloc(allocator, 4 * 1024 * 1024);
}

fn parse_coords(input: []const u8) ![2]i64 {
    var tokens = std.mem.split(u8, input, ", ");
    const x_str = tokens.next().?;
    const y_str = tokens.next().?;
    const x = try std.fmt.parseInt(i64, x_str[2..], 10);
    const y = try std.fmt.parseInt(i64, y_str[2..], 10);
    return .{ x, y };
}

fn part1(input_file_name: []const u8, target_y: i64) !void {
    const allocator = std.heap.page_allocator;
    const input = std.mem.trim(u8, try read_input(input_file_name, allocator), "\n");
    defer allocator.free(input);

    var lines = std.mem.split(u8, input, "\n");
    var positions = std.ArrayList([2]i64).init(allocator);
    while (lines.next()) |line| {
        var parts = std.mem.split(u8, line, ":");
        const sensor_str = parts.next().?;
        const beacon_str = parts.next().?;
        const sensor = try parse_coords(sensor_str[10..]);
        const beacon = try parse_coords(beacon_str[22..]);
        const distance: i64 = @intCast(@abs(beacon[0] - sensor[0]) + @abs(beacon[1] - sensor[1]));
        const dy: i64 = @intCast(@abs(sensor[1] - target_y));
        if (distance >= dy) {
            const lower = sensor[0] + dy - distance;
            const upper = sensor[0] + distance - dy;
            if (upper - lower > 0) {
                try positions.append(.{ lower, upper });
            }
        }
    }

    for (0..positions.items.len) |i| {
        for (0..positions.items.len) |j| {
            if (i == j) continue;
            const range_i = positions.items[i];
            var range_j = positions.items[j];
            if (range_i[1] < range_j[1] and range_j[0] < range_i[1]) {
                positions.items[j][0] = range_i[1];
            }
            range_j = positions.items[j];
            if (range_i[1] >= range_j[1] and range_j[1] > range_i[0]) {
                positions.items[j][1] = range_i[0];
            }
        }
    }

    var ocupied: usize = 0;
    for (positions.items) |range| {
        if (range[1] - range[0] > 0) {
            ocupied += @intCast(range[1] - range[0]);
        }
    }

    std.debug.print("Part 1: {d}\n", .{ocupied});
}

const Sensor = struct {
    pos: [2]i64,
    beacon: [2]i64,
    distance: i64,
};

fn part2(input_file_name: []const u8, limit: i64) !void {
    const allocator = std.heap.page_allocator;
    const input = std.mem.trim(u8, try read_input(input_file_name, allocator), "\n");
    defer allocator.free(input);

    var lines = std.mem.split(u8, input, "\n");
    var sensors = std.ArrayList(Sensor).init(allocator);
    while (lines.next()) |line| {
        var parts = std.mem.split(u8, line, ":");
        const sensor_str = parts.next().?;
        const beacon_str = parts.next().?;
        const sensor = try parse_coords(sensor_str[10..]);
        const beacon = try parse_coords(beacon_str[22..]);
        const distance: i64 = @intCast(@abs(beacon[0] - sensor[0]) + @abs(beacon[1] - sensor[1]));
        try sensors.append(.{ .pos = sensor, .beacon = beacon, .distance = distance });
    }
    var res = [2]i64{ 0, 0 };
    outer: for (sensors.items) |sensor| {
        for (0..@intCast(sensor.distance + 2)) |dx_usize| {
            const dx: i64 = @intCast(dx_usize);
            const dy: i64 = (sensor.distance + 1) - dx;
            const candidates = [_][2]i64{
                .{ sensor.pos[0] + dx, sensor.pos[1] + dy },
                .{ sensor.pos[0] + dx, sensor.pos[1] - dy },
                .{ sensor.pos[0] - dx, sensor.pos[1] + dy },
                .{ sensor.pos[0] - dx, sensor.pos[1] - dy },
            };
            for (candidates) |coord| {
                if (coord[0] >= 0 and coord[0] <= limit and coord[1] >= 0 and coord[1] <= limit) {
                    var doesnt_contain: usize = 0;
                    for (sensors.items) |s| {
                        if (@abs(coord[0] - s.pos[0]) + @abs(coord[1] - s.pos[1]) > s.distance) {
                            doesnt_contain += 1;
                        } else {}
                    }
                    if (doesnt_contain == sensors.items.len) {
                        res = coord;
                        break :outer;
                    }
                }
            }
        }
    }

    std.debug.print("Part 2: {d}\n", .{res[0] * 4000000 + res[1]});
}

pub fn main() !void {
    // const input_file = "sample.txt";
    // const target_y: i64 = 10;
    // const limit: i64 = 20;
    const input_file = "input.txt";
    const target_y: i64 = 2000000;
    const limit: i64 = 4000000;
    try part1(input_file, target_y);
    try part2(input_file, limit);
}
