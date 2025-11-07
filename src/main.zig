const std = @import("std");
const rl = @import("raylib");
const shared_components = @import("shared_components");

const digger_spawn = @import("features/digger/spawn.zig");
const digger_systems = @import("features/digger/systems.zig");

const area_systems = @import("features/area/systems.zig");
const area_spawn = @import("features/area/spawn.zig");

const World = @import("ecs").World;
const Grid = shared_components.Grid;

const GameAssets = @import("GameAssets.zig");

fn closeWindow(w: *World) !void {
    if (rl.windowShouldClose()) {
        w.should_exit = true;
    }
}

fn loop(alloc: std.mem.Allocator) !void {
    var world: World = .init(alloc);
    defer world.deinit();

    rl.setTargetFPS(60);

    // TODO: setup modules
    try world
        .addResource(GameAssets, .{})
        .addSystems(.startup, &.{ area_spawn.spawn, digger_spawn.spawn })
        .addSystems(.update, &.{closeWindow})
        .addSystems(.update, &.{area_systems.render})
        .addSystems(.update, &.{ digger_systems.control, digger_systems.render })
        .run();
}

pub fn main() !void {
    var base_alloc = std.heap.DebugAllocator(.{}).init;
    defer {
        if (base_alloc.deinit() == .leak) @panic("Leak memory have been detected!");
    }
    const alloc = base_alloc.allocator();

    const screenWidth = 800;
    const screenHeight = 450;

    rl.initWindow(screenWidth, screenHeight, "Digger Replace");
    defer rl.closeWindow();

    try loop(alloc);
}

test {
    std.testing.refAllDecls(@This());
}
