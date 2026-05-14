-- 1. REPAIR THE POWERSYNC PUBLICATION
-- Sometimes new tables are not automatically added to the publication.
-- This ensures PowerSync can actually "see" the data.
DROP PUBLICATION IF EXISTS powersync;
CREATE PUBLICATION powersync FOR TABLE 
    public.households,
    public.users,
    public.accounts,
    public.categories,
    public.budgets,
    public.projects,
    public.transactions,
    public.financial_periods,
    public.recurring_templates,
    public.invitations,
    public.notifications;

-- 2. VERIFY DATA EXISTENCE (Check your Supabase SQL results)
-- Run these to confirm the trigger actually worked.
SELECT count(*) as total_budgets FROM public.budgets;
SELECT count(*) as total_accounts FROM public.accounts;
SELECT count(*) as total_households FROM public.households;

-- 3. FIX RLS FOR POWERSYNC
-- PowerSync needs to be able to read the users table to assign buckets.
ALTER TABLE public.users DISABLE ROW LEVEL SECURITY;
-- (Or if you want it ON, ensure there is a policy allowing the replication role to read)
-- For now, disabling it is the safest way to verify if it's an RLS issue.
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "PowerSync can read all users" ON public.users;
CREATE POLICY "PowerSync can read all users" ON public.users
    FOR SELECT USING (true);

-- 4. ENSURE SEARCH PATH IS CORRECT FOR TRIGGER
-- This was a previous issue.
ALTER FUNCTION public.handle_new_user() SET search_path = public;
