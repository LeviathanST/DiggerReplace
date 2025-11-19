const std = @import("std");
const ecs_common = @import("ecs").common;

const World = @import("ecs").World;

const Position = ecs_common.Position;
const Grid = ecs_common.Grid;
const InGrid = @import("../components.zig").InGrid;
const Digger = @import("../components.zig").Digger;

const MoveDirection = enum { up, down, left, right };

fn move(pos: *Digger.IndexInGrid, grid: Grid, direction: MoveDirection) void {
    switch (direction) {
        .up => {
            if (pos.r - 1 >= 0)
                pos.r -= 1;
        },
        .down => {
            if (pos.r + 1 < grid.num_of_rows)
                pos.r += 1;
        },
        .left => {
            if (pos.c - 1 >= 0)
                pos.c -= 1;
        },
        .right => {
            if (pos.c + 1 < grid.num_of_cols)
                pos.c += 1;
        },
    }
}

/// move the first digger
pub fn control(w: *World, move_direction: MoveDirection) !void {
    var digger, const in_grid = (try w.query(&.{
        *Digger,
        InGrid,
    }))[0];
    const grid = try w.getComponent(in_grid.grid_entity, Grid);

    move(&digger.idx_in_grid, grid, move_direction);
}

const Action = union(enum) {
    move: MoveDirection,
};

const ParseActionError = error{
    /// Value type of action is not supported.
    /// This error should only occur in development.
    UnsupportedType,
    /// The action should have value but not found.
    ActionValueNotFound,
    /// Undefined action
    ActionNotFound,
};

pub fn parse(str: []const u8) ParseActionError!Action {
    const trimmed = std.mem.trim(u8, str, " ");
    var iter = std.mem.splitScalar(u8, trimmed, ' ');

    inline for (std.meta.fields(Action)) |field| {
        const action = iter.next() orelse
            return error.ActionNotFound;

        if (std.mem.eql(u8, field.name, action)) {
            const should_be_value = iter.next() orelse
                return ParseActionError.ActionValueNotFound;

            switch (@typeInfo(field.type)) {
                .@"enum" => {
                    const enum_value = std.meta.stringToEnum(
                        field.type,
                        should_be_value,
                    );
                    if (enum_value) |v| {
                        return @unionInit(Action, field.name, v);
                    } else {
                        return ParseActionError.ActionValueNotFound;
                    }
                },
                else => {
                    const T = field.type;
                    std.log.err("Expected `Enum`, found {s} - original type - {t}", .{
                        @typeName(T),
                        @typeInfo(T),
                    });
                    return ParseActionError.UnsupprotedType;
                },
            }
        }
    }
    return ParseActionError.ActionNotFound;
}

test "parse action" {
    const action_1 = "move up";
    const parsed_1 = try parse(action_1);
    const result_1: Action = .{
        .move = .up,
    };

    try std.testing.expectEqual(parsed_1, result_1);

    const not_found = "not_found";
    const parsed_2 = parse(not_found);
    try std.testing.expectError(ParseActionError.ActionNotFound, parsed_2);

    const value_not_found = "move";
    const parsed_4 = parse(value_not_found);
    try std.testing.expectError(ParseActionError.ActionValueNotFound, parsed_4);
}
