def get_rules_and_updates(input: str):
    rules_str, updates_str = [i.strip() for i in input.split("\n\n")]
    rules = [rule.split("|") for rule in rules_str.split('\n')]
    updates = [update.split(",") for update in updates_str.split('\n')]
    return rules, updates


def check_update(update, rules_map):
    update_map = {n: i for i,n in enumerate(update)}
    valid = True
    broken_rules = []
    for u in update:
        for rule in rules_map.get(u, []):
            if rule in update_map and update_map[rule] < update_map[u]:
                valid = False
                broken_rules.append((u, rule))
    return valid, broken_rules


def part1(input: str):
    rules, updates = get_rules_and_updates(input) 
    rules_map: dict[str, list[str]] = {}
    updates_valid = [True] * len(updates)
    for [r1, r2] in rules:
        if r1 not in rules_map: rules_map[r1] = []
        rules_map[r1].append(r2)
    
    for j, update in enumerate(updates):
        updates_valid[j], _ = check_update(update, rules_map)

    valid_updates = [u for i, u in enumerate(updates) if updates_valid[i]]
    res = sum(int(x[len(x)//2]) for x in valid_updates)
    print("Part 1:", res)
    return 0

def part2(input: str):
    rules, updates = get_rules_and_updates(input) 
    rules_map: dict[str, list[str]] = {}
    updates_valid = [True] * len(updates)
    broken_rules: list[list[tuple[int, int]]] = [[] for _ in range(len(updates))]
    for [r1, r2] in rules:
        if r1 not in rules_map: rules_map[r1] = []
        rules_map[r1].append(r2)
    
    for j, update in enumerate(updates):
        updates_valid[j], broken_rules[j] = check_update(update, rules_map)
                    
    for i, update in enumerate(updates):
        if not updates_valid[i]:
            new_update = update[:]
            broke = broken_rules[i]
            valid = False
            while not valid: 
                r1, r2 = broke[0]
                i1 = new_update.index(r1)
                i2 = new_update.index(r2)
                del new_update[i1]
                new_update.insert(i2, r1)
                valid, broke = check_update(new_update, rules_map)
            updates[i] = new_update

    incorrect_updates = [u for i, u in enumerate(updates) if not updates_valid[i]]
    res = sum(int(x[len(x)//2]) for x in incorrect_updates)
    print("Part 2:", res)
    return 0

def main():
    # with open("inputtest.txt") as input:
    with open("input.txt") as input:
        input = input.read()
    if ret := part1(input): return ret
    if ret := part2(input): return ret

if __name__ == "__main__":
    raise SystemExit(main())