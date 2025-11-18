const std = @import("std");
const rl = @import("raylib");

const World = @import("World.zig");

pub const CommonModule = struct {
    pub fn build(w: *World) void {
        _ = w.addSystems(.update, &.{
            renderRectangle,
            renderButton,
        });
    }
};

pub const Position = struct {
    x: i32,
    y: i32,
};

pub const Rectangle = struct {
    width: i32,
    height: i32,
    color: rl.Color,
};

pub fn renderRectangle(w: *World, _: std.mem.Allocator) !void {
    const queries = w.query(&.{
        Position,
        Rectangle,
    }) catch return;

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

pub const Button = struct {
    content: [:0]const u8,
    font: rl.Font,
};

pub fn renderButton(w: *World, _: std.mem.Allocator) !void {
    const queries = w.query(&.{
        Position,
        Rectangle,
        Button,
    }) catch return;
    const pos, const rec, const btn = queries[0];

    const measure_text = rl.measureTextEx(btn.font, btn.content, 20, 1);
    const text_x = pos.x + @divTrunc((rec.width - @as(i32, @intFromFloat(measure_text.x))), 2);
    const text_y = pos.y + @divTrunc((rec.height - @as(i32, @intFromFloat(measure_text.y))), 2);

    // draw the title
    rl.drawTextEx(
        btn.font,
        btn.content,
        .{ .x = @floatFromInt(text_x), .y = @floatFromInt(text_y) },
        20,
        1,
        .black,
    );
}
