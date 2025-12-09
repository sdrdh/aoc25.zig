const std = @import("std");
const aoc25_zig = @import("aoc25_zig");
const Allocator = std.mem.Allocator;
const ArrayList = std.array_list.Managed;
const expect = std.testing.expect;

const inputContent = @embedFile("data/day7.txt");

const testContent = @embedFile("data/day7_sample.txt");

fn getDimensions(content: []const u8) struct { usize, usize } {
    var it = std.mem.tokenizeScalar(u8, content, '\n');
    var rows: usize = 0;
    var cols: usize = 0;

    while (it.next()) |line| {
        rows += 1;
        cols = line.len;
    }

    return .{ rows, cols };
}

fn parseContent(content: []const u8, allocator: Allocator) ![][]u8 {
    const dimensions = getDimensions(content);
    const rows = dimensions[0];
    const cols = dimensions[1];
    var it = std.mem.tokenizeScalar(u8, content, '\n');
    var grid = try allocator.alloc([]u8, rows);
    var i: usize = 0;
    while (it.next()) |line| {
        grid[i] = try allocator.alloc(u8, cols);

        for (line, 0..) |c, j| {
            grid[i][j] = c;
        }
        i += 1;
    }
    return grid;
}

pub fn part1(content: []const u8, allocator: Allocator) !struct { usize, [][]u8 } {
    const grid = try parseContent(content, allocator);
    var count: usize = 0;
    for (0..grid.len - 1) |i| {
        for (0..grid[0].len) |j| {
            if (grid[i][j] == 'S' or grid[i][j] == '|') {
                if (grid[i + 1][j] != '^') {
                    grid[i + 1][j] = '|';
                    continue;
                }
                count += 1;
                if (j >= 1 and i + 1 < grid.len and grid[i + 1][j - 1] != '|') {
                    grid[i + 1][j - 1] = '|';
                }
                if (j + 1 < grid[0].len and i + 1 < grid.len and grid[i + 1][j + 1] != '|') {
                    grid[i + 1][j + 1] = '|';
                }
            }
        }
    }
    std.debug.print("result: {d}\n", .{count});
    return .{ count, grid };
}

test "test input part1" {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    const allocator = gpa.allocator();

    const response = try part1(testContent, allocator);

    const count = response[0];
    const grid = response[1];
    for (grid) |line| {
        std.debug.print("{s}\n", .{line});
    }

    try std.testing.expect(count == 21);
}

pub fn part2(grid: [][]u8, allocator: Allocator) !usize {
    const gridN = try allocator.alloc([]usize, grid.len + 1);
    for (0..grid.len) |i| {
        gridN[i] = try allocator.alloc(usize, grid[0].len);
    }
    for (0..grid[0].len) |i| {
        if (grid[0][i] == 'S') {
            gridN[0][i] = 1;
        } else {
            gridN[0][i] = 0;
        }
    }
    for (1..grid.len) |i| {
        for (0..grid[0].len) |j| {
            if (grid[i][j] != '|') {
                gridN[i][j] = 0;
            } else {
                var ways: usize = gridN[i - 1][j];
                if (j > 1 and grid[i][j - 1] == '^') {
                    ways += gridN[i - 1][j - 1];
                }
                if (j < grid[0].len - 1 and grid[i][j + 1] == '^') {
                    ways += gridN[i - 1][j + 1];
                }
                gridN[i][j] = ways;
            }
        }
    }
    var count: usize = 0;
    for (0..grid[0].len) |i| {
        count += gridN[grid.len - 1][i];
    }
    return count;
}

test "test input part2" {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    const allocator = gpa.allocator();

    const response = try part1(testContent, allocator);

    _ = response[0];
    const grid = response[1];
    for (grid) |line| {
        std.debug.print("{s}\n", .{line});
    }

    const count = try part2(grid, allocator);

    try expect(count == 40);
}

pub fn main() !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    var arena = std.heap.ArenaAllocator.init(gpa.allocator());
    const allocator = arena.allocator();
    defer arena.deinit();

    const response = try part1(inputContent, allocator);
    std.debug.print("Result Part 1: {d}\n", .{response[0]});

    const total2 = try part2(response[1], allocator);
    std.debug.print("Result Part 2: {d}\n", .{total2});
}
