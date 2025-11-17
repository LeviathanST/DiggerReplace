const std = @import("std");
const World = @import("../../World.zig");

pub const Renderer = struct {
    @"fn": *const fn (*World, std.mem.Allocator) anyerror!void,
};
