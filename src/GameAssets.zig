const std = @import("std");
const rl = @import("raylib");
const Config = @This();

/// This is lazy loading field
main_font: ?rl.Font = null,

/// Load the lazy variable `main_font`
pub fn getMainFont(self: *Config) !rl.Font {
    if (self.main_font == null) {
        self.main_font = try rl.loadFont("assets/fonts/boldpixelsx1.ttf");
    }
    return self.main_font.?;
}

pub fn deinit(self: Config, _: std.mem.Allocator) void {
    if (self.main_font) |f| {
        f.unload();
    }
}
