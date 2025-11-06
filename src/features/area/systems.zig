const rl = @import("raylib");

const World = @import("ecs").World;
const Grid = @import("shared_components").Grid;

pub fn render(w: *World) !void {
    const queries = try w.query(&.{Grid});
    for (queries) |query| {
        const grid = query[0]; // get "grid" field

        for (grid.matrix, 0..) |cell, i| {
            rl.drawRectangle(
                @intCast(cell.x),
                @intCast(cell.y),
                @intCast(cell.width),
                @intCast(cell.width),
                .blue,
            );

            rl.drawText(
                rl.textFormat("%d", .{i}),
                cell.x + @divTrunc(cell.width, 2) - 5,
                cell.y + @divTrunc(cell.width, 2) - 5,
                10,
                .white,
            );
        }
    }
}
