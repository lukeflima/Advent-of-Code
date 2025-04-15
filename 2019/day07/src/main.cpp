#include <cstddef>
#include <print>
#include <fstream>
#include <filesystem>
#include <string_view>
#include <vector>
#include <ranges>
#include <tuple>
#include <algorithm>
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
        prev = i + 1;
    }
    if(prev < s.length()) result.push_back(s.substr(prev));
    return result;
}

auto extract_params3(auto &program, size_t op_with_modes, size_t i) {
    auto mode1 = (op_with_modes / 100) % 10;
    auto mode2 = (op_with_modes / 1000) % 10;
    return std::make_tuple(mode1 == 0 ? program[program[i + 1]] : program[i + 1], mode2 == 0 ? program[program[i + 2]] : program[i + 2], program[i + 3]);
};

auto extract_params2(auto &program, size_t op_with_modes, size_t i) {
    auto mode1 = (op_with_modes / 100) % 10;
    auto mode2 = (op_with_modes / 1000) % 10;
    return std::make_tuple(mode1 == 0 ? program[program[i + 1]] : program[i + 1], mode2 == 0 ? program[program[i + 2]] : program[i + 2]);
};

std::string part1(const std::string_view input) {
    auto original_program = split(input, ",") 
        | std::views::transform([](std::string s) { return std::stoull(s); })
        | std::ranges::to<std::vector>();
    
    std::array<unsigned long long, 5> phases = {0ull, 1ull, 2ull, 3ull, 4ull};
    auto max_res = 0ull;
    do {
        auto res = 0ull;
        for(size_t amp = 0; amp < 5; amp++){
            auto id = phases[amp];
            auto program = original_program;  
            auto first = true;
            auto finished = false;
            for(size_t i = 0; i < program.size() && !finished; ) {
                auto op_with_modes = program[i];
                if(op_with_modes == 99) break;
                auto op = op_with_modes % 100;
                long long op1 = 0, op2 = 0, dest = 0;
                switch (op) {
                    case 1:
                        std::tie(op1, op2, dest) = extract_params3(program, op_with_modes, i);
                        program[dest] = op1 + op2;
                        i += 4;
                        break;
                    case 2:
                        std::tie(op1, op2, dest) = extract_params3(program, op_with_modes, i);
                        program[dest] = op1 * op2;
                        i += 4;
                        break;
                    case 3:
                        if (first) {
                            program[program[i + 1]] = id;
                            first = false;
                        } else {
                            program[program[i + 1]] = res;
                        }
                        i += 2;
                        break;
                    case 4:
                        res = program[program[i + 1]];  
                        i += 2;
                        finished = true;
                        break;
                    case 5:
                        std::tie(op1, op2) = extract_params2(program, op_with_modes, i);
                        i = op1 != 0 ? op2 : i + 3;
                        break;
                    case 6:
                        std::tie(op1, op2) = extract_params2(program, op_with_modes, i);
                        i = op1 == 0 ? op2 : i + 3;
                        break;
                    case 7:
                        std::tie(op1, op2, dest) = extract_params3(program, op_with_modes, i);
                        program[dest] = op1 < op2 ? 1 : 0;
                        i += 4;
                        break;
                    case 8:
                        std::tie(op1, op2, dest) = extract_params3(program, op_with_modes, i);
                        program[dest] = op1 == op2 ? 1 : 0;
                        i += 4;
                        break;
                    default:
                        std::println("Unknown opcode: {} at position {}", op, i);
                }      
            } 
        }
        max_res = std::max(max_res, res);
    } while(std::ranges::next_permutation(phases).found);
    return std::to_string(max_res);
}

struct Amp {
    unsigned long long id;
    std::vector<unsigned long long> program;
    size_t i = 0;
    bool first = true;
    bool finished = false;
    std::vector<unsigned long long> outputs;
};

std::string part2(const std::string_view input) {
    auto original_program = split(input, ",") 
    | std::views::transform([](std::string s) { return std::stoull(s); })
    | std::ranges::to<std::vector>();

    std::array<unsigned long long, 5> phases = {5ull, 6ull, 7ull, 8ull, 9ull};
    auto max_res = 0ull;
    do {
        auto res = 0ull;
        auto amps = std::array<Amp, 5>{};
        for(size_t amp = 0; amp < 5; amp++){
            amps[amp].id = phases[amp];
            amps[amp].program = original_program;
        }
        amps[4].outputs.push_back(0);
        do {
            for(size_t amp_i = 0; amp_i < 5; amp_i++){
                auto &amp = amps[amp_i];
                auto &program = amp.program;  
            
                for(size_t &i = amp.i; i < program.size() && !amp.finished; ) {
                    auto op_with_modes = program[i];
                    if(op_with_modes == 99) {
                        amp.finished = true;
                        break;
                    }
                    auto op = op_with_modes % 100;
                    long long op1 = 0, op2 = 0, dest = 0;
                    if(op == 1) {
                        std::tie(op1, op2, dest) = extract_params3(program, op_with_modes, i);
                        program[dest] = op1 + op2;
                        i += 4;
                    }
                    else if(op == 2) {
                        std::tie(op1, op2, dest) = extract_params3(program, op_with_modes, i);
                        program[dest] = op1 * op2;
                        i += 4;
                    }
                    else if(op == 3) {
                        if (amp.first) {
                            program[program[i + 1]] = amp.id;
                            amp.first = false;
                        } else {
                            auto prev_amp_i = amp_i == 0 ? 4 : amp_i - 1;
                            if (amps[prev_amp_i].outputs.empty()) {
                                break;
                            }
                            program[program[i + 1]] = amps[prev_amp_i].outputs.back();
                            amps[prev_amp_i].outputs.pop_back();
                        }
                        i += 2;
                    }
                    else if(op == 4) {
                        res = program[program[i + 1]];
                        amps[amp_i].outputs.push_back(res);
                        i += 2;
                    }
                    else if(op == 5) {
                        std::tie(op1, op2) = extract_params2(program, op_with_modes, i);
                        i = op1 != 0 ? op2 : i + 3;
                    }
                    else if(op == 6) {
                        std::tie(op1, op2) = extract_params2(program, op_with_modes, i);
                        i = op1 == 0 ? op2 : i + 3;
                    }
                    else if(op == 7) {
                        std::tie(op1, op2, dest) = extract_params3(program, op_with_modes, i);
                        program[dest] = op1 < op2 ? 1 : 0;
                        i += 4;
                    }
                    else if(op == 8) {
                        std::tie(op1, op2, dest) = extract_params3(program, op_with_modes, i);
                        program[dest] = op1 == op2 ? 1 : 0;
                        i += 4;
                    }
                    else std::println("Unknown opcode: {} at position {}", op, i);
                } 
            }
        } while(!amps[4].finished);
        max_res = std::max(max_res, res);
    } while(std::ranges::next_permutation(phases).found);
    return std::to_string(max_res);
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