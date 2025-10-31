const std = @import("std");
const rl = @import("raylib");
const ecs = @import("ecs.zig");
const Position = @import("common_types.zig").Position;
const World = ecs.World;
const ErasedComponentStorage = ecs.ErasedComponentStorage;

const Grid = @import("common_types.zig").Grid;
const Digger = @This();

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

pub fn control(w: World) !void {
    const pos = try w.getMutComponent(0, "position", Position);
    const grid = try w.getComponent(0, "grid", Grid);

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

pub fn draw(w: World) !void {
    const p = try w.getComponent(0, "position", Position);
    const grid = try w.getComponent(0, "grid", Grid);

    const pos = grid.matrix[@intCast(try grid.getActualIndex(p.x, p.y))];
    const pos_x = pos.x + @divTrunc(pos.width, 2);
    const pos_y = pos.y + @divTrunc(pos.width, 2);
    rl.drawCircle(pos_x, pos_y, 10, .red);
}
