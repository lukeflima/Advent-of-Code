#include <format>
#include <print>
#include <fstream>
#include <filesystem>
#include <string>
#include <string_view>
#include <vector>
#include <unordered_set>
#include <unordered_map>
#include <generator>
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
        result.push_back(std::string(s.substr(prev, i)));
        prev = i + 1;
    }
    if(s.length() > 0) result.push_back(s.substr(prev));
    return result;
}

class Point{
public:
    int x;
    int y;

    int manhattan_length() const {
        return std::abs(x) + std::abs(y);
    }

    Point operator+(const Point& other) const {
        return Point{x + other.x, y + other.y};
    }
    Point operator-(const Point& other) const {
        return Point{x - other.x, y - other.y};
    }
    bool operator==(const Point& other) const {
        return x == other.x && y == other.y;
    }
    bool operator<(const Point& other) const {
        return manhattan_length() < other.manhattan_length();
    }

    std::string to_string() const {
        return std::format("({},{})", x, y);
    }

    struct HashFunction{
        size_t operator()(const Point& point) const {
            return std::hash<std::string>()(point.to_string());
        }
    };
};


typedef std::unordered_set<Point, Point::HashFunction> PointSet; ;


std::string part1(const std::string_view input) {
    std::vector<PointSet> wires;
    for(auto wire: split(input, "\n")) {
        auto pos = Point{0, 0};
        auto wire_path = PointSet{};
        for(auto move: split(wire, ",")) {
            auto direction = move[0];
            auto distance = std::stoi(move.substr(1));
            Point dir{0, 0};
            if (direction =='U') dir = {-1,  0};
            if (direction =='D') dir = { 1,  0};
            if (direction =='L') dir = { 0, -1};
            if (direction =='R') dir = { 0,  1};

            for(int i = 0; i < distance; i++) {
                pos = pos + dir;
                wire_path.insert(pos);
            }
        }
        wires.push_back(wire_path);
    }

    int min_dist = std::numeric_limits<int>::max();
    for(auto point: wires[0]) {
        if(wires[1].find(point) != wires[1].end()) {
            int distance = point.manhattan_length();
            if(distance < min_dist) {
                min_dist = distance;
            }
        }
    }

    return std::to_string(min_dist);
}

typedef std::unordered_map<Point, int, Point::HashFunction> WirePath;

std::string part2(const std::string_view input) {
    std::vector<WirePath> wires;
    for(auto wire: split(input, "\n")) {
        auto pos = Point{0, 0};
        WirePath wire_path{{pos, 0}};
        int wire_length = 1;
        for(auto move: split(wire, ",")) {
            auto direction = move[0];
            auto distance = std::stoi(move.substr(1));
            Point dir{0,0};
            if (direction =='U') dir = {-1,  0};
            if (direction =='D') dir = { 1,  0};
            if (direction =='L') dir = { 0, -1};
            if (direction =='R') dir = { 0,  1};

            for(int i = 0; i < distance; i++) {
                pos = pos + dir;
                if(!wire_path.contains(pos))
                    wire_path[pos] = wire_length;
                wire_length++;
            }
        }
        wires.push_back(wire_path);
    }

    int min_dist = std::numeric_limits<int>::max();
    for(auto point_pair: wires[0]) {
        auto point = point_pair.first;
        if(wires[1].contains(point)) {
            if(point == Point{0, 0}) continue;
            auto distance = wires[0][point] + wires[1][point];
            if(distance < min_dist) {
                min_dist = distance;
            }
        }
    }
    
    return std::to_string(min_dist);
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