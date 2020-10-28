if (process.argv.length <= 2) {
  console.log(`usage: ${process.argv[0]} <map.yml>`);
  process.exit(0);
}
const input = process.argv[2];

const p = input.lastIndexOf('.');
const output = (p === -1 ? input : input.substr(0, p)) + '.s';

const data = require('js-yaml').safeLoad(require('fs').readFileSync(input));

const lines = [];
const ln = (x) => lines.push(x);
ln(`.data`);
ln(`.org    0`);
ln(``);
ln(`.int    title`);
ln(`.int    audio`);
ln(`.float  ${data.tempo}`);
ln(`.float  ${data.offset}`);
ln(`.int    sequence`);
ln(`.int    decorations`);
ln(``);
ln(`title:  .asciz  "${data.title}"`);
ln(`audio:  .incbin "${data.audio}"`);
ln(``);
ln(`.align  4`);
ln(`sequence:`);
ln(`  .int  ${data.sequence.length}`);
for (let i = 0; i < data.sequence.length; i++)
  ln(`  .int  segment_${i}`);
for (let i = 0; i < data.sequence.length; i++) {
  const seg = data.sequence[i];
  ln(`segment_${i}:`);
  ln(`  .int  ${seg.time}`);
  ln(`  .int  ${seg.lead}`);
  ln(`  .int  ${seg.notes.length}`);
  for (let j = 0; j < seg.notes.length; j++) {
    const note = seg.notes[j];
    const type = (note[0] === 'u' ? 0 : (note[0] === 'd' ? 1 : 2));
    const time = note[1] + eval(note[2] || 0);
    ln(`    .int  ${type};  .float  ${time}`);
  }
}
ln(``);
ln(`.align  4`);
ln(`decorations:`);
ln(`  .int    ${data.decorations.length}`);
for (let i = 0; i < data.decorations.length; i++) {
  const decor = data.decorations[i];
  ln(`decoration_${i}:`);
  ln(`  .int    ${decor.type}`);
  ln(`  .float  ${decor.position[0]}`);
  ln(`  .float  ${decor.position[1]}`);
  ln(`  .float  ${decor.position[2] || 0}`);
  ln(`  .float  ${(decor.size && decor.size[0]) || 1}`);
  ln(`  .float  ${(decor.size && decor.size[1]) || 1}`);
}

require('fs').writeFileSync(output, lines.join('\n') + '\n');
