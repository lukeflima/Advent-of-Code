#include <cstdio>
#include <print>
#include <fstream>
#include <filesystem>
#include <string>
#include <string_view>
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

std::string part1(const std::string_view input) {
    
    // std::vector<std::string> inv = {
    //     "hypercube",
    //     "shell",
    //     "whirled peas",
    //     "spool of cat6",
    //     "mouse",
    //     "antenna",
    //     "hologram",
    //     "semiconductor",
    // };
    // static std::string command_msg = {
    //     "east\n"
    //     "south\n"
    //     "south\n"
    //     "take hologram\n"
    //     "north\n"
    //     "north\n"
    //     "west\n"
    //     "south\n"
    //     "take mouse\n"
    //     "west\n"
    //     "take whirled peas\n"
    //     "east\n"
    //     "east\n"
    //     "take shell\n"
    //     "west\n"
    //     "north\n"
    //     "west\n"
    //     "north\n"
    //     "north\n"
    //     "west\n"
    //     "take semiconductor\n"
    //     "east\n"
    //     "south\n"
    //     "west\n"
    //     "south\n"
    //     "take hypercube\n"
    //     "north\n"
    //     "east\n"
    //     "south\n"
    //     "west\n"
    //     "take antenna\n"
    //     "south\n"
    //     "take spool of cat6\n"
    //     "north\n"
    //     "west\n"
    //     "south\n"
    //     "south\n"
    //     "inv\n"
    // };
    // std::string drop_all;
    // for(auto item: inv) {
    //     drop_all += "drop " + item + "\n";
    // }

    // // std::vector<std::string> combinations;
    // for (int mask = 1; mask < (1 << inv.size()); ++mask) {
    //     std::string combination;
    //     for (int i = 0; i < (int) inv.size(); ++i) {
    //         if (mask & (1 << i)) {
    //             combination += "take " + inv[i] + "\n";
    //         }
    //     }
    //     command_msg += drop_all + combination + "inv\n" + "south\n";
    //     // combinations.push_back(combination);
    // }

    static std::string command_msg = {
        "south\n"
        "take mouse\n"
        "north\n"
        "west\n"
        "north\n"
        "north\n"
        "west\n"
        "take semiconductor\n"
        "east\n"
        "south\n"
        "west\n"
        "south\n"
        "take hypercube\n"
        "north\n"
        "east\n"
        "south\n"
        "west\n"
        "take antenna\n"
        "west\n"
        "south\n"
        "south\n"
        "south\n"
    };

    auto input_cb = [&]() -> long long {
        static size_t index;
        if(index < command_msg.size()) {
            return (long long) command_msg[index++];
        }
        return 0;
    };
    auto output_cb = [&](long long output) {
        std::print("{}", (char) output);
    };

    intcode_computer(input, input_cb, output_cb);

    return "";
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
    
    part1(input);

    return 0;
}