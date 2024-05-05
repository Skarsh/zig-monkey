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
        if (std.mem.eql(u8, identifier, "true")) return .true;
        if (std.mem.eql(u8, identifier, "false")) return .false;
        if (std.mem.eql(u8, identifier, "if")) return .if_cond;
        if (std.mem.eql(u8, identifier, "else")) return .else_cond;
        if (std.mem.eql(u8, identifier, "return")) return .ret;
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
    minus,
    bang,
    asterisk,
    slash,
    less,
    greater,
    eq,
    not_eq,

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
    true,
    false,
    if_cond,
    else_cond,
    ret,
};
