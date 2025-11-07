// TODO: this module should be a resource
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

pub fn deinit(self: Config) void {
    self.main_font.?.unload();
}
