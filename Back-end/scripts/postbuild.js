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
