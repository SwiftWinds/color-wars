const std = @import("std");

const BOARD_SIZE = @import("constants.zig").BOARD_SIZE;

const models = @import("models.zig");

const print = std.debug.print;

const print_welcome = @import("ui.zig").print_welcome;

const is_over = @import("game.zig").is_over;

const move = @import("move.zig").move;

const get_number = @import("ui.zig").get_number;

fn prompt_for_first_player() models.Player {
    print("Who goes first? (0 = Player, 1 = AI): ", .{});
    while (true) : (print("Invalid input, try again: ", .{})) {
        return std.meta.intToEnum(models.Player, get_number(u1) catch continue) catch continue;
    }
}

fn get_state_based_on_first_player(player: models.Player, allocator: *const std.mem.Allocator) *models.State {
    var state = models.State.init(allocator, player);
    move(&state);
    return &state;
}

fn initialize_state(allocator: *const std.mem.Allocator) *models.State {
    const player = prompt_for_first_player();
    return get_state_based_on_first_player(player, allocator);
}

pub fn main() void {
    print_welcome();

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const state = initialize_state(&allocator);
    defer state.deinit();

    while (!is_over(state)) {
        print("we here!\n", .{});
        move(state);
    }
}
