const systems = @import("systems.zig");

const World = @import("ecs").World;
const Grid = @import("shared_components").Grid;

pub fn build(w: *World) void {
    _ = w
        .addSystem(.startup, spawn)
        .addSystems(.update, &.{systems.render});
}

pub fn spawn(w: *World) !void {
    w.spawnEntity(
        &.{Grid},
        .{.init(w.alloc, 3, 3, 100, 5)},
    );
}
