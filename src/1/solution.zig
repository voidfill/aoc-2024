const std = @import("std");

const puzzle_input = @embedFile("./input.txt");
const example1 = @embedFile("example1.txt");
const example2 = @embedFile("example1.txt");

// basically bubble sort, we end up with a list filled with max int values
fn lowest(list: []u32, startAt: u32) u32 {
    var min: u32 = std.math.maxInt(u32);

    for (list[startAt..]) |*item| {
        if (item.* < min) {
            std.mem.swap(u32, &min, item);
        }
    }

    return min;
}

pub fn one(input: []const u8) !u32 {
    var it = std.mem.splitScalar(u8, input, '\n');

    var left = std.ArrayList(u32).init(std.heap.page_allocator);
    var right = std.ArrayList(u32).init(std.heap.page_allocator);

    try left.ensureTotalCapacity(1000); // default input size
    try right.ensureTotalCapacity(1000);
    defer {
        left.deinit();
        right.deinit();
    }

    while (it.next()) |line| {
        try left.append(try std.fmt.parseInt(u32, line[0 .. line.len / 2 - 1], 10));
        try right.append(try std.fmt.parseInt(u32, line[line.len / 2 + 2 .. line.len], 10));
    }

    var total: u32 = 0;

    for (0..left.items.len) |i| {
        const ll = lowest(left.items, @intCast(i));
        const rl = lowest(right.items, @intCast(i));

        total += if (ll < rl) rl - ll else ll - rl;
    }

    return total;
}

test "one" {
    try std.testing.expectEqual(11, one(example1));
}

fn occurences(list: []u32, value: u32) u32 {
    var count: u32 = 0;

    for (list) |item| {
        if (item == value) {
            count += 1;
        }
    }

    return count;
}

pub fn two(input: []const u8) !u32 {
    var it = std.mem.splitScalar(u8, input, '\n');

    var left = std.ArrayList(u32).init(std.heap.page_allocator);
    var right = std.ArrayList(u32).init(std.heap.page_allocator);

    try left.ensureTotalCapacity(1000); // default input size
    try right.ensureTotalCapacity(1000);
    defer {
        left.deinit();
        right.deinit();
    }

    while (it.next()) |line| {
        try left.append(try std.fmt.parseInt(u32, line[0 .. line.len / 2 - 1], 10));
        try right.append(try std.fmt.parseInt(u32, line[line.len / 2 + 2 .. line.len], 10));
    }

    var total: u32 = 0;

    for (left.items) |ll| {
        total += ll * occurences(right.items, ll);
    }

    return total;
}

test "two" {
    try std.testing.expectEqual(31, two(example2));
}

pub fn main() !void {
    const out = std.io.getStdOut().writer();
    try out.print("Day 1\n", .{});
    try out.print("\t1: {any}\n", .{one(puzzle_input)});
    try out.print("\t2: {any}\n", .{two(puzzle_input)});
}
