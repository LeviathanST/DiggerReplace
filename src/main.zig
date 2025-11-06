const std = @import("std");
const rl = @import("raylib");
const common_types = @import("common_types.zig");
const digger = @import("digger.zig");
const grid = @import("grid.zig");

const World = @import("ecs/world.zig");
const Grid = common_types.Grid;

fn closeWindow(w: *World) !void {
    if (rl.windowShouldClose()) {
        w.should_exit = true;
    }
}

fn loop(alloc: std.mem.Allocator) !void {
    var world: World = .init(alloc);
    defer world.deinit();

    rl.setTargetFPS(60);

    try world
        .addSystems(.startup, &.{ grid.spawn, digger.spawn })
        .addSystems(.update, &.{closeWindow})
        .addSystems(.update, &.{grid.draw})
        .addSystems(.update, &.{ digger.control, digger.draw })
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
