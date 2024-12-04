const std = @import("std");

const puzzle_input = @embedFile("./input.txt");
const example1 = @embedFile("example1.txt");
const example2 = @embedFile("example1.txt");

pub fn maybeGet(list: []const u8, i: usize) u8 {
    if (i < 0 or i >= list.len) return 0;
    return list[i];
}

pub fn one(input: []const u8) !u64 {
    var it = std.mem.splitScalar(u8, input, '\n');
    const width = it.next().?.len + 1;

    var start: usize = 0;
    var xs = std.ArrayList(usize).initCapacity(std.heap.c_allocator, 1000) catch unreachable;
    defer xs.deinit();
    while (std.mem.indexOfScalarPos(u8, input, start, 'X')) |pos| {
        xs.append(pos) catch unreachable;
        start = pos + 1;
    }

    var acc: u64 = 0;
    for (xs.items) |x| {
        var xms: [8][3]u8 = undefined;

        // left
        if (x % width > 2) {
            xms[0][0] = maybeGet(input, x - 1);
            xms[0][1] = maybeGet(input, x - 2);
            xms[0][2] = maybeGet(input, x - 3);
        }
        // right
        if (x % width < width - 4) {
            xms[1][0] = maybeGet(input, x + 1);
            xms[1][1] = maybeGet(input, x + 2);
            xms[1][2] = maybeGet(input, x + 3);
        }
        // top
        if (x / width > 2) {
            xms[2][0] = maybeGet(input, x - width * 1);
            xms[2][1] = maybeGet(input, x - width * 2);
            xms[2][2] = maybeGet(input, x - width * 3);
        }
        // bottom
        if (x / width < width - 4) {
            xms[3][0] = maybeGet(input, x + width * 1);
            xms[3][1] = maybeGet(input, x + width * 2);
            xms[3][2] = maybeGet(input, x + width * 3);
        }

        // diagonals

        // left top
        if (x % width > 2 and x / width > 2) {
            xms[4][0] = maybeGet(input, x - 1 - width * 1);
            xms[4][1] = maybeGet(input, x - 2 - width * 2);
            xms[4][2] = maybeGet(input, x - 3 - width * 3);
        }
        // right top
        if (x % width < width - 4 and x / width > 2) {
            xms[5][0] = maybeGet(input, x + 1 - width * 1);
            xms[5][1] = maybeGet(input, x + 2 - width * 2);
            xms[5][2] = maybeGet(input, x + 3 - width * 3);
        }
        // left bottom
        if (x % width > 2 and x / width < width - 4) {
            xms[6][0] = maybeGet(input, x - 1 + width * 1);
            xms[6][1] = maybeGet(input, x - 2 + width * 2);
            xms[6][2] = maybeGet(input, x - 3 + width * 3);
        }
        // right bottom
        if (x % width < width - 4 and x / width < width - 4) {
            xms[7][0] = maybeGet(input, x + 1 + width * 1);
            xms[7][1] = maybeGet(input, x + 2 + width * 2);
            xms[7][2] = maybeGet(input, x + 3 + width * 3);
        }

        for (xms) |row| {
            acc += @intFromBool(std.mem.eql(u8, &row, "MAS"));
        }
    }

    return acc;
}

test "one" {
    try std.testing.expectEqual(18, one(example1));
}

pub fn two(input: []const u8) !u64 {
    var it = std.mem.splitScalar(u8, input, '\n');
    const width = it.next().?.len + 1;

    var start: usize = 0;
    var as = std.ArrayList(usize).initCapacity(std.heap.c_allocator, 1000) catch unreachable;
    defer as.deinit();
    while (std.mem.indexOfScalarPos(u8, input, start, 'A')) |pos| {
        as.append(pos) catch unreachable;
        start = pos + 1;
    }

    var acc: u64 = 0;
    for (as.items) |x| {
        var ams: [4]u8 = undefined;
        if (x % width == 0 or x / width == 0 or x % width == width - 1 or x / width == width - 1) {
            continue;
        }
        ams[0] = maybeGet(input, x - width - 1);
        ams[1] = maybeGet(input, x - width + 1);
        ams[2] = maybeGet(input, x + width - 1);
        ams[3] = maybeGet(input, x + width + 1);

        if (std.mem.eql(u8, &ams, "MSMS") or std.mem.eql(u8, &ams, "SSMM") or std.mem.eql(u8, &ams, "SMSM") or std.mem.eql(u8, &ams, "MMSS")) {
            acc += 1;
        }
    }

    return acc;
}

test "two" {
    try std.testing.expectEqual(9, two(example2));
}

pub fn main() !void {
    const out = std.io.getStdOut().writer();
    try out.print("Day 4\n", .{});
    try out.print("\t1: {any}\n", .{one(puzzle_input)});
    try out.print("\t2: {any}\n", .{two(puzzle_input)});
}

test "refalldecls" {
    std.testing.refAllDecls(@This());
}
