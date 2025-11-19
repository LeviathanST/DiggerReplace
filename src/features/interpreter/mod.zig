//! Interpreters implementation to convert a `string `
//! into `Action`.
//!
//! All functions that have `alloc` as args dont need to free
//! because those are using `World.arena`, thats meaning all
//! allocations will be freed every frames.
//!
//! Supported languages:
//! * Plaintext
//! * Zig (WIP)
const std = @import("std");

pub const plaintext = @import("plaintext.zig");

pub const ParseActionError = error{
    /// Value type of action is not supported.
    /// This error should only occur in development.
    UnsupportedType,
    /// The action should have value but not found.
    ActionValueNotFound,
    /// Undefined action
    ActionNotFound,
};

const Language = enum {
    //TODO: zig,
    plaintext,
};

pub const Action = union(enum) {
    move: @import("../digger/mod.zig").action.MoveDirection,
};

pub fn parse(
    _: std.mem.Allocator,
    source: [:0]const u8,
    lang: Language,
) !Action {
    return switch (lang) {
        // .zig => zig.parse(alloc, source),
        .plaintext => blk: {
            const sentinel_idx = std.mem.indexOfSentinel(u8, 0, source);
            break :blk plaintext.parse(source[0..sentinel_idx]);
        },
    };
}
