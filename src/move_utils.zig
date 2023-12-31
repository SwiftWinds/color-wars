const print = @import("std").debug.print;

const models = @import("models.zig");
const ui_utils = @import("ui_utils.zig");
const run_move = @import("game_utils.zig").run_move;
const has_moved = @import("game_utils.zig").has_moved;
const BOARD_SIZE = @import("constants.zig").BOARD_SIZE;

fn construct_board(state: *const models.State) [BOARD_SIZE][BOARD_SIZE]i8 {
    var board: [BOARD_SIZE][BOARD_SIZE]i8 = undefined;
    for (state.pos_to_idx, 0..) |pos, idx| {
        const row = idx / BOARD_SIZE;
        const col = idx % BOARD_SIZE;
        if (pos == null) {
            board[row][col] = 0;
            continue;
        }
        print("passed null check!\n", .{});
        const player_idx = @intFromEnum(pos.?.owner);
        const val = state.idx_to_val[player_idx][pos.?.idx];
        print("state.idx_to_val[{}][{}] = {}\n", .{ player_idx, pos.?.idx, val });
        switch (pos.?.owner) {
            models.Player.ai => board[row][col] = -@as(i8, val),
            models.Player.player => board[row][col] = val,
        }
    }
    return board;
}

pub fn in_range(pos: u5) bool {
    return 0 <= pos and pos < BOARD_SIZE * BOARD_SIZE;
}

pub fn coords_in_range(coords: models.Coords) bool {
    return 0 <= coords.row and coords.row < BOARD_SIZE and 0 <= coords.col and coords.col < BOARD_SIZE;
}

fn is_legal_pos(state: *const models.State, coords: models.Coords) bool {
    if (!coords_in_range(coords)) {
        return false;
    }
    const pos = coords.row * BOARD_SIZE + coords.col;
    if (has_moved(state.current_player, state)) {
        return state.pos_to_idx[pos] == null or state.pos_to_idx[pos].?.owner == state.current_player; // we can use .? confidently because short-circuiting
    }
    return state.pos_to_idx[pos] != null and state.pos_to_idx[pos].?.owner == state.current_player; // we can use .? confidently because short-circuiting
}

fn prompt_and_run(state: *models.State) void {
    print("Row play: ", .{});
    const row = (ui_utils.get_number(u3) catch 1) - 1; // TODO: proper error handling
    print("Col play: ", .{});
    const col = (ui_utils.get_number(u3) catch 1) - 1; // TODO: proper error handling
    const pos = row * BOARD_SIZE + col;
    print("\n", .{});
    if (!is_legal_pos(state, .{ .row = row, .col = col })) {
        print("The position ({}, {}) is not a legal move. Try another one...\n\n", .{ row + 1, col + 1 });
        prompt_and_run(state);
    } else {
        print("Player plays ({}, {})\n\n", .{ row + 1, col + 1 });
        run_move(state, pos);
    }
}

pub fn move(state: *models.State) void {
    ui_utils.print_board(construct_board(state));
    prompt_and_run(state);
}
