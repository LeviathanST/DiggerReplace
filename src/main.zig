const std = @import("std");
const rl = @import("raylib");
const common_types = @import("common_types.zig");
const digger = @import("digger.zig");
const grid = @import("grid.zig");

const World = @import("ecs/world.zig");
const Grid = common_types.Grid;

fn loop(alloc: std.mem.Allocator) !void {
    var world: World = .init(alloc);
    defer world.deinit();

    world.newComponentStorage("position", common_types.Position);
    world.newComponentStorage("id", usize);
    world.newComponentStorage("grid", Grid);

    var g = Grid.init(alloc, 4, 3, 100, 1);
    defer g.deinit(alloc);
    world.addSystem(grid.draw);

    // Digger entity
    const d = world.newEntity();
    try world.setComponent(d, common_types.Position, "position", .{ .x = 0, .y = 0 });
    try world.setComponent(d, usize, "id", 1);
    try world.setComponent(d, Grid, "grid", g);

    world.addSystem(digger.control);
    world.addSystem(digger.draw);
    //

    rl.setTargetFPS(60);
    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        try world.run();
        rl.clearBackground(.white);
    }
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
