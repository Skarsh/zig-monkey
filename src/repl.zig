const std = @import("std");
const lexer = @import("lexer.zig");

const PROMPT = ">> ";

pub fn start() !void {
    const in = std.io.getStdIn();
    var buf = std.io.bufferedReader(in.reader());

    // Get the Reader interface from BufferedReader
    var r = buf.reader();

    var line_buf: [4096]u8 = undefined;

    while (true) {
        std.debug.print("{s}", .{PROMPT});

        const line = try r.readUntilDelimiterOrEof(&line_buf, '\n');
        var lex = lexer.Lexer.new(line.?);

        while (true) {
            const token = lex.nextToken();
            if (token.type == .eof) break;

            std.debug.print("{}, {s}\n", .{ token.type, token.literal });
        }
    }
}
