const std = @import("std");

const puzzle_input = @embedFile("./input.txt");
const example1 = @embedFile("example1.txt");
const example2 = @embedFile("example1.txt");

const parseInt = std.fmt.parseInt;

var mem = [_]i8{0} ** 10;
var mem2 = [_]i8{0} ** 10;

fn parseInts(line: []const u8) []const i8 {
    var it = std.mem.splitScalar(u8, line, ' ');

    var i: u8 = 0;
    while (it.next()) |n| {
        mem[i] = parseInt(i8, n, 10) catch unreachable;
        i += 1;
    }

    return mem[0..i];
}

fn isLineSafe(nums: []const i8) bool {
    const first = nums[0];
    var pre = nums[1];
    const up = if (pre > first) true else false;

    if (pre == first) return false;
    if (up and (pre < first or pre > first + 3)) return false;
    if (!up and (pre > first or pre < first - 3)) return false;

    for (nums[2..]) |n| {
        if (n == pre) return false;
        if (up and (n < pre or n > pre + 3)) return false;
        if (!up and (n > pre or n < pre - 3)) return false;
        pre = n;
    }

    return true;
}

pub fn one(input: []const u8) !u64 {
    var acc: u64 = 0;

    var it = std.mem.splitScalar(u8, input, '\n');
    while (it.next()) |line| {
        acc += @intFromBool(isLineSafe(parseInts(line)));
    }

    return acc;
}

test "one" {
    try std.testing.expectEqual(2, one(example1));
}

fn isLineSafe2(nums: []const i8) bool {
    if (isLineSafe(nums)) return true;

    for (0..nums.len) |i| {
        var j: u8 = 0;
        for (0..nums.len) |k| {
            mem2[j] = nums[k];
            if (i != k) j += 1;
        }

        if (isLineSafe(mem2[0 .. nums.len - 1])) return true;
    }

    return false;
}

pub fn two(input: []const u8) !u64 {
    var acc: u64 = 0;

    var it = std.mem.splitScalar(u8, input, '\n');
    while (it.next()) |line| {
        acc += @intFromBool(isLineSafe2(parseInts(line)));
    }

    return acc;
}

test "two" {
    try std.testing.expectEqual(4, two(example2));
}

pub fn main() !void {
    const out = std.io.getStdOut().writer();
    try out.print("Day 2\n", .{});
    try out.print("\t1: {any}\n", .{one(puzzle_input)});
    try out.print("\t2: {any}\n", .{two(puzzle_input)});
}
