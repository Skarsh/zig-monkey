const std = @import("std");

const token = @import("token.zig");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

pub const Lexer = struct {
    input: []const u8,
    position: usize,
    read_position: usize,
    ch: u8,

    pub fn new(input: []const u8) Lexer {
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

    pub fn nextToken(self: *Lexer) token.Token {
        self.skipWhitespace();

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
                    tok.type = token.Token.keyword(tok.literal);
                    return tok;
                } else if (isDigit(self.ch)) {
                    tok.type = .int;
                    tok.literal = self.readNumber();
                    return tok;
                } else {
                    tok.type = .illegal;
                }
            },
        }

        self.readChar();
        return tok;
    }

    fn skipWhitespace(self: *Lexer) void {
        while (std.ascii.isWhitespace(self.ch)) {
            self.readChar();
        }
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

    fn readNumber(self: *Lexer) []const u8 {
        const position = self.position;
        while (isDigit(self.ch)) {
            self.readChar();
        }
        return self.input[position..self.position];
    }

    fn isDigit(ch: u8) bool {
        return std.ascii.isDigit(ch);
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
    const input =
        \\let five = 5;
        \\let ten = 10;
        \\let add = fn(x, y) {
        \\x + y;
        \\};
        \\let result = add(five, ten);
    ;

    const tests = [_]struct {
        expectedType: token.TokenType,
        expectedLiteral: []const u8,
    }{
        .{ .expectedType = .let, .expectedLiteral = "let" },
        .{ .expectedType = .ident, .expectedLiteral = "five" },
        .{ .expectedType = .assign, .expectedLiteral = "=" },
        .{ .expectedType = .int, .expectedLiteral = "5" },
        .{ .expectedType = .semicolon, .expectedLiteral = ";" },
        .{ .expectedType = .let, .expectedLiteral = "let" },
        .{ .expectedType = .ident, .expectedLiteral = "ten" },
        .{ .expectedType = .assign, .expectedLiteral = "=" },
        .{ .expectedType = .int, .expectedLiteral = "10" },
        .{ .expectedType = .semicolon, .expectedLiteral = ";" },
        .{ .expectedType = .let, .expectedLiteral = "let" },
        .{ .expectedType = .ident, .expectedLiteral = "add" },
        .{ .expectedType = .assign, .expectedLiteral = "=" },
        .{ .expectedType = .function, .expectedLiteral = "fn" },
        .{ .expectedType = .lparen, .expectedLiteral = "(" },
        .{ .expectedType = .ident, .expectedLiteral = "x" },
        .{ .expectedType = .comma, .expectedLiteral = "," },
        .{ .expectedType = .ident, .expectedLiteral = "y" },
        .{ .expectedType = .rparen, .expectedLiteral = ")" },
        .{ .expectedType = .lbrace, .expectedLiteral = "{" },
        .{ .expectedType = .ident, .expectedLiteral = "x" },
        .{ .expectedType = .plus, .expectedLiteral = "+" },
        .{ .expectedType = .ident, .expectedLiteral = "y" },
        .{ .expectedType = .semicolon, .expectedLiteral = ";" },
        .{ .expectedType = .rbrace, .expectedLiteral = "}" },
        .{ .expectedType = .semicolon, .expectedLiteral = ";" },
        .{ .expectedType = .let, .expectedLiteral = "let" },
        .{ .expectedType = .ident, .expectedLiteral = "result" },
        .{ .expectedType = .assign, .expectedLiteral = "=" },
        .{ .expectedType = .ident, .expectedLiteral = "add" },
        .{ .expectedType = .lparen, .expectedLiteral = "(" },
        .{ .expectedType = .ident, .expectedLiteral = "five" },
        .{ .expectedType = .comma, .expectedLiteral = "," },
        .{ .expectedType = .ident, .expectedLiteral = "ten" },
        .{ .expectedType = .rparen, .expectedLiteral = ")" },
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
