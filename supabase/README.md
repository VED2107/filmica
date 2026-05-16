# Supabase Backend Handoff

## Files

- `migrations/20260515_000001_initial_backend.sql`
- `functions/revenuecat-webhook/index.ts`
- `functions/delete-account/index.ts`

## What this covers

- Core tables: `profiles`, `presets`, `user_favorites`, `user_exports`, `subscription_status`, `user_preset_purchases`
- RLS policies for client-safe reads and writes
- Auth signup trigger: `handle_new_user()`
- Preset seed data for the 6 MVP presets
- Storage buckets and avatar/public asset policies
- Account deletion function: `delete_user_account(uuid)`
- Authenticated delete-account Edge Function for actual auth-user removal
- Daily export helper: `get_daily_export_count(uuid)`
- RevenueCat webhook logic for subscriptions and individual preset purchases

## Manual dashboard setup still required

### Auth

- Enable Apple provider
- Enable Google provider
- Disable email/password for MVP
- Set JWT expiry to `3600`
- Enable refresh token rotation

### Redirect URLs

Use the mobile deep-link callback URIs Claude wires into the app. Keep Supabase and RevenueCat `app_user_id` aligned to the Supabase user id.

### Edge Function secrets

Set these in Supabase before deploying the function:

- `SUPABASE_URL`
- `SUPABASE_SERVICE_ROLE_KEY`
- `REVENUECAT_WEBHOOK_SECRET`

## Suggested deploy order

1. Run the SQL migration in Supabase.
2. Verify the six preset rows exist.
3. Deploy the `revenuecat-webhook` function.
4. Deploy the `delete-account` function.
5. Point RevenueCat webhook to the function endpoint with `Authorization: Bearer <secret>`.
6. Test one subscription event and one individual preset purchase event.
7. Test deleting an authenticated account from the app.
