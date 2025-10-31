const std = @import("std");
const rl = @import("raylib");

const Grid = @import("Grid.zig");
const Digger = @import("Digger.zig");

pub fn control(d: *Digger, g: Grid) void {
    if (rl.isKeyPressed(.j) and rl.isKeyPressed(.down)) {
        d.move(g, .down);
    }
    if (rl.isKeyPressed(.k) and rl.isKeyPressed(.up)) {
        d.move(g, .up);
    }
    if (rl.isKeyPressed(.h) and rl.isKeyPressed(.left)) {
        d.move(g, .left);
    }
    if (rl.isKeyPressed(.l) and rl.isKeyPressed(.right)) {
        d.move(g, .right);
    }
}

fn loop(alloc: std.mem.Allocator) !void {
    var grid = Grid.init(alloc, 4, 3, 100, 1);
    defer grid.deinit(alloc);

    var digger = Digger.init(0, 0);

    rl.setTargetFPS(60);
    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        try grid.draw();
        try digger.draw(grid);

        control(&digger, grid);

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
