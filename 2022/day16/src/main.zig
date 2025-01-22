const std = @import("std");
const Allocator = std.mem.Allocator;
const fs = std.fs;

const StringArrayList = std.ArrayList([]const u8);

const Valve = struct {
    name: u16,
    flow_rate: usize,
    tunnels: std.ArrayList(u16),

    const Self = @This();

    pub fn deinit(self: *Self) void {
        self.tunnels.deinit();
    }
};

const State = struct {
    pressure: usize,
    remaining: usize,
    current: []const u8,
    opened: StringArrayList,

    const Self = @This();

    pub fn deinit(self: *Self) void {
        self.opened.deinit();
    }
};

fn read_input(input_file_name: []const u8, allocator: Allocator) ![]u8 {
    const input_file = try fs.cwd().openFile(input_file_name, .{});
    defer input_file.close();
    return input_file.readToEndAlloc(allocator, 4 * 1024 * 1024);
}

const ValveMap = std.AutoHashMap(u16, Valve);
const ValveDistMap = std.AutoHashMap(u16, std.AutoHashMap(u16, usize));
const Flow = struct { remaining: usize, valve_name: u16, opened: u64 = 0 };
const MemoMap = std.AutoHashMap(Flow, usize);

fn calculate_max_flow(flow: Flow, indices: *std.AutoHashMap(u16, usize), valves: *ValveMap, valves_dists: *ValveDistMap, memo: *MemoMap) !usize {
    if (memo.contains(flow)) return memo.get(flow).?;

    const valve = valves.get(flow.valve_name).?;

    var max_pressure: usize = 0;
    const dists = valves_dists.get(valve.name).?;
    var dists_iter = dists.iterator();
    while (dists_iter.next()) |entry| {
        const tunnel_name = entry.key_ptr.*;
        const tunnel_dist = entry.value_ptr.*;

        const tunnel_bit_index: u6 = @intCast(indices.get(tunnel_name).?);
        const tunnel = valves.get(tunnel_name).?;

        const bit = @as(u64, 1) << tunnel_bit_index;
        if (flow.opened & bit != 0) continue;

        if (flow.remaining <= tunnel_dist + 1) continue;
        const time_remaining = flow.remaining - tunnel_dist - 1;

        const next_flow = .{ .valve_name = tunnel_name, .remaining = time_remaining, .opened = flow.opened | bit };
        const released_pressure = time_remaining * tunnel.flow_rate;
        const tunnel_pressure = try calculate_max_flow(next_flow, indices, valves, valves_dists, memo);
        max_pressure = @max(max_pressure, released_pressure + tunnel_pressure);
    }

    try memo.put(flow, max_pressure);
    return max_pressure;
}

fn calc_id(name: []const u8) u16 {
    if (name.len > 2) std.debug.print(">2 {s}\n", .{name});
    std.debug.assert(name.len == 2);
    return @intCast(name.ptr[0] + @as(u16, name.ptr[1]) * 256);
}

fn print_id(id: u16) void {
    const c1: u8 = @intCast(@mod(id, 256));
    const c2: u8 = @intCast(@divTrunc(id, 256));
    std.debug.print("{c}{c}\n", .{ c1, c2 });
}

fn part1(input_file_name: []const u8) !void {
    const allocator = std.heap.page_allocator;
    const input = std.mem.trim(u8, try read_input(input_file_name, allocator), "\n");
    defer allocator.free(input);

    const AA_id: u16 = calc_id("AA");

    var valves = ValveMap.init(allocator);
    var lines = std.mem.split(u8, input, "\n");
    while (lines.next()) |line| {
        var blocks = std.mem.split(u8, line, "; ");
        var valve_str = blocks.next().?;
        const name = valve_str[6..8];
        const name_id: u16 = calc_id(name);
        const flow_rate = try std.fmt.parseInt(usize, valve_str[23..], 10);

        const tunels_str = blocks.next().?;
        var list = std.mem.split(u8, tunels_str[23..], ", ");
        var tunels = std.ArrayList(u16).init(allocator);
        while (list.next()) |t| {
            const t_id: u16 = calc_id(t);
            try tunels.append(t_id);
        }

        try valves.put(name_id, .{ .name = name_id, .flow_rate = flow_rate, .tunnels = tunels });
    }

    var valves_dists = ValveDistMap.init(allocator);
    var valves_iter = valves.valueIterator();
    var visited = std.AutoHashMap(u16, bool).init(allocator);

    var non_empty = std.ArrayList(u16).init(allocator);
    while (valves_iter.next()) |valve| {
        defer visited.clearRetainingCapacity();

        if (valve.flow_rate > 0) try non_empty.append(valve.name);
        if (valve.flow_rate == 0 and valve.name != AA_id) continue;

        var cur_dists = std.AutoHashMap(u16, usize).init(allocator);
        try cur_dists.put(valve.name, 0);
        try cur_dists.put(AA_id, 0);

        var queue = std.ArrayList(struct { dist: usize, valve: u16 }).init(allocator);
        try queue.append(.{ .dist = 0, .valve = valve.name });
        while (queue.items.len > 0) {
            const state = queue.pop();
            for (valves.get(state.valve).?.tunnels.items) |tunel| {
                if (visited.contains(tunel)) continue;
                try visited.put(tunel, true);

                if (valves.get(tunel).?.flow_rate > 0)
                    try cur_dists.put(tunel, state.dist + 1);

                try queue.insert(0, .{ .dist = state.dist + 1, .valve = tunel });
            }
        }
        _ = cur_dists.remove(valve.name);
        _ = cur_dists.remove(AA_id);
        try valves_dists.put(valve.name, cur_dists);
    }

    var indices = std.AutoHashMap(u16, usize).init(allocator);
    for (non_empty.items, 0..) |elem, i| {
        try indices.put(elem, i);
    }
    _ = valves_dists.get(AA_id).?;

    var memo = MemoMap.init(allocator);
    const res = try calculate_max_flow(.{ .valve_name = AA_id, .remaining = 30 }, &indices, &valves, &valves_dists, &memo);

    std.debug.print("Part 1: {d}\n", .{res});
}

