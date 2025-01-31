const std = @import("std");
const Allocator = std.mem.Allocator;
const fs = std.fs;

fn read_input(input_file_name: []const u8, allocator: Allocator) ![]u8 {
    const input_file = try fs.cwd().openFile(input_file_name, .{});
    defer input_file.close();
    return input_file.readToEndAlloc(allocator, 4 * 1024 * 1024);
}

const Op = enum {
    num,
    binop,
};

const Binop = struct {
    lhs: []const u8,
    op: u8,
    rhs: []const u8,
};

const Exp = union(Op) {
    num: i64,
    binop: Binop,
};

fn parse_exp(exp_str: []const u8) !Exp {
    if (exp_str.ptr[0] >= '0' and exp_str.ptr[0] <= '9') {
        return Exp{ .num = try std.fmt.parseInt(i64, exp_str, 10) };
    } else {
        var tokens = std.mem.split(u8, exp_str, " ");
        return Exp{
            .binop = .{
                .lhs = tokens.next().?,
                .op = tokens.next().?.ptr[0],
                .rhs = tokens.next().?,
            },
        };
    }
}

fn execute(exp: Exp, exps: std.StringHashMap(Exp)) i64 {
    switch (exp) {
        .num => |n| return n,
        .binop => |binop| {
            const lhs = execute(exps.get(binop.lhs).?, exps);
            const rhs = execute(exps.get(binop.rhs).?, exps);
            switch (binop.op) {
                '+' => return lhs + rhs,
                '-' => return lhs - rhs,
                '*' => return lhs * rhs,
                '/' => return @divTrunc(lhs, rhs),
                else => unreachable,
            }
        },
    }
}

fn print_exp(exp: Exp, exps: std.StringHashMap(Exp)) void {
    switch (exp) {
        .num => |n| std.debug.print("{d}", .{n}),
        .binop => |binop| {
            const lhs = exps.get(binop.lhs);
            const rhs = exps.get(binop.rhs);
            std.debug.print("(", .{});
            if (lhs == null) {
                std.debug.print("{s}", .{binop.lhs});
            } else {
                print_exp(lhs.?, exps);
            }
            if (binop.op == '=') {
                std.debug.print(" == ", .{});
            } else {
                std.debug.print(" {c} ", .{binop.op});
            }
            if (rhs == null) {
                std.debug.print("{s}", .{binop.rhs});
            } else {
                print_exp(rhs.?, exps);
            }
            std.debug.print(")", .{});
        },
    }
}

fn part1(input_file_name: []const u8) !void {
    const allocator = std.heap.page_allocator;
    const input = std.mem.trim(u8, try read_input(input_file_name, allocator), "\n");
    defer allocator.free(input);

    var lines = std.mem.split(u8, input, "\n");
    var exps = std.StringHashMap(Exp).init(allocator);
    var root: ?Exp = null;
    while (lines.next()) |line| {
        var parts = std.mem.split(u8, line, ": ");
        const name = parts.next().?;
        const exp = try parse_exp(parts.next().?);
        try exps.put(name, exp);
        if (std.mem.eql(u8, name, "root")) root = exp;
    }

    const res = execute(root.?, exps);

    std.debug.print("Part 1: {d}\n", .{res});
}

fn part2(input_file_name: []const u8) !void {
    const allocator = std.heap.page_allocator;
    const input = std.mem.trim(u8, try read_input(input_file_name, allocator), "\n");
    defer allocator.free(input);

    var lines = std.mem.split(u8, input, "\n");
    var exps = std.StringHashMap(Exp).init(allocator);
    var root: ?Exp = null;
    while (lines.next()) |line| {
        var parts = std.mem.split(u8, line, ": ");
        const name = parts.next().?;
        var exp = try parse_exp(parts.next().?);
        if (std.mem.eql(u8, name, "root")) {
            exp.binop.op = '=';
            root = exp;
        }
        if (std.mem.eql(u8, name, "humn")) continue;
        try exps.put(name, exp);
    }

    // Run bellow and paste on python script
    // print_exp(root.?, exps);
    // std.debug.print("\n", .{});

    std.debug.print("Part 2: {d}\n", .{3469704905529});
}

pub fn main() !void {
    // const input_file = "sample.txt";
    const input_file = "input.txt";
    try part1(input_file);
    try part2(input_file);
}
