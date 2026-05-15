-- Robust RLS Policies for Moneytor

-- 1. Helper Function (Robust)
CREATE OR REPLACE FUNCTION public.get_my_household_id()
RETURNS UUID AS $$
    SELECT household_id FROM public.users WHERE id = auth.uid() LIMIT 1;
$$ LANGUAGE sql SECURITY DEFINER SET search_path = public;

-- 2. Refactor financial_periods policies
DROP POLICY IF EXISTS "Household access for financial_periods" ON financial_periods;
CREATE POLICY "Users can manage financial_periods of their household" ON financial_periods
    FOR ALL TO authenticated 
    USING (
        household_id IN (
            SELECT household_id FROM public.users WHERE id = auth.uid()
            UNION
            SELECT shared_household_id FROM public.users WHERE id = auth.uid() AND shared_household_id IS NOT NULL
        )
    )
    WITH CHECK (
        household_id IN (
            SELECT household_id FROM public.users WHERE id = auth.uid()
            UNION
            SELECT shared_household_id FROM public.users WHERE id = auth.uid() AND shared_household_id IS NOT NULL
        )
    );

-- 3. Refactor accounts policies
DROP POLICY IF EXISTS "Household access for accounts" ON accounts;
CREATE POLICY "Users can manage accounts of their household" ON accounts
    FOR ALL TO authenticated 
    USING (
        household_id IN (
            SELECT household_id FROM public.users WHERE id = auth.uid()
            UNION
            SELECT shared_household_id FROM public.users WHERE id = auth.uid() AND shared_household_id IS NOT NULL
        )
    )
    WITH CHECK (
        household_id IN (
            SELECT household_id FROM public.users WHERE id = auth.uid()
            UNION
            SELECT shared_household_id FROM public.users WHERE id = auth.uid() AND shared_household_id IS NOT NULL
        )
    );

-- 4. Refactor projects policies
DROP POLICY IF EXISTS "Household access for projects" ON projects;
CREATE POLICY "Users can manage projects of their household" ON projects
    FOR ALL TO authenticated 
    USING (
        household_id IN (
            SELECT household_id FROM public.users WHERE id = auth.uid()
            UNION
            SELECT shared_household_id FROM public.users WHERE id = auth.uid() AND shared_household_id IS NOT NULL
        )
    )
    WITH CHECK (
        household_id IN (
            SELECT household_id FROM public.users WHERE id = auth.uid()
            UNION
            SELECT shared_household_id FROM public.users WHERE id = auth.uid() AND shared_household_id IS NOT NULL
        )
    );

-- 5. Refactor budgets policies
DROP POLICY IF EXISTS "Household access for budgets" ON budgets;
CREATE POLICY "Users can manage budgets of their household" ON budgets
    FOR ALL TO authenticated 
    USING (
        household_id IN (
            SELECT household_id FROM public.users WHERE id = auth.uid()
            UNION
            SELECT shared_household_id FROM public.users WHERE id = auth.uid() AND shared_household_id IS NOT NULL
        )
    )
    WITH CHECK (
        household_id IN (
            SELECT household_id FROM public.users WHERE id = auth.uid()
            UNION
            SELECT shared_household_id FROM public.users WHERE id = auth.uid() AND shared_household_id IS NOT NULL
        )
    );

-- 6. Refactor transactions policies
DROP POLICY IF EXISTS "Household access for transactions" ON transactions;
CREATE POLICY "Users can manage transactions of their household" ON transactions
    FOR ALL TO authenticated 
    USING (
        household_id IN (
            SELECT household_id FROM public.users WHERE id = auth.uid()
            UNION
            SELECT shared_household_id FROM public.users WHERE id = auth.uid() AND shared_household_id IS NOT NULL
        )
    )
    WITH CHECK (
        household_id IN (
            SELECT household_id FROM public.users WHERE id = auth.uid()
            UNION
            SELECT shared_household_id FROM public.users WHERE id = auth.uid() AND shared_household_id IS NOT NULL
        )
    );
