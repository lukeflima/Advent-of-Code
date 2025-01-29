const std = @import("std");
const Allocator = std.mem.Allocator;
const fs = std.fs;

const Cost = struct {
    ore: usize = 0,
    clay: usize = 0,
    obsidian: usize = 0,
};

const State = struct {
    ore: usize = 0,
    clay: usize = 0,
    obsidian: usize = 0,
    geode: usize = 0,
    ore_robots: usize = 1,
    clay_robots: usize = 0,
    obsidian_robots: usize = 0,
    geode_robots: usize = 0,
    minute: usize,
};

const Blueprint = struct {
    id: usize,
    ore_robot: Cost,
    clay_robot: Cost,
    obsidian_robot: Cost,
    geode_robot: Cost,
    max_ore_robots: usize,
    max_clay_robots: usize,
    max_obsidian_robots: usize,
};
fn compara_state(_: void, a: State, b: State) std.math.Order {
    const geode_order = std.math.order(b.geode, a.geode);
    return geode_order;
}

fn read_input(input_file_name: []const u8, allocator: Allocator) ![]u8 {
    const input_file = try fs.cwd().openFile(input_file_name, .{});
    defer input_file.close();
    return input_file.readToEndAlloc(allocator, 4 * 1024 * 1024);
}

fn get_next_number(iter: *std.mem.SplitIterator(u8, .sequence)) !usize {
    while (iter.next()) |token| {
        var all_digit = true;
        for (token) |c| {
            if (c < '0' or c > '9') {
                all_digit = false;
                break;
            }
        }
        if (all_digit) return try std.fmt.parseInt(usize, token, 10);
    }
    return error{NoNextNumber}.NoNextNumber;
}

fn can_fabricate(state: State, cost: Cost) bool {
    return state.ore >= cost.ore and state.clay >= cost.clay and state.obsidian >= cost.obsidian;
}

fn solve(state: State, blueprint: Blueprint, cache: *std.AutoHashMap(State, usize), max_geode_minute: *std.AutoHashMap(usize, usize)) !usize {
    if (cache.contains(state)) return cache.get(state).?;
    const max_geode_min = max_geode_minute.get(state.minute) orelse 0;
    try max_geode_minute.put(state.minute, @max(state.geode, max_geode_min));
    var max_geode: usize = 0;

    var updated_state = state;
    updated_state.ore += state.ore_robots;
    updated_state.clay += state.clay_robots;
    updated_state.obsidian += state.obsidian_robots;
    updated_state.geode += state.geode_robots;

    if (updated_state.geode < max_geode_min) return max_geode_min;

    updated_state.minute -= 1;

    if (updated_state.minute < 1) {
        return updated_state.geode;
    }

    var geode_robot_produced = false;
    var obsidian_robot_produced = false;
    var clay_robot_produced = false;
    var ore_robot_produced = false;
    if (can_fabricate(state, blueprint.geode_robot)) {
        const cost = blueprint.geode_robot;
        var new_state = updated_state;
        new_state.ore -= cost.ore;
        new_state.clay -= cost.clay;
        new_state.obsidian -= cost.obsidian;
        new_state.geode_robots += 1;
        max_geode = @max(max_geode, try solve(new_state, blueprint, cache, max_geode_minute));
        geode_robot_produced = true;
    }
    if (!geode_robot_produced) {
        if (state.obsidian_robots < blueprint.max_obsidian_robots and can_fabricate(state, blueprint.obsidian_robot)) {
            const cost = blueprint.obsidian_robot;
            var new_state = updated_state;
            new_state.ore -= cost.ore;
            new_state.clay -= cost.clay;
            new_state.obsidian -= cost.obsidian;
            new_state.obsidian_robots += 1;
            max_geode = @max(max_geode, try solve(new_state, blueprint, cache, max_geode_minute));
            obsidian_robot_produced = true;
        }
        if (state.clay_robots < blueprint.max_clay_robots and can_fabricate(state, blueprint.clay_robot)) {
            const cost = blueprint.clay_robot;
            var new_state = updated_state;
            new_state.ore -= cost.ore;
            new_state.clay -= cost.clay;
            new_state.obsidian -= cost.obsidian;
            new_state.clay_robots += 1;
            max_geode = @max(max_geode, try solve(new_state, blueprint, cache, max_geode_minute));
            clay_robot_produced = true;
        }
        if (state.ore_robots < blueprint.max_ore_robots and can_fabricate(state, blueprint.ore_robot)) {
            const cost = blueprint.ore_robot;
            var new_state = updated_state;
            new_state.ore -= cost.ore;
            new_state.clay -= cost.clay;
            new_state.obsidian -= cost.obsidian;
            new_state.ore_robots += 1;
            max_geode = @max(max_geode, try solve(new_state, blueprint, cache, max_geode_minute));
            ore_robot_produced = true;
        }
        var consider = true;
        if (state.clay_robots == 0 and ore_robot_produced and clay_robot_produced) consider = false;
        if (state.obsidian_robots == 0 and ore_robot_produced and clay_robot_produced and obsidian_robot_produced) consider = false;
        if (ore_robot_produced and clay_robot_produced and obsidian_robot_produced and geode_robot_produced) consider = false;

        if (consider) max_geode = @max(max_geode, try solve(updated_state, blueprint, cache, max_geode_minute));
    }

    try cache.put(state, max_geode);
    return max_geode;
}

