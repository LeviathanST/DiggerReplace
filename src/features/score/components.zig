const std = @import("std");

pub const Point = struct {
    idx_in_grid: IndexInGrid,

    pub const IndexInGrid = struct {
        r: i32,
        c: i32,
    };

    pub fn random(grid_cols: i32, grid_rows: i32) !Point {
        const x = std.crypto.random.uintAtMost(u8, @intCast(grid_cols - 1));
        const y = std.crypto.random.uintAtMost(u8, @intCast(grid_rows - 1));
        return .{
            .idx_in_grid = .{ .c = x, .r = y },
        };
    }
};
