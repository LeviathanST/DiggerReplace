const std = @import("std");
const rl = @import("raylib");
const components = @import("components.zig");

const World = @import("ecs").World;
const Position = @import("ecs").common.Position;
const DebugBox = components.DebugBox;
const DebugInfo = components.DebugInfo;

pub fn updateInfo(w: *World, _: std.mem.Allocator) !void {
    const query = (try w.query(&.{*DebugInfo}))[0];
    const info = query[0];

    const rusage = std.posix.getrusage(0);
    info.*.memory_usage = @as(i32, @intCast(rusage.maxrss));
}

pub fn render(w: *World, _: std.mem.Allocator) !void {
    const queries = try w.query(&.{ DebugBox, DebugInfo });

    for (queries) |q| {
        const box, const info = q;

        box.draw(&.{
            "Memory usage",
        }, .{
            info.memory_usage,
        });
    }
}
