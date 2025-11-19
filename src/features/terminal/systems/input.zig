const std = @import("std");
const rl = @import("raylib");
const digger = @import("../../digger/mod.zig");

const World = @import("ecs").World;

pub fn scan(
    out: []u8,
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
    if ((rl.isKeyDown(.backspace)) and
        (count.* > 0) and
        ((std.time.microTimestamp() - ts_backspace.*) > @divTrunc(1000000, 10))) // 0.1s
    {
        ts_backspace.* = std.time.microTimestamp();
        count.* -= 1;
        out[@intCast(count.*)] = 0;
    }
}

pub fn process(w: *World, content: []const u8) !void {
    const action = try digger.action.parse(content);
    switch (action) {
        .move => |direction| try digger.action.control(w, direction),
    }
}
