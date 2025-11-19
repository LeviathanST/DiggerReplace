const World = @import("ecs").World;

pub const Digger = struct {
    idx_in_grid: IndexInGrid,

    pub const IndexInGrid = struct {
        r: i32,
        c: i32,
    };
};
