const std = @import("std");

/// Skip characters in `str` until the first character is found that
/// is **different** from **all elements in `chars`**.
/// Return the number of characters skipped.
///
/// Example:
/// skipChar("abc\r\n", "\r\n") -> 2
/// skipChar("abc\r", "\r\n") -> 1
/// skipChar("abc\r\n", "\r") -> 0
/// skipChar("abc\n\r", "\r") -> 1
/// skipChar("abc", "\r") -> 0
pub fn skipChar(str: []const u8, chars: []const u8) i32 {
    if (str.len == 0) return 0;
    // enable `idx = -1` to end the loop
    var idx: isize = @intCast(str.len - 1);
    var count: i32 = 0;

    blk: while (idx >= 0) {
        for (chars) |c| {
            if (str[@intCast(idx)] != c) break :blk;
        }
        idx -= 1;
        count += 1;
    }
    return count;
}

test "skip characters" {
    const str1 = "abc\r\n";
    const skip1 = skipChar(str1, "\r\n");
    try std.testing.expectEqual(0, skip1);

    const str2 = "abc\r\n";
    const skip2 = skipChar(str2, "\n");
    try std.testing.expectEqual(1, skip2);

    const str3 = &[_]u8{0} ** 10;
    var mutable_str = @constCast(str3);
    mutable_str[6] = 'A';
    const skip3 = skipChar(str3, &[_]u8{0});
    try std.testing.expectEqual(3, skip3);
}
