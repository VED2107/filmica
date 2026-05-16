create extension if not exists pgcrypto;

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, username, avatar_url)
  values (
    new.id,
    coalesce(
      new.raw_user_meta_data->>'full_name',
      new.raw_user_meta_data->>'name',
      'User'
    ),
    coalesce(
      new.raw_user_meta_data->>'avatar_url',
      new.raw_user_meta_data->>'picture'
    )
  )
  on conflict (id) do update
  set
    username = excluded.username,
    avatar_url = coalesce(excluded.avatar_url, public.profiles.avatar_url);

  return new;
end;
$$;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text,
  avatar_url text,
  is_premium boolean not null default false,
  created_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table if not exists public.presets (
  id text primary key,
  name text not null,
  category text not null,
  config jsonb not null,
  thumbnail_url text,
  is_premium boolean not null default false,
  individual_price numeric(5, 2),
  revenuecat_product_id text,
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.user_favorites (
  user_id uuid not null references public.profiles(id) on delete cascade,
  preset_id text not null references public.presets(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_id, preset_id)
);

create table if not exists public.user_exports (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  preset_id text references public.presets(id),
  quality text not null default 'hd',
  created_at timestamptz not null default now()
);

create table if not exists public.subscription_status (
  user_id uuid primary key references public.profiles(id) on delete cascade,
  revenuecat_customer_id text unique,
  status text not null default 'free',
  plan_type text,
  expires_at timestamptz,
  updated_at timestamptz not null default now()
);

create table if not exists public.user_preset_purchases (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  preset_id text not null references public.presets(id) on delete cascade,
  revenuecat_product_id text not null,
  price_paid numeric(5, 2) not null,
  purchased_at timestamptz not null default now(),
  unique (user_id, preset_id)
);

create index if not exists idx_user_exports_user_id on public.user_exports(user_id);
create index if not exists idx_user_exports_created_at on public.user_exports(created_at);
create index if not exists idx_user_favorites_user_id on public.user_favorites(user_id);
create index if not exists idx_subscription_status_revenuecat on public.subscription_status(revenuecat_customer_id);
create index if not exists idx_user_preset_purchases_user_id on public.user_preset_purchases(user_id);

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

alter table public.profiles enable row level security;
alter table public.presets enable row level security;
alter table public.user_favorites enable row level security;
alter table public.user_exports enable row level security;
alter table public.subscription_status enable row level security;
alter table public.user_preset_purchases enable row level security;

do $$
begin
  if not exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'profiles'
      and policyname = 'Users read own profile'
  ) then
    create policy "Users read own profile"
      on public.profiles
      for select
      using (auth.uid() = id);
  end if;

  if not exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'profiles'
      and policyname = 'Users update own profile'
  ) then
    create policy "Users update own profile"
      on public.profiles
      for update
      using (auth.uid() = id)
      with check (auth.uid() = id);
  end if;

  if not exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'user_favorites'
      and policyname = 'Users manage own favorites'
  ) then
    create policy "Users manage own favorites"
      on public.user_favorites
      for all
      using (auth.uid() = user_id)
      with check (auth.uid() = user_id);
  end if;

  if not exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'presets'
      and policyname = 'Presets are public'
  ) then
    create policy "Presets are public"
      on public.presets
      for select
      using (true);
  end if;

  if not exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'user_exports'
      and policyname = 'Users read own exports'
  ) then
    create policy "Users read own exports"
      on public.user_exports
      for select
      using (auth.uid() = user_id);
  end if;

  if not exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'user_exports'
      and policyname = 'Users insert own exports'
  ) then
    create policy "Users insert own exports"
      on public.user_exports
      for insert
      with check (auth.uid() = user_id);
  end if;

  if not exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'subscription_status'
      and policyname = 'Users read own subscription'
  ) then
    create policy "Users read own subscription"
      on public.subscription_status
      for select
      using (auth.uid() = user_id);
  end if;

  if not exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'user_preset_purchases'
      and policyname = 'Users read own preset purchases'
  ) then
    create policy "Users read own preset purchases"
      on public.user_preset_purchases
      for select
      using (auth.uid() = user_id);
  end if;
end
$$;

