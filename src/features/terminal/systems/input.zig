const std = @import("std");
const rl = @import("raylib");
const digger = @import("../../digger/mod.zig");
const interpreter = @import("../../interpreter/mod.zig");

const World = @import("ecs").World;

pub fn scan(
    out: []u8,
    width: i32,
    count: *i32,
    max_length: i32,
    ts_backspace: *i64,
) !void {
    var keyInt = rl.getCharPressed();

    while (keyInt != 0) : (keyInt = rl.getCharPressed()) {
        // allow range 32..127 chars in unicode
        if ((keyInt >= 32) and (keyInt < 127) and count.* < max_length) {
            count.* += 1;
            out[@intCast(count.* - 1)] = @intCast(keyInt);
        }
    }

    // handle key holding
    if ((std.time.microTimestamp() - ts_backspace.*) > @divTrunc(1000000, 10)) // 0.1s
    {
        if (rl.isKeyDown(.backspace) and
            (count.* > 0))
        {
            const count_v = count.*;
            // NOTE: remove the space of `ENTER`
            const count_zero = countZero(out[0..@intCast(count_v)]);

            ts_backspace.* = std.time.microTimestamp();
            count.* -= blk: {
                if (count_zero != 0) {
                    break :blk count_zero;
                } else {
                    break :blk 1;
                }
            };
            out[@intCast(count.*)] = 0;
        }

        if (rl.isKeyDown(.enter)) {
            ts_backspace.* = std.time.microTimestamp();
            const remaning_to_new_line = width - @mod(count.*, width);
            count.* += remaning_to_new_line;
        }
    }
}

/// returns amount of zero in the loop from the end.
fn countZero(str: []const u8) i32 {
    var idx: isize = @intCast(str.len - 1);
    var count: i32 = 0;
    while (idx >= 0) {
        if (str[@intCast(idx)] != 0) break;
        idx -= 1;
        count += 1;
    }
    return count;
}

test "test" {
    const str1 = std.mem.zeroes([10]u8);
    try std.testing.expectEqual(10, countZero(&str1));

    var str2 = std.mem.zeroes([10]u8);
    str2[9] = 'A';
    try std.testing.expectEqual(0, countZero(&str2));

    var str3 = std.mem.zeroes([10]u8);
    str3[6] = 'A';
    try std.testing.expectEqual(3, countZero(&str3));
}

pub fn process(w: *World, alloc: std.mem.Allocator, content: [:0]const u8) !void {
    // TODO: handle error
    const action = try interpreter.parse(alloc, content, .plaintext);
    switch (action) {
        .move => |direction| try digger.action.control(w, direction),
    }
}
