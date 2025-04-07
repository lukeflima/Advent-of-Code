#include <print>
#include <fstream>
#include <filesystem>
#include <string_view>
#include <vector>
#include <ranges>
#include <algorithm>
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
    if(prev < s.size()) result.push_back(s.substr(prev));
    return result;
}

std::string part1(const std::string_view input) {
    auto program = split(input, ",") 
        | std::views::transform([](std::string s) { return std::stoull(s); })
        | std::ranges::to<std::vector>();
    auto extract_params = [&](size_t op_with_modes, size_t i) {
        auto mode1 = (op_with_modes / 100) % 10;
        auto mode2 = (op_with_modes / 1000) % 10;
        return std::make_tuple(mode1 == 0 ? program[program[i + 1]] : program[i + 1], mode2 == 0 ? program[program[i + 2]] : program[i + 2], program[i + 3]);
    };
 
    auto res = 0ll;
    for(size_t i = 0; i < program.size(); ) {
        auto op_with_modes = program[i];
        if(op_with_modes == 99) break;
        auto op = op_with_modes % 100;
        long long op1 = 0, op2 = 0, dest = 0;
        switch (op) {
            case 1:
                std::tie(op1, op2, dest) = extract_params(op_with_modes, i);
                program[dest] = op1 + op2;
                i += 4;
                break;
            case 2:
                std::tie(op1, op2, dest) = extract_params(op_with_modes, i);
                program[dest] = op1 * op2;
                i += 4;
                break;
            case 3:
                program[program[i + 1]] = 1;
                i += 2;
                break;
            case 4:
                res = program[program[i + 1]];  
                i += 2;
                break;

        }
    }
    return std::to_string(res);
}

std::string part2(const std::string_view input) {
    auto program = split(input, ",") 
        | std::views::transform([](std::string s) { return std::stoll(s); })
        | std::ranges::to<std::vector>();
    auto extract_params3 = [&](size_t op_with_modes, size_t i) {
        auto mode1 = (op_with_modes / 100) % 10;
        auto mode2 = (op_with_modes / 1000) % 10;
        return std::make_tuple(mode1 == 0 ? program[program[i + 1]] : program[i + 1], mode2 == 0 ? program[program[i + 2]] : program[i + 2], program[i + 3]);
    };
    auto extract_params2 = [&](size_t op_with_modes, size_t i) {
        auto mode1 = (op_with_modes / 100) % 10;
        auto mode2 = (op_with_modes / 1000) % 10;
        return std::make_tuple(mode1 == 0 ? program[program[i + 1]] : program[i + 1], mode2 == 0 ? program[program[i + 2]] : program[i + 2]);
    };
    auto res = 0ll;
    for(size_t i = 0; i < program.size(); ) {
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
                program[program[i + 1]] = 5;
                i += 2;
                break;
            case 4:
                res = program[program[i + 1]];  
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
            default:
                std::println("Unknown opcode: {} at position {}", op, i);
        }
    }
    return std::to_string(res);

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