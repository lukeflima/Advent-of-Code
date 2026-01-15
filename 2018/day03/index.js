const fs = require('node:fs');

function part1(input) {
    const rects = input.split('\n').map(line => {
        const [id_str, rect_str] = line.split('@ ');
        const id = Number(id_str.slice(1));
        const [coords_str, size_str] = rect_str.split(': ');
        const [x, y] = coords_str.split(',').map(Number);
        const [w, h] = size_str.split('x').map(Number);
        return {id, x, y, w, h};
    })

    const fabric = {};
    for(const rect of rects) {
        for(let i = rect.x; i < rect.x + rect.w; i++) {
            for(let j = rect.y; j < rect.y + rect.h; j++) {
                const key = `${i},${j}`;
                if(fabric[key]) {
                    fabric[key]++;
                } else {
                    fabric[key] = 1;
                }
            }
        }
    }

    let count = 0;
    for(const key in fabric) {
        if(fabric[key] > 1) count++;
    }

    return count;
}

function part2(input) {
    const rects = input.split('\n').map(line => {
        const [id_str, rect_str] = line.split('@ ');
        const id = Number(id_str.slice(1));
        const [coords_str, size_str] = rect_str.split(': ');
        const [x, y] = coords_str.split(',').map(Number);
        const [w, h] = size_str.split('x').map(Number);
        return {id, x, y, w, h};
    })

    for(const rect of rects) {
        let overlap = false;
        for(const other of rects) {
            if(rect.id === other.id) continue;
            if(!(rect.x + rect.w <= other.x || 
                 other.x + other.w <= rect.x || 
                 rect.y + rect.h <= other.y || 
                 other.y + other.h <= rect.y)) {
                overlap = true;
                break;
            }
        }
        if(!overlap) {
            return rect.id;
        }
    }       
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