const std = @import("std");
const Allocator = std.mem.Allocator;
const fs = std.fs;

fn read_input(input_file_name: []const u8, allocator: Allocator) ![]u8 {
    const input_file = try fs.cwd().openFile(input_file_name, .{});
    defer input_file.close();
    return input_file.readToEndAlloc(allocator, 4 * 1024 * 1024);
}

fn part1(input_file_name: []const u8, num_stacks: usize) !void {
    const allocator = std.heap.page_allocator;
    const input = std.mem.trim(u8, try read_input(input_file_name, allocator), "\n");
    defer allocator.free(input);

    var stacks: std.ArrayList(std.ArrayList(u8)) = try std.ArrayList(std.ArrayList(u8)).initCapacity(allocator, num_stacks);
    defer {
        for (stacks.items) |item| {
            item.deinit();
        }
        stacks.deinit();
    }
    for (0..num_stacks) |_| {
        try stacks.append(std.ArrayList(u8).init(allocator));
    }

    var blocks = std.mem.split(u8, input, "\n\n");
    var stacks_lines = std.mem.split(u8, blocks.next().?, "\n");
    while (stacks_lines.next()) |line| {
        if (stacks_lines.peek() == null) {
            break;
        }
        var i: usize = 0;
        while (i < num_stacks * 4) {
            if (line.ptr[i + 1] != ' ') {
                try stacks.items[i / 4].insert(0, line.ptr[i + 1]);
            }
            i += 4;
        }
    }

    var rearrage_lines = std.mem.split(u8, blocks.next().?, "\n");
    while (rearrage_lines.next()) |line| {
        var tokens = std.mem.split(u8, line, " ");
        _ = tokens.next(); // move
        const n: usize = try std.fmt.parseInt(usize, tokens.next().?, 10);
        _ = tokens.next(); // from
        const from: usize = try std.fmt.parseInt(usize, tokens.next().?, 10) - 1;
        _ = tokens.next(); // to
        const to: usize = try std.fmt.parseInt(usize, tokens.next().?, 10) - 1;
        for (0..n) |_| {
            try stacks.items[to].append(stacks.items[from].pop());
        }
    }
    var stacks_top = try std.ArrayList(u8).initCapacity(allocator, num_stacks);
    defer stacks_top.deinit();
    for (0..num_stacks) |i| {
        try stacks_top.append(stacks.items[i].pop());
    }
    std.debug.print("Part 1: {s}\n", .{stacks_top.items});
}
fn part2(input_file_name: []const u8, num_stacks: usize) !void {
    const allocator = std.heap.page_allocator;
    const input = std.mem.trim(u8, try read_input(input_file_name, allocator), "\n");
    defer allocator.free(input);

    var stacks: std.ArrayList(std.ArrayList(u8)) = try std.ArrayList(std.ArrayList(u8)).initCapacity(allocator, num_stacks);
    defer {
        for (stacks.items) |item| {
            item.deinit();
        }
        stacks.deinit();
    }
    for (0..num_stacks) |_| {
        try stacks.append(std.ArrayList(u8).init(allocator));
    }

    var blocks = std.mem.split(u8, input, "\n\n");
    var stacks_lines = std.mem.split(u8, blocks.next().?, "\n");
    while (stacks_lines.next()) |line| {
        if (stacks_lines.peek() == null) {
            break;
        }
        var i: usize = 0;
        while (i < num_stacks * 4) {
            if (line.ptr[i + 1] != ' ') {
                try stacks.items[i / 4].insert(0, line.ptr[i + 1]);
            }
            i += 4;
        }
    }

    var rearrage_lines = std.mem.split(u8, blocks.next().?, "\n");
    while (rearrage_lines.next()) |line| {
        var tokens = std.mem.split(u8, line, " ");
        _ = tokens.next(); // move
        const n: usize = try std.fmt.parseInt(usize, tokens.next().?, 10);
        _ = tokens.next(); // from
        const from: usize = try std.fmt.parseInt(usize, tokens.next().?, 10) - 1;
        _ = tokens.next(); // to
        const to: usize = try std.fmt.parseInt(usize, tokens.next().?, 10) - 1;
        const index = stacks.items[from].items.len - n;
        try stacks.items[to].appendSlice(stacks.items[from].items[index..]);
        stacks.items[from].shrinkRetainingCapacity(index);
    }
    var stacks_top = try std.ArrayList(u8).initCapacity(allocator, num_stacks);
    defer stacks_top.deinit();
    for (0..num_stacks) |i| {
        try stacks_top.append(stacks.items[i].pop());
    }

    std.debug.print("Part 2: {s}\n", .{stacks_top.items});
}
pub fn main() !void {
    // const input_file = "sample.txt";
    // const num_stack = 3;
    const input_file = "input.txt";
    const num_stack = 9;
    try part1(input_file, num_stack);
    try part2(input_file, num_stack);
}
