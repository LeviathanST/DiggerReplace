const std = @import("std");

const Position = @import("ecs").common.Position;
const World = @import("ecs").World;

const InGrid = @import("components.zig").InGrid;

const systems = @import("systems.zig");
pub const action = @import("utils/action.zig");

pub fn build(w: *World) void {
    _ = w
        .addSystem(.startup, spawn)
        .addSystems(.update, &.{
        systems.render,
    });
}

pub fn spawn(w: *World, _: std.mem.Allocator) !void {
    w.spawnEntity(
        &.{ Position, InGrid },
        .{
            .{ .x = 0, .y = 0 },
            // TODO: grid entity should be `null` when initialized
            .{ .grid_entity = 0 },
        },
    );
}
