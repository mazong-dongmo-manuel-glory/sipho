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

  // ── XP / referral exploits ───────────────────────────────────────────────────

  const validProfile = {
    displayName: 'Alice',
    countryCode: 'CA',
    currency: 'CAD',
    locale: 'fr',
    timezone: 'America/Toronto',
    utcOffsetMinutes: -300,
    onboardingDone: true,
  };

  async function seedUser(extra: Record<string, unknown> = {}): Promise<void> {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await ctx.firestore().doc(`users/${aliceUid}`).set({ ...validProfile, ...extra });
    });
  }

  test('Client CANNOT clear redeemedReferralCode to redeem a referral again', async () => {
    await seedUser({ redeemedReferralCode: 'FRIEND1', referredByUid: bobUid });
    const aliceDb = testEnv.authenticatedContext(aliceUid).firestore();
    const userDoc = aliceDb.doc(`users/${aliceUid}`);
    // Replacing the whole document silently drops the fields: that must be refused too.
    await assertFails(userDoc.set(validProfile));
    await assertFails(userDoc.set({ ...validProfile, referredByUid: bobUid }));
    await assertFails(userDoc.update({ redeemedReferralCode: null }));
    await assertFails(userDoc.update({ referredByUid: 'someone_else' }));
  });

  test('Client CANNOT forge a referral code or lesson progress on its own profile', async () => {
    await seedUser();
    const aliceDb = testEnv.authenticatedContext(aliceUid).firestore();
    const userDoc = aliceDb.doc(`users/${aliceUid}`);
    await assertFails(userDoc.update({ redeemedReferralCode: 'X' }));
    await assertFails(userDoc.update({ completedLessonIds: ['fake_lesson'] }));
    await assertFails(userDoc.update({ lastActiveDate: '2099-01-01' }));
  });

  test('Client CAN still update its own harmless profile fields (incl. time zone)', async () => {
    await seedUser();
    const aliceDb = testEnv.authenticatedContext(aliceUid).firestore();
    await assertSucceeds(
      aliceDb.doc(`users/${aliceUid}`).update({
        displayName: 'Alice B',
        timezone: 'Asia/Kolkata',
        utcOffsetMinutes: 330,
      })
    );
  });

  test('Time zone fields are validated (offset in minutes, bounded)', async () => {
    await seedUser();
    const aliceDb = testEnv.authenticatedContext(aliceUid).firestore();
    const userDoc = aliceDb.doc(`users/${aliceUid}`);
    await assertFails(userDoc.update({ utcOffsetMinutes: 330.5 }));
    await assertFails(userDoc.update({ utcOffsetMinutes: 5000 }));
    await assertFails(userDoc.update({ utcOffsetMinutes: '330' }));
    await assertFails(userDoc.update({ timezone: 'x'.repeat(80) }));
  });

  test('New profile cannot be created with server-only fields', async () => {
    const aliceDb = testEnv.authenticatedContext(aliceUid).firestore();
    const userDoc = aliceDb.doc(`users/${aliceUid}`);
    await assertFails(userDoc.set({ ...validProfile, redeemedReferralCode: 'X' }));
    await assertFails(userDoc.set({ ...validProfile, completedLessonIds: ['emergency_fund'] }));
    await assertSucceeds(userDoc.set(validProfile));
  });

  test('Client CANNOT write server-owned documents (months, quests, referral marker, dailyXp)', async () => {
    await seedUser();
    const aliceDb = testEnv.authenticatedContext(aliceUid).firestore();
    await assertFails(
      aliceDb.doc(`users/${aliceUid}/months/2026-01`).set({ fixedPaid: { rent: { paid: true } } })
    );
    await assertFails(aliceDb.doc(`users/${aliceUid}/quests/daily_x`).set({ status: 'completed' }));
    await assertFails(aliceDb.doc(`users/${aliceUid}/referral/redemption`).delete());
    await assertFails(aliceDb.doc(`users/${aliceUid}/dailyXp/2026-11-14`).set({ fromTransactions: 0 }));
  });

  test('Fixed expense rules: payMode / type / active are validated', async () => {
    const aliceDb = testEnv.authenticatedContext(aliceUid).firestore();
    const base = { name: 'Rent', category: 'rent', amountCents: 90000, dueDay: 1 };
    const ref = aliceDb.collection(`users/${aliceUid}/fixedExpenses`);
    await assertSucceeds(ref.doc('ok').set({ ...base, payMode: 'manual', type: 'bill', active: true }));
    await assertFails(ref.doc('bad1').set({ ...base, payMode: 'whenever' }));
    await assertFails(ref.doc('bad2').set({ ...base, type: 'mystery' }));
    await assertFails(ref.doc('bad3').set({ ...base, active: 'yes' }));
  });

  test('Transactions: absurd dates are rejected', async () => {
    const aliceDb = testEnv.authenticatedContext(aliceUid).firestore();
    const tx = aliceDb.collection(`users/${aliceUid}/transactions`);
    const base = { amountCents: 100, currency: 'CAD', category: 'groceries', source: 'manual' };
    await assertSucceeds(tx.doc('ok').set({ ...base, date: '2026-11-12' }));
    await assertFails(tx.doc('old').set({ ...base, date: '1970-01-01' }));
    await assertFails(tx.doc('far').set({ ...base, date: '2999-01-01' }));
  });
});
