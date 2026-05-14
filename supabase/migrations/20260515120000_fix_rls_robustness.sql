-- Clean up legacy policies
DROP POLICY IF EXISTS "Users can view household budgets" ON budgets;

-- Ensure is_my_household is robust
CREATE OR REPLACE FUNCTION public.is_my_household(h_id UUID)
RETURNS BOOLEAN AS $$
    SELECT EXISTS (
        SELECT 1 FROM public.users 
        WHERE id = auth.uid() 
        AND (household_id = h_id OR shared_household_id = h_id)
    );
$$ LANGUAGE sql SECURITY DEFINER SET search_path = public;

-- Ensure the household_id column in budgets is actually the correct one for sync
-- Sometimes PowerSync uploads might trigger RLS before the user profile is fully visible 
-- if sync isn't perfectly sequenced, but the trigger handles creation on Supabase side.
-- The 42501 here suggests the INSERT is failing when called by PowerSync.
