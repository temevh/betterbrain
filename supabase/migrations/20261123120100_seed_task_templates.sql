-- Better Brain: task catalogue seed
--
-- Built from the daily task system proposal: the old single `multiplier` is
-- replaced by min/max/step ranges and tiers, the duplicate "Meditate" tasks are
-- merged into focus.meditate, "Learn new words" moves to learning, oversized
-- tasks are capped (Study max 60 min, Work out max 45 min) or made doable in a
-- day, and every category now has tasks at all three tiers.
-- Re-running this file updates existing templates in place.

insert into public.task_templates
  (id, category, secondary_categories, text, amount_min, amount_max, amount_step, unit,
   tier, min_level, max_level, est_minutes, contexts, time_of_day, social_load, equipment, tip, cooldown_days)
values
  ('focus.meditate', 'focus', '{selfcare}', 'Meditate for {amount} minutes', 3, 20, 1, 'minutes', 1, 1, 10, 10, '{anywhere}', '{morning,afternoon,evening}', 0, '{}', 'Sit comfortably and count breaths to 10, then start again.', 3),
  ('focus.breaths', 'focus', '{}', 'Take 10 slow breaths before opening your phone in the morning', null, null, null, null, 1, 1, 6, 2, '{anywhere}', '{morning}', 0, '{}', null, 3),
  ('focus.top_priority', 'focus', '{productivity}', 'Write down the one thing that matters most today', null, null, null, null, 1, 1, 6, 3, '{anywhere}', '{morning}', 0, '{}', null, 3),
  ('focus.no_notifications', 'focus', '{}', 'Work on one task for {amount} minutes with notifications off', 15, 45, 5, 'minutes', 2, 3, 10, 30, '{home,work}', '{morning,afternoon,evening}', 0, '{}', null, 3),
  ('focus.phone_away', 'focus', '{}', 'Put your phone in another room for {amount} minutes', 30, 90, 15, 'minutes', 2, 3, 10, 60, '{home}', '{morning,afternoon,evening}', 0, '{}', null, 3),
  ('focus.deep_work', 'focus', '{}', 'Do a {amount}-minute deep work block with no tab switching', 60, 120, 15, 'minutes', 3, 6, 10, 90, '{home,work}', '{morning,afternoon,evening}', 0, '{}', null, 3),
  ('focus.single_task_meal', 'focus', '{selfcare}', 'Eat one whole meal without screens or reading', null, null, null, null, 3, 6, 10, 20, '{anywhere}', '{morning,afternoon,evening}', 0, '{}', 'Notice the taste and texture of each bite.', 3),
  ('creativity.draw', 'creativity', '{}', 'Draw or paint for {amount} minutes', 5, 45, 5, 'minutes', 1, 1, 10, 20, '{home}', '{morning,afternoon,evening}', 0, '{paper}', null, 3),
  ('creativity.doodle', 'creativity', '{}', 'Doodle for {amount} minutes', 3, 10, 1, 'minutes', 1, 1, 6, 5, '{anywhere}', '{morning,afternoon,evening}', 0, '{paper}', null, 3),
  ('creativity.colour_photos', 'creativity', '{}', 'Take 5 photos of things that are the same colour', null, null, null, null, 1, 1, 6, 10, '{anywhere}', '{morning,afternoon,evening}', 0, '{}', null, 3),
  ('creativity.write_story', 'creativity', '{}', 'Write a short poem or a {amount}-word story', 50, 200, 25, 'words', 2, 3, 10, 20, '{anywhere}', '{morning,afternoon,evening}', 0, '{}', null, 3),
  ('creativity.cook_freestyle', 'creativity', '{selfcare}', 'Cook something without following a recipe', null, null, null, null, 2, 3, 10, 45, '{home}', '{afternoon,evening}', 0, '{}', null, 3),
  ('creativity.share_creation', 'creativity', '{social}', 'Finish something you made and share it with one person', null, null, null, null, 3, 6, 10, 30, '{anywhere}', '{morning,afternoon,evening}', 1, '{}', null, 3),
  ('creativity.new_technique', 'creativity', '{learning}', 'Learn a new creative technique from a tutorial and try it', null, null, null, null, 3, 6, 10, 45, '{anywhere}', '{morning,afternoon,evening}', 0, '{}', null, 3),
  ('learning.study', 'learning', '{}', 'Study one topic for {amount} minutes without your phone', 10, 60, 5, 'minutes', 2, 1, 10, 30, '{anywhere}', '{morning,afternoon,evening}', 0, '{}', 'Pick the topic before you start so you don''t spend the time choosing.', 3),
  ('learning.words', 'learning', '{}', 'Learn {amount} new words in a language you''re studying', 3, 15, 1, 'words', 1, 1, 10, 15, '{anywhere}', '{morning,afternoon,evening}', 0, '{}', 'Say each word out loud in a sentence.', 3),
  ('learning.read', 'learning', '{focus}', 'Read a book for {amount} minutes', 10, 45, 5, 'minutes', 1, 1, 10, 20, '{anywhere}', '{morning,afternoon,evening}', 0, '{}', null, 3),
  ('learning.look_up', 'learning', '{}', 'Look up the answer to a question you''ve wondered about', null, null, null, null, 1, 1, 6, 10, '{anywhere}', '{morning,afternoon,evening}', 0, '{}', null, 3),
  ('learning.summarize', 'learning', '{}', 'Summarize one article or video in 3 sentences', null, null, null, null, 2, 3, 10, 20, '{anywhere}', '{morning,afternoon,evening}', 0, '{}', null, 3),
  ('learning.teach', 'learning', '{social}', 'Teach something you learned today to someone else', null, null, null, null, 3, 6, 10, 15, '{anywhere}', '{morning,afternoon,evening}', 1, '{}', null, 3),
  ('learning.documentary', 'learning', '{}', 'Watch a documentary or lecture and write down one new idea', null, null, null, null, 2, 3, 10, 45, '{home}', '{morning,afternoon,evening}', 0, '{}', null, 3),
  ('social.reply_message', 'social', '{}', 'Reply to a message you''ve been putting off', null, null, null, null, 1, 1, 6, 5, '{anywhere}', '{morning,afternoon,evening}', 1, '{}', null, 3),
  ('social.thank_someone', 'social', '{}', 'Thank someone specifically for something they did', null, null, null, null, 1, 1, 6, 5, '{anywhere}', '{morning,afternoon,evening}', 1, '{}', null, 3),
  ('social.call_friend', 'social', '{}', 'Call or voice-message a friend or family member', null, null, null, null, 2, 3, 10, 15, '{anywhere}', '{morning,afternoon,evening}', 1, '{}', null, 3),
  ('social.listen', 'social', '{}', 'Ask someone a thoughtful question and really listen to the answer', null, null, null, null, 2, 3, 10, 15, '{anywhere}', '{morning,afternoon,evening}', 1, '{}', null, 3),
  ('social.compliment', 'social', '{}', 'Compliment {amount} people on something specific', 1, 3, 1, 'people', 2, 3, 10, 10, '{anywhere}', '{morning,afternoon,evening}', 1, '{}', null, 3),
  ('social.invite', 'social', '{}', 'Invite someone to do something together this week', null, null, null, null, 3, 6, 10, 10, '{anywhere}', '{morning,afternoon,evening}', 1, '{}', null, 3),
  ('social.find_group', 'social', '{learning}', 'Look up one group, class or club you could join and save the link', null, null, null, null, 2, 3, 10, 15, '{anywhere}', '{morning,afternoon,evening}', 0, '{}', null, 3),
  ('social.new_person', 'social', '{}', 'Start a conversation with someone new', null, null, null, null, 3, 6, 10, 10, '{outside,work}', '{morning,afternoon,evening}', 2, '{}', 'A question about something you both see is an easy opener.', 3),
  ('fitness.workout', 'fitness', '{}', 'Work out for {amount} minutes', 10, 45, 5, 'minutes', 2, 1, 10, 30, '{anywhere}', '{morning,afternoon,evening}', 0, '{}', 'A warm-up counts. Start slow.', 3),
  ('fitness.squats_easy', 'fitness', '{}', 'Do 10 bodyweight squats', null, null, null, null, 1, 1, 6, 2, '{anywhere}', '{morning,afternoon,evening}', 0, '{}', null, 3),
  ('fitness.stretch', 'fitness', '{selfcare}', 'Stretch for {amount} minutes', 3, 20, 1, 'minutes', 1, 1, 10, 10, '{anywhere}', '{morning,afternoon,evening}', 0, '{}', null, 3),
  ('fitness.walk', 'fitness', '{selfcare}', 'Go for a {amount}-minute walk without headphones', 5, 45, 5, 'minutes', 1, 1, 10, 25, '{outside}', '{morning,afternoon,evening}', 0, '{}', 'Leave your phone in your pocket for the first five minutes.', 2),
  ('fitness.stairs', 'fitness', '{}', 'Take the stairs every time today', null, null, null, null, 1, 1, 6, 5, '{anywhere}', '{morning,afternoon,evening}', 0, '{}', null, 3),
  ('fitness.hourly_stretch', 'fitness', '{}', 'Stand up and stretch once an hour for 3 hours', null, null, null, null, 1, 1, 6, 5, '{home,work}', '{morning,afternoon,evening}', 0, '{}', null, 3),
  ('fitness.squats_spread', 'fitness', '{}', 'Do {amount} squats spread through the day', 10, 40, 5, 'squats', 2, 3, 10, 10, '{anywhere}', '{morning,afternoon,evening}', 0, '{}', null, 3),
  ('fitness.active_trip', 'fitness', '{}', 'Walk or bike instead of driving for one trip', null, null, null, null, 3, 6, 10, 30, '{outside}', '{morning,afternoon,evening}', 0, '{}', null, 3),
  ('fitness.new_sport', 'fitness', '{}', 'Try a sport or workout you''ve never done', null, null, null, null, 3, 6, 10, 45, '{anywhere}', '{morning,afternoon,evening}', 0, '{}', null, 3),
  ('selfcare.screen_break', 'selfcare', '{}', 'Take a {amount}-minute break away from screens', 5, 15, 5, 'minutes', 1, 1, 10, 10, '{anywhere}', '{morning,afternoon,evening}', 0, '{}', null, 3),
  ('selfcare.water', 'selfcare', '{}', 'Drink a glass of water right after waking up', null, null, null, null, 1, 1, 6, 1, '{anywhere}', '{morning}', 0, '{}', null, 3),
  ('selfcare.daylight', 'selfcare', '{}', 'Step outside for 5 minutes of daylight', null, null, null, null, 1, 1, 6, 5, '{outside}', '{morning,afternoon}', 0, '{}', null, 3),
  ('selfcare.music', 'selfcare', '{}', 'Listen to an album you love from start to finish, doing nothing else', null, null, null, null, 1, 1, 6, 40, '{home}', '{morning,afternoon,evening}', 0, '{}', null, 3),
  ('selfcare.gratitude', 'selfcare', '{}', 'Write down {amount} things you''re grateful for', 1, 5, 1, 'things', 2, 3, 10, 5, '{anywhere}', '{morning,afternoon,evening}', 0, '{}', null, 3),
  ('selfcare.early_bed', 'selfcare', '{}', 'Go to bed {amount} minutes earlier than usual', 15, 45, 15, 'minutes', 2, 3, 10, 0, '{home}', '{evening}', 0, '{}', null, 3),
  ('selfcare.free_evening', 'selfcare', '{}', 'Plan one fully free evening this week and protect it', null, null, null, null, 3, 6, 10, 10, '{anywhere}', '{morning,afternoon,evening}', 0, '{}', null, 3),
  ('selfcare.future_letter', 'selfcare', '{}', 'Write a letter to yourself one year from now', null, null, null, null, 3, 6, 10, 30, '{anywhere}', '{morning,afternoon,evening}', 0, '{}', null, 3),
  ('productivity.top3', 'productivity', '{}', 'Write tomorrow''s top 3 tasks before bed', null, null, null, null, 1, 1, 6, 5, '{anywhere}', '{evening}', 0, '{}', null, 3),
  ('productivity.emails', 'productivity', '{}', 'Delete or archive 20 emails', null, null, null, null, 1, 1, 6, 10, '{anywhere}', '{morning,afternoon,evening}', 0, '{}', null, 3),
  ('productivity.desk', 'productivity', '{}', 'Organize your desk', null, null, null, null, 1, 1, 6, 15, '{home,work}', '{morning,afternoon,evening}', 0, '{}', null, 14),
  ('productivity.todo', 'productivity', '{}', 'Clear {amount} items from your to-do list', 2, 8, 1, 'items', 2, 3, 10, 45, '{anywhere}', '{morning,afternoon,evening}', 0, '{}', null, 3),
  ('productivity.drawer', 'productivity', '{}', 'Organize one drawer, folder or desktop', null, null, null, null, 2, 3, 10, 20, '{anywhere}', '{morning,afternoon,evening}', 0, '{}', null, 7),
  ('productivity.pomodoro', 'productivity', '{focus}', 'Do {amount} focused 25-minute work sessions with short breaks', 1, 4, 1, null, 2, 3, 10, 60, '{home,work}', '{morning,afternoon,evening}', 0, '{}', null, 3),
  ('productivity.avoided_task', 'productivity', '{}', 'Spend 25 minutes on the task you''ve been avoiding the longest', null, null, null, null, 3, 6, 10, 25, '{anywhere}', '{morning,afternoon,evening}', 0, '{}', null, 3),
  ('productivity.weekly_review', 'productivity', '{}', 'Set up a weekly review and do the first one', null, null, null, null, 3, 6, 10, 30, '{anywhere}', '{morning,afternoon,evening}', 0, '{}', null, 14)
