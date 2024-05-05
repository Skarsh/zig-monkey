const std = @import("std");

const token = @import("token.zig");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

const Lexer = struct {
    input: []const u8,
    position: usize,
    read_position: usize,
    ch: u8,

    fn new(input: []const u8) Lexer {
        var lexer = Lexer{ .input = input, .position = 0, .read_position = 0, .ch = 0 };
        lexer.readChar();
        return lexer;
    }

    fn readChar(self: *Lexer) void {
        if (self.read_position >= self.input.len) {
            self.ch = 0;
        } else {
            self.ch = self.input[self.read_position];
        }
        self.position = self.read_position;
        self.read_position += 1;
    }

    // TODO: There's a way here to not use the newToken function and hence
    // prevent using the charToString function that has to allocate for a new string literal
    // by using the readIdentifier on all tokens
    fn nextToken(self: *Lexer) token.Token {
        const char_str = self.curr_string();

        var tok: token.Token = token.Token.init(.illegal, char_str);

        switch (self.ch) {
            '=' => tok.type = .assign,
            ';' => tok.type = .semicolon,
            '(' => tok.type = .lparen,
            ')' => tok.type = .rparen,
            ',' => tok.type = .comma,
            '+' => tok.type = .plus,
            '{' => tok.type = .lbrace,
            '}' => tok.type = .rbrace,
            0 => {
                tok.type = .eof;
                tok.literal = "";
            },
            else => {
                if (isLetter(self.ch)) {
                    tok.literal = self.readIdentifier();
                    return tok;
                } else {
                    //tok = newToken(token.ILLEGAL, self.ch);
                    tok.type = .illegal;
                }
            },
        }

        self.readChar();
        return tok;
    }

    fn readIdentifier(self: *Lexer) []const u8 {
        const position = self.position;
        while (isLetter(self.ch)) {
            self.readChar();
        }
        return self.input[position..self.position];
    }

    fn isLetter(ch: u8) bool {
        return std.ascii.isAlphabetic(ch) or ch == '_';
    }

    fn curr_string(self: Lexer) []const u8 {
        if (self.position >= self.input.len) {
            return "0";
        } else {
            return self.input[self.position..self.read_position];
        }
    }
};

test "TestNextToken" {
    const input = "=+(){},;";

    const tests = [_]struct {
        expectedType: token.TokenType,
        expectedLiteral: []const u8,
    }{
        .{ .expectedType = .assign, .expectedLiteral = "=" },
        .{ .expectedType = .plus, .expectedLiteral = "+" },
        .{ .expectedType = .lparen, .expectedLiteral = "(" },
        .{ .expectedType = .rparen, .expectedLiteral = ")" },
        .{ .expectedType = .lbrace, .expectedLiteral = "{" },
        .{ .expectedType = .rbrace, .expectedLiteral = "}" },
        .{ .expectedType = .comma, .expectedLiteral = "," },
        .{ .expectedType = .semicolon, .expectedLiteral = ";" },
        .{ .expectedType = .eof, .expectedLiteral = "" },
    };

    var lexer = Lexer.new(input);

    for (0.., tests) |i, tt| {
        const tok = lexer.nextToken();

        std.testing.expectEqual(tt.expectedType, tok.type) catch |err| {
            std.debug.print("\n\ntests[{}] - tokentype wrong. expected: {any}, got: {any}\n\n", .{ i, tt.expectedType, tok.type });
            return err;
        };

        std.testing.expect(std.mem.eql(u8, tt.expectedLiteral, tok.literal)) catch |err| {
            std.debug.print("\n\ntests[{}] - literal wrong. expected: {s}, got: {s}\n\n", .{ i, tt.expectedLiteral, tok.literal });
            return err;
        };
    }
}
