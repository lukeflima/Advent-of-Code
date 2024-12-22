def mix(num, secret_number):
    return num ^ secret_number

def prune(secret_number):
    return secret_number % 16777216

def calculate_number(secret_number):
    secret_number = prune(mix(secret_number * 64, secret_number))
    secret_number = prune(mix(secret_number // 32, secret_number))
    secret_number = prune(mix(secret_number * 2048, secret_number))
    return secret_number


def part1(input: str):
    secret_numbers = list(map(int, input.splitlines()))
    res = 0
    for secret_number in secret_numbers:
        for i in range(2000):
            secret_number = calculate_number(secret_number)
        res += secret_number
    print("Part 1:", res)
    return 0

def part2(input: str):
    secret_numbers = list(map(int, input.splitlines()))

    price_changes = []
    for secret_number in secret_numbers:
        prev_price = secret_number % 10
        prev_number = secret_number
        difs = []
        for i in range(2000):
            secret_number = calculate_number(prev_number)
            price = secret_number % 10
            difs.append((price, price - prev_price))
            prev_number = secret_number
            prev_price = price
        price_changes.append(difs)

    scores = {}
    for price_change in price_changes:
        seen = set()
        for a, b, c, d in zip(price_change, price_change[1:], price_change[2:], price_change[3:]):
            pattern = (a[1], b[1], c[1], d[1])
            if pattern not in scores:
                scores[pattern] = d[0]
            elif pattern in scores and pattern not in seen:
                scores[pattern] += d[0]
            seen.add(pattern)
    
    print("Part 2:", max(scores.values()))
    return 0


def main():
    # with open("inputtest.txt") as input:
    with open("input.txt") as input:
        input = input.read()
    if ret := part1(input): return ret
    if ret := part2(input): return ret

if __name__ == "__main__":
    raise SystemExit(main())