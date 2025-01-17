const std = @import("std");
const Allocator = std.mem.Allocator;
const fs = std.fs;

const PacketEnum = enum {
    list,
    integer,
};

const Packet = union(PacketEnum) {
    list: []Packet,
    integer: u64,
};

fn read_input(input_file_name: []const u8, allocator: Allocator) ![]u8 {
    const input_file = try fs.cwd().openFile(input_file_name, .{});
    defer input_file.close();
    return input_file.readToEndAlloc(allocator, 4 * 1024 * 1024);
}

fn _parse_packet(allocator: Allocator, input: []const u8) !Packet {
    var i: usize = 0;
    var list = std.ArrayList(Packet).init(allocator);
    while (i < input.len) {
        if (input[i] == '[') {
            var j = i + 1;
            var opens: usize = 1;
            while (j < input.len) {
                if (input[j] == '[') {
                    opens += 1;
                } else if (input[j] == ']') {
                    opens -= 1;
                    if (opens == 0) {
                        break;
                    }
                }
                j += 1;
            }
            if (j == input.len) {
                break;
            }
            const sub_packet = try _parse_packet(allocator, input[i + 1 .. j]);
            try list.append(sub_packet);
            i = j + 1;
        } else if (input[i] == ',') {
            i += 1;
        } else {
            var j = i;
            // find all digits
            while (j < input.len and input[j] >= '0' and input[j] <= '9') {
                j += 1;
            }
            const n = try std.fmt.parseInt(u64, input[i..j], 10);
            try list.append(.{ .integer = n });
            i = j + 1;
        }
    }
    return .{ .list = try list.toOwnedSlice() };
}

fn parse_packet(allocator: Allocator, input: []const u8) !Packet {
    return (try _parse_packet(allocator, input)).list[0];
}

fn _print_packet(packet: Packet, level: usize) void {
    switch (packet) {
        .list => |list| {
            std.debug.print("[", .{});
            for (list, 0..) |sub_packet, i| {
                _print_packet(sub_packet, level + 1);
                if (i != list.len - 1) {
                    std.debug.print(",", .{});
                }
            }
            std.debug.print("]", .{});
        },
        .integer => |integer| {
            std.debug.print("{d}", .{integer});
        },
    }
    if (level == 0) {
        std.debug.print("\n", .{});
    }
}
fn print_packet(packet: Packet) void {
    _print_packet(packet, 0);
}

fn _compare(packet1: Packet, packet2: Packet) ?bool {
    const tag1 = std.meta.activeTag(packet1);
    const tag2 = std.meta.activeTag(packet2);
    var res: ?bool = null;
    if (tag1 == .integer and tag2 == .integer) {
        if (packet1.integer < packet2.integer) {
            return true;
        } else if (packet1.integer > packet2.integer) {
            return false;
        }
    } else if (tag1 == .list and tag2 == .list) {
        const list1 = packet1.list;
        const list2 = packet2.list;
        var i: usize = 0;
        while (i < list1.len and i < list2.len) : (i += 1) {
            const sub_packet1 = list1[i];
            const sub_packet2 = list2[i];
            res = _compare(sub_packet1, sub_packet2);
            if (res != null) return res;
        }
        if (list1.len != list2.len) {
            if (i == list1.len) {
                return true;
            } else if (i == list2.len) {
                return false;
            }
        }
    } else {
        if (tag1 == .integer) {
            var new_packet_slice = [1]Packet{packet1};
            res = _compare(.{ .list = &new_packet_slice }, packet2);
            if (res != null) return res;
        } else {
            var new_packet_slice = [1]Packet{packet2};
            res = _compare(packet1, .{ .list = &new_packet_slice });
            if (res != null) return res;
        }
    }
    return null;
}

fn compare(packet1: Packet, packet2: Packet) bool {
    return _compare(packet1, packet2).?;
}

fn sort_compare(_: void, packet1: Packet, packet2: Packet) bool {
    return compare(packet1, packet2);
}

fn part1(input_file_name: []const u8) !void {
    const allocator = std.heap.page_allocator;
    const input = std.mem.trim(u8, try read_input(input_file_name, allocator), "\n");
    defer allocator.free(input);
    var blocks = std.mem.split(u8, input, "\n\n");
    var index: usize = 0;
    var res: usize = 0;
    while (blocks.next()) |block| {
        index += 1;
        var lines = std.mem.split(u8, block, "\n");
        const packet1 = try parse_packet(allocator, lines.next().?);
        const packet2 = try parse_packet(allocator, lines.next().?);
        // print_packet(packet1);
        // print_packet(packet2);
        const cmp = compare(packet1, packet2);
        if (cmp) {
            res += index;
        }
    }
    std.debug.print("Part 1: {d}\n", .{res});
}

fn part2(input_file_name: []const u8) !void {
    const allocator = std.heap.page_allocator;
    const input = std.mem.trim(u8, try read_input(input_file_name, allocator), "\n");
    defer allocator.free(input);
    var lines = std.mem.split(u8, input, "\n");
    var packets = std.ArrayList(Packet).init(allocator);
    try packets.append(try parse_packet(allocator, "[[2]]"));
    try packets.append(try parse_packet(allocator, "[[6]]"));
    while (lines.next()) |line| {
        if (line.len == 0) {
            continue;
        }
        try packets.append(try parse_packet(allocator, line));
    }

    std.mem.sort(Packet, packets.items, {}, sort_compare);
    var res: u64 = 1;
    for (packets.items, 1..) |packet, i| {
        if (std.meta.activeTag(packet) == .list) {
            const list = packet.list;
            if (list.len == 1) {
                const sub_packet = list[0];
                if (std.meta.activeTag(sub_packet) == .list) {
                    const sub_list = sub_packet.list;
                    if (sub_list.len == 1) {
                        const sub_sub_packet = sub_list[0];
                        if (std.meta.activeTag(sub_sub_packet) == .integer) {
                            if (sub_sub_packet.integer == 2 or sub_sub_packet.integer == 6) {
                                res *= i;
                            }
                        }
                    }
                }
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
