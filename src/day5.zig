const std = @import("std");
const aoc25_zig = @import("aoc25_zig");
const Allocator = std.mem.Allocator;
const ArrayList = std.array_list.Managed;
const HashMap = std.AutoHashMap;

const inputContent = @embedFile("data/day5.txt");

const testContent = @embedFile("data/day5_sample.txt");

const Range = struct {
    start: u64,
    end: u64,
};

fn parseContent(content: []const u8, allocator: Allocator) !struct { []Range, []u64 } {
    // Split content into two sections: ranges and numbers
    var it = std.mem.tokenizeSequence(u8, content, "\n\n");

    var ranges_it = std.mem.tokenizeScalar(u8, it.next() orelse "", '\n');
    var numbers_it = std.mem.tokenizeScalar(u8, it.next() orelse "", '\n');
    // Initialize ArrayLists for ranges and numbers
    var ranges = ArrayList(Range).init(allocator);
    var numbers = ArrayList(u64).init(allocator);

    // Parse ranges
    while (ranges_it.next()) |line| {
        var line_it = std.mem.tokenizeScalar(u8, line, '-');
        const start_str = if (line_it.next()) |s| s else continue;
        const end_str = if (line_it.next()) |e| e else continue;
        const start_num = try std.fmt.parseInt(u64, start_str, 10);
        const end_num = try std.fmt.parseInt(u64, end_str, 10);
        try ranges.append(.{ .start = start_num, .end = end_num });
    }

    // Parse numbers
    while (numbers_it.next()) |line| {
        const num = try std.fmt.parseInt(u64, line, 10);
        try numbers.append(num);
    }
    return .{ ranges.items, numbers.items };
}

test "parseContent test" {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    const allocator = gpa.allocator();

    const parsed = try parseContent(testContent, allocator);
    try std.testing.expect(parsed[0].len == 4);
    try std.testing.expect(parsed[1].len == 6);
}

pub fn part1(content: []const u8, allocator: Allocator) !usize {
    const parsed = try parseContent(content, allocator);
    const ranges = parsed[0];
    const numbers = parsed[1];
    var total: usize = 0;
    // Check each number against all ranges
    for (numbers) |num| {
        var contained = false;
        for (ranges) |range| {
            if (num >= range.start and num <= range.end) {
                contained = true;
                break;
            }
        }
        if (contained) {
            total += 1;
        }
    }
    return total;
}

test "test input part1" {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    const allocator = gpa.allocator();

    try std.testing.expect(try part1(testContent, allocator) == 3);
}

fn lessThanEqual(_: void, a: Range, b: Range) bool {
    if (a.start < b.start) {
        return true;
    } else if (a.start == b.start and a.end < b.end) {
        return true;
    }
    return false;
}

pub fn part2(content: []const u8, allocator: Allocator) !usize {
    const parsed = try parseContent(content, allocator);
    const ranges = parsed[0];

    std.mem.sort(Range, ranges, {}, lessThanEqual);

    var rangesMerged = ArrayList(Range).init(allocator);
    for (ranges) |range| {
        if (rangesMerged.items.len == 0) {
            try rangesMerged.append(range);
            continue;
        }
        var last = &rangesMerged.items[rangesMerged.items.len - 1];
        if (range.start <= last.end) {
            // Overlap, so merge
            if (range.end > last.end) {
                last.end = range.end;
            }
        } else {
            // No overlap, so add new range
            try rangesMerged.append(range);
        }
    }
    var total: usize = 0;
    for (rangesMerged.items) |range| {
        total += range.end - range.start + 1;
    }
    return total;
}

test "test input part2" {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    const allocator = gpa.allocator();

    try std.testing.expect(try part2(testContent, allocator) == 14);
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
