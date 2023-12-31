const std = @import("std");

const models = @import("models.zig");
const coords_in_range = @import("move.zig").coords_in_range;
const coords_utils = @import("coords_utils.zig");
const constants = @import("constants.zig");
const safe_add = @import("int_utils.zig").safe_add;

pub fn is_over(state: *const models.State) bool {
    return state.moves.items.len > 1 and (std.mem.indexOfScalar(u5, &state.territories, 0) != null);
}

pub fn has_moved(player: models.Player, state: *const models.State) bool {
    return !(state.moves.items.len <= 1 and state.territories[@intFromEnum(player)] == 0);
}

fn swapRemove(arr: *[constants.BOARD_SIZE * constants.BOARD_SIZE]u3, idx: u5, len: *u5) void {
    const last_idx = len.* - 1;
    arr[idx] = arr[last_idx];
    len.* -= 1;
}

fn get_coords(coords: *const models.Coords, state: *const models.State) u3 {
    const pos = coords_utils.coords_to_pos(coords);
    const idx = state.pos_to_idx[pos];
    return if (idx == null) 0 else state.idx_to_val[@intFromEnum(idx.?.owner)][idx.?.idx];
}

fn add_coords(coords: *const models.Coords, val: u3, player_idx: u1, state: *models.State) void {
    const pos = coords_utils.coords_to_pos(coords);
    const i = &state.territories[player_idx];
    state.pos_to_idx[pos] = models.Index{
        .owner = @enumFromInt(player_idx),
        .idx = i.*,
    };
    state.idx_to_val[player_idx][i.*] = val;
    i.* += 1;
}

fn remove_coords(coords: *const models.Coords, player_idx: u1, state: *models.State) void {
    const pos = coords_utils.coords_to_pos(coords);
    const i = state.pos_to_idx[pos].?.idx;
    swapRemove(&state.idx_to_val[player_idx], i, &state.territories[player_idx]);
    state.pos_to_idx[pos] = null;
}

fn increment_coords(coords: *const models.Coords, player_idx: u1, state: *models.State) void {
    if (coords_owner(coords, state) != player_idx) {
        add_coords(coords, 1, player_idx, state);
        return;
    }
    const pos = coords_utils.coords_to_pos(coords);
    const i = state.pos_to_idx[pos].?.idx;
    state.idx_to_val[player_idx][i] += 1;
}

fn coords_owner(coords: *const models.Coords, state: *models.State) ?u1 {
    const pos = coords_utils.coords_to_pos(coords);
    return if (state.pos_to_idx[pos] == null) null else @intFromEnum(state.pos_to_idx[pos].?.owner);
}

pub fn run_move(state: *models.State, pos: u5) void {
    const player_idx = @intFromEnum(state.current_player);
    const opponent_idx = player_idx ^ 1;
    const opponent: models.Player = @enumFromInt(opponent_idx);
    defer state.current_player = opponent;
    const coords = coords_utils.pos_to_coords(pos);
    if (coords_owner(coords, state) == null) {
        add_coords(coords, 3, player_idx, state);
        return;
    }
    increment_coords(coords, player_idx, state);
    if (get_coords(coords, state) < 4) {
        return;
    }
    var q = std.fifo.LinearFifo(u5, .{ .Static = constants.BOARD_SIZE * constants.BOARD_SIZE }).init();
    q.writeItem(pos) catch |err| {
        std.debug.print("Failed to write to queue: {}\n", .{err});
        return;
    };
    while (q.readItem()) |overflowed_pos| {
        // pseudocode:
        // coords = pop from queue
        // remove coords from player territory
        // for (constants.DIRECTIONS) |dir| {
        //    coords = coords + dir
        //    if (coords is null) {
        //        add_coords(coords, player_idx, 1)
        //        continue
        //    }
        //    if (coords.owner == opponent_idx) {
        //        change_owner(coords)
        //    }
        //    increment_coords(coords)
        //    if (val at coords < 4) {
        //        continue
        //    }
        //    add coords to queue
        // }
        const overflowed_coords = coords_utils.pos_to_coords(overflowed_pos);
        remove_coords(overflowed_coords, player_idx, state);
        for (constants.DIRECTIONS) |dir| {
            const new_coords = models.Coords{ .row = safe_add(overflowed_coords.row, dir.row), .col = safe_add(coords.col, dir.col) };
            if (!coords_in_range(new_coords)) {
                continue;
            }
            if (coords_owner(&new_coords, state) == null) {
                add_coords(&new_coords, 1, player_idx, state);
                continue;
            }
            if (coords_owner(&new_coords, state) == opponent_idx) {
                remove_coords(&new_coords, opponent_idx, state);
            }
            increment_coords(&new_coords, player_idx, state);
            if (get_coords(&new_coords, state) < 4) {
                continue;
            }
            q.writeItem(coords_utils.coords_to_pos(&new_coords)) catch |err| {
                std.debug.print("Failed to write to queue: {}\n", .{err});
                return;
            };
        }
    }
}
