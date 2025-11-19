const std = @import("std");
const rl = @import("raylib");
const digger = @import("../../digger/mod.zig");

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
            const non_zero = skipLongestZero(out[0..@intCast(count_v)]) + 1;

            ts_backspace.* = std.time.microTimestamp();
            count.* -= blk: {
                if (count_v - non_zero != 0) {
                    break :blk count_v - non_zero;
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

/// returns the index of the first non-zero character in the loop
/// from the last index.
fn skipLongestZero(str: []const u8) i32 {
    var idx = str.len - 1;
    while (idx > 0) {
        if (str[idx] != 0) break;
        idx -= 1;
    }
    return @intCast(idx);
}

test "test" {
    const str1 = std.mem.zeroes([10]u8);
    try std.testing.expectEqual(0, skipLongestZero(&str1));

    var str2 = std.mem.zeroes([10]u8);
    str2[9] = 'A';
    try std.testing.expectEqual(9, skipLongestZero(&str2));

    var str3 = std.mem.zeroes([10]u8);
    str3[6] = 'A';
    try std.testing.expectEqual(6, skipLongestZero(&str3));
}

pub fn process(w: *World, content: []const u8) !void {
    // TODO: handle error
    const action = try digger.action.parse(content);
    switch (action) {
        .move => |direction| try digger.action.control(w, direction),
    }
}
