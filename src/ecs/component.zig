const std = @import("std");
const World = @import("world.zig");
const ecs_util = @import("util.zig");
const EntityID = World.EntityID;

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
    deinit_fn: *const fn (World, std.mem.Allocator) void,

    pub inline fn cast(w: World, comptime T: type) !*Storage(T) {
        const Type = ecs_util.Deref(T);
        const hash = std.hash_map.hashString(@typeName(Type));
        const s = w.component_storages.get(hash) orelse return error.ComponentStorageNotFound;
        return ErasedStorage.castFromPtr(s.ptr, Type);
    }

    pub inline fn castFromPtr(ptr: *anyopaque, comptime T: type) *Storage(T) {
        return @ptrCast(@alignCast(ptr));
    }
};
