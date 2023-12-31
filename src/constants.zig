pub const Offset = @import("models.zig").Offset;

pub const BOARD_SIZE = 5;

pub const UI_WIDTH = 40;

pub const DIRECTIONS = [_]Offset{
    .{ .row = 0, .col = 1 },
    .{ .row = 1, .col = 0 },
    .{ .row = 0, .col = -1 },
    .{ .row = -1, .col = 0 },
};
