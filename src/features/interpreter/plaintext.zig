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

    const command_parser: Command.Parser = .init(alloc, interpreter);

    const cmd: []const u8 = iter.first();
    const should_be_value = iter.next() orelse {
        interpreter.appendError(alloc, .{
            .tag = .expected_type_action,
            .extra = .{ .expected_token = "arguments" },
            .token = "empty",
        });
        return .none;
    };

    return command_parser.parse(cmd, should_be_value, .enum_literal);
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
    try std.testing.expectEqual(result_1, parsed_1);

    const action_2 = "nothing arg";
    _ = try parse(alloc, &interpreter, action_2);

    try std.testing.expectEqualDeep(Error{
        .tag = .unknown_action,
        .token = "nothing",
    }, list_err.*.getLast());

    const action_3 = "move forward";
    _ = try parse(alloc, &interpreter, action_3);

    try std.testing.expectEqualDeep(Error{
        .tag = .expected_type_action,
        .extra = .{ .expected_token = "digger.MoveDirection" },
        .token = "forward",
    }, list_err.*.getLast());
}
