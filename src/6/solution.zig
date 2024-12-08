const std = @import("std");

const puzzle_input = @embedFile("./input.txt");
const example1 = @embedFile("example1.txt");
const example2 = @embedFile("example1.txt");

const Position = packed struct(u8) {
    up: bool = false,
    right: bool = false,
    down: bool = false,
    left: bool = false,
    _: u1 = 0,
    fakeRock: bool = false,
    player: bool = false,
    rock: bool = false,

    const P = Position;

    pub fn toU8(self: P) u8 {
        return @bitCast(self);
    }

    pub fn fromU8(u: u8) P {
        return @bitCast(u);
    }

    pub fn isEmpty(self: P) bool {
        return self.toU8() == 0;
    }

    pub fn hasBits(self: P, bits: P) bool {
        return self.toU8() & bits.toU8() == bits.toU8();
    }

    pub fn markDirection(p: P, d: P) P {
        return .fromU8(p.toU8() | d.toU8());
    }

    pub fn rotateRight(pos: P) P {
        return if (pos.left) .{ .up = true } else .fromU8(pos.toU8() << 1);
    }

    pub fn next(pos: P, width: usize, cur: usize) usize {
        return switch (pos.toU8()) {
            P.toU8(.{ .up = true }) => cur - width,
            P.toU8(.{ .right = true }) => cur + 1,
            P.toU8(.{ .down = true }) => cur + width,
            P.toU8(.{ .left = true }) => cur - 1,
            else => unreachable,
        };
    }

    pub fn nextOutside(pos: P, width: usize, cur: usize) bool {
        return switch (pos.toU8()) {
            P.toU8(.{ .up = true }) => cur / width == 0,
            P.toU8(.{ .right = true }) => cur % width == width - 1,
            P.toU8(.{ .down = true }) => cur / width == width - 1,
            P.toU8(.{ .left = true }) => cur % width == 0,
            else => unreachable,
        };
    }

    pub fn toS(self: P) []const u8 {
        if (self.fakeRock) return "X";
        if (self.rock) return "■";
        if (self.player) return "▲";

        return switch (self.toU8()) {
            (P{}).toU8() => "·",
            (P{ .up = true }).toU8() => "↑",
            (P{ .right = true }).toU8() => "→",
            (P{ .down = true }).toU8() => "↓",
            (P{ .left = true }).toU8() => "←",

            else => "+",
        };
    }
};

fn prettyPrint(input: []const Position, comptime width: usize) void {
    for (0..width) |i| {
        for (0..width) |j| {
            std.debug.print("{s}", .{input[i * width + j].toS()});
        }
        std.debug.print("\n", .{});
    }
}

fn toPositions(comptime input: []const u8) [input.len - std.math.sqrt(input.len) + 1]Position {
    var out: [input.len - std.math.sqrt(input.len) + 1]Position = undefined;

    var i: usize = 0;
    for (input) |c| {
        if (c == '\n') continue;
        out[i] = switch (c) {
            '#' => .{ .rock = true },
            '^' => .{ .player = true },
            else => .{},
        };
        i += 1;
    }

    return out;
}

fn doesLoop(input: []Position, playerPos: usize, rotation: Position, comptime width: usize) bool {
    var pp = playerPos;
    var r = rotation;

    while (true) {
        if (input[pp].hasBits(r)) return true;
        input[pp] = input[pp].markDirection(r);
        if (r.nextOutside(width, pp)) return false;

        const np = r.next(width, pp);
        if (input[np].rock) {
            r = r.rotateRight();
        } else {
            pp = np;
        }
    }
}

pub fn one(comptime input: []const u8) !u64 {
    const width = comptime std.math.sqrt(input.len);
    var positions = toPositions(input);
    const playerStart = std.mem.indexOfScalar(Position, &positions, .{ .player = true }) orelse unreachable;

    _ = doesLoop(&positions, playerStart, .{ .up = true }, width);

    var acc: u64 = 0;
    for (positions) |p| {
        if (!p.rock and p.toU8() != 0) acc += 1;
    }

    return acc;
}

test "one" {
    try std.testing.expectEqual(41, one(example1));
}

pub fn two(comptime _input: []const u8) !u64 {
    const lineLen = comptime std.math.sqrt(_input.len);
    var in = toPositions(_input);
    var placedRocks: [in.len]bool = [_]bool{false} ** in.len;
    var pp = std.mem.indexOfScalar(Position, &in, .{ .player = true }) orelse unreachable;
    var r: Position = .{ .up = true };

    while (true) {
        in[pp] = in[pp].markDirection(r);

        if (r.nextOutside(lineLen, pp)) break;

        const np = r.next(lineLen, pp);

        if (in[np].rock) {
            r = r.rotateRight();
            continue;
        } else if (in[np].isEmpty()) {
            var copy = in;
            copy[np] = .{ .rock = true, .fakeRock = true };

            const d = doesLoop(&copy, pp, .rotateRight(r), lineLen) and !placedRocks[np];
            if (d) placedRocks[np] = true;
        }

        pp = np;
    }

    var acc: u64 = 0;
    for (placedRocks) |placed| {
        if (placed) acc += 1;
    }

    return acc;
}

test "two" {
    try std.testing.expectEqual(6, two(example2));
}

pub fn main() !void {
    const out = std.io.getStdOut().writer();
    try out.print("Day 6\n", .{});
    try out.print("\t1: {any}\n", .{one(puzzle_input)});
    try out.print("\t2: {any}\n", .{two(puzzle_input)});
}
