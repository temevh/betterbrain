-- Better Brain: initial Supabase schema
--
-- Replaces the Firestore collections `tasks`, `users` and `users/{uid}/tasks`
-- with Postgres tables protected by Row Level Security. Daily task assignment,
-- swaps, completion and missed-day bookkeeping run in the database as RPCs so
-- the client can't reroll tasks or race on stat updates.

-- ---------------------------------------------------------------------------
-- Lookup: categories
-- ---------------------------------------------------------------------------
create table public.categories (
  id text primary key,
  sort_order smallint not null default 0
);

insert into public.categories (id, sort_order) values
  ('fitness', 1),
  ('learning', 2),
  ('productivity', 3),
  ('selfcare', 4),
  ('social', 5),
  ('focus', 6),
  ('creativity', 7);

-- ---------------------------------------------------------------------------
-- Task catalogue (replaces the Firestore `tasks` collection)
-- ---------------------------------------------------------------------------
create table public.task_templates (
  id text primary key,                                   -- stable slug, e.g. 'focus.meditate'
  category text not null references public.categories,
  secondary_categories text[] not null default '{}',
  text text not null,                                    -- uses {amount} and {unit} placeholders
  amount_min numeric,                                    -- null for fixed tasks
  amount_max numeric,
  amount_step numeric,
  unit text,
  tier smallint not null default 1 check (tier between 1 and 3),
  min_level numeric(3,1) not null default 1 check (min_level between 1 and 10),
  max_level numeric(3,1) not null default 10 check (max_level between 1 and 10),
  est_minutes integer,
  contexts text[] not null default '{anywhere}',
  time_of_day text[] not null default '{morning,afternoon,evening}',
  social_load smallint not null default 0 check (social_load between 0 and 2),
  equipment text[] not null default '{}',
  easier_variant_id text references public.task_templates,
  tip text,
  cooldown_days integer not null default 3 check (cooldown_days >= 0),
  weight numeric not null default 1 check (weight >= 0),
  active boolean not null default true,
  created_at timestamptz not null default now(),
  check (min_level <= max_level),
  check (
    (amount_min is null and amount_max is null and amount_step is null)
    or (amount_min is not null and amount_max is not null and amount_step > 0
        and amount_min <= amount_max)
  )
);
create index task_templates_category_idx on public.task_templates (category) where active;

-- ---------------------------------------------------------------------------
-- Users
-- ---------------------------------------------------------------------------
create table public.profiles (
  id uuid primary key references auth.users on delete cascade,
  email text,
  -- Minutes east of UTC, sent by the app on every open. Used to work out the
  -- user's local date on the server (pg_cron job and RPCs).
  utc_offset_minutes integer not null default 0 check (utc_offset_minutes between -840 and 840),
  legacy_firebase_uid text unique,                       -- set by the data migration script
  last_seen_at timestamptz,
  created_at timestamptz not null default now()
);

-- One row per user and category they chose in onboarding (replaces users.stats).
create table public.user_category_levels (
  user_id uuid not null references public.profiles on delete cascade,
  category text not null references public.categories,
  level numeric(3,1) not null default 1 check (level between 1 and 10),
  goal boolean not null default true,                    -- "I want to improve this"
  enabled boolean not null default true,
  updated_at timestamptz not null default now(),
  primary key (user_id, category)
);

create type public.assignment_status as enum ('assigned', 'completed', 'missed', 'rest_day');

-- One main task per user per local day (replaces users/{uid}/tasks).
create table public.daily_assignments (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles on delete cascade,
  assigned_date date not null,                           -- the user's local date
  template_id text references public.task_templates,     -- null only for imported legacy rows
  category text not null references public.categories,
  amount numeric,
  rendered_text text not null,
  status public.assignment_status not null default 'assigned',
  feedback smallint check (feedback between -1 and 1),   -- -1 too hard, 0 just right, 1 too easy
  reflection text,
  swap_count smallint not null default 0,
  swapped_from text[] not null default '{}',             -- template ids swapped away today
  level_before numeric(3,1),
  level_after numeric(3,1),
  assigned_at timestamptz not null default now(),
  completed_at timestamptz,
  unique (user_id, assigned_date)
);
create index daily_assignments_open_idx on public.daily_assignments (assigned_date) where status = 'assigned';
create index daily_assignments_user_template_idx on public.daily_assignments (user_id, template_id);

