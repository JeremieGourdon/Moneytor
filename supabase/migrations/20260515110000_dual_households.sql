-- 1. Schema update
ALTER TABLE public.users ADD COLUMN shared_household_id UUID REFERENCES public.households(id);

-- 2. New Helper Function for RLS
CREATE OR REPLACE FUNCTION public.is_my_household(h_id UUID)
RETURNS BOOLEAN AS $$
    SELECT EXISTS (
        SELECT 1 FROM public.users 
        WHERE id = auth.uid() 
        AND (household_id = h_id OR shared_household_id = h_id)
    );
$$ LANGUAGE sql SECURITY DEFINER;

-- 3. Replace old helper function usage across all tables
DROP POLICY IF EXISTS "Users can select their own household" ON households;
CREATE POLICY "Users can select their own household" ON households
    FOR SELECT TO authenticated USING (public.is_my_household(id));

DROP POLICY IF EXISTS "Users can update their own household" ON households;
CREATE POLICY "Users can update their own household" ON households
    FOR UPDATE TO authenticated 
    USING (public.is_my_household(id))
    WITH CHECK (public.is_my_household(id));

DROP POLICY IF EXISTS "Household access for financial_periods" ON financial_periods;
CREATE POLICY "Household access for financial_periods" ON financial_periods
    FOR ALL TO authenticated 
    USING (public.is_my_household(household_id))
    WITH CHECK (public.is_my_household(household_id));

-- Users table RLS
DROP POLICY IF EXISTS "Users can select household members" ON users;
CREATE POLICY "Users can select household members" ON users
    FOR SELECT TO authenticated USING (
        public.is_my_household(household_id) 
        OR 
        (shared_household_id IS NOT NULL AND public.is_my_household(shared_household_id))
    );

-- Accounts RLS (With public/private distinction)
DROP POLICY IF EXISTS "Household access for accounts" ON accounts;
CREATE POLICY "Household access for accounts" ON accounts
    FOR ALL TO authenticated 
    USING (
        public.is_my_household(household_id)
        AND (
            is_public = TRUE OR owner_id = auth.uid()
        )
    )
    WITH CHECK (
        public.is_my_household(household_id)
        AND (
            is_public = TRUE OR owner_id = auth.uid()
        )
    );

-- Other tables
DROP POLICY IF EXISTS "Household access for budgets" ON budgets;
CREATE POLICY "Household access for budgets" ON budgets
    FOR ALL TO authenticated 
    USING (public.is_my_household(household_id))
    WITH CHECK (public.is_my_household(household_id));

DROP POLICY IF EXISTS "Household access for categories" ON categories;
CREATE POLICY "Household access for categories" ON categories
    FOR ALL TO authenticated 
    USING (public.is_my_household(household_id))
    WITH CHECK (public.is_my_household(household_id));

DROP POLICY IF EXISTS "Household access for projects" ON projects;
CREATE POLICY "Household access for projects" ON projects
    FOR ALL TO authenticated 
    USING (public.is_my_household(household_id))
    WITH CHECK (public.is_my_household(household_id));

DROP POLICY IF EXISTS "Household access for transactions" ON transactions;
CREATE POLICY "Household access for transactions" ON transactions
    FOR ALL TO authenticated 
    USING (public.is_my_household(household_id))
    WITH CHECK (public.is_my_household(household_id));

DROP POLICY IF EXISTS "Household access for recurring_templates" ON recurring_templates;
CREATE POLICY "Household access for recurring_templates" ON recurring_templates
    FOR ALL TO authenticated 
    USING (public.is_my_household(household_id))
    WITH CHECK (public.is_my_household(household_id));

-- 4. Auto-Onboarding Trigger
CREATE OR REPLACE FUNCTION public.handle_new_user() 
RETURNS TRIGGER AS $$
DECLARE
    new_household_id UUID;
    new_account_id UUID;
    new_budget_id UUID;
    new_period_id UUID;
BEGIN
    new_household_id := uuid_generate_v4();
    new_account_id := uuid_generate_v4();
    new_budget_id := uuid_generate_v4();
    new_period_id := uuid_generate_v4();

    -- 1. Create personal household
    INSERT INTO public.households (id, name, default_month_start_day)
    VALUES (new_household_id, 'My Finances', 1);

    -- 2. Create user profile
    INSERT INTO public.users (id, household_id, first_name, role)
    VALUES (NEW.id, new_household_id, 'New User', 'admin');

    -- 3. Create initial financial period
    INSERT INTO public.financial_periods (id, household_id, name, start_date, end_date)
    VALUES (new_period_id, new_household_id, to_char(NOW(), 'FMMonth YYYY'), date_trunc('month', NOW()), date_trunc('month', NOW()) + interval '1 month');

    -- 4. Create default private account
    INSERT INTO public.accounts (id, household_id, owner_id, name, type, is_public, is_default)
    VALUES (new_account_id, new_household_id, NEW.id, 'Current Account', 'checking', false, true);

    -- 5. Create default Unplanned budget
    INSERT INTO public.budgets (id, household_id, account_id, name, default_amount, icon, color, is_default)
    VALUES (new_budget_id, new_household_id, new_account_id, 'Unplanned', 0, 'help-circle', '#71717A', true);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();
