#include <algorithm>
#include <condition_variable>
#include <print>
#include <fstream>
#include <filesystem>
#include <queue>
#include <string>
#include <string_view>
#include <thread>
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
                break;
        }
    }
}


struct Packet {
    long long address;
    long long x;
    long long y;
};

struct Computer {
    std::vector<Packet> packet_queue;
    size_t last_packet_sent = -1;
    bool running = true;
    bool idle = false;
};

std::string part1(const std::string_view input) {
    static long long answer = -1;
    static bool found_answer = false;
    static std::array<Computer, 50> computers;
    std::vector<std::jthread> threads;
    // Initialize computers
    for(int address = 0; address < 50; address++) {
        threads.emplace_back([&, address]() {
            intcode_computer(std::string(input), [&,address]() -> long long {
                static thread_local bool address_sent = false;
                static thread_local Packet current_packet;
                static thread_local int step = 0;
                
                if(!address_sent) {
                    address_sent = true;
                    return address;
                }
                
                if(computers[address].packet_queue.empty()) {
                    return -1;
                }
                
                if(step == 0) {
                    current_packet.address = -1;
                    if(computers[address].last_packet_sent + 1 >= computers[address].packet_queue.size()) {
                        return -1;
                    }
                    computers[address].last_packet_sent++;
                    current_packet = computers[address].packet_queue[computers[address].last_packet_sent];
                }
                if(current_packet.address != -1) {
                    if( step == 0) {
                        step = 1;
                        return current_packet.x;
                    } else {
                        step = 0;
                        return current_packet.y;
                    }
                }
                return -1;
            }, 
            [&](long long output) {
                static thread_local int step = 0;
                static thread_local Packet packet;
                
                if(step == 0) {
                    packet.address = output;
                    step = 1;
                } else if(step == 1) {
                    packet.x = output;
                    step = 2;
                } else {
                    packet.y = output;
                    step = 0;
                    
                    if(packet.address == 255) {
                        if(!found_answer) {
                            answer = packet.y;
                            found_answer = true;
                        }
                    } else if(packet.address >= 0 && packet.address < 50) {
                        computers[packet.address].packet_queue.push_back(packet);
                    }
                }
            });
        });
    }

    while(!found_answer) {
        std::this_thread::sleep_for(std::chrono::milliseconds(100));
    }

    for(auto& thread : threads) {
        thread.request_stop();
        thread.detach();
    }
    
    return std::to_string(answer);
}

std::string part2(const std::string_view input) {
    static Packet nat_packet;
    static bool nat_sent;
    static long long last_y = -1000000;
    static bool found_answer = false;
    static std::array<Computer, 50> computers;
    std::vector<std::jthread> threads;
    for(int address = 0; address < 50; address++) {
        threads.emplace_back([&, address]() {
            intcode_computer(std::string(input), [&,address]() -> long long {
                static thread_local bool address_sent = false;
                static thread_local Packet current_packet;
                static thread_local int step = 0;
                
                if(!address_sent) {
                    address_sent = true;
                    return address;
                }
                
                if(computers[address].packet_queue.empty()) {
                    computers[address].idle = true;
                    return -1;
                }
                
                if(step == 0) {
                    current_packet.address = -1;
                    if(computers[address].last_packet_sent + 1 >= computers[address].packet_queue.size()) {
                        computers[address].idle = true;
                        return -1;
                    }
                    computers[address].idle = false;
                    computers[address].last_packet_sent++;
                    current_packet = computers[address].packet_queue[computers[address].last_packet_sent];
                }
                if(current_packet.address != -1) {
                    if( step == 0) {
                        step = 1;
                        return current_packet.x;
                    } else {
                        step = 0;
                        return current_packet.y;
                    }
                }
                computers[address].idle = true;
                return -1;
            }, 
            [&](long long output) {
                static thread_local int step = 0;
                static thread_local Packet packet;
                
                if(step == 0) {
                    packet.address = output;
                    step = 1;
                } else if(step == 1) {
                    packet.x = output;
                    step = 2;
                } else {
                    packet.y = output;
                    step = 0;
                    
                    if(packet.address == 255) {
                        nat_packet = packet;
                        nat_sent = false;
                    } else if(packet.address >= 0 && packet.address < 50) {
                        computers[packet.address].packet_queue.push_back(packet);
                    }
                }
            });
        });
    }

    while(!found_answer) {
        std::this_thread::sleep_for(std::chrono::milliseconds(100));
        if(!nat_sent && std::ranges::all_of(computers, [](const auto& c) { return c.idle; })) {
            computers[0].packet_queue.push_back(nat_packet);
            if(nat_packet.y == last_y) found_answer = true;
            last_y = nat_packet.y;
            nat_sent = true;
        }
    }

    for(auto& thread : threads) {
        thread.request_stop();
        thread.detach();
    }
    
    return std::to_string(last_y);
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