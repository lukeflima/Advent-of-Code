#include <cassert>
#include <print>
#include <fstream>
#include <filesystem>
#include <queue>
#include <string>
#include <string_view>
#include <unordered_map>
#include <unordered_set>
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

    Point operator+(const Point& other) const {
        return Point{x + other.x, y + other.y};
    }
};

struct PointHash {
    std::size_t operator()(const Point& p) const {
        return std::hash<int>()(p.x) ^ std::hash<int>()(p.y);
    }
};

struct PointLevelHash {
    std::size_t operator()(const std::pair<Point, int>& p) const {
        return std::hash<int>()(p.first.x) ^ std::hash<int>()(p.first.y) ^ std::hash<int>()(p.second);
    }
};
    
std::string part1(const std::string_view input) {
    auto grid = split(input, "\n");
    auto in_grid = [&](const Point& p) {
        return p.y >= 0 && p.y < (int)grid.size() && p.x >= 0 && p.x < (int)grid[0].size();
    };
    std::unordered_map<std::string, std::vector<Point>> portals_map;

    Point start{-1, -1};
    Point end{-1, -1};
    
    for(int y = 0; y < (int) grid.size(); ++y) {
        for(int x = 0; x < (int) grid[y].size(); ++x) {
            char c = grid[y][x];
            if(c >= 'A' && c <= 'Z') {
                std::string portal_name{c};
                Point portal_pos = {x, y};
                
                if(x + 1 < (int) grid[y].size() && grid[y][x + 1] >= 'A' && grid[y][x + 1] <= 'Z') {
                    portal_name += grid[y][x + 1];
                    if(x + 2 < (int) grid[y].size() && grid[y][x + 2] == '.') {
                        portal_pos = Point{x + 2, y};
                    } else if(x - 1 >= 0 && grid[y][x - 1] == '.') {
                        portal_pos = Point{x - 1, y};
                    } else continue;
                }
                else if(y + 1 < (int) grid.size() && grid[y + 1][x] >= 'A' && grid[y + 1][x] <= 'Z') {
                    portal_name += grid[y + 1][x];
                    if(y + 2 < (int) grid.size() && grid[y + 2][x] == '.') {
                        portal_pos = Point{x, y + 2};
                    } else if(y - 1 >= 0 && grid[y - 1][x] == '.') {
                        portal_pos = Point{x, y - 1};
                    } else continue;
                }
                else continue;

                if(portal_name == "AA") {
                    start = portal_pos;
                } else if(portal_name == "ZZ") {
                    end = portal_pos;
                } else {
                    portals_map[portal_name].push_back(portal_pos);
                }
            }
        }
    }

    std::unordered_map<Point, Point, PointHash> portals;
    for(const auto& [name, points] : portals_map) {
        if(points.size() == 2) {
            portals[points[0]] = points[1];
            portals[points[1]] = points[0];
        }
    }

    struct State {
        long long steps;
        Point position;
        
        bool operator>(const State& other) const {
            return steps > other.steps;
        }
    };
    
    std::priority_queue<State, std::vector<State>, std::greater<State>> pq;
    pq.push({0, start});
    
    std::unordered_map<Point, long long, PointHash> distance;
    distance[start] = 0;

    long long min_steps = std::numeric_limits<long long>::max();
    
    while(!pq.empty()) {
        auto state = pq.top();
        pq.pop();
        
        if(distance[state.position] < state.steps) continue;
        
        if(state.position == end) {
            min_steps = state.steps;
            break;
        }

        std::vector<Point> directions = {{0, -1}, {0, 1}, {-1, 0}, {1, 0}};
        for (const auto& dir : directions) {
            Point neighbor = state.position + dir;
            
            if (!in_grid(neighbor)) continue;
            
            char cell = grid[neighbor.y][neighbor.x];
            if (cell != '.') continue;
            
            long long new_steps = state.steps + 1;
            
            if (!distance.count(neighbor) || distance[neighbor] > new_steps) {
                distance[neighbor] = new_steps;
                pq.push({new_steps, neighbor});
            }
        }

        if(portals.count(state.position)) {
            Point portal_exit = portals[state.position];
            long long new_steps = state.steps + 1;
            
            if (!distance.count(portal_exit) || distance[portal_exit] > new_steps) {
                distance[portal_exit] = new_steps;
                pq.push({new_steps, portal_exit});
            }
        }
    }
    
    return std::to_string(min_steps);
}

