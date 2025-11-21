//! Interpreters implementation to parse the source code
//! from `ingame/terminal` into `Action`.
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

const Interpreter = @This();

errors: std.ArrayList(Error) = .empty,

pub const Error = struct {
    tag: Tag,
    extra: ?struct {
        expected_token: []const u8,
    } = null,
    token: []const u8,

    pub const Tag = enum {
        unknown_action,
        expected_type_action,
        /// Errors in development
        not_supported_type,
    };

    /// Write the `err` message to `writer`.
    ///
    /// TODO: display hints to fix error.
    pub fn render(err: Error, w: *std.Io.Writer) !void {
        try switch (err.tag) {
            .unknown_action => w.print("function `{s}` unknown.\n", .{err.token}),
            .expected_type_action => w.print(
                "expected `{s}` type, found `{s}`.\n",
                .{ err.extra.?.expected_token, err.token },
            ),
            // TODO: remove this error
            .not_supported_type => w.print(
                "not supported type `{s}`, please contact with developers if you see this error.\n",
                .{err.token},
            ),
        };
    }
};

const Language = enum {
    plaintext,
};

pub const Command = union(enum) {
    /// Nothing action will be executed, the parser should return errors
    none,
    move: @import("../digger/mod.zig").action.MoveDirection,

    /// return `null` if the action not found.
    pub fn get(
        action: []const u8,
        args: []const u8,
        node_tag: std.zig.Ast.Node.Tag,
    ) !?Command {
        inline for (std.meta.fields(Command)) |f| {
            if (std.mem.eql(u8, f.name, action)) {
                const arg = Command.getArgType(
                    f.name,
                    args,
                    node_tag,
                );
                return @unionInit(Command, f.name, arg);
            }
        }
        return null;
    }

    /// Get the arguments of an action.
    ///
    /// This function assert the `node_tag` should
    /// be corresponding with the arg type.
    pub fn getArgType(
        comptime action: []const u8,
        arg_value: []const u8,
        node_tag: std.zig.Ast.Node.Tag,
    ) @FieldType(Command, action) {
        switch (@typeInfo(@FieldType(Command, action))) {
            .@"enum" => {
                std.debug.assert(node_tag == .enum_literal);

                return std.meta.stringToEnum(
                    @FieldType(Command, action),
                    arg_value,
                );
            },
            else => unreachable, // not supported type
        }
    }
};

pub fn parse(
    self: *Interpreter,
    alloc: std.mem.Allocator,
    source: []const u8,
    lang: Language,
) !Command {
    const normalized_source = try normalizedSource(alloc, source);

    const action = try switch (lang) {
        .plaintext => blk: {
            const sentinel_idx = std.mem.indexOfSentinel(u8, 0, normalized_source);
            break :blk plaintext.parse(alloc, self, source[0..sentinel_idx]);
        },
    };

    if (action == .none) {
        var aw = std.Io.Writer.Allocating.init(alloc);
        const errs = try self.errors.toOwnedSlice(alloc);
        for (errs) |err| {
            try err.render(&aw.writer);
            std.log.debug("{s}", .{try aw.toOwnedSlice()});
        }
    }

    return action;
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
