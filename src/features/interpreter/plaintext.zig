const std = @import("std");

const Interpreter = @import("Interpreter.zig");

const Error = Interpreter.Error;
const Command = Interpreter.Command;

pub fn parse(
    alloc: std.mem.Allocator,
    interpreter: *Interpreter,
    source: []const u8,
) !Command {
    // TODO: line iteration
    const trimmed = std.mem.trim(u8, source, " ");
    var iter = std.mem.splitScalar(u8, trimmed, ' ');

    var method: []const u8 = undefined;

    while (iter.next()) |action| {
        method = action;
        inline for (std.meta.fields(Command)) |field| {
            if (std.mem.eql(u8, field.name, action)) {
                const should_be_value = iter.next() orelse {
                    try interpreter.errors.append(alloc, .{
                        .tag = .expected_type_action,
                        .extra = .{ .expected_token = "up/down/left/right" },
                        .token = "",
                    });
                    return .none;
                };

                switch (@typeInfo(field.type)) {
                    .@"enum" => {
                        // TODO: handle check enum values
                        const enum_value = std.meta.stringToEnum(
                            field.type,
                            should_be_value,
                        );
                        if (enum_value) |v| {
                            return @unionInit(Command, field.name, v);
                        } else {
                            try interpreter.errors.append(alloc, .{
                                .tag = .expected_type_action,
                                .extra = .{ .expected_token = "up/down/left/right" },
                                .token = should_be_value,
                            });
                            return .none;
                        }
                    },
                    else => {
                        const T = field.type;
                        try interpreter.errors.append(alloc, .{
                            .tag = .not_supported_type,
                            .token = @typeName(T),
                        });
                        return .none;
                    },
                }
            }
        }
    }

    try interpreter.errors.append(
        alloc,
        .{ .tag = .unknown_action, .token = method },
    );
    return .none;
}

test "parse action (plaintext)" {
    // simulate the `World.arena`
    var base_alloc = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer base_alloc.deinit();
    const alloc = base_alloc.allocator();

    var interpreter: Interpreter = .{};
    const list_err = &interpreter.errors;

    const action_1 = "move up";
    const parsed_1 = try parse(alloc, &interpreter, action_1);
    const result_1: Command = .{
        .move = .up,
    };
    try std.testing.expectEqual(parsed_1, result_1);

    const action_2 = "nothing";
    _ = try parse(alloc, &interpreter, action_2);

    try std.testing.expectEqual(list_err.*.getLast(), Error{
        .tag = .unknown_action,
        .token = "nothing",
    });

    const action_3 = "move forward";
    _ = try parse(alloc, &interpreter, action_3);

    try std.testing.expectEqualDeep(list_err.*.getLast(), Error{
        .tag = .expected_type_action,
        .extra = .{ .expected_token = "up/down/left/right" },
        .token = "forward",
    });
}
