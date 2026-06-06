const sharp = require('sharp');
const fs = require('fs');
const path = require('path');

const inputDir = './covers';
const outputDir = './covers_compressed';

if (!fs.existsSync(outputDir)) fs.mkdirSync(outputDir);

// PNG lang ang source — hindi .jpg
const files = fs.readdirSync(inputDir).filter(f => f.endsWith('.png'));

// Skip kung may .jpg na sa output
const toProcess = files.filter(f => {
  const outName = f.replace('.png', '.jpg');
  return !fs.existsSync(path.join(outputDir, outName));
});

if (toProcess.length === 0) {
  console.log('Wala nang bago — lahat ay na-compress na!');
  process.exit(0);
}

console.log(`Bagong i-co-compress: ${toProcess.length} (skip: ${files.length - toProcess.length})`);

Promise.all(
  toProcess.map((file, i) =>
    sharp(path.join(inputDir, file))
      .resize(500, 600, { fit: 'cover' })
      .jpeg({ quality: 82 })
      .toFile(path.join(outputDir, file.replace('.png', '.jpg')))
      .then(() => {
  fs.unlinkSync(path.join(inputDir, file));
  console.log(`[${i+1}/${toProcess.length}] Done + Deleted: ${file}`);
})
  )
).then(() => console.log('TAPOS NA!'));