-- ---------------------------------------------------------------------------
-- Profile row for every new auth user (email, Google and anonymous guests)
-- ---------------------------------------------------------------------------
create function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles (id, email)
  values (new.id, new.email)
  on conflict (id) do nothing;
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- Keep the email in sync when a guest upgrades to an email account.
create function public.handle_user_email_change()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  update public.profiles set email = new.email where id = new.id;
  return new;
end;
$$;

create trigger on_auth_user_email_changed
  after update of email on auth.users
  for each row when (old.email is distinct from new.email)
  execute function public.handle_user_email_change();

-- ---------------------------------------------------------------------------
-- Row Level Security
-- ---------------------------------------------------------------------------
alter table public.categories enable row level security;
alter table public.task_templates enable row level security;
alter table public.profiles enable row level security;
alter table public.user_category_levels enable row level security;
alter table public.daily_assignments enable row level security;

create policy "categories are readable" on public.categories
  for select to anon, authenticated using (true);

-- Anonymous (guest) users have the `authenticated` role too.
create policy "templates are readable when signed in" on public.task_templates
  for select to authenticated using (true);

create policy "read own profile" on public.profiles
  for select to authenticated using (id = (select auth.uid()));

create policy "read own levels" on public.user_category_levels
  for select to authenticated using (user_id = (select auth.uid()));
create policy "insert own levels" on public.user_category_levels
  for insert to authenticated with check (user_id = (select auth.uid()));
create policy "update own levels" on public.user_category_levels
  for update to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));
create policy "delete own levels" on public.user_category_levels
  for delete to authenticated using (user_id = (select auth.uid()));

-- Assignments are read-only to clients; all writes go through the RPCs below.
create policy "read own assignments" on public.daily_assignments
  for select to authenticated using (user_id = (select auth.uid()));

-- Profiles are written by triggers and RPCs only.
revoke insert, update, delete on public.profiles from anon, authenticated;
revoke insert, update, delete on public.daily_assignments from anon, authenticated;
revoke insert, update, delete on public.task_templates from anon, authenticated;
revoke insert, update, delete on public.categories from anon, authenticated;

-- ---------------------------------------------------------------------------
-- Internal helpers (not callable by clients)
-- ---------------------------------------------------------------------------

-- The user's local date, from the offset the app last reported.
create function public._local_date(p_user uuid)
returns date
language sql
stable
security definer
set search_path = ''
as $$
  select ((now() at time zone 'UTC')
          + make_interval(mins => coalesce(p.utc_offset_minutes, 0)))::date
  from public.profiles p
  where p.id = p_user;
$$;

-- Amount for a template at a level: a gentle curve inside the template's level
-- window, rounded to the step. Replaces ceil(level * multiplier).
create function public._compute_amount(t public.task_templates, p_level numeric)
returns numeric
language plpgsql
immutable
set search_path = ''
as $$
declare
  frac numeric;
  raw numeric;
  stepped numeric;
begin
  if t.amount_min is null then
    return null;
  end if;
  if t.max_level > t.min_level then
    frac := greatest(0, least(1, (p_level - t.min_level) / (t.max_level - t.min_level)));
  else
    frac := 0.5;
  end if;
  raw := t.amount_min + (t.amount_max - t.amount_min) * power(frac, 0.8);
  stepped := t.amount_min + round((raw - t.amount_min) / t.amount_step) * t.amount_step;
  return greatest(t.amount_min, least(t.amount_max, stepped));
end;
$$;

create function public._render_text(t public.task_templates, p_amount numeric)
returns text
language sql
immutable
set search_path = ''
as $$
  select replace(
           replace(t.text, '{amount}', coalesce(trim_scale(p_amount)::text, '')),
           '{unit}', coalesce(t.unit, ''));
$$;

-- Picks today's template for a user. Category weights follow the task system
-- proposal: goal x1.5, neglected categories up to x2, a breather after
-- "too hard", and no back-to-back category when 3+ are enabled. Then templates
-- are filtered by level window and cooldown, relaxing filters until something
-- fits so the app never shows "No task available".
create function public._pick_template(p_user uuid, p_date date, p_exclude text[] default '{}')
returns table (template_id text, category text, level numeric)
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  v_category text;
  v_level numeric;
  v_template text;
  v_enabled integer;
  v_yesterday text;
  relax integer;
