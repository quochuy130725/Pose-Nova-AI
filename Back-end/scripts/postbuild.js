const fs = require('fs');
const path = require('path');

const distDir = path.join(__dirname, '..', 'dist');
const targetFile = path.join(distDir, 'server.js');

if (!fs.existsSync(distDir)) {
  fs.mkdirSync(distDir, { recursive: true });
}

// Shim to support both 'node dist/server.js' and 'node dist/src/server.js'
fs.writeFileSync(targetFile, "require('./src/server.js');\n", 'utf8');
console.log('✅ Generated dist/server.js redirect shim to dist/src/server.js');

// Copy docs directory to dist/docs
const docsSrc = path.join(__dirname, '..', 'docs');
const docsDest = path.join(distDir, 'docs');
if (fs.existsSync(docsSrc)) {
  fs.cpSync(docsSrc, docsDest, { recursive: true });
  console.log('✅ Copied docs to dist/docs');
}

