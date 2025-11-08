#include <algorithm>
#include <cmath>
#include <filesystem>
#include <fstream>
#include <limits>
#include <map>
#include <print>
#include <ranges>
#include <string>
#include <string_view>
#include <unordered_map>
#include <functional>
#include <vector>
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
    for (unsigned long i = s.find(delimiter); i != s.npos; i = s.find(delimiter, prev)) {
        result.push_back(s.substr(prev, i - prev));
        prev = i + 1;
    }
    if (prev < s.size()) result.push_back(s.substr(prev));
    return result;
}

struct Point {
    int x;
    int y;
    inline bool operator==(const Point &p) const { return x == p.x && y == p.y; }
    inline Point operator+(const Point &p) const { return {x + p.x, y + p.y}; }
    double length() { return std::abs(std::sqrt((double)(x * x + y * y))); }
    double angle() { return std::atan2(y, x) + std::numbers::pi; }
};

struct Point_Hash {
    inline std::size_t operator()(const Point &p) const {
        return p.x * 3137 + p.y;
    }
};

template <> struct std::formatter<Point> : std::formatter<std::string> {
    auto format(const Point &p, std::format_context &ctx) const {
        return formatter<std::string>::format("Point{.x=" + std::to_string(p.x) + ", .y=" + std::to_string(p.y) + "}", ctx);
    }
};

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
                // std::print("{}, ", op1);
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


std::string part1(const std::string_view input) {
    Point dirs[]{Point{1, 0}, Point{0, 1}, Point{-1, 0}, Point{0, -1}};
    auto cur_pos = Point{0, 0};
    size_t cur_dir = 0;
    std::unordered_map<Point, long long, Point_Hash> visited;
    bool first_read = true;
    auto input_cb = [&]() -> long long {
        if(visited.contains(cur_pos)) return visited[cur_pos];
        return 0;
    };
    auto output_cb = [&](long long output) {
        if(first_read) {
            visited[cur_pos] = output;
        } else {
            cur_dir = output == 0 ? (cur_dir + 4 - 1) % 4 : (cur_dir + 1) % 4;
            cur_pos = cur_pos + dirs[cur_dir];
        }
        first_read = !first_read;
    };
    intcode_computer(input, input_cb, output_cb);
    return std::to_string(visited.size());
}

std::string part2(const std::string_view input) {
    Point dirs[]{Point{1, 0}, Point{0, 1}, Point{-1, 0}, Point{0, -1}};
    auto cur_pos = Point{0, 0};
    size_t cur_dir = 0;
    std::unordered_map<Point, long long, Point_Hash> visited{{cur_pos, 1}};
    bool first_read = true;
    auto input_cb = [&]() -> long long {
        if(visited.contains(cur_pos)) return visited[cur_pos];
        return 0;
    };
    auto output_cb = [&](long long output) {
        if(first_read) {
            visited[cur_pos] = output;
        } else {
            cur_dir = output == 0 ? (cur_dir + 4 - 1) % 4 : (cur_dir + 1) % 4;
            cur_pos = cur_pos + dirs[cur_dir];
        }
        first_read = !first_read;
    };
    intcode_computer(input, input_cb, output_cb);

    int min_x = std::numeric_limits<int>::max();
    int min_y = std::numeric_limits<int>::max();
    int max_x = std::numeric_limits<int>::min();
    int max_y = std::numeric_limits<int>::min();

    for(auto it = visited.begin(); it != visited.end(); ++it) {
        auto p = it->first;
        min_x = std::min(min_x, p.x);
        max_x = std::max(max_x, p.x);
        min_y = std::min(min_y, p.y);
        max_y = std::max(max_y, p.y);
    }

    std::string res = "\n";
    for(int x = max_x; x >= min_x; x--) {
        for(int y = min_y; y <= max_y; y++) {
            Point p{x, y};
            auto color = " ";
            if(visited.contains(p)) {
                color = visited[p] == 0 ? " " : "█";
            }
            res += color;
        }
        res += "\n";
    }

    return res;
}

int main(int argc, char **argv) {
    if (argc != 2) {
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
