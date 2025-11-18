const std = @import("std");
const rl = @import("raylib");

const World = @import("World.zig");

pub const CommonModule = struct {
    pub fn build(w: *World) void {
        _ = w.addSystems(.update, &.{
            renderRectangle,
            renderButton,
            renderGrid,
        });
    }
};

pub const Position = struct {
    x: i32,
    y: i32,
};

pub const Rectangle = struct {
    width: i32,
    height: i32,
    color: rl.Color,
};

pub fn renderRectangle(w: *World, _: std.mem.Allocator) !void {
    const queries = (try queryToRender(w, &.{
        Position,
        Rectangle,
    })) orelse return;

    for (queries) |query| {
        const pos, const rec = query;
        rl.drawRectangle(
            pos.x,
            pos.y,
            rec.width,
            rec.height,
            rec.color,
        );
    }
}

pub const Button = struct {
    content: [:0]const u8,
    font: rl.Font,
};

pub fn renderButton(w: *World, _: std.mem.Allocator) !void {
    const queries = (try queryToRender(w, &.{
        Position,
        Rectangle,
        Button,
    })) orelse return;

    const pos, const rec, const btn = queries[0];

    const measure_text = rl.measureTextEx(btn.font, btn.content, 20, 1);
    const text_x = pos.x + @divTrunc((rec.width - @as(i32, @intFromFloat(measure_text.x))), 2);
    const text_y = pos.y + @divTrunc((rec.height - @as(i32, @intFromFloat(measure_text.y))), 2);

    // draw the title
    rl.drawTextEx(
        btn.font,
        btn.content,
        .{ .x = @floatFromInt(text_x), .y = @floatFromInt(text_y) },
        20,
        1,
        .black,
    );
}

/// # Examples:
/// * rows = 3, cols = 3
/// |--|--|--|
/// |1 |2 |3 |
/// |--|--|--|
/// |4 |5 |6 |
/// |--|--|--|
/// |7 |8 |9 |
/// |--|--|--|
///
/// # Definitions:
/// - **Symbol:** `E(r, c)` is the element at _r-th_ row, _c-th_ col.
/// _(i, j are started from 0)_
///   + ## Examples:
///     + `E(0, 0)` = 1
///     + `E(1, 2)` = 6
///
/// - **Symbol:** `I(E(r, c))` is the actual index of `E(0, 0)` in the grid.
// TODO:
// Grid should only draw lines, not block
// references to component hierarchy in `Bevy` if want to draw blocks

