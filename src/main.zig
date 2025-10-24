const std = @import("std");
const rl = @import("raylib");

const Grid = @import("Grid.zig");
const Digger = @import("Digger.zig");

pub fn control(d: *Digger) void {
    if (rl.isKeyPressed(.j) or rl.isKeyPressed(.down)) {
        d.move(.down);
    }
    if (rl.isKeyPressed(.k) or rl.isKeyPressed(.up)) {
        d.move(.up);
    }
    if (rl.isKeyPressed(.h) or rl.isKeyPressed(.left)) {
        d.move(.left);
    }
    if (rl.isKeyPressed(.l) or rl.isKeyPressed(.right)) {
        d.move(.right);
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

    var grid = try Grid.init(alloc, 4, 3, 100, 1);
    defer grid.deinit();

    var digger = try Digger.init(0, 0, grid);

    rl.setTargetFPS(60);

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        try grid.draw();
        try digger.draw();

        control(&digger);

        rl.clearBackground(.white);
    }
}

test {
    std.testing.refAllDecls(@This());
}
