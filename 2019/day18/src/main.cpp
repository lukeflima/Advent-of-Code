#include <limits>
#include <print>
#include <fstream>
#include <filesystem>
#include <queue>
#include <string_view>
#include <unordered_map>
#include <unordered_set>
#include <vector>
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
        prev = i + delimiter.length();
    }
    if(prev < s.length()) result.push_back(s.substr(prev));
    return result;
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
    auto grid = split(input, "\n");
    Point start_position{0, 0};
    for(int y = 0; y < (int)grid.size(); y++) {
        for(int x = 0; x < (int)grid[y].size(); x++) {
            if(grid[y][x] == '@') {
                start_position = {x, y};
                grid[y][x] = ' ';
            }
        }
    }
    constexpr int num_of_keys = 26;
    typedef std::array<bool, num_of_keys> keys_collected_t;

    struct KeyMove {
        Point position;
        char key;
        long long distance;
    };

    auto find_possible_key_moves = [&](Point start, const keys_collected_t& keys_collected) -> std::vector<KeyMove> {
        std::vector<KeyMove> result;

        std::queue<std::pair<Point, long long>> q;
        q.push({start, 0});

        std::unordered_set<Point, PointHash> visited;
        visited.insert(start);
        
        while(!q.empty()) {
            auto [current_position, distance] = q.front();
            q.pop();

            std::vector<Point> neighbors = {
                {current_position.x, current_position.y - 1},
                {current_position.x, current_position.y + 1},
                {current_position.x - 1, current_position.y},
                {current_position.x + 1, current_position.y}
            };
            for (const auto& neighbor : neighbors) {
                if (neighbor.y < 0 || neighbor.y >= (int)grid.size() || neighbor.x < 0 || neighbor.x >= (int)grid[0].size()) {
                    continue;
                }
                char cell = grid[neighbor.y][neighbor.x];

                if (cell == '#') continue;
                if (visited.contains(neighbor)) continue;
                
                visited.insert(neighbor);
                if (cell >= 'A' && cell <= 'Z' && !keys_collected[cell - 'A']) continue; 
                if (cell >= 'a' && cell <= 'z' && !keys_collected[cell - 'a']) {
                    result.push_back({neighbor, cell, distance + 1});
                    continue;
                }
                q.push({neighbor, distance + 1});
            }
        }
        return result;
    };

    struct State {
        long long steps;
        Point position; 
        keys_collected_t keys_collected;
        
        bool operator==(const State& other) const {
            return position == other.position && keys_collected == other.keys_collected;
        }
        bool operator<(const State& other) const {
            return steps < other.steps;
        }
    };
    
    struct StateHash {
        std::size_t operator()(const State& s) const {
            std::size_t hash = std::hash<int>()(s.position.x) ^ std::hash<int>()(s.position.y);
            for (bool key_collected : s.keys_collected) {
                hash ^= std::hash<bool>()(key_collected);
            }
            return hash;
        }    
    };

    std::unordered_map<State, long long, StateHash> visited;
    std::priority_queue<State> pq;
    pq.push({0, start_position, {false}});

    long long min_steps = std::numeric_limits<long long>::max();
    while(!pq.empty()) {
        auto state = pq.top();
        pq.pop();

        if(state.steps > min_steps) continue;

        if(visited.contains(state) && visited[state] <= state.steps) continue;
        visited[state] = state.steps;

        if (std::ranges::all_of(state.keys_collected, [](bool b){ return b; })) {
            min_steps = std::min(state.steps, min_steps);
            continue;
        }
        
        std::vector<KeyMove> key_moves = find_possible_key_moves(state.position, state.keys_collected);
        
        for (const auto& [move, key, steps] : key_moves) {
            auto new_keys_collected = state.keys_collected;
            new_keys_collected[key - 'a'] = true;
            pq.push({state.steps + steps, move, new_keys_collected});
        }
    }

    return std::to_string(min_steps);
}

