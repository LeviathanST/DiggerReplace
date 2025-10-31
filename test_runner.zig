const std = @import("std");
const builtin = @import("builtin");

pub const std_options: std.Options = .{
    .log_level = .err,
};

pub fn main() !void {
    for (builtin.test_functions) |t| {
        t.func() catch |err| {
            std.debug.print("\x1b[1;31mFAILED:\x1b[1;0m {s} - \x1b[1;31m{}\x1b[1;0m\n", .{ t.name, err });
            continue;
        };
        std.debug.print("\x1b[1;32mPASSED:\x1b[1;0m {s}\n", .{t.name});
    }
}