begin
  select count(*) into v_enabled
  from public.user_category_levels l
  where l.user_id = p_user and l.enabled;

  if v_enabled = 0 then
    raise exception 'no_categories' using hint = 'User has not picked any categories yet';
  end if;

  select a.category into v_yesterday
  from public.daily_assignments a
  where a.user_id = p_user and a.assigned_date = p_date - 1;

  -- 1. Weighted category pick (Efraimidis-Spirakis: smallest -ln(u)/w wins).
  select c.category, c.level into v_category, v_level
  from (
    select l.category, l.level,
      1.0
      * case when l.goal then 1.5 else 1.0 end
      * least(2.0, 1.0 + 0.2 * coalesce(
          p_date - (select max(a.assigned_date) from public.daily_assignments a
                    where a.user_id = p_user and a.category = l.category
                      and a.assigned_date < p_date),
          10))
      * case when exists (
          select 1 from public.daily_assignments a
          where a.user_id = p_user and a.category = l.category
            and a.feedback = -1 and a.assigned_date >= p_date - 3)
        then 0.5 else 1.0 end
      * case when v_enabled >= 3 and l.category = v_yesterday then 0 else 1.0 end
      as w
    from public.user_category_levels l
    where l.user_id = p_user and l.enabled
      and exists (select 1 from public.task_templates t
                  where t.active and t.category = l.category)
  ) c
  where c.w > 0
  order by -ln(1.0 - random()) / c.w
  limit 1;

  -- Every weighted category was ruled out: fall back to any enabled one with templates.
  if v_category is null then
    select l.category, l.level into v_category, v_level
    from public.user_category_levels l
    where l.user_id = p_user and l.enabled
      and exists (select 1 from public.task_templates t
                  where t.active and t.category = l.category)
    order by random()
    limit 1;
  end if;

  if v_category is null then
    raise exception 'no_templates' using hint = 'No active templates for the user''s categories';
  end if;

  -- 2. Template pick, relaxing cooldown, then the level window.
  for relax in 0..2 loop
    select t.id into v_template
    from public.task_templates t
    where t.active
      and t.category = v_category
      and not (t.id = any (p_exclude))
      and (relax >= 2 or v_level between t.min_level and t.max_level)
      and (relax >= 1 or not exists (
            select 1 from public.daily_assignments a
            where a.user_id = p_user and a.template_id = t.id
              and a.assigned_date > p_date - t.cooldown_days
              and a.assigned_date < p_date))
    order by -ln(1.0 - random()) / greatest(0.0001,
      t.weight
      * case when exists (
          select 1 from public.daily_assignments a
          where a.user_id = p_user and a.template_id = t.id
            and a.status = 'completed' and a.feedback = 0)
        then 1.3 else 1.0 end
      * case when exists (
          select 1 from public.daily_assignments a
          where a.user_id = p_user and t.id = any (a.swapped_from))
        then 0.5 else 1.0 end)
    limit 1;

    exit when v_template is not null;
  end loop;

  -- Last resort: the gentlest task in the category, even if it was excluded.
  if v_template is null then
    select t.id into v_template
    from public.task_templates t
    where t.active and t.category = v_category
    order by t.tier, t.min_level, random()
    limit 1;
  end if;

  return query select v_template, v_category, v_level;
end;
$$;

-- Change a category level by delta, clamped to 1..10. Returns the new level.
create function public._adjust_level(p_user uuid, p_category text, p_delta numeric)
returns numeric
language sql
volatile
security definer
set search_path = ''
as $$
  update public.user_category_levels
  set level = greatest(1, least(10, level + p_delta)),
      updated_at = now()
  where user_id = p_user and category = p_category
  returning level;
$$;

-- Mark a user's past open assignments as missed and lower the level by 0.2.
create function public._finalize_missed(p_user uuid, p_today date)
returns integer
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  r record;
  n integer := 0;
  v_after numeric;