fn part2(input_file_name: []const u8) !void {
    var general_purpose_allocator = std.heap.GeneralPurposeAllocator(.{}){};
    // defer std.debug.assert(general_purpose_allocator.deinit() == .ok);

    const allocator = general_purpose_allocator.allocator();
    const full_input = try read_input(input_file_name, allocator);
    defer allocator.free(full_input);

    const input = std.mem.trim(u8, full_input, "\n");

    const AA_id: u16 = calc_id("AA");

    var valves = ValveMap.init(allocator);
    defer {
        var valves_iter = valves.valueIterator();
        while (valves_iter.next()) |valve| {
            valve.deinit();
        }

        valves.deinit();
    }
    var lines = std.mem.split(u8, input, "\n");
    while (lines.next()) |line| {
        var blocks = std.mem.split(u8, line, "; ");
        var valve_str = blocks.next().?;
        const name = valve_str[6..8];
        const name_id: u16 = calc_id(name);
        const flow_rate = try std.fmt.parseInt(usize, valve_str[23..], 10);

        const tunels_str = blocks.next().?;
        var list = std.mem.split(u8, tunels_str[23..], ", ");
        var tunels = std.ArrayList(u16).init(allocator);
        while (list.next()) |t| {
            const t_id: u16 = calc_id(t);
            try tunels.append(t_id);
        }

        try valves.put(name_id, .{ .name = name_id, .flow_rate = flow_rate, .tunnels = tunels });
    }

    var valves_dists = ValveDistMap.init(allocator);
    defer {
        var valves_dists_iter = valves_dists.iterator();
        while (valves_dists_iter.next()) |v| {
            v.value_ptr.deinit();
        }
        valves_dists.deinit();
    }
    var valves_iter = valves.valueIterator();
    var visited = std.AutoHashMap(u16, bool).init(allocator);

    var non_empty = std.ArrayList(u16).init(allocator);
    defer non_empty.deinit();
    while (valves_iter.next()) |valve| {
        defer visited.clearRetainingCapacity();
        if (valve.flow_rate > 0) try non_empty.append(valve.name);
        if (valve.flow_rate == 0 and valve.name != AA_id) continue;

        var cur_dists = std.AutoHashMap(u16, usize).init(allocator);
        try cur_dists.put(valve.name, 0);
        try cur_dists.put(AA_id, 0);

        var queue = std.ArrayList(struct { dist: usize, valve: u16 }).init(allocator);
        defer queue.deinit();
        try queue.append(.{ .dist = 0, .valve = valve.name });
        while (queue.items.len > 0) {
            const state = queue.pop();
            for (valves.get(state.valve).?.tunnels.items) |tunel| {
                if (visited.contains(tunel)) continue;
                try visited.put(tunel, true);

                if (valves.get(tunel).?.flow_rate > 0)
                    try cur_dists.put(tunel, state.dist + 1);

                try queue.insert(0, .{ .dist = state.dist + 1, .valve = tunel });
            }
        }
        _ = cur_dists.remove(valve.name);
        _ = cur_dists.remove(AA_id);
        try valves_dists.put(valve.name, cur_dists);
    }
    visited.deinit();

    var indices = std.AutoHashMap(u16, usize).init(allocator);
    defer indices.deinit();
    for (non_empty.items, 0..) |elem, i| {
        try indices.put(elem, i);
    }

    var memo = MemoMap.init(allocator);
    defer memo.deinit();
    var res: usize = 0;
    const bound = (@as(u16, 1) << @intCast(non_empty.items.len)) - 1;
    const limit: usize = @intCast((bound + 1) / 2);
    for (0..limit) |i| {
        const me = try calculate_max_flow(.{ .valve_name = AA_id, .remaining = 26, .opened = i }, &indices, &valves, &valves_dists, &memo);
        const elephant = try calculate_max_flow(.{ .valve_name = AA_id, .remaining = 26, .opened = bound ^ i }, &indices, &valves, &valves_dists, &memo);
        res = @max(res, me + elephant);
    }

    std.debug.print("Part 2: {d}\n", .{res});
}

pub fn main() !void {
    // const input_file = "sample.txt";
    const input_file = "input.txt";
    try part1(input_file);
    try part2(input_file);
}
