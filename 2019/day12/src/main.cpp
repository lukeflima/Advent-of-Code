#include <numeric>
#include <print>
#include <fstream>
#include <filesystem>
#include <string>
#include <string_view>
#include <vector>
#include <ranges>
#include <algorithm>
#include <cmath>
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

struct Point {
    int x;
    int y;
    int z;

    inline Point operator+(const Point& other) const {
        return Point{x + other.x, y + other.y, z + other.z};
    }

    friend inline Point operator+=(Point& p1, const Point& p2) {
        p1 = p1 + p2;
        return p1;
    }
};

struct Moon {
    Point position;
    Point velocity{0, 0, 0};

    inline bool operator==(const Moon& other) const {
        return position.x == other.position.x && position.y == other.position.y && position.z == other.position.z
            && velocity.x == other.velocity.x && velocity.y == other.velocity.y && velocity.z == other.velocity.z;
    }

    long long potential_energy() const {
        return std::abs(position.x) + std::abs(position.y) + std::abs(position.z);
    }
    long long kinetic_energy() const {
        return std::abs(velocity.x) + std::abs(velocity.y) + std::abs(velocity.z);
    }
    long long total_energy() const {
        return potential_energy() * kinetic_energy();
    }
};

struct MoonHash {
    std::size_t operator()(const Moon& moon) const {
        return std::hash<int>()(moon.position.x) ^ std::hash<int>()(moon.position.y) ^ std::hash<int>()(moon.position.z)
            ^ std::hash<int>()(moon.velocity.x) ^ std::hash<int>()(moon.velocity.y) ^ std::hash<int>()(moon.velocity.z);
    }
};
struct MoonState {
    std::vector<Moon> moons;

    inline bool operator==(const MoonState& other) const {
        return std::ranges::equal(moons, other.moons);
    }
};

struct MoonStateHash {
    std::size_t operator()(const MoonState& state) const {
        std::size_t seed = 0;
        for(const auto& moon : state.moons) {
            seed ^= MoonHash()(moon) + 0x9e3779b9 + (seed << 6) + (seed >> 2);
        }
        return seed;
    }
};

std::string part1(const std::string_view input) {
    auto moons = split(input, "\n")
        | std::views::transform([](const auto& line) {
            Moon moon;
            sscanf(line.c_str(), "<x=%d, y=%d, z=%d>", &moon.position.x, &moon.position.y, &moon.position.z);
            return moon;
        })
        | std::ranges::to<std::vector<Moon>>();
    for(int step = 0; step < 1000; step++) {
        for(size_t i = 0; i < moons.size(); i++) {
            for(size_t j = 0; j < moons.size(); j++) {
                if(i == j) continue;
                if(moons[i].position.x < moons[j].position.x) moons[i].velocity.x += 1;
                else if(moons[i].position.x > moons[j].position.x) moons[i].velocity.x -= 1;
                if(moons[i].position.y < moons[j].position.y) moons[i].velocity.y += 1;
                else if(moons[i].position.y > moons[j].position.y) moons[i].velocity.y -= 1;
                if(moons[i].position.z < moons[j].position.z) moons[i].velocity.z += 1;
                else if(moons[i].position.z > moons[j].position.z) moons[i].velocity.z -= 1;
            }
        }
        for(size_t i = 0; i < moons.size(); i++) {
            moons[i].position += moons[i].velocity;
        }
    }
    auto total_energy = std::ranges::fold_left(moons, 0ll, [](int acc, const Moon& moon) {
        return acc + moon.total_energy();
    });
    return std::to_string(total_energy);
}

struct AxisState {
    std::vector<int> pos;
    std::vector<int> vel;
};

static void step_axis(AxisState& axis) {
    for (size_t i = 0; i < axis.pos.size(); i++) {
        for (size_t j = 0; j < axis.pos.size(); j++) {
            if (i == j) continue;
            if (axis.pos[i] < axis.pos[j]) axis.vel[i]++;
            else if (axis.pos[i] > axis.pos[j]) axis.vel[i]--;
        }
    }
    for (size_t i = 0; i < axis.pos.size(); i++) {
        axis.pos[i] += axis.vel[i];
    }
}

static long long find_cycle(const AxisState& initial_state) {
    AxisState axis = initial_state;
    long long steps = 0;
    do {
        step_axis(axis);
        steps++;
    } while (axis.pos != initial_state.pos || axis.vel != initial_state.vel);
    return steps;
}

std::string part2(const std::string_view input) {
    auto moons = split(input, "\n")
        | std::views::transform([](const auto& line) {
            Moon moon;
            sscanf(line.c_str(), "<x=%d, y=%d, z=%d>", &moon.position.x, &moon.position.y, &moon.position.z);
            return moon;
        })
        | std::ranges::to<std::vector<Moon>>();
    
    AxisState x, y, z;
    for (const auto& m : moons) {
        x.pos.push_back(m.position.x);
        x.vel.push_back(0);

        y.pos.push_back(m.position.y);
        y.vel.push_back(0);
        
        z.pos.push_back(m.position.z);
        z.vel.push_back(0);
    }

    auto x_cycle = find_cycle(x);
    auto y_cycle = find_cycle(y);
    auto z_cycle = find_cycle(z);

    auto step = std::lcm(std::lcm(x_cycle, y_cycle), z_cycle);

    return std::to_string(step);
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