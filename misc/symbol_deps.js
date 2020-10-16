// arm-none-eabi-objdump -d build/a.out > a.d
// node symbol_deps.js a.d

const lines = (f) => require('fs').readFileSync(f).toString().split('\n');

const re_fn_start = /^[0-9a-f]{8} <([0-9A-Za-z_.]+).*>:$/;
const re_fn_ref = /<([0-9A-Za-z_.]+).*>$/;

const deps = [];
let cur_fn = '';

for (let line of lines(process.argv[2])) {
  const r1 = re_fn_start.exec(line);
  if (r1 !== null) cur_fn = r1[1];

  const r2 = re_fn_ref.exec(line);
  if (r2 !== null) {
    const fn = r2[1];
    if (fn !== cur_fn) {
      // Add edge (fn, cur_fn)
      if (deps[fn] === undefined) deps[fn] = {};
      deps[fn][cur_fn] = 1;
    }
  }
}

let vis = undefined;
let count = undefined;
const traverse = (fn, level) => {
  if (level === undefined) {
    level = 0;
    vis = {};
    count = 0;
  } else {
    console.log('  '.repeat(level) + fn);
  }
  for (let f in deps[fn]) {
    if (vis[f] === undefined) {
      vis[f] = 1;
      count++;
      traverse(f, level + 1);
    }
  }
};

console.log('Parsing done. Enter a list of symbols, one on each line');
require('readline').createInterface(process.stdin).on('line', (line) => {
  traverse(line);
  console.log(count);
});
