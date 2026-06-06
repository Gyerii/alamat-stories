const sharp = require('sharp');
const fs = require('fs');
const path = require('path');

const inputDir = './covers';
const outputDir = './covers_compressed';

if (!fs.existsSync(outputDir)) fs.mkdirSync(outputDir);

const files = fs.readdirSync(inputDir).filter(f => f.endsWith('.jpg'));
console.log(`Compressing ${files.length} images...`);

Promise.all(
  files.map((file, i) =>
    sharp(path.join(inputDir, file))
      .resize(500, 600, { fit: 'cover' })
      .jpeg({ quality: 82 })
      .toFile(path.join(outputDir, file.replace('.jpg', '.jpg')))
      .then(() => console.log(`[${i+1}/${files.length}] Done: ${file}`))
  )
).then(() => console.log('TAPOS NA!'));