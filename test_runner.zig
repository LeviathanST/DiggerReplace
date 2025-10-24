const std = @import("std");
const builtin = @import("builtin");

pub const std_options: std.Options = .{
    .log_level = .err,
};

pub fn main() !void {
    for (builtin.test_functions) |t| {
        t.func() catch |err| {
            std.debug.print("{s} fail: {}\n", .{ t.name, err });
            continue;
        };
        std.debug.print("{s} passed\n", .{t.name});
    }
}
