const std = @import("std");

const token = @import("token.zig");
const lexer = @import("lexer.zig");
const repl = @import("repl.zig");

pub fn main() !void {
    std.debug.print("This is the Monkey programming language!\n", .{});
    std.debug.print("Feel free to type in commands\n", .{});

    try repl.start();
}
