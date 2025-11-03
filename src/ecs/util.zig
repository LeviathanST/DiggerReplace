const std = @import("std");

/// Return the child type of `T` if it is a pointer.
pub fn Deref(comptime T: type) type {
    if (@typeInfo(T) == .pointer)
        return std.meta.Child(T);
    return T;
}
