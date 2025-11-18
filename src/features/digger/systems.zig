const std = @import("std");
const rl = @import("raylib");

const World = @import("ecs").World;
const Position = @import("ecs").common.Position;
const Grid = @import("ecs").common.Grid;

const InGrid = @import("components.zig").InGrid;

const MoveDirection = enum { up, down, left, right };

pub fn move(pos: *Position, grid: Grid, direction: MoveDirection) void {
    switch (direction) {
        .up => {
            if (pos.x - 1 >= 0)
                pos.x -= 1;
        },
        .down => {
            if (pos.x + 1 < grid.num_of_rows)
                pos.x += 1;
        },
        .left => {
            if (pos.y - 1 >= 0)
                pos.y -= 1;
        },
        .right => {
            if (pos.y + 1 < grid.num_of_cols)
                pos.y += 1;
        },
    }
}

/// move the first digger
pub fn control(w: *World, move_direction: MoveDirection) !void {
    const pos, const in_grid = (try w.query(&.{ *Position, InGrid }))[0];
    const grid = try w.getComponent(in_grid.grid_entity, Grid);

    move(pos, grid, move_direction);
}

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
