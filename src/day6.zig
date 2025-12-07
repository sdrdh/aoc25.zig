const std = @import("std");
const aoc25_zig = @import("aoc25_zig");
const Allocator = std.mem.Allocator;
const ArrayList = std.array_list.Managed;
const expect = std.testing.expect;

const inputContent = @embedFile("data/day6.txt");

const testContent = @embedFile("data/day6_sample.txt");

fn getContentSize(content: []const u8) struct { usize, usize } {
    var it = std.mem.tokenizeScalar(u8, content, '\n');
    var rows: usize = 0;
    var row_length: usize = 0;
    while (it.next()) |line| {
        rows += 1;
        if (row_length == 0) {
            var row_it = std.mem.tokenizeScalar(u8, line, ' ');
            while (row_it.next()) |_| {
                row_length += 1;
            }
        }
    }
    return .{ rows, row_length };
}

test "getContentSize" {
    const contentDimensions = getContentSize(testContent);

    try std.testing.expect(contentDimensions[0] == 4);
    try std.testing.expect(contentDimensions[1] == 4);
}

const Operation = struct { numbers: []u32, operator: u8 };

fn getResult(operands: []u32, operator: u8) u64 {
    if (operator == '*') {
        var result: u64 = 1;
        for (operands) |number| {
            result *= number;
        }
        return result;
    } else if (operator == '+') {
        var result: u64 = 0;
        for (operands) |number| {
            result += number;
        }
        return result;
    } else unreachable;
}

fn parseContent(content: []const u8, allocator: Allocator) ![]Operation {
    const dimensions = getContentSize(content);

    var it = std.mem.tokenizeScalar(u8, content, '\n');
    const numbers: [][]u32 = try allocator.alloc([]u32, dimensions[1]);
    for (0..dimensions[1]) |i| {
        numbers[i] = try allocator.alloc(u32, dimensions[0] - 1);
    }
    for (0..dimensions[0] - 1) |i| {
        const line = it.next() orelse unreachable;
        var j: usize = 0;
        var line_it = std.mem.tokenizeScalar(u8, line, ' ');
        while (line_it.next()) |num_str| {
            numbers[j][i] = try std.fmt.parseInt(u32, num_str, 10);
            j += 1;
        }
    }

    const operators: []u8 = try allocator.alloc(u8, dimensions[1]);

    const line = it.next() orelse unreachable;
    var i: usize = 0;
    var line_it = std.mem.tokenizeScalar(u8, line, ' ');
    while (line_it.next()) |operator| {
        try std.testing.expect(operator.len == 1);
        operators[i] = operator[0];
        i += 1;
    }
    var operations = ArrayList(Operation).init(allocator);
    for (0..dimensions[1]) |idx| {
        const operation = Operation{ .numbers = numbers[idx], .operator = operators[idx] };
        try operations.append(operation);
    }
    return operations.items;
}

test "parseContent" {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    const allocator = gpa.allocator();

    const parsedContent = try parseContent(testContent, allocator);

    try expect(parsedContent.len == 4);
    try expect(parsedContent[0].numbers.len == 3);
    try expect(parsedContent[0].operator == '*');
}

pub fn part1(content: []const u8, allocator: Allocator) !usize {
    const operations = try parseContent(content, allocator);
    var total: u64 = 0;
    for (operations) |operation| {
        total += getResult(operation.numbers, operation.operator);
    }
    return total;
}

test "test input part1" {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    const allocator = gpa.allocator();

    try std.testing.expect(try part1(testContent, allocator) == 4277556);
}

fn getOperatorsLine(content: []const u8) []const u8 {
    var it = std.mem.tokenizeScalar(u8, content, '\n');
    while (it.next()) |line| {
        if (line[0] == '*' or line[0] == '+') {
            return line;
        }
    }
    unreachable;
}

test "getOperatorsLine" {
    const operatorsLine = getOperatorsLine(testContent);

    try expect(std.mem.eql(u8, operatorsLine, "*   +   *   + "));
}

fn getOperandsLines(content: []const u8, allocator: Allocator) ![][]const u8 {
    var operands = ArrayList([]const u8).init(allocator);
    var it = std.mem.tokenizeScalar(u8, content, '\n');
    while (it.next()) |line| {
        if (line[0] == '*' or line[0] == '+') {
            return operands.items;
        }
        try operands.append(line);
    }
    return operands.items;
}

const CephelopodOperation = struct { numbers: [][]const u8, operator: u8 };

fn getCephelopodResult(opn: CephelopodOperation, allocator: Allocator) !u64 {
    var numbers = ArrayList(u32).init(allocator);
    var max: usize = 0;
    for (opn.numbers) |number| {
        max = @max(max, number.len);
    }
    for (0..max) |_| {
        try numbers.append(0);
    }
    for (opn.numbers) |number| {
        for (number, 0..) |d, i| {
            var digit: u32 = 0;
            if (d != ' ') {
                digit = d - '0';
                numbers.items[i] = numbers.items[i] * 10 + digit;
            }
        }
    }
    return getResult(numbers.items, opn.operator);
}

fn parseContent2(content: []const u8, allocator: Allocator) ![]CephelopodOperation {
    const operatorLine = getOperatorsLine(content);
    const operandLines = try getOperandsLines(content, allocator);
    var opns = ArrayList(CephelopodOperation).init(allocator);
    var prev: usize = 0;
    for (1..operatorLine.len) |i| {
        // Encountered
        if (operatorLine[i] == '*' or operatorLine[i] == '+' or i == operatorLine.len - 1) {
            // Find the previous one would be a ' '. extract till that.
            var end_idx: usize = 0;
            if (operatorLine[i] == '*' or operatorLine[i] == '+') {
                end_idx = i - 1;
            } else {
                end_idx = operatorLine.len - 1;
            }
            var operands = ArrayList([]const u8).init(allocator);
            // Once the next operator is found, parse the previous numbers.
            for (operandLines) |line| {
                if (end_idx == operatorLine.len - 1) {
                    try operands.append(line[prev..]);
                } else {
                    try operands.append(line[prev..end_idx]);
                }
            }
            // Create CephelopodOperation.
            const prevOperator = operatorLine[prev];
            try opns.append(CephelopodOperation{ .numbers = operands.items, .operator = prevOperator });
            prev = i;
        }
    }
    return opns.items;
}

test "parseContent2" {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    const allocator = gpa.allocator();

    const operations = try parseContent2(testContent, allocator);

    try expect(operations.len == 4);
    try expect(operations[0].numbers.len == 3);
    try expect(operations[0].operator == '*');
    const expected = "64 ";
    try expect(std.mem.eql(u8, operations[3].numbers[0], expected));
}

pub fn part2(content: []const u8, allocator: Allocator) !usize {
    const operations = try parseContent2(content, allocator);
    var result: u64 = 0;
    for (operations) |opn| {
        result += try getCephelopodResult(opn, allocator);
    }
    return result;
}

pub fn main() !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    var arena = std.heap.ArenaAllocator.init(gpa.allocator());
    const allocator = arena.allocator();
    defer arena.deinit();

    const total = try part1(inputContent, allocator);
    std.debug.print("Result Part 1: {d}\n", .{total});

    const total2 = try part2(inputContent, allocator);
    std.debug.print("Result Part 2: {d}\n", .{total2});
}

test "test input part2" {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    const allocator = gpa.allocator();

    try expect(try part2(testContent, allocator) == 3263827);
}
