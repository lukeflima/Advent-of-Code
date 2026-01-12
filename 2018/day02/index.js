const { log } = require('node:console');
const fs = require('node:fs');

function part1(input) {
    let contain_twice = 0;
    let contain_thrice = 0;
    for(const line of input.split("\n")) {
        
        const freq_chars = {}
        for(const c of line) {
            if(freq_chars[c]) freq_chars[c] += 1;
            else freq_chars[c] = 1;
        }
        
        let does_contain_twice = false;
        let does_contain_thrice = false;
        for(const char in freq_chars) {
            if(freq_chars[char] == 2) does_contain_twice = true;
            if(freq_chars[char] == 3) does_contain_thrice = true;
        }

        if(does_contain_twice) contain_twice += 1;
        if(does_contain_thrice) contain_thrice += 1;
    }
    return contain_twice * contain_thrice;
}

// chatgpt
function levenshtein(a, b) {
  if (a.length < b.length) [a, b] = [b, a];

  let previous = Array(b.length + 1).fill(0);
  let current = Array(b.length + 1).fill(0);

  for (let j = 0; j <= b.length; j++) previous[j] = j;

  for (let i = 1; i <= a.length; i++) {
    current[0] = i;
    for (let j = 1; j <= b.length; j++) {
      const cost = a[i - 1] === b[j - 1] ? 0 : 1;
      current[j] = Math.min(
        previous[j] + 1,
        current[j - 1] + 1,
        previous[j - 1] + cost
      );
    }
    [previous, current] = [current, previous];
  }

  return previous[b.length];
}

function part2(input) {
    const ids = input.split("\n");
    let id1 = '';
    let id2 = '';
    loop: for(let i = 0; i < ids.length; i++) {
        for(let j = i+1; j < ids.length; j++) {
            if(levenshtein(ids[i], ids[j]) == 1) {
                id1 = ids[i];
                id2 = ids[j];
                break loop;
            }
        }
    }
    let res = '';
    for(let i = 0; i < id1.length; i++) {
        if(id1[i] == id2[i]) res += id1[i];
    }
    return res;
}

function main() {
    if(process.argv.length != 3) {
        console.log("node index.js <text input>")
        process.exit(1);
    }
    
    const input = fs.readFileSync(process.argv[2], "utf8").trim();

    console.log(`Part 1: ${part1(input)}`);
    console.log(`Part 2: ${part2(input)}`);
}   

main();