const std = @import("std");

const puzzle_input = @embedFile("./input.txt");
const example1 = @embedFile("example1.txt");
const example2 = @embedFile("example2.txt");

fn isDigit(c: u8) bool {
    return c >= '0' and c <= '9';
}

const State = union(enum) {
    invalid: void,
    m: void,
    mu: void,
    mul: void,
    @"mul(": struct {
        a: [3]u8 = [_]u8{0} ** 3,
        al: u2 = 0,
        sep: bool = false,
        b: [3]u8 = [_]u8{0} ** 3,
        bl: u2 = 0,
    },
};

const StateMachine = struct {
    validMuls: u64 = 0,
    state: State = State.invalid,

    pub fn feed(self: *StateMachine, input: u8) void {
        switch (self.state) {
            .invalid => {
                self.state = switch (input) {
                    'm' => .m,
                    else => .invalid,
                };
            },
            .m => {
                self.state = switch (input) {
                    'u' => .mu,
                    else => .invalid,
                };
            },
            .mu => {
                self.state = switch (input) {
                    'l' => .mul,
                    else => .invalid,
                };
            },
            .mul => {
                self.state = switch (input) {
                    '(' => .{ .@"mul(" = .{} },
                    else => .invalid,
                };
            },
            .@"mul(" => |*state| {
                if (input == ')') {
                    if (state.al == 0 or state.al > 3 or state.bl == 0 or state.bl > 3) {
                        self.state = .invalid;
                        return;
                    }

                    const a = std.fmt.parseInt(u64, state.a[0..state.al], 10) catch unreachable;
                    const b = std.fmt.parseInt(u64, state.b[0..state.bl], 10) catch unreachable;

                    self.validMuls += a * b;
                    self.state = .invalid;
                    return;
                }
                if (state.sep) {
                    if (input == ',') {
                        self.state = .invalid;
                        return;
                    }
                    if (isDigit(input)) {
                        if (state.bl == 3) {
                            self.state = .invalid;
                            return;
                        }
                        state.b[state.bl] = input;
                        state.bl += 1;
                        return;
                    } else self.state = .invalid;
                } else {
                    if (input == ',') {
                        if (state.al == 0) {
                            self.state = .invalid;
                            return;
                        }
                        state.sep = true;
                        return;
                    }
                    if (isDigit(input)) {
                        if (state.al == 3) {
                            self.state = .invalid;
                            return;
                        }
                        state.a[state.al] = input;
                        state.al += 1;
                        return;
                    } else self.state = .invalid;
                }
            },
        }
    }
};

pub fn one(input: []const u8) !u64 {
    var s: StateMachine = .{};
    for (input) |c| s.feed(c);
    return s.validMuls;
}

test "one" {
    try std.testing.expectEqual(161, one(example1));
}

const State2 = union(enum) {
    invalid: void,
    m: void,
    mu: void,
    mul: void,
    @"mul(": struct {
        a: [3]u8 = [_]u8{0} ** 3,
        al: u2 = 0,
        sep: bool = false,
        b: [3]u8 = [_]u8{0} ** 3,
        bl: u2 = 0,
    },

    d: void,
    do: void,
    don: void,
    @"don'": void,
    @"don't": void,
    @"don't(": void,

    @"do(": void,
};

const StateMachine2 = struct {
    validMuls: u64 = 0,
    mulsAllowed: bool = true,
    state: State2 = State2.invalid,

    pub fn feed(self: *StateMachine2, input: u8) void {
        switch (self.state) {
            .invalid => {
                self.state = switch (input) {
                    'm' => if (self.mulsAllowed) .m else .invalid,
                    'd' => .d,
                    else => .invalid,
                };
            },
            .m => {
                self.state = switch (input) {
                    'u' => .mu,
                    else => .invalid,
                };
            },
            .mu => {
                self.state = switch (input) {
                    'l' => .mul,
                    else => .invalid,
                };
            },
            .mul => {
                self.state = switch (input) {
                    '(' => .{ .@"mul(" = .{} },
                    else => .invalid,
                };
            },
            .@"mul(" => |*state| {
                if (input == ')') {
                    if (state.al == 0 or state.al > 3 or state.bl == 0 or state.bl > 3) {
                        self.state = .invalid;
                        return;
                    }

                    const a = std.fmt.parseInt(u64, state.a[0..state.al], 10) catch unreachable;
                    const b = std.fmt.parseInt(u64, state.b[0..state.bl], 10) catch unreachable;

                    self.validMuls += a * b;
                    self.state = .invalid;
                    return;
                }
                if (state.sep) {
                    if (input == ',') {
                        self.state = .invalid;
                        return;
                    }
                    if (isDigit(input)) {
                        if (state.bl == 3) {
                            self.state = .invalid;
                            return;
                        }
                        state.b[state.bl] = input;
                        state.bl += 1;
                        return;
                    } else self.state = .invalid;
                } else {
                    if (input == ',') {
                        if (state.al == 0) {
                            self.state = .invalid;
                            return;
                        }
                        state.sep = true;
                        return;
                    }
                    if (isDigit(input)) {
                        if (state.al == 3) {
                            self.state = .invalid;
                            return;
                        }
                        state.a[state.al] = input;
                        state.al += 1;
                        return;
                    } else self.state = .invalid;
                }
            },

            .d => {
                self.state = switch (input) {
                    'o' => .do,
                    else => .invalid,
                };
            },
            .do => {
                self.state = switch (input) {
                    'n' => .don,
                    '(' => .@"do(",
                    else => .invalid,
                };
            },
            .don => {
                self.state = switch (input) {
                    '\'' => .@"don'",
                    else => .invalid,
                };
            },
            .@"don'" => {
                self.state = switch (input) {
                    't' => .@"don't",
                    else => .invalid,
                };
            },
            .@"don't" => {
                self.state = switch (input) {
                    '(' => .@"don't(",
                    else => .invalid,
                };
            },
            .@"don't(" => {
                if (input == ')') self.mulsAllowed = false;
                self.state = .invalid;
            },
            .@"do(" => {
                if (input == ')') self.mulsAllowed = true;
                self.state = .invalid;
            },
        }
    }
};

pub fn two(input: []const u8) !u64 {
    var s: StateMachine2 = .{};
    for (input) |c| s.feed(c);
    return s.validMuls;
}

test "two" {
    try std.testing.expectEqual(48, two(example2));
}

pub fn main() !void {
    const out = std.io.getStdOut().writer();
    try out.print("Day 3\n", .{});
    try out.print("\t1: {any}\n", .{one(puzzle_input)});
    try out.print("\t2: {any}\n", .{two(puzzle_input)});
}
