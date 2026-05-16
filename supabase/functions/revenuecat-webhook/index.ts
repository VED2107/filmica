import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

type RevenueCatEvent = {
  app_user_id?: string;
  original_app_user_id?: string;
  product_id?: string;
  expiration_at_ms?: number | null;
};

type RevenueCatWebhookBody = {
  api_version?: string;
  event?: RevenueCatEvent;
  type?: string;
};

const presetProductMap: Record<string, string> = {
  preset_light_leak: "light_leak",
  preset_mono_classic: "mono_classic",
  preset_golden_hour: "golden_hour",
  preset_soft_fade: "soft_fade",
};

const activeSubscriptionEvents = new Set([
  "INITIAL_PURCHASE",
  "RENEWAL",
  "UNCANCELLATION",
]);

const inactiveSubscriptionEvents = new Set([
  "EXPIRATION",
  "CANCELLATION",
  "BILLING_ISSUE",
]);

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "content-type": "application/json" },
  });
}

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return json({ error: "Method not allowed" }, 405);
  }

  const secret = Deno.env.get("REVENUECAT_WEBHOOK_SECRET");
  const authHeader = req.headers.get("authorization");

  if (!secret || authHeader !== `Bearer ${secret}`) {
    return json({ error: "Unauthorized" }, 401);
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

  if (!supabaseUrl || !serviceRoleKey) {
    return json({ error: "Missing Supabase environment variables" }, 500);
  }

  const body = (await req.json()) as RevenueCatWebhookBody;
  const event = body.event;
  const eventType = body.type;
  const appUserId = event?.app_user_id;
  const productId = event?.product_id;

  if (!event || !eventType || !appUserId) {
    return json({ error: "Invalid RevenueCat payload" }, 400);
  }

  const supabase = createClient(supabaseUrl, serviceRoleKey, {
    auth: { persistSession: false },
  });

  const presetId = productId ? presetProductMap[productId] : undefined;

  if (presetId && eventType === "NON_RENEWING_PURCHASE") {
    const { data: preset, error: presetError } = await supabase
      .from("presets")
      .select("individual_price")
      .eq("id", presetId)
      .maybeSingle();

    if (presetError) {
      return json({ error: presetError.message }, 500);
    }

    const { error: purchaseError } = await supabase
      .from("user_preset_purchases")
      .upsert(
        {
          user_id: appUserId,
          preset_id: presetId,
          revenuecat_product_id: productId,
          price_paid: preset?.individual_price ?? 0,
        },
        { onConflict: "user_id,preset_id" },
      );

    if (purchaseError) {
      return json({ error: purchaseError.message }, 500);
    }

    return json({ success: true, type: "preset_purchase", presetId });
  }

  let status = "free";
  let planType: string | null = null;
  let expiresAt: string | null = null;

  if (activeSubscriptionEvents.has(eventType)) {
    status = "active";
    planType = productId ?? null;
    expiresAt = event.expiration_at_ms
      ? new Date(event.expiration_at_ms).toISOString()
      : null;
  } else if (inactiveSubscriptionEvents.has(eventType)) {
    status = "expired";
  }

  const { error: subscriptionError } = await supabase
    .from("subscription_status")
    .upsert(
      {
        user_id: appUserId,
        revenuecat_customer_id: event.original_app_user_id ?? appUserId,
        status,
        plan_type: planType,
        expires_at: expiresAt,
        updated_at: new Date().toISOString(),
      },
      { onConflict: "user_id" },
    );

  if (subscriptionError) {
    return json({ error: subscriptionError.message }, 500);
  }

  const { error: profileError } = await supabase
    .from("profiles")
    .update({ is_premium: status === "active" })
    .eq("id", appUserId);

  if (profileError) {
    return json({ error: profileError.message }, 500);
  }

  return json({ success: true, type: "subscription", status });
});
