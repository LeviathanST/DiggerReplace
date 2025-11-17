const std = @import("std");
const components = @import("components.zig");

const World = @import("../../World.zig");
const Renderer = components.Renderer;

pub fn autoRender(w: *World, alloc: std.mem.Allocator) !void {
    const queries = try w.query(&.{Renderer});
    for (queries) |query| {
        const renderer = query[0];

        try renderer.@"fn"(w, alloc);
    }
}
