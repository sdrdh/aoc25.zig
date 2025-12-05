const std = @import("std");
const aoc25_zig = @import("aoc25_zig");
const Allocator = std.mem.Allocator;
const DoublyLinkedList = std.DoublyLinkedList;
const Node = DoublyLinkedList.Node;

const inputContent = @embedFile("data/day3.txt");

const testContent = "987654321111111\n811111111111119\n234234234234278\n818181911112111";

const DigitNode = struct {
    value: u8,
    prev: ?*DigitNode = null,
    next: ?*DigitNode = null,
};

pub fn part1(content: []const u8, allocator: Allocator) !usize {
    var it = std.mem.tokenizeScalar(u8, content, '\n');
    var total: usize = 0;
    while (it.next()) |row| {
        const joltage = try findNBatteryJoltageForARow(row, 2, allocator);
        total += joltage;
    }
    return total;
}

fn findNBatteryJoltageForARow(row: []const u8, n: usize, allocator: Allocator) !usize {
    var first = try allocator.create(DigitNode);
    defer allocator.destroy(first);
    first.* = .{ .value = row[0] - '0' };
    var curr: ?*DigitNode = first;
    for (1..n) |i| {
        const digit = row[i] - '0';
        const digit_node = try allocator.create(DigitNode);
        digit_node.* = .{ .value = digit };
        if (curr) |c| {
            c.next = digit_node;
            digit_node.prev = c;
        }
        curr = digit_node;
    }
    var last = curr;
    for (row[n..]) |c| {
        const digit = c - '0';
        curr = first;
        while (curr != null) {
            const node = curr orelse break;
            if (node.next != null and node.value < node.next.?.value) {
                if (node.prev != null) {
                    node.prev.?.next = node.next;
                    node.next.?.prev = node.prev;
                } else {
                    first = node.next orelse unreachable;
                    first.prev = null;
                }
                const new_digit_node = try allocator.create(DigitNode);
                new_digit_node.* = .{ .value = digit };
                last.?.next = new_digit_node;
                new_digit_node.prev = last;
                last = new_digit_node;
                break;
            }
            if (node.next == null) {
                if (node.value < digit) {
                    const digit_node = try allocator.create(DigitNode);
                    digit_node.* = .{ .value = digit };
                    node.prev.?.next = digit_node;
                    digit_node.prev = node.prev.?;
                    node.next = null;
                    node.prev = null;
                    last = digit_node;
                }
                break;
            }
            curr = node.next;
        }
    }
    var result: usize = 0;
    var it: ?*DigitNode = first;
    while (it != null) {
        if (it == null) break;
        result = result * 10 + it.?.value;
        it = it.?.next;
    }
    return result;
}

pub fn part2(content: []const u8, allocator: Allocator) !usize {
    var it = std.mem.tokenizeScalar(u8, content, '\n');
    var total: usize = 0;
    while (it.next()) |row| {
        const joltage = try findNBatteryJoltageForARow(row, 12, allocator);
        total += joltage;
    }
    return total;
}

pub fn main() !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    const allocator = gpa.allocator();
    const total = try part1(inputContent, allocator);
    std.debug.print("Result Part 1: {d}\n", .{total});

    const total2 = try part2(inputContent, allocator);
    std.debug.print("Result Part 2: {d}\n", .{total2});
}

test "test input part1" {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    const allocator = gpa.allocator();

    try std.testing.expect(try part1(testContent, allocator) == 357);
}

test "test input part2" {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    const allocator = gpa.allocator();

    try std.testing.expect(try part2(testContent, allocator) == 3121910778619);
}

test "findNJoltageForARow" {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    const allocator = gpa.allocator();

    try std.testing.expect(try findNBatteryJoltageForARow("1234567890", 2, allocator) == 90);
    try std.testing.expect(try findNBatteryJoltageForARow("234234234234278", 2, allocator) == 78);
    try std.testing.expect(try findNBatteryJoltageForARow("818181911112111", 12, allocator) == 888911112111);
}
