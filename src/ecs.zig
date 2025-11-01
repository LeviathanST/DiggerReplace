pub const query = @import("ecs/query.zig");

const component = @import("ecs/component.zig");
pub const ErasedComponentStorage = component.ErasedStorage;
pub const ComponentStorage = component.Storage;

pub const World = @import("ecs/world.zig");

test {
    _ = @import("ecs/query.zig");
}
