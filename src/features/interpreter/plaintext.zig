const std = @import("std");

const ParseActionError = @import("mod.zig").ParseActionError;
const Action = @import("mod.zig").Action;

pub fn parse(source: []const u8) !Action {
    const trimmed = std.mem.trim(u8, source, " ");
    var iter = std.mem.splitScalar(u8, trimmed, ' ');

    while (iter.next()) |action| {
        inline for (std.meta.fields(Action)) |field| {
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
    }

    return ParseActionError.ActionNotFound;
}

test "parse action (plaintext)" {
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
