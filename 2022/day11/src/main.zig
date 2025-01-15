const std = @import("std");
const Allocator = std.mem.Allocator;
const fs = std.fs;

fn read_input(input_file_name: []const u8, allocator: Allocator) ![]u8 {
    const input_file = try fs.cwd().openFile(input_file_name, .{});
    defer input_file.close();
    return input_file.readToEndAlloc(allocator, 4 * 1024 * 1024);
}

const Monkey = struct {
    id: usize,
    items: std.ArrayList(usize),
    throw_test: Op,
    test_value: usize,
    bored_throw: [2]usize,

    fn create(allocator: Allocator, id: usize, items: []usize, throw_test: Op, test_value: usize, bored_throw: [2]usize) !*Monkey {
        var items_list = std.ArrayList(usize).init(allocator);
        for (items) |item| {
            try items_list.append(item);
        }
        const monkey_ptr = try allocator.create(Monkey);
        monkey_ptr.* = Monkey{
            .id = id,
            .items = items_list,
            .throw_test = throw_test,
            .test_value = test_value,
            .bored_throw = bored_throw,
        };
        return monkey_ptr;
    }
};

const OpType = enum { add, mul };
const ArgType = enum { num, old };
const Arg = union(ArgType) {
    num: usize,
    old: void,
};

const Op = union(OpType) {
    add: [2]Arg,
    mul: [2]Arg,
};

fn resolve_arg(arg: Arg, old: usize) usize {
    switch (arg) {
        .num => |num| return num,
        .old => return old,
    }
}

fn parse_arg(arg: []const u8) !Arg {
    if (arg[0] == 'o') {
        return Arg{ .old = {} };
    } else {
        return Arg{ .num = try std.fmt.parseInt(usize, arg, 10) };
    }
}

fn print_arg(arg: Arg) void {
    switch (arg) {
        .num => |num| std.debug.print("{d}", .{num}),
        .old => std.debug.print("old", .{}),
    }
}

fn print_op(op: Op) void {
    switch (op) {
        .add => |args| {
            print_arg(args[0]);
            std.debug.print(" + ", .{});
            print_arg(args[1]);
        },
        .mul => |args| {
            print_arg(args[0]);
            std.debug.print(" * ", .{});
            print_arg(args[1]);
        },
    }
    std.debug.print("\n", .{});
}

fn part1(input_file_name: []const u8) !void {
    const allocator = std.heap.page_allocator;
    const input = std.mem.trim(u8, try read_input(input_file_name, allocator), "\n");
    defer allocator.free(input);
    var blocks = std.mem.split(u8, input, "\n\n");
    var monkeys = std.ArrayList(*Monkey).init(allocator);
    var monkeys_items_inspected = std.ArrayList(usize).init(allocator);
    while (blocks.next()) |block| {
        var lines = std.mem.split(u8, std.mem.trim(u8, block, "\n"), "\n");
        const monkey_id_line = lines.next().?;
        const monkey_id = try std.fmt.parseInt(u32, monkey_id_line[7 .. monkey_id_line.len - 1], 10);
        const items_line = lines.next().?[18..];
        var items = std.ArrayList(usize).init(allocator);
        var items_str = std.mem.split(u8, items_line, ", ");
        while (items_str.next()) |item_str| {
            try items.append(try std.fmt.parseInt(usize, item_str, 10));
        }
        const op_line = lines.next().?[19..];
        var tokens = std.mem.split(u8, op_line, " ");
        const lhs = try parse_arg(tokens.next().?);
        const op_str = tokens.next().?;
        const rhs = try parse_arg(tokens.next().?);
        const op: Op = switch (op_str.ptr[0]) {
            '+' => Op{ .add = .{ lhs, rhs } },
            '*' => Op{ .mul = .{ lhs, rhs } },
            else => unreachable,
        };
        const test_value = try std.fmt.parseInt(usize, lines.next().?[21..], 10);
        const true_trhow = try std.fmt.parseInt(usize, lines.next().?[29..], 10);
        const false_trhow = try std.fmt.parseInt(usize, lines.next().?[30..], 10);

        try monkeys.append(try Monkey.create(allocator, monkey_id, try items.toOwnedSlice(), op, test_value, .{ true_trhow, false_trhow }));
        try monkeys_items_inspected.append(0);
    }
    // print monkeys

    for (0..20) |_| {
        for (0..monkeys.items.len) |i| {
            const monkey = monkeys.items[i];
            for (monkey.items.items) |old| {
                monkeys_items_inspected.items[monkey.id] += 1;
                const new = switch (monkey.throw_test) {
                    .add => resolve_arg(monkey.throw_test.add[0], old) + resolve_arg(monkey.throw_test.add[1], old),
                    .mul => resolve_arg(monkey.throw_test.mul[0], old) * resolve_arg(monkey.throw_test.mul[1], old),
                };
                const worry = new / 3;
                if (worry % monkey.test_value == 0) {
                    try monkeys.items[monkey.bored_throw[0]].items.append(worry);
                } else {
                    try monkeys.items[monkey.bored_throw[1]].items.append(worry);
                }
            }
            monkey.items.clearRetainingCapacity();
        }
    }
    std.mem.sort(usize, monkeys_items_inspected.items, {}, comptime std.sort.desc(usize));

    std.debug.print("Part 1: {d}\n", .{monkeys_items_inspected.items[0] * monkeys_items_inspected.items[1]});
}

