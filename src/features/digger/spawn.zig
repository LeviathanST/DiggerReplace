const Position = @import("shared_components").Position;
const World = @import("ecs").World;

const InGrid = @import("components.zig").InGrid;

pub fn spawn(w: *World) !void {
    w.spawnEntity(
        &.{ Position, InGrid },
        .{
            .{ .x = 0, .y = 0 },
            .{ .grid_entity = 0 },
        },
    );
}
