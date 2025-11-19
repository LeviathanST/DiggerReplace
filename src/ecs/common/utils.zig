const std = @import("std");
const World = @import("../World.zig");

/// This function is the same with `World.query()`, but it
/// return `null` if one of the storage of `components` not found.
///
/// Used to extract all components of an entity and ensure they are
/// existed to render.
pub fn queryToRender(w: *World, comptime types: []const type) !?[]std.meta.Tuple(types) {
    return w.query(types) catch |err| switch (err) {
        World.GetComponentError.StorageNotFound => null,
        else => err,
    };
}
