const std = @import("std");
const aoc25_zig = @import("aoc25_zig");

const inputContent = @embedFile("data/day2_1.text");

const testContent = "11-22,95-115,998-1012,1188511880-1188511890,222220-222224,1698522-1698528,446443-446449,38593856-38593862,565653-565659,824824821-824824827,2121212118-2121212124";

fn numberOfDigits(n: usize) u32 {
    var count: u32 = 0;
    var num = n;
    while (num != 0) : (num /= 10) {
        count += 1;
    }
    return count;
}

pub fn part1(content: []const u8) !usize {
    var it = std.mem.tokenizeScalar(u8, content, ',');
    var total: usize = 0;
    while (it.next()) |range| {
        var range_it = std.mem.tokenizeScalar(u8, range, '-');
        const start = if (range_it.next()) |s| s else return error.InvalidInput;
        const end = if (range_it.next()) |e| e else return error.InvalidInput;

        const start_num = try std.fmt.parseInt(u64, start, 10);
        const end_num = try std.fmt.parseInt(u64, end, 10);
        for (start_num..end_num + 1) |num| {
            const digits = numberOfDigits(num);
            if (digits % 2 != 0) {
                continue;
            }
            const half = digits / 2;
            const first_half: usize = num / std.math.pow(usize, 10, half);
            const second_half: usize = num % std.math.pow(usize, 10, half);
            if (first_half == second_half) {
                total += num;
            }
        }
    }
    return total;
}

fn repeatDigits(num: usize, times: usize) usize {
    var final = num;
    for (1..times) |_| {
        final = final * std.math.pow(usize, 10, numberOfDigits(num)) + num;
    }
    return final;
}

pub fn part2(content: []const u8) !usize {
    var it = std.mem.tokenizeScalar(u8, content, ',');
    var total: usize = 0;
    while (it.next()) |range| {
        var range_it = std.mem.tokenizeScalar(u8, range, '-');
        const start = if (range_it.next()) |s| s else return error.InvalidInput;
        const end = if (range_it.next()) |e| e else return error.InvalidInput;

        const start_num = try std.fmt.parseInt(u64, start, 10);
        const end_num = try std.fmt.parseInt(u64, end, 10);
        num_blk: for (start_num..end_num + 1) |num| {
            const digits = numberOfDigits(num);
            var i: usize = 1;
            while (i <= digits / 2) : (i += 1) {
                if (digits % i != 0) {
                    // Can't evenly split, so skip
                    continue;
                }
                const reminder = num % std.math.pow(usize, 10, i);
                const num_repeats = digits / i;
                const repeated_num = repeatDigits(reminder, num_repeats);
                if (repeated_num == num) {
                    // Found a valid repeated pattern
                    total += num;
                    continue :num_blk;
                }
            }
        }
    }
    return total;
}

pub fn main() !void {
    const total = try part1();
    std.debug.print("Result Part 1: {d}\n", .{total});

    const total2 = try part2();
    std.debug.print("Result Part 2: {d}\n", .{total2});
}

test "repeatDigits" {
    try std.testing.expect(repeatDigits(12, 3) == 121212);
    try std.testing.expect(repeatDigits(5, 4) == 5555);
}

test "numberOfDigits" {
    try std.testing.expect(numberOfDigits(0) == 0);
    try std.testing.expect(numberOfDigits(5) == 1);
    try std.testing.expect(numberOfDigits(12) == 2);
    try std.testing.expect(numberOfDigits(12345) == 5);
}

test "part1 test input" {
    const result = try part1(testContent);
    try std.testing.expect(result == 1227775554);
}

test "part2 test input" {
    const result = try part2(testContent);
    try std.testing.expect(result == 4174379265);
}
