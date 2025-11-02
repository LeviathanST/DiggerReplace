const std = @import("std");
const component = @import("component.zig");

const ErasedComponentStorage = component.ErasedStorage;
const ComponentStorage = component.Storage;
const World = @This();

pub const EntityID = usize;
pub const SystemFn = *const fn (World) anyerror!void;

entity_count: usize = 0,
/// Each storage store data of a component.
/// # Example:
/// |--Velocity--|   |--Position--|
/// | x: 5, y: 2 |   | x: 5, y: 2 |
/// |------------|   |------------|
/// |x: 15, y: 2 |   |x: 15, y: 2 |
/// |------------|   |------------|
///
/// Get data of a component via `get('name_of_your_component')`
component_storages: std.AutoHashMap(u64, ErasedComponentStorage),
systems: std.ArrayList(SystemFn),
alloc: std.mem.Allocator,
_arena: *std.heap.ArenaAllocator,

/// This function can cause to `panic` due to out of memory
pub fn init(alloc: std.mem.Allocator) World {
    const arena = alloc.create(std.heap.ArenaAllocator) catch @panic("OOM");
    arena.* = .init(alloc);
    return .{
        .alloc = arena.allocator(),
        .component_storages = .init(alloc),
        .systems = .empty,
        ._arena = arena,
    };
}

pub fn deinit(self: *World) void {
    var storage_iter = self.component_storages.iterator();
    while (storage_iter.next()) |entry| {
        entry.value_ptr.*.deinit_fn(entry.value_ptr.ptr, self.alloc);
    }

    self.component_storages.deinit();
    self.systems.deinit(self.alloc);

    self._arena.deinit();
    self._arena.child_allocator.destroy(self._arena);
}

pub fn newEntity(self: *World) EntityID {
    const id = self.entity_count;
    self.entity_count += 1;
    return id;
}

/// Create a new component `T` storage with `name`.
///
/// This function can cause to `panic` due to out of memory
pub fn newComponentStorage(
    self: *World,
    comptime T: type,
) void {
    const storage = self.alloc.create(ComponentStorage(T)) catch @panic("OOM");
    errdefer self.alloc.destroy(storage);
    storage.* = .{
        .data = .empty,
    };

    const hash = std.hash_map.hashString(@typeName(T));
    self.component_storages.put(hash, .{
        .ptr = storage,
        .deinit_fn = struct {
            pub fn deinit(ptr: *anyopaque, alloc: std.mem.Allocator) void {
                const s = ErasedComponentStorage.cast(ptr, T);
                s.deinit(alloc);
            }
        }.deinit,
    }) catch @panic("OOM");
}

/// This function can cause to `panic` due to out of memory
pub fn setComponent(
    self: *World,
    entity_id: EntityID,
    comptime T: type,
    component_value: T,
) !void {
    // Get the storage of `T` component by hash.
    const hash = std.hash_map.hashString(@typeName(T));
    const r = self
        .component_storages
        .get(hash) orelse return error.ComponentStorageNotFound;

    const actual_s = ErasedComponentStorage.cast(r.ptr, T);

    // Append the value of the component to data
    // list in the storage
    actual_s.data.put(
        self.alloc,
        entity_id,
        component_value,
    ) catch @panic("OOM");
}

pub fn getComponent(
    self: World,
    entity_id: EntityID,
    comptime T: type,
) !T {
    const hash = std.hash_map.hashString(@typeName(T));
    const s = self
        .component_storages
        .get(hash) orelse return error.ComponentStorageNotFound;

    const actual_s = ErasedComponentStorage.cast(s.ptr, T);
    return actual_s.data.get(entity_id) orelse error.ComponentValueNotFound;
}

pub fn getMutComponent(
    self: World,
    entity_id: EntityID,
    comptime T: type,
) !*T {
    const hash = std.hash_map.hashString(@typeName(T));
    const s = self
        .component_storages
        .get(hash) orelse return error.ComponentStorageNotFound;

    const actual_s = ErasedComponentStorage.cast(s.ptr, T);
    return actual_s.data.getPtr(entity_id) orelse error.ComponentValueNotFound;
}

test "Init entities" {
    const alloc = std.testing.allocator;

    const Position = struct {
        x: i32,
        y: i32,
    };

    var world: World = .init(alloc);
    defer world.deinit();
    world.newComponentStorage(Position);

    const entity_1 = world.newEntity();
    try world.setComponent(entity_1, Position, .{ .x = 5, .y = 6 });

    const comp_value_1 = try world.getComponent(entity_1, Position);
    try std.testing.expect(comp_value_1.x == 5);
    try std.testing.expect(comp_value_1.y == 6);

    const entity_2 = world.newEntity();
    try world.setComponent(entity_2, Position, .{ .x = 10, .y = 6 });

    const comp_value_2 = try world.getComponent(entity_2, Position);
    try std.testing.expect(comp_value_2.x == 10);
    try std.testing.expect(comp_value_2.y == 6);
}

pub fn addSystem(self: *World, system: SystemFn) void {
    self.systems.append(self.alloc, system) catch @panic("OOM");
}

pub fn run(self: World) !void {
    for (self.systems.items) |system| {
        try system(self);
    }
}

test "Run systems" {
    const alloc = std.testing.allocator;

    const Position = struct {
        x: i32,
        y: i32,
    };

    var world: World = .init(alloc);
    defer world.deinit();
    world.newComponentStorage(Position);

    // Init entity
    const entity_1 = world.newEntity();
    try world.setComponent(entity_1, Position, .{ .x = 5, .y = 6 });

    // get the pointer to see changes when `world.run` is executed
    const comp_value_1 = try world.getMutComponent(entity_1, Position);
    try std.testing.expect(comp_value_1.x == 5);
    try std.testing.expect(comp_value_1.y == 6);
    //

    const move_entity = struct {
        pub fn move(w: World) !void {
            const pos = try w.getMutComponent(0, Position);

            pos.x += 1;
            pos.y += 1;
        }
    }.move;

    world.addSystem(move_entity);
    try world.run();

    try std.testing.expect(comp_value_1.x == 6);
    try std.testing.expect(comp_value_1.y == 7);
}
