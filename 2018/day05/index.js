const fs = require('node:fs');

function reduce_polymer(input) {    
    while(true) {
        let did_reduce = false;
        for(let i = 0; i < input.length - 1; i++) {
            if(input[i] !== input[i+1] && input[i].toLowerCase() === input[i+1].toLowerCase()) {
                input = input.slice(0, i) + input.slice(i + 2);
                did_reduce = true;
            }
        }
        if(!did_reduce) break;
    }
    return input;
}

function part1(input) {
    return reduce_polymer(input).length;
}

function part2(input) {
    let min_length = input.length;
    for(let charCode = 'a'.charCodeAt(0); charCode <= 'z'.charCodeAt(0); charCode++) {
        const filtered_input = input.split('').filter(c => c.toLowerCase() !== String.fromCharCode(charCode)).join('');
        const reduced_filtered = reduce_polymer(filtered_input);
        if(reduced_filtered.length < min_length) {
            min_length = reduced_filtered.length;
        }
    }
    return min_length;
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