std::string part2(const std::string_view input) {
    auto grid = split(input, "\n");
    auto in_grid = [&](const Point& p) {
        return p.y >= 0 && p.y < (int)grid.size() && p.x >= 0 && p.x < (int)grid[0].size();
    };

    std::unordered_map<std::string, std::vector<Point>> portals_map;

    Point start{-1, -1};
    Point end{-1, -1};
    
    // Portal detection (same as before)
    for(int y = 0; y < (int) grid.size(); ++y) {
        for(int x = 0; x < (int) grid[y].size(); ++x) {
            char c = grid[y][x];
            if(c >= 'A' && c <= 'Z') {
                std::string portal_name{c};
                Point portal_pos = {x, y};
                
                if(x + 1 < (int) grid[y].size() && grid[y][x + 1] >= 'A' && grid[y][x + 1] <= 'Z') {
                    portal_name += grid[y][x + 1];
                    if(x + 2 < (int) grid[y].size() && grid[y][x + 2] == '.') {
                        portal_pos = Point{x + 2, y};
                    } else if(x - 1 >= 0 && grid[y][x - 1] == '.') {
                        portal_pos = Point{x - 1, y};
                    } else continue;
                }
                else if(y + 1 < (int) grid.size() && grid[y + 1][x] >= 'A' && grid[y + 1][x] <= 'Z') {
                    portal_name += grid[y + 1][x];
                    if(y + 2 < (int) grid.size() && grid[y + 2][x] == '.') {
                        portal_pos = Point{x, y + 2};
                    } else if(y - 1 >= 0 && grid[y - 1][x] == '.') {
                        portal_pos = Point{x, y - 1};
                    } else continue;
                }
                else continue;

                if(portal_name == "AA") {
                    start = portal_pos;
                } else if(portal_name == "ZZ") {
                    end = portal_pos;
                } else {
                    portals_map[portal_name].push_back(portal_pos);
                }
            }
        }
    }

    // Build portal connections
    std::unordered_map<Point, Point, PointHash> portals;
    for(const auto& [name, points] : portals_map) {
        if(points.size() == 2) {
            portals[points[0]] = points[1];
            portals[points[1]] = points[0];
        }
    }

    // Determine which portals are outer/inner
    std::unordered_map<Point, bool, PointHash> is_outer_portal;
    for(const auto& [portal, _] : portals) {
        is_outer_portal[portal] = (portal.x <= 2 || portal.x >= (int)grid[0].size() - 3 ||
                                   portal.y <= 2 || portal.y >= (int)grid.size() - 3);
    }

    struct State {
        long long steps;
        Point position; 
        int level;
        
        bool operator>(const State& other) const {
            if(steps != other.steps) return steps > other.steps;
            return level > other.level;
        }
    };
    
    std::priority_queue<State, std::vector<State>, std::greater<State>> pq;
    pq.push({0, start, 0});
    
    std::unordered_map<std::pair<Point, int>, long long, PointLevelHash> distance;
    distance[{start, 0}] = 0;

    long long min_steps = std::numeric_limits<long long>::max();
    
    while(!pq.empty()) {
        auto state = pq.top();
        pq.pop();
        
        // Skip if we found a better path to this state
        if(distance[{state.position, state.level}] < state.steps) {
            continue;
        }
        
        if(state.level == 0 && state.position == end) {
            min_steps = state.steps;
            break;
        }

        // Explore neighbors
        std::vector<Point> directions = {{0, -1}, {0, 1}, {-1, 0}, {1, 0}};
        for (const auto& dir : directions) {
            Point neighbor = state.position + dir;
            
            if (!in_grid(neighbor)) continue;
            
            char cell = grid[neighbor.y][neighbor.x];
            if (cell != '.') continue;
            
            long long new_steps = state.steps + 1;
            auto key = std::make_pair(neighbor, state.level);
            
            if (!distance.contains(key) || distance[key] > new_steps) {
                distance[key] = new_steps;
                pq.push({new_steps, neighbor, state.level});
            }
        }

        if(portals.count(state.position)) {
            bool outer = is_outer_portal[state.position];
            int new_level = state.level + (outer ? -1 : 1);
            
            if(new_level >= 0 && new_level <= 30) {
                Point portal_exit = portals[state.position];
                long long new_steps = state.steps + 1;
                auto key = std::make_pair(portal_exit, new_level);
                
                if (!distance.count(key) || distance[key] > new_steps) {
                    distance[key] = new_steps;
                    pq.push({new_steps, portal_exit, new_level});
                }
            }
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
    
    std::println("Part 1: {}", part1(input));
    std::println("Part 2: {}", part2(input));

    return 0;
}