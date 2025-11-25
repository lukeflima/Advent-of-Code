#include <print>
#include <fstream>
#include <filesystem>
#include <queue>
#include <string>
#include <string_view>
#include <unordered_map>
#include <utility>
#include <vector>
#include <ranges>
#include <algorithm>
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

enum DroidReply {
    WALL = 0,
    MOVED = 1,
    FOUND_OXYGEN = 2
};

enum MoveCommand {
    NORTH = 1,
    SOUTH = 2,
    WEST = 3,
    EAST = 4
};
auto format_as(MoveCommand s) {
    switch (s) {
        case NORTH: return "NORTH";
        case SOUTH: return "SOUTH";
        case WEST: return "WEST";
        case EAST: return "EAST";
    }
    return "UNKNOWN";
}

struct Point {
    int x;
    int y;
    bool operator==(const Point& other) const {
        return x == other.x && y == other.y;
    }
    bool operator<(const Point& other) const {
        return std::tie(x, y) < std::tie(other.x, other.y);
    }
};

struct PointHash {
    std::size_t operator()(const Point& p) const {
        return std::hash<int>()(p.x) ^ std::hash<int>()(p.y);
    }    
};


std::string part1(const std::string_view input) {
    Point droid_position{0, 0};
    std::map<Point, DroidReply> area_map{{droid_position, MOVED}};
    Point oxygen_position{100000000, -100000000};
    std::vector<MoveCommand> move_stack;
    MoveCommand last_move = NORTH;
    bool completed = false;
    auto output_cb = [&](long long output) {
        DroidReply reply = static_cast<DroidReply>(output);
        Point next_position = droid_position;
        switch(last_move) {
            case NORTH: next_position.y -= 1; break;
            case SOUTH: next_position.y += 1; break;
            case WEST: next_position.x -= 1; break;
            case EAST: next_position.x += 1; break;
        }
        if (reply != WALL) {
            droid_position = next_position;
            if (!area_map.contains(droid_position)) move_stack.push_back(last_move);
        }
        if (reply == FOUND_OXYGEN) {
            oxygen_position = droid_position;
        }
        area_map[next_position] = reply;
        std::vector<std::pair<Point, MoveCommand>> possible_moves = {
            {{droid_position.x, droid_position.y - 1}, NORTH},
            {{droid_position.x, droid_position.y + 1}, SOUTH},
            {{droid_position.x - 1, droid_position.y}, WEST},
            {{droid_position.x + 1, droid_position.y}, EAST}
        };
        bool found_unvisited = false;
        for (const auto& move : possible_moves) {
            if (!area_map.contains(move.first)) {
                last_move = move.second;
                found_unvisited = true;
                break;
            }
        }
        if(!found_unvisited) {
            if(move_stack.empty()) {
                completed = true;
            }
            switch (move_stack.back()) {
                case NORTH: last_move = SOUTH; break;
                case SOUTH: last_move = NORTH; break;
                case WEST: last_move = EAST; break;
                case EAST: last_move = WEST; break;
            }
            move_stack.pop_back();
        } 
    };
    auto input_cb = [&]() -> long long {
        if (completed) return 0;
        return last_move;
    };

    intcode_computer(input, input_cb, output_cb);

    struct State {
        long long distance; 
        Point posiotion;
        bool operator<(const State& other) const {
            return distance < other.distance;
        }
    };
    std::priority_queue<State> pq;
    pq.push({0, {0, 0}});

    std::unordered_map<Point, bool, PointHash> visited;
    long long min_distance = 1000000000;
    while(!pq.empty()) {
        auto state = pq.top();
        pq.pop();

        if(visited.contains(state.posiotion)) continue;
        visited[state.posiotion] = true;

        if (state.posiotion == oxygen_position) {
            min_distance = state.distance;
            break;
        }
        
        std::vector<Point> neighbors = {
            {state.posiotion.x, state.posiotion.y - 1},
            {state.posiotion.x, state.posiotion.y + 1},
            {state.posiotion.x - 1, state.posiotion.y},
            {state.posiotion.x + 1, state.posiotion.y}
        };
        for (const auto& neighbor : neighbors) {
            if (area_map.contains(neighbor) && area_map[neighbor] != WALL) {
                pq.push({state.distance + 1, neighbor});    
            }
        }
    }

    return std::to_string(min_distance);
}

std::string part2(const std::string_view input) {
    Point droid_position{0, 0};
    Point oxygen_position{100000000, -100000000};
    std::map<Point, DroidReply> area_map{{droid_position, MOVED}};

    std::vector<MoveCommand> move_stack;
    MoveCommand last_move = NORTH;
    bool completed = false;

    auto output_cb = [&](long long output) {
        DroidReply reply = static_cast<DroidReply>(output);
        Point next_position = droid_position;
        switch(last_move) {
            case NORTH: next_position.y -= 1; break;
            case SOUTH: next_position.y += 1; break;
            case WEST: next_position.x -= 1; break;
            case EAST: next_position.x += 1; break;
        }
        if (reply != WALL) {
            droid_position = next_position;
            if (!area_map.contains(droid_position)) move_stack.push_back(last_move);
        }
        if (reply == FOUND_OXYGEN) {
            oxygen_position = droid_position;
        }
        area_map[next_position] = reply;
        std::vector<std::pair<Point, MoveCommand>> possible_moves = {
            {{droid_position.x, droid_position.y - 1}, NORTH},
            {{droid_position.x, droid_position.y + 1}, SOUTH},
            {{droid_position.x - 1, droid_position.y}, WEST},
            {{droid_position.x + 1, droid_position.y}, EAST}
        };
        bool found_unvisited = false;
        for (const auto& move : possible_moves) {
            if (!area_map.contains(move.first)) {
                last_move = move.second;
                found_unvisited = true;
                break;
            }
        }
        if(!found_unvisited) {
            if(move_stack.empty()) {
                completed = true;
            }
            switch (move_stack.back()) {
                case NORTH: last_move = SOUTH; break;
                case SOUTH: last_move = NORTH; break;
                case WEST: last_move = EAST; break;
                case EAST: last_move = WEST; break;
            }
            move_stack.pop_back();
        } 
    };

    auto input_cb = [&]() -> long long {
        if (completed) return 0;
        return last_move;
    };

    intcode_computer(input, input_cb, output_cb);

    std::unordered_map<Point, bool, PointHash> visited;
    visited[oxygen_position] = true;
    bool oxygen_filled = false;
    int minutes = 0;
    do {
        oxygen_filled = true;
        std::vector<Point> next_positions;
        for(auto & [point, _] : visited) {
            if(!area_map.contains(point)) {
                continue;
            }
            std::vector<Point> neighbors = {
                {point.x, point.y - 1},
                {point.x, point.y + 1},
                {point.x - 1, point.y},
                {point.x + 1, point.y}
            };
            for (const auto& neighbor : neighbors) {
                if (area_map.contains(neighbor) && area_map[neighbor] != WALL && !visited.contains(neighbor)) {
                    next_positions.push_back(neighbor);   
                    oxygen_filled = false;
                }
            }
        }
        for(const auto& pos : next_positions) {
            visited[pos] = true;
        }
        minutes++;
    } while(!oxygen_filled);
    
    return std::to_string(minutes - 1);
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