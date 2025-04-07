#include <algorithm>
#include <cassert>
#include <cctype>
#include <print>
#include <fstream>
#include <filesystem>
#include <string>
#include <string_view>
#include <vector>
#include <ranges>
namespace fs = std::filesystem;

std::string strip(std::string_view s) {
    size_t spaces_start = 0;
    while (std::isspace(s[spaces_start])) spaces_start++;
    size_t spaces_end = s.size();
    while (std::isspace(s[spaces_end - 1])) spaces_end--;
    return std::string(s.substr(spaces_start, spaces_end));
}

std::vector<std::string> split(std::string_view s_input, std::string_view delimiter) {
    std::vector<std::string> result;
    auto s = std::string(s_input);
    unsigned long prev = 0;
    for(unsigned long i = s.find(delimiter); i != s.npos; i = s.find(delimiter, prev)) {
        result.push_back(s.substr(prev, i - prev));
        prev = i + 1;
    }
    if(s.length() > 0) result.push_back(s.substr(prev));
    return result;
}

std::string part1(const std::string_view input) {
    auto program = split(input, ",") 
        | std::views::transform([](std::string s) { return std::stoull(s); })
        | std::ranges::to<std::vector>();
    program[1] = 12;
    program[2] = 2;
    for(size_t i = 0; i < program.size(); i += 4) {
        auto op = program[i];
        if(op == 99) break;
        auto op1 = program[program[i + 1]];
        auto op2 = program[program[i + 2]];
        auto dest = program[i + 3];
        if(op == 1) {
            program[dest] = op1 + op2;
        } else if(op == 2) {
            program[dest] = op1 * op2;
        }
    }
    return std::to_string(program[0]);
}

std::string part2(const std::string_view input) {
    auto orginal_program = split(input, ",") 
        | std::views::transform([](std::string s) { return std::stoull(s); })
        | std::ranges::to<std::vector>();
    for(unsigned long long noun = 0; noun < 100; noun++) {
        for(unsigned long long verb = 0; verb < 100; verb++) {
            auto program = orginal_program;
            program[1] = noun;
            program[2] = verb;
            for(size_t i = 0; i < program.size(); i += 4) {
                auto op = program[i];
                if(op == 99) break;
                auto op1 = program[program[i + 1]];
                auto op2 = program[program[i + 2]];
                auto dest = program[i + 3];
                if(op == 1) {
                    program[dest] = op1 + op2;
                } else if(op == 2) {
                    program[dest] = op1 * op2;
                }
            }
            if (program[0] == 19690720) return std::to_string(100 * noun + verb);
        }
    }
    assert(false && "Unreachable");
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