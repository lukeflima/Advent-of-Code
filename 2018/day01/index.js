const { assert } = require('node:console');
const fs = require('node:fs');

function part1(input) {
    let freq = 0;
    for(const line of input.split('\n')) {
        freq += parseInt(line);
    }
    return freq;
}

function part2(input) {
    let freq = 0;
    const seq = input.split('\n').map(s => parseInt(s));
    
    let i = 0;
    const reached = {};
    while(true) {
        if(reached[freq]) return freq;
        reached[freq] = true;
        freq += seq[i];
        i = (i + 1) % seq.length;
    }
    
    assert(false, "Unreachable");
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