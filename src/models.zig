// u3 => for board length   (0.. 5)
// u5 => for board position (0..25)
// u1 => for player         (0.. 2)

const std = @import("std");

const BOARD_SIZE = @import("constants.zig").BOARD_SIZE;

pub const Player = enum(u1) { player = 0, ai = 1 };

pub const Index = struct { owner: Player, idx: u5 };

const Move = struct { manual: bool, pos: u5 };

pub const State = struct {
    // there are 25 positions on the board (5x5)
    pos_to_idx: [BOARD_SIZE * BOARD_SIZE]?Index = [_]?Index{null} ** (BOARD_SIZE * BOARD_SIZE),
    // there are 25 possible indices for each player (25 if they own the whole board)
    idx_to_val: [2][BOARD_SIZE * BOARD_SIZE]u3 = undefined,
    // this is the number of territories each player owns. It's [2]u5 because there are 2 players and up to 25 territories each
    territories: [2]u5 = [_]u5{ 0, 0 },
    moves: std.ArrayList(Move),
    current_player: Player,

    pub fn init(allocator: *const std.mem.Allocator, player: Player) State {
        return .{
            .moves = std.ArrayList(Move).init(allocator.*),
            .current_player = player,
        };
    }

    pub fn deinit(state: *State) void {
        state.moves.deinit();
    }
};

pub const Coords = struct { row: u3, col: u3 };
pub const Offset = struct { row: i2, col: i2 };
