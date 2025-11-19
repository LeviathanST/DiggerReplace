const std = @import("std");
const rl = @import("raylib");
const Config = @This();

/// The font use for most displayed text.
main_font: ?rl.Font = null,
/// The font use for displayed text in terminal.
terminal_font: ?rl.Font = null,

pub fn getMainFont(self: *Config) !rl.Font {
    if (self.main_font == null) {
        self.main_font = try rl.loadFont("assets/fonts/boldpixelsx1.ttf");
    }
    return self.main_font.?;
}
pub fn getTerminalFont(self: *Config) !rl.Font {
    if (self.terminal_font == null) {
        self.terminal_font = try rl.loadFont("assets/fonts/jetbrains-mono-medium.ttf");
    }
    return self.terminal_font.?;
}

pub fn deinit(self: Config, _: std.mem.Allocator) void {
    if (self.main_font) |f| {
        f.unload();
    }
    if (self.terminal_font) |f| {
        f.unload();
    }
}