begin
  for r in
    select a.id, a.category
    from public.daily_assignments a
    where a.user_id = p_user and a.status = 'assigned' and a.assigned_date < p_today
    order by a.assigned_date
    for update
  loop
    v_after := public._adjust_level(p_user, r.category, -0.2);
    update public.daily_assignments
    set status = 'missed',
        level_after = v_after
    where id = r.id;
    n := n + 1;
  end loop;
  return n;
end;
$$;

-- Create today's assignment for a user if it doesn't exist yet.
create function public._assign_for(p_user uuid, p_date date)
returns uuid
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  v_id uuid;
  v_pick record;
  t public.task_templates;
  v_amount numeric;
begin
  select a.id into v_id
  from public.daily_assignments a
  where a.user_id = p_user and a.assigned_date = p_date;
  if v_id is not null then
    return v_id;
  end if;

  select * into v_pick from public._pick_template(p_user, p_date);
  select * into t from public.task_templates where id = v_pick.template_id;
  v_amount := public._compute_amount(t, v_pick.level);

  insert into public.daily_assignments
    (user_id, assigned_date, template_id, category, amount, rendered_text, level_before)
  values
    (p_user, p_date, t.id, t.category, v_amount, public._render_text(t, v_amount), v_pick.level)
  on conflict (user_id, assigned_date) do nothing
  returning id into v_id;

  if v_id is null then
    -- Another request assigned it concurrently.
    select a.id into v_id
    from public.daily_assignments a
    where a.user_id = p_user and a.assigned_date = p_date;
  end if;
  return v_id;
end;
$$;

-- The JSON shape the app reads for one assignment.
create function public._assignment_json(p_id uuid)
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select to_jsonb(a)
         || jsonb_build_object(
              'tip', t.tip,
              'unit', t.unit,
              'can_swap', a.status = 'assigned' and a.swap_count < 1)
  from public.daily_assignments a
  left join public.task_templates t on t.id = a.template_id
  where a.id = p_id;
$$;

-- ---------------------------------------------------------------------------
-- Client RPCs
-- ---------------------------------------------------------------------------

-- Returns today's task, assigning and saving it first if needed. The app calls
-- this on every open and passes its current UTC offset so the server knows the
-- user's local day.
create function public.get_or_assign_daily_task(p_utc_offset_minutes integer default null)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  v_user uuid := auth.uid();
  v_today date;
  v_id uuid;
begin
  if v_user is null then
    raise exception 'not_authenticated';
  end if;

  update public.profiles
  set last_seen_at = now(),
      utc_offset_minutes = coalesce(
        case when p_utc_offset_minutes between -840 and 840 then p_utc_offset_minutes end,
        utc_offset_minutes)
  where id = v_user;

  v_today := public._local_date(v_user);
  perform public._finalize_missed(v_user, v_today);
  v_id := public._assign_for(v_user, v_today);
  return public._assignment_json(v_id);
end;
$$;

-- One free swap per day. Lowers the category level by 0.1.
create function public.swap_daily_task()
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  v_user uuid := auth.uid();
  a public.daily_assignments;
  v_pick record;
  t public.task_templates;
  v_amount numeric;
  v_after numeric;
begin
  if v_user is null then
    raise exception 'not_authenticated';
  end if;

  select * into a
  from public.daily_assignments
  where user_id = v_user and assigned_date = public._local_date(v_user)
  for update;

  if a.id is null then
    raise exception 'no_task_today';
  end if;
  if a.status <> 'assigned' then
    raise exception 'task_already_finished';
  end if;
  if a.swap_count >= 1 then
    raise exception 'swap_already_used';
  end if;

  v_after := public._adjust_level(v_user, a.category, -0.1);

  select * into v_pick
  from public._pick_template(v_user, a.assigned_date,
                             a.swapped_from || coalesce(a.template_id, ''));
  select * into t from public.task_templates where id = v_pick.template_id;
  v_amount := public._compute_amount(t, v_pick.level);

  update public.daily_assignments
  set template_id = t.id,
      category = t.category,
      amount = v_amount,
      rendered_text = public._render_text(t, v_amount),
      swap_count = swap_count + 1,
      swapped_from = swapped_from || coalesce(a.template_id, ''),
      level_before = v_pick.level
  where id = a.id;

  return public._assignment_json(a.id);
end;
$$;

