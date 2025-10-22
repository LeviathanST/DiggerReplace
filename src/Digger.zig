const std = @import("std");
const rl = @import("raylib");

const Grid = @import("Grid.zig");

const Digger = @This();

/// the col index in the grid
col: i32,
/// the row index in the grid
row: i32,
_grid: Grid,

pub fn init(row: i32, col: i32, grid: Grid) !Digger {
    return .{ .col = col, .row = row, ._grid = grid };
}

pub fn move(self: *Digger, kinds: enum { up, down, left, right }) void {
    switch (kinds) {
        .up => {
            if (self.row - 1 >= 0)
                self.row -= 1;
        },
        .down => {
            if (self.row + 1 < self._grid.num_of_rows)
                self.row += 1;
        },
        .left => {
            if (self.col - 1 >= 0)
                self.col -= 1;
        },
        .right => {
            if (self.col + 1 < self._grid.num_of_cols)
                self.col += 1;
        },
    }
}

pub fn draw(self: Digger) !void {
    const pos = self._grid.matrix[@intCast(try self._grid.getActualIndex(self.row, self.col))];
    const pos_x = pos.x + @divTrunc(pos.width, 2);
    const pos_y = pos.y + @divTrunc(pos.width, 2);
    rl.drawCircle(pos_x, pos_y, 10, .red);
}
