
# Better brain

Get a personalized task every day, based on the skills and areas of life that you wish to improve on.


## Features
- Get a new task every day, based on the areas of life that you want to improve on
- Either log in to save stats across devices, or use as guest to save progess on device instead
- Keep track of your daily streak
- See previous tasks in the handy calendar view
- Rate and give feedback on the tasks to change their difficulty
## Tech used

**Client:** Flutter

**Authentication:** oAuth 

**Backend:** Supabase (Postgres, Auth, pg_cron)


## Setup

### 1. Supabase project

1. Create a project at [supabase.com](https://supabase.com).
2. Apply the SQL in `supabase/migrations/` in order, either with the Supabase CLI (`supabase link --project-ref <ref>` then `supabase db push`) or by pasting each file into the SQL editor.
   - `..._initial_schema.sql` creates the tables, Row Level Security, the task RPCs and an hourly `pg_cron` job that records missed days and pre-assigns each user's next task.
   - `..._seed_task_templates.sql` loads the task catalogue. It is safe to re-run after editing.
3. In **Authentication > Sign In / Providers**:
   - keep **Email** enabled. With **Confirm email** on, new users must click the link before they can log in;
   - enable **Allow anonymous sign-ins** (used for guest mode). Turning on CAPTCHA or rate limits for it is recommended;
   - enable **Google** and enter the Web client ID and secret from Google Cloud. Add the iOS client ID to "Authorized Client IDs" if you build for iOS.

### 2. App config

Copy `config/app_config.example.json` to `config/app_config.json` (git-ignored) and fill in:

| Key | Where to find it |
| --- | --- |
| `SUPABASE_URL` | Project Settings > API |
| `SUPABASE_ANON_KEY` | Project Settings > API Keys (anon or publishable key; never the service role key) |
| `GOOGLE_WEB_CLIENT_ID` | Google Cloud > Credentials > OAuth client of type "Web application" |
| `GOOGLE_IOS_CLIENT_ID` | Google Cloud OAuth client of type "iOS" (iOS only) |

Run with:

```
flutter pub get
flutter run --dart-define-from-file=config/app_config.json
```

The VS Code launch configurations already pass this file.

For Google sign-in on Android, the Android OAuth client in Google Cloud must have your app's SHA-1. On iOS, add the reversed iOS client ID as a URL scheme in `ios/Runner/Info.plist`.

### 3. Moving existing Firebase users (one-off)

`scripts/migrate_firebase_data.mjs` copies Firebase Auth users, their category levels and task history into Supabase. Firebase password hashes can't be used by Supabase, so email/password users reset their password once: run the script with `--send-reset` to email them a link, or they can use "Forgot password?" on the login screen. Google users just sign in with Google again. See the comment at the top of the script for usage, and start with `--dry-run`.

## How daily tasks work

- The server picks and saves today's task the first time the app asks (`get_or_assign_daily_task`), so reopening the app always shows the same task.
- Categories are weighted toward goals and categories you haven't seen lately, with a breather after "too hard" and no back-to-back repeats. Templates have cooldowns and level windows, and amounts follow a curve between each template's min and max.
- Feedback moves the category level: too easy +0.5, just right +0.2, no feedback +0.1, too hard −0.3. A missed day is −0.2 and a swap is −0.1. Levels stay between 1 and 10.
- One free swap per day (`swap_daily_task`).
- An hourly `pg_cron` job (`daily_rollover`) marks unfinished past tasks as missed and assigns the new day's task for users active in the last 30 days, even if the app stays closed.
- Guests are Supabase anonymous users, so they get the same tasks and can upgrade to an email account from the menu without losing progress.

## Screenshots

[![account-creation.jpg](https://i.postimg.cc/mgdY2r95/account-creation.jpg)](https://postimg.cc/BjKLm4MT)

[![cat-selection.jpg](https://i.postimg.cc/0QSDfdBT/cat-selection.jpg)](https://postimg.cc/zbJyDW57)

[![conf.jpg](https://i.postimg.cc/tgwFWm2d/conf.jpg)](https://postimg.cc/1g0gZMx4)

[![main-screen.jpg](https://i.postimg.cc/qqXnfB0Q/main-screen.jpg)](https://postimg.cc/D40mLTSb)

[![success.jpg](https://i.postimg.cc/VkNtTchB/success.jpg)](https://postimg.cc/QHRV9vhH)

[![calendar.jpg](https://i.postimg.cc/d3KdSZML/calendar.jpg)](https://postimg.cc/tZ2YsT4j)