on conflict (id) do update set
  category = excluded.category,
  secondary_categories = excluded.secondary_categories,
  text = excluded.text,
  amount_min = excluded.amount_min,
  amount_max = excluded.amount_max,
  amount_step = excluded.amount_step,
  unit = excluded.unit,
  tier = excluded.tier,
  min_level = excluded.min_level,
  max_level = excluded.max_level,
  est_minutes = excluded.est_minutes,
  contexts = excluded.contexts,
  time_of_day = excluded.time_of_day,
  social_load = excluded.social_load,
  equipment = excluded.equipment,
  tip = excluded.tip,
  cooldown_days = excluded.cooldown_days,
  active = true;

-- Targets for a future "make it easier" button.
update public.task_templates t set easier_variant_id = v.easier
from (values
  ('focus.meditate', 'focus.breaths'),
  ('focus.no_notifications', 'focus.top_priority'),
  ('focus.phone_away', 'focus.breaths'),
  ('focus.deep_work', 'focus.no_notifications'),
  ('creativity.draw', 'creativity.doodle'),
  ('creativity.write_story', 'creativity.doodle'),
  ('learning.study', 'learning.look_up'),
  ('social.call_friend', 'social.reply_message'),
  ('social.listen', 'social.thank_someone'),
  ('social.compliment', 'social.thank_someone'),
  ('social.new_person', 'social.listen'),
  ('fitness.workout', 'fitness.squats_easy'),
  ('fitness.walk', 'fitness.stairs'),
  ('fitness.squats_spread', 'fitness.squats_easy'),
  ('selfcare.gratitude', 'selfcare.water'),
  ('productivity.todo', 'productivity.top3'),
  ('productivity.avoided_task', 'productivity.top3')
) as v(id, easier)
where t.id = v.id;

