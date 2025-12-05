const std = @import("std");
const aoc25_zig = @import("aoc25_zig");

const inputContent = @embedFile("data/day1.txt");
const allocator = std.mem.Allocator.default;

pub fn part1() !u32 {
    var it = std.mem.tokenizeScalar(u8, inputContent, '\n');
    var total: u32 = 0;
    var current: u32 = 50;
    while (it.next()) |line| {
        const direction = line[0];
        const count: u32 = try std.fmt.parseInt(u32, line[1..], 10) % 100;
        switch (direction) {
            'R' => current = current + count,
            'L' => if (count > current) {
                current = 100 + current - count;
            } else {
                current = current - count;
            },
            else => return error.InvalidDirection,
        }
        current = current % 100;
        if (current == 0) {
            total += 1;
        }
    }
    return total;
}

pub fn part2() !u32 {
    var it = std.mem.tokenizeScalar(u8, inputContent, '\n');
    var total: u32 = 0;
    var current: u32 = 50;
    var next: u32 = 0;
    while (it.next()) |line| {
        const direction = line[0];
        const countStr = line[1..];
        const count = try std.fmt.parseInt(u32, countStr, 10);
        switch (direction) {
            'R' => {
                next = current + count;
                total += next / 100;
                current = next % 100;
            },
            'L' => {
                next = if (count % 100 > current)
                    100 + current - (count % 100)
                else
                    current - (count % 100);
                var toAdd = count / 100;
                if (count % 100 > current and current != 0) {
                    toAdd += 1;
                }
                if (next == 0) {
                    toAdd += 1;
                }
                total += toAdd;
                current = 0 + next;
            },
            else => return error.InvalidDirection,
        }
        std.debug.assert(current < 100);
    }
    return total;
}

pub fn main() !void {
    const total = try part1();
    std.debug.print("Result: {d}\n", .{total});
    const total2 = try part2();
    std.debug.print("Result part 2: {d}\n", .{total2});
}
