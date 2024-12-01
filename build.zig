const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{ .preferred_optimize_mode = .ReleaseFast });
    const day = b.option([]const u8, "day", "Day to run");

    const run_step = b.step("run", "Run the solution");
    const test_step = b.step("test", "Run the example inputs");

    var src_dir = try b.build_root.handle.openDir("src", .{ .iterate = true });
    defer src_dir.close();

    var iter = src_dir.iterate();
    while (try iter.next()) |entry| {
        if (day) |d| {
            if (!std.mem.eql(u8, entry.name, d)) continue;
        } else if (std.mem.eql(u8, entry.name, "0")) {
            continue;
        }

        const sub_path = try std.fmt.allocPrint(b.allocator, "src/{s}/solution.zig", .{entry.name});

        const exe = b.addExecutable(.{
            .name = entry.name,
            .root_source_file = .{ .src_path = .{ .owner = b, .sub_path = sub_path } },
            .target = target,
            .optimize = optimize,
        });
        const run_exe = b.addRunArtifact(exe);
        run_step.dependOn(&run_exe.step);

        const unit_tests = b.addTest(.{
            .name = entry.name,
            .root_source_file = .{ .src_path = .{ .owner = b, .sub_path = sub_path } },
            .target = target,
            .optimize = optimize,
        });
        const run_unit_tests = b.addRunArtifact(unit_tests);
        test_step.dependOn(&run_unit_tests.step);
    }
}
