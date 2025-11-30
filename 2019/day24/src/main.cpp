#include <algorithm>
#include <cstddef>
#include <cstdint>
#include <print>
#include <fstream>
#include <filesystem>
#include <queue>
#include <string>
#include <string_view>
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

    Point operator+(const Point& other) const {
        return {x + other.x, y + other.y};
    }
    bool operator==(const Point& other) const {
        return x == other.x && y == other.y;
    }
};

typedef std::pair<Point, int> PointLevel;


struct PointLevelHash {
    size_t operator()(const PointLevel& pl) const {
        return std::hash<int>()(pl.first.x) ^ std::hash<int>()(pl.first.y*5) ^ std::hash<int>()(pl.second*33);
    }
};

uint32_t calculate_biodiversity(const std::vector<std::string> &grid) {
    uint32_t biodiversity = 0;
    for(size_t y = 0; y < grid.size(); y++) {
        for(size_t x = 0; x < grid[0].size(); x++) {
            if(grid[y][x] == '#') biodiversity |= (1 << (y*grid.size() + x));
        }
    }
    return biodiversity;
}

std::string part1(const std::string_view input) {
    auto grid = split(input, "\n");
    std::unordered_set<uint32_t> states{calculate_biodiversity(grid)};
    Point dirs[]{{-1, 0}, {0, 1}, {1, 0}, {0, -1}};
    uint32_t res = -1;
    while(true) {
        auto new_grid = grid;
        for(size_t y = 0; y < grid.size(); y++) {
            for(size_t x = 0; x < grid[0].size(); x++) {
                Point pos{(int)x, (int)y};
                size_t num_neighbours = 0;
                for(const auto& dir: dirs) {
                    auto neighbour = pos + dir;
                    if(neighbour.x >= 0 && neighbour.y >= 0 && neighbour.x < 5 && neighbour.y < 5){
                        if(grid[neighbour.y][neighbour.x] == '#') num_neighbours += 1;
                    }
                }
                if(grid[pos.y][pos.x] == '#') {
                    if(num_neighbours != 1) new_grid[y][x] = '.';
                } else {
                    if(num_neighbours == 1 || num_neighbours == 2) new_grid[y][x] = '#';
                }
            }
        }
        grid = new_grid;
        auto new_biodiversity = calculate_biodiversity(grid);
        if(states.contains(new_biodiversity)) {
            res = new_biodiversity;
            break;
        }
        states.insert(new_biodiversity);
    }
    return std::to_string(res);
}

std::string part2(const std::string_view input) {
    auto grid = split(input, "\n");
    std::unordered_set<PointLevel, PointLevelHash> bugs;
    for(size_t y = 0; y < grid.size(); y++) {
        for(size_t x = 0; x < grid[0].size(); x++) {
            if(grid[y][x] == '#') bugs.insert({{(int)x, (int)y}, 0});
        }
    }
    Point dirs[]{{-1, 0}, {0, 1}, {1, 0}, {0, -1}};
    for(int min = 0; min < 200; min++) {
        std::unordered_set<PointLevel, PointLevelHash> new_bugs;
        std::queue<PointLevel> queue;
        std::unordered_set<PointLevel, PointLevelHash> visited;
        for(auto& pl: bugs) {
            queue.push(pl);
            visited.insert(pl);
        }
        
        while(!queue.empty()){
            auto pl = queue.front();
            queue.pop();
            
            auto [pos, level] = pl;

            std::vector<PointLevel> neighbours;
            for(const auto& dir: dirs) {
                auto neighbour = pos + dir;
                if(neighbour.x > 4) {
                    neighbours.push_back({{3,2}, level - 1});
                }
                else if(neighbour.x < 0) {
                    neighbours.push_back({{1,2}, level - 1});
                }
                else if(neighbour.y > 4) {
                    neighbours.push_back({{2,3}, level - 1});
                }
                else if(neighbour.y < 0) {
                    neighbours.push_back({{2,1}, level - 1});
                }
                else if(neighbour == Point{2, 2}) {
                    if(dir == Point{1, 0}) {
                        neighbours.push_back({{0, 0}, level + 1});
                        neighbours.push_back({{0, 1}, level + 1});
                        neighbours.push_back({{0, 2}, level + 1});
                        neighbours.push_back({{0, 3}, level + 1});
                        neighbours.push_back({{0, 4}, level + 1});
                    } else if(dir == Point{-1, 0}) {
                        neighbours.push_back({{4, 0}, level + 1});
                        neighbours.push_back({{4, 1}, level + 1});
                        neighbours.push_back({{4, 2}, level + 1});
                        neighbours.push_back({{4, 3}, level + 1});
                        neighbours.push_back({{4, 4}, level + 1});
                    } else if(dir == Point{0, -1}) {
                        neighbours.push_back({{0, 4}, level + 1});
                        neighbours.push_back({{1, 4}, level + 1});
                        neighbours.push_back({{2, 4}, level + 1});
                        neighbours.push_back({{3, 4}, level + 1});
                        neighbours.push_back({{4, 4}, level + 1});
                    } else if(dir == Point{0, +1}){
                        neighbours.push_back({{0, 0}, level + 1});
                        neighbours.push_back({{1, 0}, level + 1});
                        neighbours.push_back({{2, 0}, level + 1});
                        neighbours.push_back({{3, 0}, level + 1});
                        neighbours.push_back({{4, 0}, level + 1});
                    }
                } else {
                    neighbours.push_back({neighbour, level});
                }
            }
            size_t num_neighbours = 0;
            for(auto &npl: neighbours) {
                if(bugs.contains(npl)) {
                    num_neighbours += 1;
                }
                if(bugs.contains(pl)){
                    if(!visited.contains(npl)) {
                        queue.push(npl);
                        visited.insert(npl);
                    }
                }
            }
            if(bugs.contains(pl) && num_neighbours == 1) new_bugs.insert(pl);
            if(!bugs.contains(pl) && (num_neighbours == 1 || num_neighbours == 2)) new_bugs.insert(pl);
        }

        bugs = new_bugs;
    }
    return std::to_string(bugs.size());
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