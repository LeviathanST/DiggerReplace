const std = @import("std");
const rl = @import("raylib");
const World = @import("ecs.zig").World;

const Config = @import("Config.zig");
const Grid = @import("common_types.zig").Grid;

pub fn draw(w: World) !void {
    const grid = try w.getComponent(0, Grid);

    for (grid.matrix, 0..) |cell, i| {
        rl.drawRectangle(
            @intCast(cell.x),
            @intCast(cell.y),
            @intCast(cell.width),
            @intCast(cell.width),
            .blue,
        );

        rl.drawText(
            rl.textFormat("%d", .{i}),
            cell.x + @divTrunc(cell.width, 2) - 5,
            cell.y + @divTrunc(cell.width, 2) - 5,
            10,
            .white,
        );
    }
}
