const std = @import("std");
const World = @import("world.zig");
const ErasedComponentStorage = @import("component.zig").ErasedStorage;
const EntityID = World.EntityID;

pub fn query(_: World, _: []type) ![]EntityID {
    // TODO:
    return &.{};
}

// TODO: WIP
fn findMatch(
    alloc: std.mem.Allocator,
    dest: *std.ArrayList(EntityID),
    src: std.ArrayList(EntityID),
) !void {
    var l: std.ArrayList(EntityID) = .empty;
    defer l.deinit(alloc);

    outer: for (src.items) |it1| {
        for (dest.items) |it2| {
            if (it2 == it1) {
                try l.append(alloc, it1);
                continue :outer;
            }
        }
    }

    try dest.replaceRange(alloc, 0, dest.items.len, try l.toOwnedSlice(alloc));
}

test "find match" {
    const alloc = std.testing.allocator;
    var buf1 = [_]EntityID{ 1, 2, 3, 5 };
    var l1: std.ArrayList(EntityID) = .initBuffer(&buf1);
    defer l1.deinit(alloc);

    var buf2 = [_]EntityID{ 1, 2, 3, 5 };
    var l2: std.ArrayList(EntityID) = .initBuffer(&buf2);
    defer l2.deinit(alloc);

    try findMatch(alloc, &l2, l1);

    try std.testing.expectEqualSlices(EntityID, &[_]EntityID{ 1, 2, 3 }, l2.items);
}
