const std = @import("std");

const print = std.debug.print;

const constants = @import("constants.zig");

pub fn print_welcome() void {
    print("{s}\n\n{s:^[2]}\n\n{[0]s}\n", .{ "*" ** constants.UI_WIDTH, "Color Wars AI", constants.UI_WIDTH });
    print("Player = 1 to 4\t  AI Computer = -1 to -4\n\n", .{});
}

pub fn print_board(board: [constants.BOARD_SIZE][constants.BOARD_SIZE]i8) void {
    for (board) |row| {
        print("\n|", .{});
        for (row) |cell| {
            if (cell >= 0) {
                print(" ", .{}); // Add a space for positive numbers (player numbers) for alignment
            }
            print("{}|", .{cell});
        }
        print("\n+", .{});
        for (0..constants.BOARD_SIZE) |_| {
            print("--+", .{});
        }
    }
    print("\n\n", .{});
}

// We can read any arbitrary number type with number_type
pub fn get_number(comptime number_type: type) !number_type {
    const stdin = std.io.getStdIn().reader();

    var buffer: [3]u8 = undefined;

    // Read until the '\n' char and capture the value if there's no error
    if (try stdin.readUntilDelimiterOrEof(buffer[0..], '\n')) |value| {
        return try std.fmt.parseInt(number_type, value, 10);
    }
    return @as(number_type, 0);
}
