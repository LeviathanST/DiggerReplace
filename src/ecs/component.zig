const std = @import("std");
const EntityID = @import("world.zig").EntityID;

pub fn Storage(comptime T: type) type {
    return struct {
        data: std.AutoHashMapUnmanaged(EntityID, T),

        pub fn deinit(self: *@This(), alloc: std.mem.Allocator) void {
            self.data.deinit(alloc);
        }
    };
}

/// Erased-type component storage
pub const ErasedStorage = struct {
    ptr: *anyopaque,
    deinit_fn: *const fn (*anyopaque, std.mem.Allocator) void,

    pub inline fn cast(ptr: *anyopaque, comptime T: type) *Storage(T) {
        return @ptrCast(@alignCast(ptr));
    }
};
