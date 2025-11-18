const std = @import("std");
const World = @import("world.zig");

pub const ErasedResource = struct {
    ptr: *anyopaque,
    deinit_fn: *const fn (World, std.mem.Allocator) void,

    pub inline fn cast(w: World, comptime T: type) !*T {
        const hash = std.hash_map.hashString(@typeName(T));
        const value = w.resources.get(hash) orelse return error.ResourceNotFound;
        return @ptrCast(@alignCast(value.ptr));
    }
};
