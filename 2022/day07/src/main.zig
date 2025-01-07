const std = @import("std");
const Allocator = std.mem.Allocator;
const fs = std.fs;

fn read_input(input_file_name: []const u8, allocator: Allocator) ![]u8 {
    const input_file = try fs.cwd().openFile(input_file_name, .{});
    defer input_file.close();
    return input_file.readToEndAlloc(allocator, 4 * 1024 * 1024);
}

const EntryType = enum { file, dir };

const Size = usize;

const File = struct {
    name: []const u8,
    size: Size,
};

const Dir = struct {
    const Self = @This();
    const Entry = union(EntryType) {
        file: File,
        dir: *Self,
    };
    const Entries = std.StringHashMap(Entry);
    name: []const u8,
    parent: ?*Self,
    entries: Entries,
    size: Size = 0,
    allocator: Allocator,

    pub fn create(allocator: Allocator, name: []const u8, parent: ?*Self) !*Self {
        const dir_ptr = try allocator.create(Dir);
        dir_ptr.name = name;
        dir_ptr.parent = parent;
        dir_ptr.entries = Entries.init(allocator);
        dir_ptr.allocator = allocator;
        dir_ptr.size = 0;
        return dir_ptr;
    }
    pub fn deinit(self: Self) void {
        self.entries.deinit();
    }
};

fn get_size(dir: *Dir, seen: *std.StringHashMap(Size)) !Size {
    if (seen.contains(dir.name)) {
        return seen.get(dir.name).?;
    }
    var iter = dir.entries.iterator();
    var size: Size = 0;
    while (iter.next()) |entry| {
        switch (entry.value_ptr.*) {
            .dir => |d| size += try get_size(d, seen),
            .file => |file| size += file.size,
        }
    }
    try seen.put(dir.name, size);
    return size;
}

fn print_indent(indent: usize) void {
    for (0..indent * 2) |_| {
        std.debug.print(" ", .{});
    }
}

fn print_dir(dir: *Dir, indent: usize) void {
    print_indent(indent);
    std.debug.print("- {s} (dir)\n", .{dir.name});
    var iter = dir.entries.iterator();
    while (iter.next()) |entry| {
        switch (entry.value_ptr.*) {
            .dir => |d| print_dir(d, indent + 1),
            .file => |*file| {
                print_indent(indent + 1);
                std.debug.print("- {s} (file, size={})\n", .{ file.name, file.size });
            },
        }
    }
}

fn part1(input_file_name: []const u8) !void {
    const allocator = std.heap.page_allocator;
    const input = std.mem.trim(u8, try read_input(input_file_name, allocator), "\n");
    const root = try Dir.create(allocator, "/", null);
    var lines = std.mem.split(u8, input, "\n");
    _ = lines.next(); // $ cd /
    var cur_dir: *Dir = root;
    while (lines.next()) |line| {
        if (line.ptr[0] == '$') {
            var tokens = std.mem.split(u8, line, " ");
            _ = tokens.next(); // $
            const cmd = tokens.next().?;
            if (cmd.ptr[0] == 'c') {
                //cd
                const new_dir = tokens.next().?;
                if (new_dir.ptr[0] == '.') {
                    cur_dir = cur_dir.parent.?;
                } else {
                    cur_dir = cur_dir.entries.get(new_dir).?.dir;
                }
            } else {
                //ls
                while (lines.peek() != null and lines.peek().?.ptr[0] != '$') {
                    var tokens_ = std.mem.split(u8, lines.next().?, " ");
                    const dir_or_size = tokens_.next().?;
                    const entry_name = tokens_.next().?;
                    if (dir_or_size.ptr[0] == 'd') {
                        const abs_path = try std.mem.join(allocator, "/", &[_][]const u8{ cur_dir.name, entry_name });
                        const newdir = try Dir.create(allocator, abs_path, cur_dir);
                        try cur_dir.entries.put(entry_name, Dir.Entry{ .dir = newdir });
                    } else {
                        const size = try std.fmt.parseInt(u64, dir_or_size, 10);
                        try cur_dir.entries.put(entry_name, Dir.Entry{ .file = File{ .name = entry_name, .size = size } });
                    }
                }
            }
        }
    }

    var dirs = std.StringHashMap(Size).init(allocator);
    const root_size = try get_size(root, &dirs);

    var res1: Size = 0;
    var res2: Size = std.math.maxInt(Size);
    const total_disk_available: Size = 70000000;
    const free_space_needed: Size = 30000000;
    const free_space_needed_remaining = free_space_needed - (total_disk_available - root_size);

    var dir_iters = dirs.iterator();
    while (dir_iters.next()) |dir_entry| {
        const dir = dir_entry.value_ptr.*;
        if (dir <= 100000) {
            res1 += dir;
        }
        if (dir >= free_space_needed_remaining) {
            res2 = @min(res2, dir);
        }
    }

    std.debug.print("Part 1: {}\n", .{res1});
    std.debug.print("Part 2: {}\n", .{res2});
}

pub fn main() !void {
    // const input_file = "sample.txt";
    const input_file = "input.txt";
    try part1(input_file);
}
