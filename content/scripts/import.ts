import * as admin from 'firebase-admin';
import * as fs from 'fs';
import * as path from 'path';

// Run with: npx ts-node content/scripts/import.ts --project sipho-dev
async function main() {
  if (!admin.apps.length) {
    admin.initializeApp();
  }
  const db = admin.firestore();
  console.log('Starting content import to Firestore...');

  // 1. Import countries
  const countriesDir = path.resolve(__dirname, '../countries');
  const countryFiles = fs.readdirSync(countriesDir).filter((f) => f.endsWith('.json'));

  for (const file of countryFiles) {
    const filePath = path.join(countriesDir, file);
    const data = JSON.parse(fs.readFileSync(filePath, 'utf8'));
    const docId = data.code;
    await db.doc(`countries/${docId}`).set(data, { merge: true });
    console.log(`✓ Imported country pack: ${docId}`);
  }

  // 2. Import lessons
  const lessonsDir = path.resolve(__dirname, '../lessons');
  const lessonFiles = fs.readdirSync(lessonsDir).filter((f) => f.endsWith('.json'));

  for (const file of lessonFiles) {
    const filePath = path.join(lessonsDir, file);
    const data = JSON.parse(fs.readFileSync(filePath, 'utf8'));
    const docId = data.id;
    await db.doc(`lessons/${docId}`).set(data, { merge: true });
    console.log(`✓ Imported lesson: ${docId}`);
  }

  console.log('✅ Content import complete!');
}

main().catch((err) => {
  console.error('Error importing content:', err);
  process.exit(1);
});

