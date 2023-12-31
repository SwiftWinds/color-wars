const Coords = @import("models.zig").Coords;

const BOARD_SIZE = @import("constants.zig").BOARD_SIZE;

pub fn coords_to_pos(coords: *const Coords) u5 {
    return coords.row * BOARD_SIZE + coords.col;
}

pub fn pos_to_coords(pos: u5) *const Coords {
    return &Coords{ .row = @intCast(pos / BOARD_SIZE), .col = @intCast(pos % BOARD_SIZE) };
}