pub const Grid = struct {
    matrix: []Cell,
    num_of_cols: i32,
    num_of_rows: i32,
    cell_width: i32,
    cell_height: i32,
    /// * color of:
    /// + *lines* if `render_mode` is `.line`
    /// + *blocks* if `render_mode` is `.block`
    color: rl.Color,
    cell_gap: i32,
    render_mode: RenderMode,

    const RenderMode = enum { line, block, none };

    pub const Error = error{
        OverNumRow,
        OverNumCol,
    };

    pub const Cell = struct {
        /// The actual x position in pixels.
        /// col_idx * (cell_width + cell_gap)
        x: i32,
        /// The actual y position in pixels.
        /// row_idx * (cell_width + cell_gap)
        y: i32,
    };

    /// Create a grid (1 dimension array) with `num_of_rows` * `num_of_cols` cells.
    /// Each `cell` is a square.
    ///
    /// If you wonder why I choose 1-dimension and not n-dimension. The anwser is that
    /// Im avoiding allocating more times and managing more array ptr.
    ///
    /// `|-| <-> |-| <-> |-|`
    /// `|4| <-> |5| <-> |6|`
    /// `|-| gap |-| gap |-|`
    /// `|7| <-> |8| <-> |9|`
    /// `|-| <-> |-| <-> |-|`
    pub fn init(
        alloc: std.mem.Allocator,
        pos_start_x: i32,
        pos_start_y: i32,
        num_of_rows: i32,
        num_of_cols: i32,
        cell_width: i32,
        cell_height: i32,
        color: rl.Color,
        // the space between cells
        cell_gap: i32,
        render_mode: RenderMode,
    ) Grid {
        const matrix = alloc.alloc(Cell, @intCast(num_of_rows * num_of_cols)) catch @panic("OOM");

        for (0..@intCast(num_of_rows)) |r| {
            for (0..@intCast(num_of_cols)) |c| {
                matrix[c + r * @as(u32, @intCast(num_of_cols))] = .{
                    .x = pos_start_x + @as(i32, @intCast((c))) * (cell_width + cell_gap),
                    .y = pos_start_y + @as(i32, @intCast((r))) * (cell_height + cell_gap),
                };
            }
        }

        return .{
            .matrix = matrix,
            .num_of_rows = num_of_rows,
            .num_of_cols = num_of_cols,
            .cell_width = cell_width,
            .cell_height = cell_height,
            .color = color,
            .cell_gap = cell_gap,
            .render_mode = render_mode,
        };
    }

    pub fn deinit(self: *Grid, alloc: std.mem.Allocator) void {
        alloc.free(self.matrix);
    }

    /// - Because the matrix is an one dimension array, so the elements can
    /// be flatted: `[1, 2, 3, 4, 5, 6, 7, 8, 9]`
    ///
    /// - Get the actual index of E(0, 0) in the grid by the general formula:
    ///   `I(E(r, c)) = r-th + c-th * num_of_cols`
    /// # Examples
    /// + I(E(0, 0)) = 0 + 0 * 3 = 0 => grid[0]
    ///      `v`
    ///  => `[1, 2, 3 , 4, 5, 6, 7, 8, 9]`
    ///      `v`
    ///  =>`|--|--|--|`
    ///   `>|1*|2 |3 |`
    ///    `|--|--|--|`
    ///    `|4 |5 |6 |`
    ///    `|--|--|--|`
    ///    `|7 |8 |9 |`
    ///    `|--|--|--|`
    ///
    /// + I(E(1, 0)) = 0 + 1 * 3 = 3 => grid[3]
    ///                 `v`
    ///   => `[1, 2, 3 , 4, 5, 6, 7, 8, 9]`
    ///       `v`
    ///   =>`|--|--|--|`
    ///     `|1 |2 |3 |`
    ///     `|--|--|--|`
    ///    `>|4*|5 |6 |`
    ///     `|--|--|--|`
    ///     `|7 |8 |9 |`
    ///     `|--|--|--|`
    ///
    /// + I(E(2, 1)) = 1 + 2 * 3 = 7 => grid[7]
    ///                            `v`
    ///   => `[1, 2, 3, 4, 5, 6, 7, 8, 9]`
    ///          `v`
    ///   =>`|--|--|--|`
    ///     `|1 |2 |3 |`
    ///     `|--|--|--|`
    ///     `|4 |5 |6 |`
    ///     `|--|--|--|`
    ///    `>|7 |8*|9 |`
    ///     `|--|--|--|`
    pub fn getActualIndex(self: Grid, r: i32, c: i32) !usize {
        if (r > self.num_of_rows - 1) return Error.OverNumRow;
        if (c > self.num_of_cols - 1) return Error.OverNumCol;
        return @intCast(c + r * self.num_of_cols);
    }

    test "get actual position in the grid" {
        const alloc = std.testing.allocator;
        var grid = Grid.init(alloc, 3, 3, 1, 1);
        defer grid.deinit(alloc);

        const pos1 = try grid.getActualIndex(0, 0);
        try std.testing.expect(pos1 == 0);
        try std.testing.expect(grid.matrix[pos1].x == 0); // 0 * (1 + 1)
        try std.testing.expect(grid.matrix[pos1].y == 0); // 0 * (1 + 1)

        const pos2 = try grid.getActualIndex(1, 0);
        try std.testing.expect(pos2 == 3);
        try std.testing.expect(grid.matrix[pos2].x == 0); // 0 * (1 + 1)
        try std.testing.expect(grid.matrix[pos2].y == 2); // 1 * (1 + 1)

        const pos3 = try grid.getActualIndex(1, 1);
        try std.testing.expect(pos3 == 4);
        try std.testing.expect(grid.matrix[pos3].x == 2); // 1 * (1 + 1)
        try std.testing.expect(grid.matrix[pos3].y == 2); // 1 * (1 + 1)

        try std.testing.expectError(Error.OverNumCol, grid.getActualIndex(0, 4));
        try std.testing.expectError(Error.OverNumRow, grid.getActualIndex(4, 0));

        var grid2 = Grid.init(alloc, 2, 3, 2, 1);
        defer grid2.deinit(alloc);

        const pos4 = try grid2.getActualIndex(0, 2);
        try std.testing.expect(pos4 == 2);
        try std.testing.expect(grid2.matrix[pos4].x == 6); // 2 * (2 + 1)
        try std.testing.expect(grid2.matrix[pos4].y == 0); // 0 * (2 + 1)

        const pos5 = try grid2.getActualIndex(1, 2);
        try std.testing.expect(pos5 == 5);
        try std.testing.expect(grid2.matrix[pos5].x == 6); // 2 * (2 + 1)
        try std.testing.expect(grid2.matrix[pos5].y == 3); // 2 * (2 + 1)

        try std.testing.expectError(Error.OverNumRow, grid2.getActualIndex(2, 3));
        try std.testing.expectError(Error.OverNumRow, grid2.getActualIndex(3, 4));
    }
};

fn renderGrid(w: *World, _: std.mem.Allocator) !void {
    const queries = (try queryToRender(w, &.{Grid})) orelse return;

    for (queries) |q| {
        const grid = q[0];

        switch (grid.render_mode) {
            .line => renderGridLine(grid),
            .block => renderGridBlock(grid),
            .none => {},
        }
    }
}

fn renderGridBlock(grid: Grid) void {
    for (grid.matrix) |cell| {
        rl.drawRectangle(
            @intCast(cell.x),
            @intCast(cell.y),
            @intCast(grid.cell_width),
            @intCast(grid.cell_height),
            grid.color,
        );
    }
}

fn renderGridLine(grid: Grid) void {
    const rows: usize = @intCast(grid.num_of_rows);
    const cols: usize = @intCast(grid.num_of_cols);

    // draw vertical lines
    for (0..rows) |i| {
        const idx_x1 = cols * i;
        const idx_y1 = cols * (i + 1) - 1;

        rl.drawLine(
            grid.matrix[idx_x1].x,
            grid.matrix[idx_x1].y,
            grid.matrix[idx_y1].x,
            grid.matrix[idx_y1].y,
            grid.color,
        );
    }

    // draw horizontal lines
    for (0..cols) |i| {
        const idx_x1 = i;
        const idx_y1 = cols * (rows - 1) + i;

        rl.drawLine(
            grid.matrix[idx_x1].x,
            grid.matrix[idx_x1].y,
            grid.matrix[idx_y1].x,
            grid.matrix[idx_y1].y,
            grid.color,
        );
    }
}

fn queryToRender(w: *World, comptime types: []const type) !?[]std.meta.Tuple(types) {
    return w.query(types) catch |err| switch (err) {
        World.GetComponentError.StorageNotFound => null,
        else => err,
    };
}
