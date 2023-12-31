pub fn OneBiggerInt(comptime T: type) type {
    var info = @typeInfo(T);
    info.Int.bits += 1;
    return @Type(info);
}

/// Allows u32 + i16 to work
pub fn safe_add(a: anytype, b: anytype) @TypeOf(a) {
    if (b >= 0) {
        return a + @as(@TypeOf(a), @intCast(b));
    }
    return a - @as(@TypeOf(a), @intCast(-@as(OneBiggerInt(@TypeOf(b)), b)));
}
