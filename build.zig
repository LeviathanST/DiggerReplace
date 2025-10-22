const std = @import("std");

pub fn build(b: *std.Build) void {
    const t = b.standardTargetOptions(.{});
    const o = b.standardOptimizeOption(.{});

    const raylib_dep = b.dependency("raylib_zig", .{
        .target = t,
        .optimize = o,
    });

    const raylib = raylib_dep.module("raylib");
    const raylib_artifact = raylib_dep.artifact("raylib");

    {
        const exe = b.addExecutable(.{
            .name = "digger_replace",
            .root_module = b.createModule(.{
                .root_source_file = b.path("src/main.zig"),
                .target = t,
                .optimize = o,
            }),
        });
        b.installArtifact(exe);

        const run_step = b.step("run", "Run the application");
        const run_exe = b.addRunArtifact(exe);
        exe.linkLibrary(raylib_artifact);
        exe.root_module.addImport("raylib", raylib);
        run_step.dependOn(&run_exe.step);
    }

    {
        const test_exe = b.addTest(.{
            .root_module = b.createModule(.{
                .root_source_file = b.path("src/main.zig"),
                .target = t,
                .optimize = o,
            }),
        });
        const run_test_step = b.step("test", "Run unit tests");
        const run_test = b.addRunArtifact(test_exe);
        test_exe.linkLibrary(raylib_artifact);
        test_exe.root_module.addImport("raylib", raylib);
        run_test_step.dependOn(&run_test.step);
    }
}