insert into public.presets (
  id,
  name,
  category,
  config,
  is_premium,
  individual_price,
  revenuecat_product_id,
  sort_order
)
values
  (
    'classic_film',
    'Classic Film',
    'film',
    '{"brightness":0,"contrast":1.1,"saturation":1.0,"warmth":0.3,"grain":0.2,"fadeAmount":0.15,"vignetteStrength":0.3,"lutAsset":null,"overlayAsset":null,"overlayOpacity":0}'::jsonb,
    false,
    null,
    null,
    1
  ),
  (
    'vintage_fade',
    'Vintage Fade',
    'vintage',
    '{"brightness":0,"contrast":0.8,"saturation":0.7,"warmth":0.2,"grain":0.15,"fadeAmount":0.3,"vignetteStrength":0.2,"lutAsset":null,"overlayAsset":null,"overlayOpacity":0}'::jsonb,
    false,
    null,
    null,
    2
  ),
  (
    'light_leak',
    'Light Leak',
    'light_leak',
    '{"brightness":0.05,"contrast":1.0,"saturation":1.1,"warmth":0.2,"grain":0.1,"fadeAmount":0.1,"vignetteStrength":0.15,"lutAsset":null,"overlayAsset":"light_leak.png","overlayOpacity":0.4}'::jsonb,
    true,
    1.49,
    'preset_light_leak',
    3
  ),
  (
    'mono_classic',
    'Mono Classic',
    'bw',
    '{"brightness":0,"contrast":1.4,"saturation":0,"warmth":0,"grain":0.3,"fadeAmount":0.1,"vignetteStrength":0.4,"lutAsset":null,"overlayAsset":null,"overlayOpacity":0}'::jsonb,
    true,
    0.99,
    'preset_mono_classic',
    4
  ),
  (
    'golden_hour',
    'Golden Hour',
    'warm',
    '{"brightness":0.1,"contrast":1.05,"saturation":1.2,"warmth":0.6,"grain":0.05,"fadeAmount":0.05,"vignetteStrength":0.2,"lutAsset":null,"overlayAsset":null,"overlayOpacity":0}'::jsonb,
    true,
    1.49,
    'preset_golden_hour',
    5
  ),
  (
    'soft_fade',
    'Soft Fade',
    'fade',
    '{"brightness":0.05,"contrast":0.7,"saturation":0.8,"warmth":0.15,"grain":0.1,"fadeAmount":0.4,"vignetteStrength":0.15,"lutAsset":null,"overlayAsset":null,"overlayOpacity":0}'::jsonb,
    true,
    0.99,
    'preset_soft_fade',
    6
  )
on conflict (id) do update
set
  name = excluded.name,
  category = excluded.category,
  config = excluded.config,
  is_premium = excluded.is_premium,
  individual_price = excluded.individual_price,
  revenuecat_product_id = excluded.revenuecat_product_id,
  sort_order = excluded.sort_order,
  updated_at = now();

insert into storage.buckets (id, name, public)
values
  ('preset-thumbnails', 'preset-thumbnails', true),
  ('preset-assets', 'preset-assets', true),
  ('avatars', 'avatars', false)
on conflict (id) do nothing;

do $$
begin
  if not exists (
    select 1
    from pg_policies
    where schemaname = 'storage'
      and tablename = 'objects'
      and policyname = 'Users upload own avatar'
  ) then
    create policy "Users upload own avatar"
      on storage.objects
      for insert
      with check (
        bucket_id = 'avatars'
        and auth.uid()::text = (storage.foldername(name))[1]
      );
  end if;

  if not exists (
    select 1
    from pg_policies
    where schemaname = 'storage'
      and tablename = 'objects'
      and policyname = 'Users read own avatar'
  ) then
    create policy "Users read own avatar"
      on storage.objects
      for select
      using (
        bucket_id = 'avatars'
        and auth.uid()::text = (storage.foldername(name))[1]
      );
  end if;

  if not exists (
    select 1
    from pg_policies
    where schemaname = 'storage'
      and tablename = 'objects'
      and policyname = 'Users update own avatar'
  ) then
    create policy "Users update own avatar"
      on storage.objects
      for update
      using (
        bucket_id = 'avatars'
        and auth.uid()::text = (storage.foldername(name))[1]
      )
      with check (
        bucket_id = 'avatars'
        and auth.uid()::text = (storage.foldername(name))[1]
      );
  end if;

  if not exists (
    select 1
    from pg_policies
    where schemaname = 'storage'
      and tablename = 'objects'
      and policyname = 'Users delete own avatar'
  ) then
    create policy "Users delete own avatar"
      on storage.objects
      for delete
      using (
        bucket_id = 'avatars'
        and auth.uid()::text = (storage.foldername(name))[1]
      );
  end if;

  if not exists (
    select 1
    from pg_policies
    where schemaname = 'storage'
      and tablename = 'objects'
      and policyname = 'Public read preset thumbnails'
  ) then
    create policy "Public read preset thumbnails"
      on storage.objects
      for select
      using (bucket_id = 'preset-thumbnails');
  end if;

  if not exists (
    select 1
    from pg_policies
    where schemaname = 'storage'
      and tablename = 'objects'
      and policyname = 'Public read preset assets'
  ) then
    create policy "Public read preset assets"
      on storage.objects
      for select
      using (bucket_id = 'preset-assets');
  end if;
end
$$;

create or replace function public.delete_user_account(target_user_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if auth.uid() is distinct from target_user_id then
    raise exception 'Unauthorized';
  end if;

  update public.profiles
  set deleted_at = now()
  where id = target_user_id;

  delete from public.user_favorites
  where user_id = target_user_id;
end;
$$;

create or replace function public.get_daily_export_count(target_user_id uuid)
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  export_count integer;
begin
  if auth.uid() is distinct from target_user_id then
    raise exception 'Unauthorized';
  end if;

  select count(*)::integer
  into export_count
  from public.user_exports
  where user_id = target_user_id
    and created_at >= current_date
    and created_at < current_date + interval '1 day';

  return export_count;
end;
$$;
