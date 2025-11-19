const std = @import("std");
const rl = @import("raylib");

const World = @import("../World.zig");
const Position = @import("position.zig").Position;

const queryToRender = @import("utils.zig").queryToRender;

pub const Rectangle = struct {
    width: i32,
    height: i32,
    color: rl.Color,
};

pub fn render(w: *World, _: std.mem.Allocator) !void {
    const queries = (try queryToRender(w, &.{
        Position,
        Rectangle,
    })) orelse return;

    for (queries) |query| {
        const pos, const rec = query;
        rl.drawRectangle(
            pos.x,
            pos.y,
            rec.width,
            rec.height,
            rec.color,
        );
    }
}
