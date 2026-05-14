-- Update onboarding trigger to create 2 accounts (Checking + Savings)
-- and link "Unplanned" budget to Checking and "Monthly Savings" project to Savings.

-- 1. Add account_id to projects if it doesn't exist
DO $$ 
BEGIN 
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='projects' AND column_name='account_id') THEN
        ALTER TABLE public.projects ADD COLUMN account_id UUID REFERENCES public.accounts(id);
    END IF;
END $$;

CREATE OR REPLACE FUNCTION public.handle_new_user() 
RETURNS TRIGGER AS $$
DECLARE
    new_household_id UUID;
    checking_account_id UUID;
    savings_account_id UUID;
    unplanned_budget_id UUID;
    savings_project_id UUID;
    new_period_id UUID;
BEGIN
    new_household_id := extensions.uuid_generate_v4();
    checking_account_id := extensions.uuid_generate_v4();
    savings_account_id := extensions.uuid_generate_v4();
    unplanned_budget_id := extensions.uuid_generate_v4();
    savings_project_id := extensions.uuid_generate_v4();
    new_period_id := extensions.uuid_generate_v4();

    -- 1. Create personal household
    INSERT INTO public.households (id, name, default_month_start_day)
    VALUES (new_household_id, 'My Finances', 1);

    -- 2. Create user profile
    INSERT INTO public.users (id, household_id, first_name, role)
    VALUES (NEW.id, new_household_id, COALESCE(NEW.raw_user_meta_data->>'first_name', 'New User'), 'admin');

    -- 3. Create initial financial period
    INSERT INTO public.financial_periods (id, household_id, name, start_date, end_date)
    VALUES (new_period_id, new_household_id, to_char(NOW(), 'FMMonth YYYY'), date_trunc('month', NOW()), (date_trunc('month', NOW()) + interval '1 month'));

    -- 4. Create default private CHECKING account
    INSERT INTO public.accounts (id, household_id, owner_id, name, type, is_public, is_default)
    VALUES (checking_account_id, new_household_id, NEW.id, 'Checking Account', 'checking', false, true);

    -- 5. Create default private SAVINGS account
    INSERT INTO public.accounts (id, household_id, owner_id, name, type, is_public, is_default)
    VALUES (savings_account_id, new_household_id, NEW.id, 'Savings Account', 'savings', false, false);

    -- 6. Create default "Unplanned" budget linked to Checking
    INSERT INTO public.budgets (id, household_id, account_id, name, default_amount, icon, color, is_default)
    VALUES (unplanned_budget_id, new_household_id, checking_account_id, 'Unplanned', 0, 'help-circle', '#71717A', true);

    -- 7. Create default "Monthly Savings" project linked to Savings
    INSERT INTO public.projects (id, household_id, account_id, name, target_amount, is_pinned_to_dashboard)
    VALUES (savings_project_id, new_household_id, savings_account_id, 'Monthly Savings', 0, true);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, extensions;
