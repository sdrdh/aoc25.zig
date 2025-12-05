const std = @import("std");
const aoc25_zig = @import("aoc25_zig");
const Allocator = std.mem.Allocator;
const ArrayList = std.array_list.Managed;

const inputContent = @embedFile("data/day4.txt");

const testContent = "..@@.@@@@.\n@@@.@.@.@@\n@@@@@.@.@@\n@.@@@@..@.\n@@.@@@@.@@\n.@@@@@@@.@\n.@.@.@.@@@\n@.@@@.@@@@\n.@@@@@@@@.\n@.@.@@@.@.";

const neighborOffsets = [_][2]isize{
    .{ -1, -1 },
    .{ -1, 0 },
    .{ -1, 1 },
    .{ 0, -1 },
    .{ 0, 1 },
    .{ 1, -1 },
    .{ 1, 0 },
    .{ 1, 1 },
};

fn getGridSize(content: []const u8) struct { usize, usize } {
    var it = std.mem.tokenizeScalar(u8, content, '\n');
    var rows: usize = 0;
    var row_length: usize = 0;
    while (it.next()) |line| {
        rows += 1;
        row_length = line.len;
    }
    return .{ rows, row_length };
}

fn clearGrid(grid: [][]u8) void {
    const rows = grid.len;
    const row_length = grid[0].len;
    for (0..rows) |r| {
        for (0..row_length) |c| {
            if (grid[r][c] == 'x') {
                grid[r][c] = '.';
            }
        }
    }
}

fn parseToGrid(content: []const u8, rows: usize, cols: usize, allocator: Allocator) ![][]u8 {
    var it = std.mem.tokenizeScalar(u8, content, '\n');
    const grid: [][]u8 = try allocator.alloc([]u8, rows);
    var rows_index: usize = 0;
    while (it.next()) |line| {
        grid[rows_index] = try allocator.alloc(u8, cols);
        var col_index: usize = 0;
        for (line) |c| {
            grid[rows_index][col_index] = c;
            col_index += 1;
        }
        rows_index += 1;
    }
    return grid;
}

test "parseToGrid test" {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    const allocator = gpa.allocator();

    const grid = try parseToGrid("1\n2\n3", 3, 1, allocator);
    try std.testing.expect(grid.len == 3);
    try std.testing.expect(grid[0][0] == '1');
}

fn markRemovable(grid: [][]u8) usize {
    const rows = grid.len;
    const row_length = grid[0].len;
    const num_rows: isize = @intCast(rows);
    const num_cols: isize = @intCast(row_length);
    var marked: usize = 0;
    for (0..rows) |r| {
        for (0..row_length) |c| {
            if (grid[r][c] != '@') {
                continue;
            }
            var occupied_neighbors: usize = 0;
            for (neighborOffsets) |offset| {
                const nr: isize = @as(isize, @intCast(r)) + offset[0];
                const nc = @as(isize, @intCast(c)) + offset[1];
                if (nr < 0 or nc < 0 or nr >= num_rows or nc >= num_cols) {
                    continue;
                }
                const neighbour = grid[@as(usize, @intCast(nr))][@as(usize, @intCast(nc))];
                if (neighbour == '@' or neighbour == 'x') {
                    occupied_neighbors += 1;
                }
            }
            if (occupied_neighbors < 4) {
                grid[r][c] = 'x';
                marked += 1;
            }
        }
    }
    return marked;
}

pub fn part1(content: []const u8, allocator: Allocator) !usize {
    const grid_size = getGridSize(content);
    const grid = try parseToGrid(content, grid_size[0], grid_size[1], allocator);
    const marked = markRemovable(grid);

    return marked;
}

pub fn part2(content: []const u8, allocator: Allocator) !usize {
    const grid_size = getGridSize(content);
    const grid = try parseToGrid(content, grid_size[0], grid_size[1], allocator);
    var total_marked: usize = 0;
    while (true) {
        const marked = markRemovable(grid);
        if (marked == 0) {
            break;
        }
        total_marked += marked;
        clearGrid(grid);
    }
    return total_marked;
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

test "test input part1" {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    const allocator = gpa.allocator();

    try std.testing.expect(try part1(testContent, allocator) == 13);
}

test "test input part2" {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    const allocator = gpa.allocator();

    try std.testing.expect(try part2(testContent, allocator) == 43);
}
