// TODO: Move this to `ecs.common`
const std = @import("std");
const rl = @import("raylib");
const systems = @import("systems.zig");
const ecs_common = @import("ecs").common;
const components = @import("components.zig");

const World = @import("ecs").World;
const Position = ecs_common.Position;
const Box = ecs_common.DebugBox;
const Info = ecs_common.DebugInfo;

pub fn build(w: *World) void {
    _ = w
        .addSystem(.startup, spawn)
        .addSystems(.update, &.{
        systems.updateInfo,
        systems.render,
    });
}

pub fn spawn(w: *World, _: std.mem.Allocator) !void {
    w.spawnEntity(
        &.{ Info, Position, Box },
        .{
            .{},
            .{
                .x = 10,
                .y = rl.getScreenHeight() - 100,
            },
            .{
                .font_size = 20,
                .width = 250,
                .item_height = 30,
            },
        },
    );
}
