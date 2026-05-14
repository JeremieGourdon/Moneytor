-- RLS Policies for Moneytor

-- 1. Helper Function
CREATE OR REPLACE FUNCTION public.get_my_household_id()
RETURNS UUID AS $$
    SELECT household_id FROM public.users WHERE id = auth.uid();
$$ LANGUAGE sql SECURITY DEFINER;

-- Enable RLS on all tables
ALTER TABLE households ENABLE ROW LEVEL SECURITY;
ALTER TABLE financial_periods ENABLE ROW LEVEL SECURITY;
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE budgets ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE recurring_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- 2. households
DROP POLICY IF EXISTS "Users can select their own household" ON households;
CREATE POLICY "Users can select their own household" ON households
    FOR SELECT TO authenticated USING (id = public.get_my_household_id());

DROP POLICY IF EXISTS "Users can update their own household" ON households;
CREATE POLICY "Users can update their own household" ON households
    FOR UPDATE TO authenticated 
    USING (id = public.get_my_household_id())
    WITH CHECK (id = public.get_my_household_id());

-- 3. financial_periods
DROP POLICY IF EXISTS "Household access for financial_periods" ON financial_periods;
CREATE POLICY "Household access for financial_periods" ON financial_periods
    FOR ALL TO authenticated 
    USING (household_id = public.get_my_household_id())
    WITH CHECK (household_id = public.get_my_household_id());

-- 4. users
DROP POLICY IF EXISTS "Users can select themselves" ON users;
CREATE POLICY "Users can select themselves" ON users
    FOR SELECT TO authenticated USING (id = auth.uid());

DROP POLICY IF EXISTS "Users can select household members" ON users;
CREATE POLICY "Users can select household members" ON users
    FOR SELECT TO authenticated USING (household_id = public.get_my_household_id());

DROP POLICY IF EXISTS "Users can update their own profile" ON users;
CREATE POLICY "Users can update their own profile" ON users
    FOR UPDATE TO authenticated 
    USING (id = auth.uid())
    WITH CHECK (id = auth.uid());

-- 5. accounts
DROP POLICY IF EXISTS "Household access for accounts" ON accounts;
CREATE POLICY "Household access for accounts" ON accounts
    FOR ALL TO authenticated 
    USING (household_id = public.get_my_household_id())
    WITH CHECK (
        household_id = public.get_my_household_id() 
        AND (
            (owner_id IS NULL AND is_public IS TRUE) -- Joint accounts must be public
            OR 
            (owner_id = auth.uid()) -- Personal accounts must be owned by the creator
        )
    );

-- 6. budgets
DROP POLICY IF EXISTS "Household access for budgets" ON budgets;
CREATE POLICY "Household access for budgets" ON budgets
    FOR ALL TO authenticated 
    USING (household_id = public.get_my_household_id())
    WITH CHECK (household_id = public.get_my_household_id());

-- 7. categories
DROP POLICY IF EXISTS "Household access for categories" ON categories;
CREATE POLICY "Household access for categories" ON categories
    FOR ALL TO authenticated 
    USING (household_id = public.get_my_household_id())
    WITH CHECK (household_id = public.get_my_household_id());

-- 8. projects
DROP POLICY IF EXISTS "Household access for projects" ON projects;
CREATE POLICY "Household access for projects" ON projects
    FOR ALL TO authenticated 
    USING (household_id = public.get_my_household_id())
    WITH CHECK (household_id = public.get_my_household_id());

-- 9. transactions
DROP POLICY IF EXISTS "Household access for transactions" ON transactions;
CREATE POLICY "Household access for transactions" ON transactions
    FOR ALL TO authenticated 
    USING (household_id = public.get_my_household_id())
    WITH CHECK (household_id = public.get_my_household_id());

-- 10. recurring_templates
DROP POLICY IF EXISTS "Household access for recurring_templates" ON recurring_templates;
CREATE POLICY "Household access for recurring_templates" ON recurring_templates
    FOR ALL TO authenticated 
    USING (household_id = public.get_my_household_id())
    WITH CHECK (household_id = public.get_my_household_id());

-- 11. notifications
DROP POLICY IF EXISTS "Users can access their own notifications" ON notifications;
CREATE POLICY "Users can access their own notifications" ON notifications
    FOR ALL TO authenticated 
    USING (user_id = auth.uid())
    WITH CHECK (user_id = auth.uid());
