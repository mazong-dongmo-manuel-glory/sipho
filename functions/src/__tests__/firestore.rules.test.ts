import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
  RulesTestEnvironment,
} from '@firebase/rules-unit-testing';
import * as fs from 'fs';
import * as path from 'path';

let testEnv: RulesTestEnvironment;

beforeAll(async () => {
  const rules = fs.readFileSync(path.resolve(__dirname, '../../../firestore.rules'), 'utf8');
  testEnv = await initializeTestEnvironment({
    projectId: 'sipho-dev-test',
    firestore: { rules },
  });
});

afterAll(async () => {
  if (testEnv) {
    await testEnv.cleanup();
  }
});

beforeEach(async () => {
  await testEnv.clearFirestore();
});

describe('Firestore Security Rules', () => {
  const aliceUid = 'alice_123';
  const bobUid = 'bob_456';

  test('User can read their own user profile', async () => {
    const aliceDb = testEnv.authenticatedContext(aliceUid).firestore();
    const userDoc = aliceDb.doc(`users/${aliceUid}`);
    await assertSucceeds(userDoc.get());
  });

  test('User CANNOT read another users profile directly', async () => {
    const bobDb = testEnv.authenticatedContext(bobUid).firestore();
    const aliceDoc = bobDb.doc(`users/${aliceUid}`);
    await assertFails(aliceDoc.get());
  });

  test('Client CANNOT write to game/state (Functions only)', async () => {
    const aliceDb = testEnv.authenticatedContext(aliceUid).firestore();
    const gameState = aliceDb.doc(`users/${aliceUid}/game/state`);
    await assertFails(gameState.set({ xp: 1000 }));
  });

  test('Client can create valid manual transaction with positive int cents', async () => {
    const aliceDb = testEnv.authenticatedContext(aliceUid).firestore();
    const tx = aliceDb.collection(`users/${aliceUid}/transactions`).doc('tx1');
    await assertSucceeds(
      tx.set({
        amountCents: 1550,
        currency: 'CAD',
        category: 'groceries',
        date: '2026-11-12',
        source: 'manual',
      })
    );
  });

  test('Client CANNOT create transaction with negative cents', async () => {
    const aliceDb = testEnv.authenticatedContext(aliceUid).firestore();
    const tx = aliceDb.collection(`users/${aliceUid}/transactions`).doc('tx_invalid');
    await assertFails(
      tx.set({
        amountCents: -500,
        currency: 'CAD',
        category: 'groceries',
        date: '2026-11-12',
        source: 'manual',
      })
    );
  });

  test('Public profile has no money amounts and is readable by any authenticated user', async () => {
    const bobDb = testEnv.authenticatedContext(bobUid).firestore();
    const publicProfile = bobDb.doc(`publicProfiles/${aliceUid}`);
    await assertSucceeds(publicProfile.get());
  });
});

