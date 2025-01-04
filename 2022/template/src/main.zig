const std = @import("std");
const fs = std.fs;
const dotenv = @import("dotenv");

pub fn main() !void {
    // var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    // defer _ = gpa.deinit();

    const allocator = std.heap.page_allocator;

    try dotenv.load(allocator, .{});
    const env_map = try std.process.getEnvMap(allocator);

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);
    if (args.len < 2) {
        std.debug.print("Please provide a day\n", .{});
    }

    const day_str = args[1];
    const day = try std.fmt.parseInt(usize, day_str, 10);
    const day_folder = try std.fmt.allocPrint(
        allocator,
        "day{d:0>2}",
        .{day},
    );
    defer allocator.free(day_folder);

    fs.cwd().makeDir(day_folder) catch {};
    var day_dir = try fs.cwd().openDir(day_folder, .{});
    defer day_dir.close();

    var template_dir = try fs.cwd().openDir("template/src/template", .{ .iterate = true });
    defer template_dir.close();

    var walk = try template_dir.walk(allocator);
    defer walk.deinit();
    while (true) {
        const entry_option = try walk.next();
        if (entry_option == null) break;
        const entry = entry_option.?;
        if (entry.path[0] == '.') continue;
        if (entry.kind == .file) {
            try template_dir.copyFile(entry.path, day_dir, entry.path, .{});
        } else if (entry.kind == .directory) {
            day_dir.makeDir(entry.path) catch {};
        }
    }

    // Create a HTTP client
    var client = std.http.Client{ .allocator = allocator };
    defer client.deinit();

    // Allocate a buffer for server headers
    var buf: [4096]u8 = undefined;

    // Start the HTTP request
    const input_url = try std.fmt.allocPrint(
        allocator,
        "https://adventofcode.com/2022/day/{d}/input",
        .{day},
    );
    defer allocator.free(input_url);
    const uri = try std.Uri.parse(input_url);
    const session_id = env_map.get("SESSION_ID");
    if (session_id == null) return;
    const cookies = try std.fmt.allocPrint(
        allocator,
        "session={s}",
        .{session_id.?},
    );
    var req = try client.open(.GET, uri, .{
        .server_header_buffer = &buf,
        .extra_headers = &.{
            .{ .name = "cookie", .value = cookies },
        },
    });
    defer req.deinit();
    // Send the HTTP request headers
    try req.send();
    // Finish the body of a request
    try req.finish();
    // Waits for a response from the server and parses any headers that are sent
    try req.wait();

    if (req.response.status == .ok) {
        const body = try req.reader().readAllAlloc(allocator, 4096 * 1024);
        defer allocator.free(body);
        const input_file = try day_dir.createFile("input.txt", .{});
        // const input_file = try day_dir.openFile("input", .{ .mode = .write_only });
        defer input_file.close();
        const n = try input_file.write(body);
        std.debug.print("input.txt: {d} bytes\n", .{n});
    }
}
