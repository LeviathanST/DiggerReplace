const component = @import("ecs/component.zig");

pub const ErasedComponentStorage = component.ErasedStorage;
pub const ComponentStorage = component.Storage;
pub const World = @import("ecs/World.zig");

pub const mods = @import("ecs/modules.zig");

test {
    @import("std").testing.refAllDecls(@This());
}
