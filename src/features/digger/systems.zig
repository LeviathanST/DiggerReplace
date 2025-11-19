const std = @import("std");
const rl = @import("raylib");

const World = @import("ecs").World;
const Position = @import("ecs").common.Position;
const Grid = @import("ecs").common.Grid;

const InGrid = @import("components.zig").InGrid;

/// Draw all diggers
pub fn render(w: *World, _: std.mem.Allocator) !void {
    const queries = try w.query(&.{ Position, InGrid });

    for (queries) |query| {
        const pos, const in_grid = query;
        const grid = try w.getComponent(in_grid.grid_entity, Grid);

        const pos_in_px = grid.matrix[@intCast(try grid.getActualIndex(pos.x, pos.y))];
        const pos_x = pos_in_px.x + @divTrunc(grid.cell_width, 2);
        const pos_y = pos_in_px.y + @divTrunc(grid.cell_width, 2);
        rl.drawCircle(pos_x, pos_y, 10, .red);
    }
}
