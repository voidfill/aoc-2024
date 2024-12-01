const std = @import("std");

const puzzle_input = @embedFile("./input.txt");
const example1 = @embedFile("example1.txt");
const example2 = @embedFile("example1.txt");

pub fn one(input: []const u8) !u8 {
    _ = input;
    return 1;
}

test "one" {
    try std.testing.expectEqual(1, one(example1));
}

pub fn two(input: []const u8) !u8 {
    _ = input;
    return 2;
}

test "two" {
    try std.testing.expectEqual(2, two(example2));
}

pub fn main() !void {
    const out = std.io.getStdOut().writer();
    try out.print("Day 0\n", .{});
    try out.print("\t1: {any}\n", .{one(puzzle_input)});
    try out.print("\t2: {any}\n", .{two(puzzle_input)});
}
