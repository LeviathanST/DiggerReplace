const std = @import("std");
const rl = @import("raylib");

const GameAssets = @import("../../GameAssets.zig");
const World = @import("ecs").World;
const Grid = @import("shared_components").Grid;

pub fn render(w: *World, _: std.mem.Allocator) !void {
    const assets = try w.getMutResource(GameAssets);
    const queries = try w.query(&.{Grid});
    const font = try assets.getMainFont();

    for (queries) |query| {
        const grid = query[0]; // get "grid" field

        for (grid.matrix, 0..) |cell, i| {
            rl.drawRectangle(
                @intCast(cell.x),
                @intCast(cell.y),
                @intCast(cell.width),
                @intCast(cell.width),
                .blue,
            );

            rl.drawTextEx(
                font,
                rl.textFormat("%d", .{i}),
                .{
                    .x = @floatFromInt(cell.x + @divTrunc(cell.width, 2) - 5),
                    .y = @floatFromInt(cell.y + @divTrunc(cell.width, 2) - 5),
                },
                @floatFromInt(font.baseSize - 9),
                0,
                .white,
            );
        }
    }
}
