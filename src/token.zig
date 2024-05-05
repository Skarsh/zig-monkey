const std = @import("std");

pub const Token = struct {
    type: TokenType,
    literal: []const u8,

    pub fn init(tokenType: TokenType, literal: []const u8) Token {
        return Token{ .type = tokenType, .literal = literal };
    }

    pub fn keyword(identifier: []const u8) TokenType {
        if (std.mem.eql(u8, identifier, "let")) return .let;
        if (std.mem.eql(u8, identifier, "fn")) return .function;
        return .ident;
    }
};

pub const TokenType = enum {
    illegal,
    eof,

    // Identifiers + literals
    ident,
    int,

    // Operators
    assign,
    plus,

    // Delimiters
    comma,
    semicolon,

    lparen,
    rparen,
    lbrace,
    rbrace,

    // Keywords
    function,
    let,
};
