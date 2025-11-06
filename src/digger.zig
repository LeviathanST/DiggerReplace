const std = @import("std");
const rl = @import("raylib");
const ecs = @import("ecs.zig");
const Position = @import("common_types.zig").Position;
const World = ecs.World;
const ErasedComponentStorage = ecs.ErasedComponentStorage;

const Grid = @import("common_types.zig").Grid;
const Digger = @This();

pub const InGrid = struct { grid_entity: World.EntityID };

pub fn spawn(w: *World) !void {
    w.spawnEntity(
        &.{ Position, InGrid },
        .{
            .{ .x = 0, .y = 0 },
            .{ .grid_entity = 0 },
        },
    );
}

pub fn move(pos: *Position, grid: Grid, kinds: enum { up, down, left, right }) void {
    switch (kinds) {
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
pub fn control(w: *World) !void {
    const pos, const in_grid = (try w.query(&.{ *Position, InGrid }))[0];
    const grid = try w.getComponent(in_grid.grid_entity, Grid);

    if (rl.isKeyPressed(.j) or rl.isKeyPressed(.down)) {
        move(pos, grid, .down);
    }
    if (rl.isKeyPressed(.k) or rl.isKeyPressed(.up)) {
        move(pos, grid, .up);
    }
    if (rl.isKeyPressed(.h) or rl.isKeyPressed(.left)) {
        move(pos, grid, .left);
    }
    if (rl.isKeyPressed(.l) or rl.isKeyPressed(.right)) {
        move(pos, grid, .right);
    }
}

/// Draw all diggers
pub fn draw(w: *World) !void {
    const queries = try w.query(&.{ Position, InGrid });

    for (queries) |query| {
        const pos, const in_grid = query;
        const grid = try w.getComponent(in_grid.grid_entity, Grid);

        const pos_in_px = grid.matrix[@intCast(try grid.getActualIndex(pos.x, pos.y))];
        const pos_x = pos_in_px.x + @divTrunc(pos_in_px.width, 2);
        const pos_y = pos_in_px.y + @divTrunc(pos_in_px.width, 2);
        rl.drawCircle(pos_x, pos_y, 10, .red);
    }
}
