const rl = @import("raylib");
const Config = @This();

main_font: rl.Font,

pub fn init() !Config {
    return .{
        .main_font = try rl.loadFont("assets/fonts/boldpixelsx1.ttf"),
    };
}

pub fn deinit(self: Config) void {
    self.main_font.unload();
}
