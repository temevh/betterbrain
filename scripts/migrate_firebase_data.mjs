// One-off copy of Better Brain users and history from Firebase to Supabase.
//
// What it does
//   1. Creates a Supabase auth user for every Firebase Auth user (same email,
//      marked confirmed). Firebase password hashes can't be verified by
//      Supabase, so email/password users must reset their password once
//      (pass --send-reset to email them a link). Google users just sign in
//      with Google again and Supabase links the identity by email.
//   2. Copies users/{uid}.stats into user_category_levels.
//   3. Copies users/{uid}/tasks into daily_assignments. The date comes from
//      the year/month/day fields, not the `date` Timestamp. Rows with
//      difficulty 404 or isCompleted false become status 'missed'.
//
// Usage (from this folder):
//   npm install
//   set FIREBASE_SERVICE_ACCOUNT=path/to/service-account.json
//   set SUPABASE_URL=https://<ref>.supabase.co
//   set SUPABASE_SERVICE_ROLE_KEY=<service role key, never commit it>
//   node migrate_firebase_data.mjs --dry-run
//   node migrate_firebase_data.mjs [--send-reset]
//
// Safe to re-run: existing users are matched by email and existing days are
// skipped.

import { readFileSync } from 'node:fs';
import admin from 'firebase-admin';
import { createClient } from '@supabase/supabase-js';

const args = new Set(process.argv.slice(2));
const DRY_RUN = args.has('--dry-run');
const SEND_RESET = args.has('--send-reset');

const { FIREBASE_SERVICE_ACCOUNT, SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY } = process.env;
if (!FIREBASE_SERVICE_ACCOUNT || !SUPABASE_URL || !SUPABASE_SERVICE_ROLE_KEY) {
  console.error('Set FIREBASE_SERVICE_ACCOUNT, SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY.');
  process.exit(1);
}

admin.initializeApp({
  credential: admin.credential.cert(JSON.parse(readFileSync(FIREBASE_SERVICE_ACCOUNT, 'utf8'))),
});
const firestore = admin.firestore();
const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, {
  auth: { autoRefreshToken: false, persistSession: false },
});

const CATEGORIES = new Set([
  'fitness', 'learning', 'productivity', 'selfcare', 'social', 'focus', 'creativity',
]);

const pad = (n) => String(n).padStart(2, '0');
const clampLevel = (v) => Math.round(Math.min(10, Math.max(1, Number(v) || 1)) * 10) / 10;

async function listFirebaseUsers() {
  const users = [];
  let pageToken;
  do {
    const page = await admin.auth().listUsers(1000, pageToken);
    users.push(...page.users);
    pageToken = page.pageToken;
  } while (pageToken);
  return users;
}

async function findSupabaseUserIdByEmail(email) {
  const { data, error } = await supabase
    .from('profiles')
    .select('id')
    .ilike('email', email)
    .maybeSingle();
  if (error) throw error;
  return data?.id ?? null;
}

async function ensureSupabaseUser(fbUser) {
  const existing = await findSupabaseUserIdByEmail(fbUser.email);
  if (existing) return existing;
  if (DRY_RUN) return null;

  const { data, error } = await supabase.auth.admin.createUser({
    email: fbUser.email,
    email_confirm: true,
    user_metadata: { legacy_firebase_uid: fbUser.uid },
  });
  if (error) throw error;
  return data.user.id;
}

async function migrateUser(fbUser, summary) {
  if (!fbUser.email) {
    summary.skippedNoEmail++;
    return;
  }
  const providers = fbUser.providerData.map((p) => p.providerId);
  const userId = await ensureSupabaseUser(fbUser);

  const userDoc = await firestore.collection('users').doc(fbUser.uid).get();
  const stats = userDoc.exists ? userDoc.data().stats ?? {} : {};
  const levels = Object.entries(stats)
    .filter(([category]) => CATEGORIES.has(category))
    .map(([category, value]) => ({
      user_id: userId,
      category,
      level: clampLevel(value),
      goal: true,
      enabled: true,
    }));

  const taskSnap = await firestore.collection('users').doc(fbUser.uid).collection('tasks').get();
  const byDate = new Map();
  for (const doc of taskSnap.docs) {
    const t = doc.data();
    if (!t.year || !t.month || !t.day || !CATEGORIES.has(t.category)) continue;
    const assignedDate = `${t.year}-${pad(t.month)}-${pad(t.day)}`;
    const completed = t.isCompleted === true && t.difficulty !== 404;
    const feedback = completed && [-1, 0, 1].includes(t.difficulty) ? t.difficulty : null;
    const reflection =
      completed && typeof t.reflection === 'string' && t.reflection.trim() ? t.reflection.trim() : null;
    const row = {
      user_id: userId,
      assigned_date: assignedDate,
      template_id: null,
      category: t.category,
      rendered_text: t.taskText || '(task text missing)',
      status: completed ? 'completed' : 'missed',
      feedback,
      reflection,
      assigned_at: (t.createdAt?.toDate?.() ?? new Date(assignedDate)).toISOString(),
      completed_at: completed ? (t.createdAt?.toDate?.() ?? new Date(assignedDate)).toISOString() : null,
    };
    // Old builds could save two rows for one day; keep the completed one.
    const prev = byDate.get(assignedDate);
    if (!prev || (prev.status !== 'completed' && row.status === 'completed')) {
      byDate.set(assignedDate, row);
    }
  }
  const assignments = [...byDate.values()];

  console.log(
    `${fbUser.email} [${providers.join(', ') || 'no provider'}]: ` +
      `${levels.length} categories, ${assignments.length} days` +
      (userId ? '' : ' (would create user)'),
  );
  summary.users++;
  summary.days += assignments.length;
  if (DRY_RUN) return;

  const { error: profileError } = await supabase
    .from('profiles')
    .update({ legacy_firebase_uid: fbUser.uid, last_seen_at: new Date().toISOString() })
    .eq('id', userId);
  if (profileError) throw profileError;

  if (levels.length) {
    const { error } = await supabase
      .from('user_category_levels')
      .upsert(levels, { onConflict: 'user_id,category' });
    if (error) throw error;
  }

  if (assignments.length) {
    const { error } = await supabase
      .from('daily_assignments')
      .upsert(assignments, { onConflict: 'user_id,assigned_date', ignoreDuplicates: true });
    if (error) throw error;
  }

  if (SEND_RESET && providers.includes('password')) {
    const { error } = await supabase.auth.resetPasswordForEmail(fbUser.email);
    if (error) console.warn(`  could not send reset email: ${error.message}`);
    else summary.resetsSent++;
  }
}

const summary = { users: 0, days: 0, skippedNoEmail: 0, resetsSent: 0, failed: 0 };
const fbUsers = await listFirebaseUsers();
console.log(`${fbUsers.length} Firebase users${DRY_RUN ? ' (dry run, nothing is written)' : ''}`);

for (const fbUser of fbUsers) {
  try {
    await migrateUser(fbUser, summary);
  } catch (e) {
    summary.failed++;
    console.error(`Failed for ${fbUser.email ?? fbUser.uid}: ${e.message ?? e}`);
  }
}

console.log(summary);
