const fs = require('fs');

// 1. discovery_feed_screen.dart
let f1 = fs.readFileSync('Front-end/lib/screens/discovery_feed_screen.dart', 'utf8');
f1 = f1.replace(/'ESCROW PROTECTED'/, "AppLanguageController.instance.isEnglish ? 'ESCROW PROTECTED' : 'BẢO VỆ KÝ QUỸ'");
fs.writeFileSync('Front-end/lib/screens/discovery_feed_screen.dart', f1);
console.log('Updated discovery_feed_screen.dart');

// 2. create_styling_request_screen.dart
let f2 = fs.readFileSync('Front-end/lib/screens/create_styling_request_screen.dart', 'utf8');
f2 = f2.replace(/'Escrow Protected'/, "AppLanguageController.instance.isEnglish ? 'Escrow Protected' : 'Bảo Vệ Ký Quỹ'");
fs.writeFileSync('Front-end/lib/screens/create_styling_request_screen.dart', f2);
console.log('Updated create_styling_request_screen.dart');
