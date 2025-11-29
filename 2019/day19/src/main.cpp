#include <print>
#include <fstream>
#include <filesystem>
#include <string>
#include <string_view>
#include <unordered_set>
#include <vector>
#include <ranges>
#include <map>
#include <cmath>
#include <functional>
#include <assert.h>
namespace fs = std::filesystem;

std::string strip(std::string_view s) {
    size_t spaces_start = 0;
    while (std::isspace(s[spaces_start])) spaces_start++;
    size_t spaces_end = s.size();
    while (std::isspace(s[spaces_end - 1])) spaces_end--;
    return std::string(s.substr(spaces_start, spaces_end - spaces_start));
}

std::vector<std::string> split(std::string_view s_input, std::string_view delimiter) {
    std::vector<std::string> result;
    auto s = std::string(s_input);
    unsigned long prev = 0;
    for(unsigned long i = s.find(delimiter); i != s.npos; i = s.find(delimiter, prev)) {
        result.push_back(s.substr(prev, i - prev));
        prev = i + delimiter.length();
    }
    if(prev < s.length()) result.push_back(s.substr(prev));
    return result;
}

void intcode_computer(const std::string_view input, const std::function<long long()>& input_cb, const std::function<void(long long)>& output_cb) {
     auto program = split(input, ",") 
    | std::views::transform([](std::string s) { return std::stoll(s); })
    | std::views::enumerate
    | std::ranges::to<std::map>();
    auto program_size = program.size();
    auto relative_base = 0ll;
    auto value_from_mode_addr = [&](size_t i, size_t mode) {
        if(mode == 0) return program[i];
        if(mode == 1) return (long long) i;
        return program[i] + relative_base;
    }; 
    auto value_from_mode = [&](size_t i, size_t mode) {
        return program[value_from_mode_addr(i, mode)];
    }; 
    auto extract_mode = [&](size_t op_with_modes, size_t mode_index) {
        return (op_with_modes / (size_t) std::pow(10, mode_index + 1)) % 10;
    };   
    auto extract_params3 = [&](size_t op_with_modes, size_t i) {
        return std::make_tuple(
            value_from_mode(i + 1, extract_mode(op_with_modes, 1)), 
            value_from_mode(i + 2, extract_mode(op_with_modes, 2)), 
            value_from_mode_addr(i + 3, extract_mode(op_with_modes, 3))
        );
    };
    auto extract_params2 = [&](size_t op_with_modes, size_t i) {
        return std::make_tuple(
            value_from_mode(i + 1, extract_mode(op_with_modes, 1)), 
            value_from_mode(i + 2, extract_mode(op_with_modes, 2))
        );
    };
    auto extract_params1 = [&](size_t op_with_modes, size_t i) {
        return  value_from_mode(i + 1, extract_mode(op_with_modes, 1));
    };
    for(size_t i = 0; i < program_size; ) {
        auto op_with_modes = program[i];
        if(op_with_modes == 99) break;
        auto op = op_with_modes % 100;
        long long op1 = 0, op2 = 0, dest = 0;
        switch (op) {
            case 1:
                std::tie(op1, op2, dest) = extract_params3(op_with_modes, i);
                program[dest] = op1 + op2;
                i += 4;
                break;
            case 2:
                std::tie(op1, op2, dest) = extract_params3(op_with_modes, i);
                program[dest] = op1 * op2;
                i += 4;
                break;
            case 3:
                program[value_from_mode_addr(i + 1, extract_mode(op_with_modes, 1))] = input_cb();
                i += 2;
                break;
            case 4:
                op1 = extract_params1(op_with_modes, i);
                output_cb(op1);
                i += 2;
                break;
            case 5:
                std::tie(op1, op2) = extract_params2(op_with_modes, i);
                i = op1 != 0 ? op2 : i + 3;
                break;
            case 6:
                std::tie(op1, op2) = extract_params2(op_with_modes, i);
                i = op1 == 0 ? op2 : i + 3;
                break;
            case 7:
                std::tie(op1, op2, dest) = extract_params3(op_with_modes, i);
                program[dest] = op1 < op2 ? 1 : 0;
                i += 4;
                break;
            case 8:
                std::tie(op1, op2, dest) = extract_params3(op_with_modes, i);
                program[dest] = op1 == op2 ? 1 : 0;
                i += 4;
                break;
            case 9:
                op1 = extract_params1(op_with_modes, i);
                relative_base += op1;
                i += 2;
                break;
            default:
                std::println("Unknown opcode: {} at position {}", op, i);
        }
    }
}

struct Point {
    int x;
    int y;

    bool operator==(const Point& other) const {
        return x == other.x && y == other.y;
    }
};

struct PointHash {
    std::size_t operator()(const Point& p) const {
        return std::hash<int>()(p.x) ^ std::hash<int>()(p.y);
    }
};

std::string part1(const std::string_view input) {
    std::unordered_set<Point, PointHash> affected_points;
    for (int y = 0; y < 50; ++y) {
        for (int x = 0; x < 50; ++x) {
            Point current_position{x, y};
            auto input_cb = [&]() -> long long {
                static bool sending_x = false;
                sending_x = !sending_x;

                if(sending_x) return current_position.x;
                return current_position.y;
            };
            auto output_cb = [&](long long output) {
                if(output == 1) affected_points.insert(current_position);
            };

            intcode_computer(input, input_cb, output_cb);
        }
    }

    return std::to_string(affected_points.size());
}

std::string part2(const std::string_view input) {
    std::unordered_set<Point, PointHash> affected_points;
    Point top_left_100x100{-1, -1};
    for (int x = 1000; ; ++x) {
        int last_y = 0;
        Point first_affected_point{-1, -1};
        for (int y = last_y; y < 1'000'000; ++y) {
            Point current_position{x, y};

            auto input_cb = [&]() -> long long {
                static bool sending_x = false;
                sending_x = !sending_x;

                if(sending_x) return current_position.x;
                return current_position.y;
            };

            auto output_cb = [&](long long output) {
                if(output == 1) {
                    affected_points.insert(current_position);
                    if(first_affected_point.x == -1) first_affected_point = current_position;
                }
                if(output == 0 && first_affected_point.x != -1) {
                    last_y = first_affected_point.y;
                    y = 1'000'000; // Break inner loop
                }
            }; 
            intcode_computer(input, input_cb, output_cb);
        }

        Point top_left{first_affected_point.x - 99, first_affected_point.y};
        Point bottom_left{top_left.x, top_left.y + 99};
        Point bottom_right{first_affected_point.x, first_affected_point.y + 99};
        if(affected_points.contains(top_left) && affected_points.contains(bottom_left) && affected_points.contains(bottom_right)) {
            top_left_100x100 = top_left;
            break;
        }
    }

    return std::to_string(top_left_100x100.x * 10000 + top_left_100x100.y);
}

int main(int argc, char **argv) {
    if(argc != 2) {
        std::print("Usage: {} file_name", argv[0]);
        return -1;
    }
    const auto file_path = argv[1];

    auto size = fs::file_size(file_path);
    std::string input(size, '\0');
    std::ifstream input_file(file_path);
    input_file.read(&input[0], size);
    input = strip(input);
    
    std::println("Part 1: {}", part1(input));
    std::println("Part 2: {}", part2(input));

    return 0;
}