std::string part2(const std::string_view input) {
    auto grid = split(input, "\n");
    std::array<Point, 4> start_positions;
    for(int y = 0; y < (int)grid.size(); y++) {
        for(int x = 0; x < (int)grid[y].size(); x++) {
            if(grid[y][x] == '@') {
                grid[y-1][x-1] = ' ';
                grid[y-1][x]   = '#';
                grid[y-1][x+1] = ' ';
                grid[y][x-1]   = '#';
                grid[y][x]     = '#';
                grid[y][x+1]   = '#';
                grid[y+1][x-1] = ' ';
                grid[y+1][x]   = '#';
                grid[y+1][x+1] = ' ';
                start_positions[0] = {x-1, y-1};
                start_positions[1] = {x+1, y-1};
                start_positions[2] = {x-1, y+1};
                start_positions[3] = {x+1, y+1};
            }
        }
    }
    constexpr int num_of_keys = 26;
    typedef std::array<bool, num_of_keys> keys_collected_t;

    struct KeyMove {
        Point position;
        size_t robot_index;
        char key;
        long long distance;
    };

    auto find_possible_key_moves = [&](const std::array<Point, 4>& starts, const keys_collected_t& keys_collected) -> std::vector<KeyMove> {
        std::vector<KeyMove> result;

        for (size_t robot_index = 0; robot_index < starts.size(); robot_index++) {
            Point start = starts[robot_index];

            std::queue<std::pair<Point, long long>> q;
            q.push({start, 0});

            std::unordered_set<Point, PointHash> visited;
            visited.insert(start);

            while(!q.empty()) {
                auto [current_position, distance] = q.front();
                q.pop();

                std::vector<Point> neighbors = {
                    {current_position.x, current_position.y - 1},
                    {current_position.x, current_position.y + 1},
                    {current_position.x - 1, current_position.y},
                    {current_position.x + 1, current_position.y}
                };
                for (const auto& neighbor : neighbors) {
                    if (neighbor.y < 0 || neighbor.y >= (int)grid.size() || neighbor.x < 0 || neighbor.x >= (int)grid[0].size()) continue;

                    char cell = grid[neighbor.y][neighbor.x];
                    if (cell == '#') continue;

                    if (visited.contains(neighbor)) continue;
                    visited.insert(neighbor);

                    if (cell >= 'A' && cell <= 'Z' && !keys_collected[cell - 'A']) continue;
                    if (cell >= 'a' && cell <= 'z' && !keys_collected[cell - 'a']) {
                        result.push_back({neighbor, robot_index, cell, distance + 1});
                        continue;
                    }
                    q.push({neighbor, distance + 1});
                }
            }
        }
        return result;
    };

    struct State {
        long long steps;
        std::array<Point, 4> positions; 
        keys_collected_t keys_collected;
        
        bool operator==(const State& other) const {
            return positions == other.positions && keys_collected == other.keys_collected;
        }
        bool operator<(const State& other) const {
            return steps < other.steps;
        }
    };
    
    struct StateHash {
        std::size_t operator()(const State& s) const {
            std::size_t hash = 0;
            for (const auto& position : s.positions) {
                hash ^= std::hash<int>()(position.x) ^ std::hash<int>()(position.y);
            }
            for (bool key_collected : s.keys_collected) {
                hash ^= std::hash<bool>()(key_collected);
            }
            return hash;
        }    
    };

    std::unordered_map<State, long long, StateHash> visited;
    std::priority_queue<State> pq;
    pq.push({0, start_positions, {false}});

    long long min_steps = std::numeric_limits<long long>::max();
    while(!pq.empty()) {
        auto state = pq.top();
        pq.pop();

        if(state.steps > min_steps) continue;

        if(visited.contains(state) && visited[state] <= state.steps) continue;
        visited[state] = state.steps;

        if (std::ranges::all_of(state.keys_collected, [](bool b){ return b; })) {
            min_steps = std::min(state.steps, min_steps);
            continue;
        }
        
        std::vector<KeyMove> key_moves = find_possible_key_moves(state.positions, state.keys_collected);
        for (const auto& [move, robot_index, key, steps] : key_moves) {
            auto new_keys_collected = state.keys_collected;
            new_keys_collected[key - 'a'] = true;
            auto new_positions = state.positions;
            new_positions[robot_index] = move;
            pq.push({state.steps + steps, new_positions, new_keys_collected});
        }
    }

    return std::to_string(min_steps);
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