fn part2(input_file_name: []const u8) !void {
    const allocator = std.heap.page_allocator;
    const input = std.mem.trim(u8, try read_input(input_file_name, allocator), "\n");
    defer allocator.free(input);
    var blocks = std.mem.split(u8, input, "\n\n");
    var monkeys = std.ArrayList(*Monkey).init(allocator);
    var monkeys_items_inspected = std.ArrayList(usize).init(allocator);
    var lmc: usize = 1;
    while (blocks.next()) |block| {
        var lines = std.mem.split(u8, std.mem.trim(u8, block, "\n"), "\n");
        const monkey_id_line = lines.next().?;
        const monkey_id = try std.fmt.parseInt(u32, monkey_id_line[7 .. monkey_id_line.len - 1], 10);
        const items_line = lines.next().?[18..];
        var items = std.ArrayList(usize).init(allocator);
        var items_str = std.mem.split(u8, items_line, ", ");
        while (items_str.next()) |item_str| {
            try items.append(try std.fmt.parseInt(usize, item_str, 10));
        }
        const op_line = lines.next().?[19..];
        var tokens = std.mem.split(u8, op_line, " ");
        const lhs = try parse_arg(tokens.next().?);
        const op_str = tokens.next().?;
        const rhs = try parse_arg(tokens.next().?);
        const op: Op = switch (op_str.ptr[0]) {
            '+' => Op{ .add = .{ lhs, rhs } },
            '*' => Op{ .mul = .{ lhs, rhs } },
            else => unreachable,
        };
        const test_value = try std.fmt.parseInt(usize, lines.next().?[21..], 10);
        lmc *= test_value;
        const true_trhow = try std.fmt.parseInt(usize, lines.next().?[29..], 10);
        const false_trhow = try std.fmt.parseInt(usize, lines.next().?[30..], 10);

        try monkeys.append(try Monkey.create(allocator, monkey_id, try items.toOwnedSlice(), op, test_value, .{ true_trhow, false_trhow }));
        try monkeys_items_inspected.append(0);
    }

    for (0..10000) |_| {
        for (0..monkeys.items.len) |i| {
            const monkey = monkeys.items[i];
            for (monkey.items.items) |old| {
                monkeys_items_inspected.items[monkey.id] += 1;
                const new = switch (monkey.throw_test) {
                    .add => resolve_arg(monkey.throw_test.add[0], old) + resolve_arg(monkey.throw_test.add[1], old),
                    .mul => resolve_arg(monkey.throw_test.mul[0], old) * resolve_arg(monkey.throw_test.mul[1], old),
                };
                const worry = new % lmc;
                if (worry % monkey.test_value == 0) {
                    try monkeys.items[monkey.bored_throw[0]].items.append(worry);
                } else {
                    try monkeys.items[monkey.bored_throw[1]].items.append(worry);
                }
            }
            monkey.items.clearRetainingCapacity();
        }
    }
    std.mem.sort(usize, monkeys_items_inspected.items, {}, comptime std.sort.desc(usize));

    std.debug.print("Part 2: {d}\n", .{monkeys_items_inspected.items[0] * monkeys_items_inspected.items[1]});
}

pub fn main() !void {
    // const input_file = "sample.txt";
    const input_file = "input.txt";
    try part1(input_file);
    try part2(input_file);
}
