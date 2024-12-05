const std = @import("std");

const puzzle_input = @embedFile("./input.txt");
const example1 = @embedFile("example1.txt");
const example2 = @embedFile("example1.txt");

const ar = struct {
    arr: [100]u8 = [_]u8{0} ** 100,
    len: u8 = 0,

    pub fn push(self: *ar, to: u8) void {
        for (self.arr[0..self.len]) |num| {
            if (num == to) return;
        }
        self.arr[self.len] = to;
        self.len += 1;
    }

    pub fn slice(self: *ar) []u8 {
        return self.arr[0..self.len];
    }
};

pub fn one(input: []const u8) !u64 {
    var backwards = [_]ar{.{}} ** 100;

    const manualStart = std.mem.indexOf(u8, input, "\n\n") orelse unreachable;

    var itOrders = std.mem.splitScalar(u8, input[0..manualStart], '\n');
    while (itOrders.next()) |line| {
        const n1 = std.fmt.parseInt(u8, line[0..2], 10) catch unreachable;
        const n2 = std.fmt.parseInt(u8, line[3..5], 10) catch unreachable;
        backwards[n2].push(n1);
    }

    var acc: u64 = 0;

    var itManuals = std.mem.splitScalar(u8, input[manualStart + 2 ..], '\n');
    outer: while (itManuals.next()) |line| {
        const middlePageIndex = line.len / 6;
        var notAllowedNums: ar = .{};
        var middlePageNum: u8 = 0;

        var itPages = std.mem.splitScalar(u8, line, ',');
        var i: u8 = 0;
        while (itPages.next()) |page| {
            const pageNum = std.fmt.parseInt(u8, page, 10) catch unreachable;

            for (notAllowedNums.slice()) |num| if (num == pageNum) continue :outer;
            for (backwards[pageNum].slice()) |num| notAllowedNums.push(num);

            if (i == middlePageIndex) middlePageNum = pageNum;
            i += 1;
        }

        acc += middlePageNum;
    }

    return acc;
}

test "one" {
    try std.testing.expectEqual(143, one(example1));
}

pub fn two(input: []const u8) !u64 {
    _ = input;
    return 2;
}

test "two" {
    try std.testing.expectEqual(2, two(example2));
}

pub fn main() !void {
    const out = std.io.getStdOut().writer();
    try out.print("Day 5\n", .{});
    try out.print("\t1: {any}\n", .{one(puzzle_input)});
    try out.print("\t2: {any}\n", .{two(puzzle_input)});
}
