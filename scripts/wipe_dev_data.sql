-- ⚠️ WARNING: THIS WILL DELETE ALL DATA AND ALL USERS ⚠️
-- Run this in the Supabase SQL Editor.

-- 1. Disable triggers temporarily to avoid issues during wipe
SET session_replication_role = 'replica';

-- 2. Truncate all tables in the public schema
-- CASCADE ensures that dependent records (transactions, budgets, etc.) are also removed.
TRUNCATE 
    public.households, 
    public.users, 
    public.accounts, 
    public.budgets, 
    public.categories, 
    public.transactions, 
    public.projects,
    public.financial_periods,
    public.invitations,
    public.recurring_templates,
    public.notifications
RESTART IDENTITY CASCADE;

-- 3. Delete all users from Supabase Auth
-- This will also clear their identities, sessions, and MFA factors.
DELETE FROM auth.users;

-- 4. Re-enable triggers
SET session_replication_role = 'origin';
