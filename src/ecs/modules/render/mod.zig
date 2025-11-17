//! # Feature
//! * Auto-render all components which have `render()`.
const std = @import("std");
const World = @import("../../World.zig");

pub const components = @import("components.zig");
pub const systems = @import("systems.zig");

pub fn build(w: *World) void {
    _ = w.addSystem(.update, systems.autoRender);
}
