const std = @import("std");
const Allocator = std.mem.Allocator;
const fs = std.fs;

const StringArrayList = std.ArrayList([]const u8);

const Valve = struct {
    name: []const u8,
    flow_rate: usize,
    tunnels: StringArrayList,

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

fn compare_state(_: void, a: State, b: State) std.math.Order {
    return std.math.order(a.pressure, b.pressure).invert();
}

fn contains(list: StringArrayList, value: []const u8) bool {
    for (list.items) |item| {
        if (std.mem.eql(u8, item, value)) return true;
    }
    return false;
}

fn read_input(input_file_name: []const u8, allocator: Allocator) ![]u8 {
    const input_file = try fs.cwd().openFile(input_file_name, .{});
    defer input_file.close();
    return input_file.readToEndAlloc(allocator, 4 * 1024 * 1024);
}

fn compareStrings(_: void, lhs: []const u8, rhs: []const u8) bool {
    return std.mem.order(u8, lhs, rhs).compare(std.math.CompareOperator.lt);
}

fn indexOfString(haystack: [][]const u8, needle: []const u8) ?usize {
    for (haystack, 0..) |hay, i| {
        if (std.mem.eql(u8, hay, needle)) return i;
    }
    return null;
}

const ValveMap = std.StringHashMap(Valve);
const ValveDistMap = std.StringArrayHashMap(std.StringArrayHashMap(usize));
const Flow = struct { remaining: usize, valve_index: usize, opened: u64 = 0 };
const MemoMap = std.AutoArrayHashMap(Flow, usize);

fn calculate_max_flow(flow: Flow, valve_names: [][]const u8, indices: *std.StringArrayHashMap(usize), valves: *ValveMap, valves_dists: *ValveDistMap, memo: *MemoMap) !usize {
    if (memo.contains(flow)) return memo.get(flow).?;

    const valve = valves.get(valve_names[flow.valve_index]).?;

    var max_pressure: usize = 0;
    const dists = valves_dists.get(valve.name).?;
    for (dists.keys(), dists.values()) |tunnel_name, tunnel_dist| {
        const tunnel_bit_index: u6 = @intCast(indices.get(tunnel_name).?);
        const tunnel = valves.get(tunnel_name).?;
        const tunnel_index = indexOfString(valve_names, tunnel_name).?;

        const bit = @as(u64, 1) << tunnel_bit_index;
        if (flow.opened & bit != 0) continue;

        if (flow.remaining <= tunnel_dist + 1) continue;
        const time_remaining = flow.remaining - tunnel_dist - 1;

        const next_flow = .{ .valve_index = tunnel_index, .remaining = time_remaining, .opened = flow.opened | bit };
        const released_pressure = time_remaining * tunnel.flow_rate;
        const tunnel_pressure = try calculate_max_flow(next_flow, valve_names, indices, valves, valves_dists, memo);
        max_pressure = @max(max_pressure, released_pressure + tunnel_pressure);
    }
    // }
    try memo.put(flow, max_pressure);
    return max_pressure;
}

fn part1(input_file_name: []const u8) !void {
    const allocator = std.heap.page_allocator;
    const input = std.mem.trim(u8, try read_input(input_file_name, allocator), "\n");
    defer allocator.free(input);

    var valves = ValveMap.init(allocator);
    var valves_names = std.ArrayList([]const u8).init(allocator);
    var lines = std.mem.split(u8, input, "\n");
    while (lines.next()) |line| {
        var blocks = std.mem.split(u8, line, "; ");
        var valve_str = blocks.next().?;
        const name = valve_str[6..8];
        const flow_rate = try std.fmt.parseInt(usize, valve_str[23..], 10);

        try valves_names.append(name);

        const tunels_str = blocks.next().?;
        var list = std.mem.split(u8, tunels_str[23..], ", ");
        var tunels = StringArrayList.init(allocator);
        while (list.next()) |t| {
            try tunels.append(t);
        }

        try valves.put(name, .{ .name = name, .flow_rate = flow_rate, .tunnels = tunels });
    }

    std.mem.sort([]const u8, valves_names.items, {}, compareStrings);

    var valves_dists = ValveDistMap.init(allocator);
    var valves_iter = valves.valueIterator();
    var visited = std.StringArrayHashMap(bool).init(allocator);

    var non_empty = std.ArrayList([]const u8).init(allocator);
    while (valves_iter.next()) |valve| {
        defer visited.clearRetainingCapacity();

        if (valve.flow_rate > 0) try non_empty.append(valve.name);
        if (valve.flow_rate == 0 and !std.mem.eql(u8, valve.name, "AA")) continue;

        var cur_dists = std.StringArrayHashMap(usize).init(allocator);
        try cur_dists.put(valve.name, 0);
        try cur_dists.put("AA", 0);

        var queue = std.ArrayList(struct { dist: usize, valve: []const u8 }).init(allocator);
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
        _ = cur_dists.swapRemove(valve.name);
        _ = cur_dists.swapRemove("AA");
        try valves_dists.put(valve.name, cur_dists);
    }

    var indices = std.StringArrayHashMap(usize).init(allocator);
    for (non_empty.items, 0..) |elem, i| {
        try indices.put(elem, i);
    }

    var memo = MemoMap.init(allocator);
    const res = try calculate_max_flow(.{ .valve_index = 0, .remaining = 30 }, valves_names.items, &indices, &valves, &valves_dists, &memo);

    std.debug.print("Part 1: {d}\n", .{res});
}

fn part2(input_file_name: []const u8) !void {
    var general_purpose_allocator = std.heap.GeneralPurposeAllocator(.{}){};
    // defer _ = general_purpose_allocator.deinit();

    const allocator = general_purpose_allocator.allocator();

    const input = std.mem.trim(u8, try read_input(input_file_name, allocator), "\n");

    var valves = ValveMap.init(allocator);
    defer {
        var valves_iter = valves.valueIterator();
        while (valves_iter.next()) |valve| {
            valve.deinit();
        }

        valves.deinit();
    }
    var valves_names = std.ArrayList([]const u8).init(allocator);
    defer valves_names.deinit();
    var lines = std.mem.split(u8, input, "\n");
    while (lines.next()) |line| {
        var blocks = std.mem.split(u8, line, "; ");
        var valve_str = blocks.next().?;
        const name = valve_str[6..8];
        const flow_rate = try std.fmt.parseInt(usize, valve_str[23..], 10);

        try valves_names.append(name);

        const tunels_str = blocks.next().?;
        var list = std.mem.split(u8, tunels_str[23..], ", ");
        var tunels = StringArrayList.init(allocator);
        while (list.next()) |t| {
            try tunels.append(t);
        }

        try valves.put(name, .{ .name = name, .flow_rate = flow_rate, .tunnels = tunels });
    }

    std.mem.sort([]const u8, valves_names.items, {}, compareStrings);

    var valves_dists = ValveDistMap.init(allocator);
    defer {
        valves_dists.deinit();
    }
    var valves_iter = valves.valueIterator();
    var visited = std.StringArrayHashMap(bool).init(allocator);

    var non_empty = std.ArrayList([]const u8).init(allocator);
    while (valves_iter.next()) |valve| {
        defer visited.clearRetainingCapacity();
        if (valve.flow_rate > 0) try non_empty.append(valve.name);
        if (valve.flow_rate == 0 and !std.mem.eql(u8, valve.name, "AA")) continue;

        var cur_dists = std.StringArrayHashMap(usize).init(allocator);
        try cur_dists.put(valve.name, 0);
        try cur_dists.put("AA", 0);

        var queue = std.ArrayList(struct { dist: usize, valve: []const u8 }).init(allocator);
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
        _ = cur_dists.swapRemove(valve.name);
        _ = cur_dists.swapRemove("AA");
        try valves_dists.put(valve.name, cur_dists);
    }
    visited.deinit();

    var indices = std.StringArrayHashMap(usize).init(allocator);
    defer indices.deinit();
    for (non_empty.items, 0..) |elem, i| {
        try indices.put(elem, i);
    }

    var memo = MemoMap.init(allocator);
    defer memo.deinit();
    var res: usize = 0;
    const bound = (@as(u64, 1) << @intCast(non_empty.items.len)) - 1;
    const limit: usize = @intCast((bound + 1) / 2);
    for (0..limit) |i| {
        const me = try calculate_max_flow(.{ .valve_index = 0, .remaining = 26, .opened = i }, valves_names.items, &indices, &valves, &valves_dists, &memo);
        const elephant = try calculate_max_flow(.{ .valve_index = 0, .remaining = 26, .opened = bound ^ i }, valves_names.items, &indices, &valves, &valves_dists, &memo);
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
