#include <print>
#include <fstream>
#include <filesystem>
#include <string_view>
#include <vector>
#include <cstdint>
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

struct Node {
    int value;
    Node* next;
    Node* prev;
};

struct Deck {
    Node* head;
    Node* tail;
    int size;
};

struct Instruction {
    enum Type {
        CUT,
        DEAL_INTO_NEW_STACK,
        DEAL_WITH_INCREMENT
    } type;
    int argument;
};

std::string part1(const std::string_view input) {
    Deck deck = {nullptr, nullptr, 0};
    Node* nodes[10007];
    for (int i = 0; i < 10007; i++) {
        Node* new_node = new Node{i, nullptr, deck.tail};
        nodes[i] = new_node;
        if (deck.tail) {
            deck.tail->next = new_node;
        } else {
            deck.head = new_node;
        }
        deck.tail = new_node;
        deck.size++;
    }
    deck.tail->next = deck.head;
    deck.head->prev = deck.tail;
    std::vector<Instruction> instructions;
    std::vector<std::string> lines = split(input, "\n");
    for (const std::string& line : lines) {
        if (line == "deal into new stack") {
            instructions.push_back({Instruction::DEAL_INTO_NEW_STACK, 0});
        } else if (line.starts_with("cut ")) {
            int n = std::stoi(line.substr(4));
            instructions.push_back({Instruction::CUT, n});
        } else if (line.starts_with("deal with increment ")) {
            int n = std::stoi(line.substr(20));
            instructions.push_back({Instruction::DEAL_WITH_INCREMENT, n});
        }
    }
    for(const Instruction& instr : instructions) {
        if (instr.type == Instruction::DEAL_INTO_NEW_STACK) {
            for (int i = 0; i < deck.size; i++) {
                Node* temp = nodes[i]->next;
                nodes[i]->next = nodes[i]->prev;
                nodes[i]->prev = temp;
                nodes[i] = temp;
            }
            Node* temp = deck.head;
            deck.head = deck.tail;
            deck.tail = temp;
        } else if (instr.type == Instruction::CUT) {
            int n = instr.argument;
            if (n > 0) {
                for (int i = 0; i < n; i++) {
                    deck.head = deck.head->next;
                    deck.tail = deck.tail->next;
                }
            } else {
                for (int i = 0; i < -n; i++) {
                    deck.head = deck.head->prev;
                    deck.tail = deck.tail->prev;
                }
            }
        } else if (instr.type == Instruction::DEAL_WITH_INCREMENT) {
            int n = instr.argument;
            Node* new_nodes[10007];
            Node* current = deck.head;
            for (int i = 0; i < 10007; i++) {
                new_nodes[(i * n) % 10007] = current;
                current = current->next;
            }
            for (int i = 0; i < 10007; i++) {
                new_nodes[i]->next = new_nodes[(i + 1) % 10007];
                new_nodes[i]->prev = new_nodes[(i - 1 + 10007) % 10007];
            }
            deck.head = new_nodes[0];
            deck.tail = new_nodes[10006];
        }
    }
    // distance of 2019 from head
    int index = 0;
    Node* current = deck.head;
    while (current->value != 2019) {
        current = current->next;
        index++;
    }

    for (int i = 0; i < 10007; i++) delete nodes[i];

    return std::to_string(index);
}


// Mostly from ChatGPT with some tweaks

static __int128_t MOD_M = (__int128_t)119315717514047LL;
static long long REPEAT_K = 101741582076661LL;

static inline long long norm128(__int128_t x) {
    x %= MOD_M;
    if (x < 0) x += MOD_M;
    return (long long)x;
}

static long long mulmod_ll(long long a, long long b) {
    __int128_t r = ( __int128_t)a * ( __int128_t)b;
    return norm128(r);
}

static long long powmod(long long base, long long exp) {
    __int128_t b = base;
    __int128_t res = 1;
    __int128_t m = MOD_M;
    while (exp > 0) {
        if (exp & 1) res = (res * b) % m;
        b = (b * b) % m;
        exp >>= 1;
    }
    return norm128(res);
}

// extended gcd for __int128_t
static __int128_t ext_gcd(__int128_t a, __int128_t b, __int128_t &x, __int128_t &y) {
    if (b == 0) {
        x = 1;
        y = 0;
        return a;
    }
    __int128_t x1, y1;
    __int128_t g = ext_gcd(b, a % b, x1, y1);
    x = y1;
    y = x1 - (a / b) * y1;
    return g;
}

static long long modinv(long long a) {
    __int128_t x, y;
    __int128_t aa = a;
    ext_gcd(aa < 0 ? aa + MOD_M : aa, MOD_M, x, y);
    // g should be 1
    long long inv = norm128(x);
    return inv;
}

std::string part2(const std::string_view input) {
    std::vector<Instruction> instructions;
    std::vector<std::string> lines = split(input, "\n");
    for (const std::string& line : lines) {
        if (line == "deal into new stack") {
            instructions.push_back({Instruction::DEAL_INTO_NEW_STACK, 0});
        } else if (line.starts_with("cut ")) {
            int n = std::stoi(line.substr(4));
            instructions.push_back({Instruction::CUT, n});
        } else if (line.starts_with("deal with increment ")) {
            int n = std::stoi(line.substr(20));
            instructions.push_back({Instruction::DEAL_WITH_INCREMENT, n});
        }
    }

    // We will compute forward mapping f(x) = a*x + b (mod M) for a single sequence of instructions
    // start with identity
    long long a = 1;
    long long b = 0;

    for (const Instruction& instr : instructions) {
        if (instr.type == Instruction::DEAL_INTO_NEW_STACK) {
            // op(u) = -u - 1
            // g(x) = - (a*x + b) - 1 = (-a) * x + (-b - 1)
            a = norm128(-(__int128_t)a);
            b = norm128(-(__int128_t)b - 1);
        } else if (instr.type == Instruction::CUT) {
            long long n = instr.argument;
            // op(u) = u - n
            // g(x) = a*x + b - n
            b = norm128((__int128_t)b - n);
        } else if (instr.type == Instruction::DEAL_WITH_INCREMENT) {
            long long n = instr.argument;
            // op(u) = u * n
            // g(x) = (a*x + b) * n = (a*n)*x + (b*n)
            a = mulmod_ll(a, n);
            b = mulmod_ll(b, n);
        }
    }

    // Compute f^K: a_k and b_k where f^K(x) = a_k * x + b_k (mod M)
    long long a_k = powmod(a, REPEAT_K);

    long long b_k;
    if (a == 1) {
        // f^k(x) = x + k*b
        b_k = norm128((__int128_t)b * ( (__int128_t)REPEAT_K ));
    } else {
        // b_k = b * (1 - a^k) * inv(1 - a) mod M
        long long one_minus_a = norm128(1 - (__int128_t)a);
        long long inv_one_minus_a = modinv(one_minus_a);
        long long numerator = norm128(1 - (__int128_t)a_k); // (1 - a^k)
        b_k = mulmod_ll(mulmod_ll(b, numerator), inv_one_minus_a);
    }

    // We want the card that ends up at position TARGET after K shuffles.
    // f maps original_index -> new_index. To find original index that maps to TARGET after K
    // shuffles we invert f^K:
    // x = (a_k)^{-1} * (TARGET - b_k) mod M
    const long long TARGET = 2020;
    long long inv_a_k = modinv(a_k);
    long long res = mulmod_ll(inv_a_k, norm128((__int128_t)TARGET - (__int128_t)b_k));

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