-- Completes today's task. Feedback moves the category level:
-- too easy +0.5, just right +0.2, no feedback +0.1, too hard -0.3.
create function public.complete_daily_task(p_feedback smallint default null, p_reflection text default null)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  v_user uuid := auth.uid();
  a public.daily_assignments;
  v_delta numeric;
  v_before numeric;
  v_after numeric;
begin
  if v_user is null then
    raise exception 'not_authenticated';
  end if;
  if p_feedback is not null and p_feedback not between -1 and 1 then
    raise exception 'invalid_feedback';
  end if;

  select * into a
  from public.daily_assignments
  where user_id = v_user and assigned_date = public._local_date(v_user)
  for update;

  if a.id is null then
    raise exception 'no_task_today';
  end if;
  if a.status = 'completed' then
    return public._assignment_json(a.id);
  end if;

  v_delta := case p_feedback
               when 1 then 0.5
               when 0 then 0.2
               when -1 then -0.3
               else 0.1
             end;

  select level into v_before
  from public.user_category_levels
  where user_id = v_user and category = a.category;

  v_after := coalesce(public._adjust_level(v_user, a.category, v_delta), v_before);

  update public.daily_assignments
  set status = 'completed',
      feedback = p_feedback,
      reflection = nullif(trim(p_reflection), ''),
      completed_at = now(),
      level_before = coalesce(v_before, level_before),
      level_after = v_after
  where id = a.id;

  return public._assignment_json(a.id);
end;
$$;

-- Onboarding: replace the user's categories and starting levels in one call.
-- p_levels is a JSON object such as {"focus": 4, "fitness": 7}.
create function public.save_onboarding(p_levels jsonb, p_utc_offset_minutes integer default null)
returns void
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  v_user uuid := auth.uid();
begin
  if v_user is null then
    raise exception 'not_authenticated';
  end if;
  if p_levels is null or jsonb_typeof(p_levels) <> 'object' or p_levels = '{}'::jsonb then
    raise exception 'no_categories';
  end if;

  update public.profiles
  set utc_offset_minutes = coalesce(
        case when p_utc_offset_minutes between -840 and 840 then p_utc_offset_minutes end,
        utc_offset_minutes)
  where id = v_user;

  update public.user_category_levels
  set enabled = false, updated_at = now()
  where user_id = v_user and not (p_levels ? category);

  insert into public.user_category_levels (user_id, category, level, goal, enabled)
  select v_user, e.key, greatest(1, least(10, round(e.value::text::numeric, 1))), true, true
  from jsonb_each(p_levels) e
  join public.categories c on c.id = e.key
  on conflict (user_id, category) do update
    set level = excluded.level, enabled = true, updated_at = now();
end;
$$;

-- ---------------------------------------------------------------------------
-- Scheduled job: record missed days and pre-assign today's task
-- ---------------------------------------------------------------------------

-- For every user seen in the last 30 days: mark yesterday's unfinished task as
-- missed, then assign today's task so it is saved even if the app stays closed.
-- Runs hourly, so each user is handled within an hour of their local midnight.
create function public.daily_rollover()
returns integer
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  r record;
  v_today date;
  n integer := 0;
begin
  for r in
    select p.id
    from public.profiles p
    where p.last_seen_at > now() - interval '30 days'
      and exists (select 1 from public.user_category_levels l
                  where l.user_id = p.id and l.enabled)
  loop
    begin
      v_today := public._local_date(r.id);
      n := n + public._finalize_missed(r.id, v_today);
      perform public._assign_for(r.id, v_today);
    exception when others then
      raise warning 'daily_rollover failed for %: %', r.id, sqlerrm;
    end;
  end loop;
  return n;
end;
$$;

-- Lock down function execution: helpers are internal, RPCs are for signed-in users.
revoke execute on all functions in schema public from public, anon, authenticated;
grant execute on function public.get_or_assign_daily_task(integer) to authenticated;
grant execute on function public.swap_daily_task() to authenticated;
grant execute on function public.complete_daily_task(smallint, text) to authenticated;
grant execute on function public.save_onboarding(jsonb, integer) to authenticated;

create extension if not exists pg_cron;

select cron.schedule(
  'better-brain-daily-rollover',
  '5 * * * *',
  $$select public.daily_rollover();$$
);
