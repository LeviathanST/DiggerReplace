const std = @import("std");
const systems = @import("systems.zig");

const Position = @import("ecs").common.Position;
const World = @import("ecs").World;

const InGrid = @import("components.zig").InGrid;

pub fn build(w: *World) void {
    _ = w
        .addSystem(.startup, spawn)
        .addSystems(.update, &.{
        systems.control,
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
