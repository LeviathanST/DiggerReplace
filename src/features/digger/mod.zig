const std = @import("std");

const Position = @import("ecs").common.Position;
const World = @import("ecs").World;

const InGrid = @import("components.zig").InGrid;

pub const systems = @import("systems.zig");

pub fn build(w: *World) void {
    _ = w
        .addSystem(.startup, spawn)
        .addSystems(.update, &.{
        systems.render,
    });
}

pub fn spawn(w: *World, _: std.mem.Allocator) !void {
    w.spawnEntity(
        &.{ Position, InGrid },
        .{
            .{ .x = 0, .y = 0 },
            // TODO: grid entity should be `null` when initialized
            .{ .grid_entity = 0 },
        },
    );
}

const Action = enum {
    move,
};

pub fn getActionFromStr(str: []const u8) !?Action {
    var token: [8 * 500]u8 = undefined;
    var fbs = std.io.Writer.fixed(&token);

    for (str) |c| {
        if (c != 0) {
            try fbs.writeByte(c);
        }
    }

    return std.meta.stringToEnum(Action, token[0..fbs.end]);
}
