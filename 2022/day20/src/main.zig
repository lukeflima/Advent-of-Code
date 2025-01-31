const std = @import("std");
const Allocator = std.mem.Allocator;
const fs = std.fs;

fn read_input(input_file_name: []const u8, allocator: Allocator) ![]u8 {
    const input_file = try fs.cwd().openFile(input_file_name, .{});
    defer input_file.close();
    return input_file.readToEndAlloc(allocator, 4 * 1024 * 1024);
}
const L = std.DoublyLinkedList(i64);

fn print_list(list: L) void {
    var cur = list.first;
    var c: usize = 0;
    while (c < list.len) {
        c += 1;
        const node = cur.?;
        cur = node.next;
        std.debug.print("{d},", .{node.data});
    }
    std.debug.print("\n", .{});
}

fn part1(input_file_name: []const u8) !void {
    const allocator = std.heap.page_allocator;
    const input = std.mem.trim(u8, try read_input(input_file_name, allocator), "\n");
    defer allocator.free(input);

    var lines = std.mem.split(u8, input, "\n");
    var list = L{};
    var original_list = std.ArrayList(*L.Node).init(allocator);
    var zero_value_option: ?*L.Node = null;

    while (lines.next()) |line| {
        var num_node = try allocator.create(L.Node);
        num_node.data = try std.fmt.parseInt(i64, line, 10);
        try original_list.append(num_node);
        list.append(num_node);
        if (num_node.data == 0) zero_value_option = num_node;
    }
    const zero_value: *L.Node = zero_value_option.?;

    // make it loop
    list.first.?.prev = list.last.?;
    list.last.?.next = list.first.?;

    const len: i64 = @intCast(original_list.items.len - 1);
    for (original_list.items) |node| {
        const value = node.data;
        if (value == 0) continue;
        const position: i64 = @rem(value, len);
        if (position == 0) continue;

        var place = node;
        if (position > 0) {
            for (0..@intCast(position)) |_| {
                place = place.next.?;
            }
        } else {
            for (0..@intCast(@abs(position))) |_| {
                place = place.prev.?;
            }
            place = place.prev.?;
        }

        node.next.?.prev = node.prev.?;
        node.prev.?.next = node.next.?;

        place.next.?.prev = node;
        node.next = place.next.?;
        place.next = node;
        node.prev = place;
    }

    var decoded_list = try std.ArrayList(i64).initCapacity(allocator, list.len);
    try decoded_list.append(0);
    var cur = zero_value.next.?;
    while (cur != zero_value) {
        try decoded_list.append(cur.data);
        cur = cur.next.?;
    }

    var res: i64 = 0;
    res += decoded_list.items[1000 % decoded_list.items.len];
    res += decoded_list.items[2000 % decoded_list.items.len];
    res += decoded_list.items[3000 % decoded_list.items.len];

    std.debug.print("Part 1: {d}\n", .{res});
}

fn part2(input_file_name: []const u8) !void {
    const allocator = std.heap.page_allocator;
    const input = std.mem.trim(u8, try read_input(input_file_name, allocator), "\n");
    defer allocator.free(input);

    var lines = std.mem.split(u8, input, "\n");
    var list = L{};
    var original_list = std.ArrayList(*L.Node).init(allocator);
    var zero_value_option: ?*L.Node = null;

    while (lines.next()) |line| {
        var num_node = try allocator.create(L.Node);
        num_node.data = try std.fmt.parseInt(i64, line, 10) * 811589153;
        try original_list.append(num_node);
        list.append(num_node);
        if (num_node.data == 0) zero_value_option = num_node;
    }
    const zero_value: *L.Node = zero_value_option.?;

    // make it loop
    list.first.?.prev = list.last.?;
    list.last.?.next = list.first.?;

    const len: i64 = @intCast(original_list.items.len - 1);
    for (0..10) |_| {
        for (original_list.items) |node| {
            const value = node.data;
            if (value == 0) continue;
            const position: i64 = @rem(value, len);
            if (position == 0) continue;

            var place = node;
            if (position > 0) {
                for (0..@intCast(position)) |_| {
                    place = place.next.?;
                }
            } else {
                for (0..@intCast(-position)) |_| {
                    place = place.prev.?;
                }
                place = place.prev.?;
            }

            node.next.?.prev = node.prev.?;
            node.prev.?.next = node.next.?;

            place.next.?.prev = node;
            node.next = place.next.?;
            place.next = node;
            node.prev = place;
        }
    }

    var decoded_list = try std.ArrayList(i64).initCapacity(allocator, list.len);
    try decoded_list.append(0);
    var cur = zero_value.next.?;
    while (cur != zero_value) {
        try decoded_list.append(cur.data);
        cur = cur.next.?;
    }

    var res: i64 = 0;
    res += decoded_list.items[1000 % decoded_list.items.len];
    res += decoded_list.items[2000 % decoded_list.items.len];
    res += decoded_list.items[3000 % decoded_list.items.len];

    std.debug.print("Part 2: {d}\n", .{res});
}

pub fn main() !void {
    // const input_file = "sample.txt";
    const input_file = "input.txt";
    try part1(input_file);
    try part2(input_file);
}
