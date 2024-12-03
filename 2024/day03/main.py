
class Result:
    bytes: int

    def __init__(self, bytes: int):
        self.bytes = bytes


class MultResult(Result):
    result: int

    def __init__(self, result, bytes: int):
        self.result = result
        super().__init__(bytes)


class EnableResult(Result):
    enable: bool

    def __init__(self, enable, bytes: int):
        self.enable = enable
        super().__init__(bytes)

    
def parse_mul(input: str, start: int) -> MultResult | None:
    c = start
    lhs, rhs = 0, 0
    if input[c:c+4] == 'mul(':
        c += 4 

        digit_count = 0
        digits = ""
        while digit_count < 3:
            if input[c].isdigit():
                digits += input[c]
                digit_count += 1
                c += 1
            else: 
                break
        if digit_count == 0:
            return None
        lhs = int(digits)

        if input[c] != ',':
            return None
        c += 1
        
        digit_count = 0
        digits = ""
        while digit_count < 3:
            if input[c].isdigit():
                digits += input[c]
                digit_count += 1
                c += 1
            else: 
                break
        if digit_count == 0:
            return None
        if input[c] != ")":
            return None
        c += 1
        rhs = int(digits)
        return MultResult(lhs*rhs, c - start)
    return None 

def parse_enable(input: str, start: int) -> EnableResult | None:
    if input[start:start+4] == "do()":
        return EnableResult(True, 4)
    if input[start:start+7] == "don't()":
        return EnableResult(False, 7)
    return None

def part1(input):
    c = 0
    s = 0
    while c < len(input):
        r = parse_mul(input, c)
        if r is None:
            c += 1
        else:
            s += r.result
            c += r.bytes
    print("Part 1:", s)
    return 0

def part2(input):
    c = 0
    s = 0
    enabled = True
    while c < len(input):
        mul_r = parse_mul(input, c)
        if mul_r is None:
            enabled_r = parse_enable(input, c)
            if enabled_r is None:
                c += 1
            else:
                enabled = enabled_r.enable
                c += enabled_r.bytes
        else:
            if enabled:
                s += mul_r.result
            c += mul_r.bytes
    print("Part 2:", s)
    return 0

def main():
    # with open("inputtest.txt") as input:
    with open("input.txt") as input:
        input = input.read()
    if ret := part1(input): return ret
    if ret := part2(input): return ret

if __name__ == "__main__":
    raise SystemExit(main())