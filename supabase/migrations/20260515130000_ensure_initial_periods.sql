-- 1. UPDATE ONBOARDING TRIGGER TO CREATE INITIAL PERIODS
-- This ensures that the moment an account is created, a period is created for it.
-- We use a "Gap Period" logic: from NOW to the end of the current month.

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
    new_household_id UUID;
    checking_id UUID;
    savings_id UUID;
    unplanned_budget_id UUID;
    period_start TIMESTAMP;
    period_end TIMESTAMP;
BEGIN
    SET search_path = public;
    
    -- Create Personal Household
    new_household_id := gen_random_uuid();
    INSERT INTO public.households (id, name, currency, default_month_start_day)
    VALUES (new_household_id, 'Personal Household', 'EUR', 1);

    -- Link User to Household
    UPDATE public.users 
    SET household_id = new_household_id, 
        role = 'owner',
        updated_at = NOW()
    WHERE id = NEW.id;

    -- Create Checking Account
    checking_id := gen_random_uuid();
    INSERT INTO public.accounts (id, household_id, owner_id, name, type, is_public, is_default)
    VALUES (checking_id, new_household_id, NEW.id, 'Checking Account', 'checking', FALSE, TRUE);

    -- Create Savings Account
    savings_id := gen_random_uuid();
    INSERT INTO public.accounts (id, household_id, owner_id, name, type, is_public, is_default)
    VALUES (savings_id, new_household_id, NEW.id, 'Savings Account', 'savings', FALSE, FALSE);

    -- Create "Unplanned" Budget for Checking
    unplanned_budget_id := gen_random_uuid();
    INSERT INTO public.budgets (id, household_id, account_id, name, default_amount, is_default, icon)
    VALUES (unplanned_budget_id, new_household_id, checking_id, 'Unplanned', 0, TRUE, 'shopping-cart');

    -- Create "Monthly Savings" Project for Savings
    INSERT INTO public.projects (id, household_id, account_id, name, target_amount)
    VALUES (gen_random_uuid(), new_household_id, savings_id, 'Monthly Savings', 0);

    -- NEW: CREATE INITIAL FINANCIAL PERIODS
    -- Logic: From today until the end of the month (since default_month_start_day is 1)
    period_start := date_trunc('day', NOW());
    period_end := (date_trunc('month', NOW()) + interval '1 month' - interval '1 day');

    -- Period for Checking
    INSERT INTO public.financial_periods (id, household_id, account_id, name, start_date, end_date)
    VALUES (gen_random_uuid(), new_household_id, checking_id, 'Initial Period', period_start, period_end);

    -- Period for Savings
    INSERT INTO public.financial_periods (id, household_id, account_id, name, start_date, end_date)
    VALUES (gen_random_uuid(), new_household_id, savings_id, 'Initial Period', period_start, period_end);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. REPAIR SCRIPT FOR EXISTING ACCOUNTS
-- Run this if you have accounts without a period.
DO $$
DECLARE
    acc RECORD;
    p_start TIMESTAMP;
    p_end TIMESTAMP;
BEGIN
    p_start := date_trunc('day', NOW());
    p_end := (date_trunc('month', NOW()) + interval '1 month' - interval '1 day');

    FOR acc IN 
        SELECT a.id, a.household_id FROM public.accounts a
        LEFT JOIN public.financial_periods fp ON a.id = fp.account_id
        WHERE fp.id IS NULL
    LOOP
        INSERT INTO public.financial_periods (id, household_id, account_id, name, start_date, end_date)
        VALUES (gen_random_uuid(), acc.household_id, acc.id, 'Initial Period', p_start, p_end);
    END LOOP;
END $$;