fn part1(input_file_name: []const u8) !void {
    var general_purpose_allocator = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = general_purpose_allocator.allocator();
    const input = std.mem.trim(u8, try read_input(input_file_name, allocator), "\n");
    defer allocator.free(input);

    var lines = std.mem.split(u8, input, "\n");
    var res: usize = 0;
    while (lines.next()) |line| {
        var parts = std.mem.split(u8, line, ": ");
        const blueprint_id = try std.fmt.parseInt(usize, parts.next().?[10..], 10);
        var tokens = std.mem.split(u8, parts.next().?, " ");
        const ore_robot = Cost{ .ore = try get_next_number(&tokens) };
        const clay_robot = Cost{ .ore = try get_next_number(&tokens) };
        const obsidian_robot = Cost{
            .ore = try get_next_number(&tokens),
            .clay = try get_next_number(&tokens),
        };
        const geode_robot = Cost{
            .ore = try get_next_number(&tokens),
            .obsidian = try get_next_number(&tokens),
        };
        const max_ore_robots = @max(ore_robot.ore, @max(clay_robot.ore, @max(obsidian_robot.ore, geode_robot.ore)));
        const max_clay_robots = @max(ore_robot.clay, @max(clay_robot.clay, @max(obsidian_robot.clay, geode_robot.clay)));
        const max_obsidian_robots = @max(ore_robot.obsidian, @max(clay_robot.obsidian, @max(obsidian_robot.obsidian, geode_robot.obsidian)));

        const blueprint = Blueprint{
            .id = blueprint_id,
            .ore_robot = ore_robot,
            .clay_robot = clay_robot,
            .obsidian_robot = obsidian_robot,
            .geode_robot = geode_robot,
            .max_ore_robots = max_ore_robots,
            .max_clay_robots = max_clay_robots,
            .max_obsidian_robots = max_obsidian_robots,
        };
        var cache = std.AutoHashMap(State, usize).init(allocator);
        defer cache.deinit();

        var max_geode_minute = std.AutoHashMap(usize, usize).init(allocator);
        defer max_geode_minute.deinit();
        const max_geode = try solve(.{ .minute = 24 }, blueprint, &cache, &max_geode_minute);
        const quality = max_geode * blueprint_id;
        // std.debug.print("Blueprint {d}: {d}\n", .{ blueprint_id, quality });
        res += quality;
    }

    std.debug.print("Part 1: {d}\n", .{res});
}

fn part2(input_file_name: []const u8) !void {
    var general_purpose_allocator = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = general_purpose_allocator.allocator();
    const input = std.mem.trim(u8, try read_input(input_file_name, allocator), "\n");
    defer allocator.free(input);
    var lines = std.mem.split(u8, input, "\n");
    var res: usize = 1;
    var i: usize = 0;
    while (lines.next()) |line| {
        defer i += 1;
        if (i == 3) break;
        var parts = std.mem.split(u8, line, ": ");
        const blueprint_id = try std.fmt.parseInt(usize, parts.next().?[10..], 10);
        var tokens = std.mem.split(u8, parts.next().?, " ");
        const ore_robot = Cost{ .ore = try get_next_number(&tokens) };
        const clay_robot = Cost{ .ore = try get_next_number(&tokens) };
        const obsidian_robot = Cost{
            .ore = try get_next_number(&tokens),
            .clay = try get_next_number(&tokens),
        };
        const geode_robot = Cost{
            .ore = try get_next_number(&tokens),
            .obsidian = try get_next_number(&tokens),
        };
        const max_ore_robots = @max(ore_robot.ore, @max(clay_robot.ore, @max(obsidian_robot.ore, geode_robot.ore)));
        const max_clay_robots = @max(ore_robot.clay, @max(clay_robot.clay, @max(obsidian_robot.clay, geode_robot.clay)));
        const max_obsidian_robots = @max(ore_robot.obsidian, @max(clay_robot.obsidian, @max(obsidian_robot.obsidian, geode_robot.obsidian)));

        const blueprint = Blueprint{
            .id = blueprint_id,
            .ore_robot = ore_robot,
            .clay_robot = clay_robot,
            .obsidian_robot = obsidian_robot,
            .geode_robot = geode_robot,
            .max_ore_robots = max_ore_robots,
            .max_clay_robots = max_clay_robots,
            .max_obsidian_robots = max_obsidian_robots,
        };
        var cache = std.AutoHashMap(State, usize).init(allocator);
        defer cache.deinit();
        var max_geode_minute = std.AutoHashMap(usize, usize).init(allocator);
        defer max_geode_minute.deinit();
        const max_geode = try solve(.{ .minute = 32 }, blueprint, &cache, &max_geode_minute);
        // std.debug.print("Blueprint {d}: {d}\n", .{ blueprint_id, max_geode });
        res *= max_geode;
    }

    std.debug.print("Part 2: {d}\n", .{res});
}

pub fn main() !void {
    // const input_file = "sample.txt";
    const input_file = "input.txt";
    try part1(input_file);
    try part2(input_file);
}
