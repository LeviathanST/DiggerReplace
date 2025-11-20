const std = @import("std");
const rl = @import("raylib");
const digger = @import("../../digger/mod.zig");
const interpreter = @import("../../interpreter/mod.zig");
const utils = @import("../utils.zig");

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
            const count_zero = utils.skipChar(out[0..@intCast(count_v)], &[_]u8{0});
            const count_cr = utils.skipChar(out[0..@intCast(count_v - count_zero)], "\r");

            ts_backspace.* = std.time.microTimestamp();
            count.* -= blk: {
                if (count_zero != 0 or count_cr != 0) {
                    break :blk count_zero + count_cr;
                } else {
                    break :blk 1;
                }
            };
            out[@intCast(count.*)] = 0;
        }

        if (rl.isKeyDown(.enter)) {
            ts_backspace.* = std.time.microTimestamp();
            const remaning_to_new_line = width - @mod(count.*, width);
            out[@intCast(count.*)] = '\r';
            count.* += remaning_to_new_line;
        }
    }
}

pub fn process(w: *World, alloc: std.mem.Allocator, content: [:0]const u8) !void {
    std.log.debug("Input: {s}", .{content});
    // TODO: handle error
    if (try interpreter.parse(alloc, content, .zig)) |action| {
        switch (action) {
            .move => |direction| try digger.action.control(w, direction),
        }
    }
}
