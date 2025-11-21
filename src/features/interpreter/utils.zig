const std = @import("std");

/// From `features.digger.utils.action.MoveDirection`
/// to`digger.MoveDirection`
///
/// From `features.terminal.action.Debug`
/// to`terminal.Debug`
///
/// This function asserts that the string must be a valid format:
/// * `features.<object-name>.<...>.<ActionType>`
///
/// This function can cause to panic due to out of memory.
pub fn normalizedActionType(
    alloc: std.mem.Allocator,
    str: []const u8,
) []const u8 {
    var iter = std.mem.splitScalar(u8, str, '.');
    _ = iter.first(); // skip `features`
    const object = iter.next().?; // get the main object
    var action_type: []const u8 = undefined;

    std.debug.assert(iter.rest().len > 0);
    while (iter.next()) |a| {
        action_type = a;
    }

    return std.mem.concat(alloc, u8, &[_][]const u8{
        object, ".", action_type,
    }) catch @panic("OOM");
}

test "normalized action type" {
    const alloc = std.testing.allocator;

    const str1 = "features.digger.utils.action.MoveDirection";
    const normalized1 = normalizedActionType(alloc, str1);
    defer alloc.free(normalized1);

    try std.testing.expectEqualStrings(
        "digger.MoveDirection",
        normalized1,
    );
}

/// Normalized the source code:
/// * Trimming.
/// * Remove null-character.
pub fn normalizedSource(alloc: std.mem.Allocator, source: []const u8) ![:0]const u8 {
    var list: std.ArrayList(u8) = .empty;
    const trimmed = std.mem.trim(u8, source, " ");

    for (trimmed) |c| {
        if (c != 0) {
            try list.append(alloc, c);
        }
    }
    return list.toOwnedSliceSentinel(alloc, 0);
}
