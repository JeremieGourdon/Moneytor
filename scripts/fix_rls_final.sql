-- Moneytor RLS Policy - Final Robust Version
-- 1. Helper function that bypasses RLS (SECURITY DEFINER)
CREATE OR REPLACE FUNCTION public.is_my_household(h_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        -- We query auth.uid() directly and use a subquery to avoid recursion
        SELECT 1 FROM public.users 
        WHERE id = auth.uid() 
        AND (household_id = h_id OR shared_household_id = h_id)
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- 2. Clean and robust users table policies
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can insert their own profile" ON public.users;
DROP POLICY IF EXISTS "Users can update their own profile" ON public.users;
DROP POLICY IF EXISTS "Users can view household members" ON public.users;

-- Allow insert during signup
CREATE POLICY "Users can insert their own profile" ON public.users FOR INSERT TO authenticated WITH CHECK (id = auth.uid());

-- Allow viewing yourself (Critical for PowerSync bucket assignment)
CREATE POLICY "Users can view themselves" ON public.users FOR SELECT TO authenticated USING (id = auth.uid());

-- Allow viewing household members (Uses the Security Definer helper)
CREATE POLICY "Users can view household members" ON public.users FOR SELECT TO authenticated 
USING (public.is_my_household(household_id) OR (shared_household_id IS NOT NULL AND public.is_my_household(shared_household_id)));

-- Allow updating yourself
CREATE POLICY "Users can update their own profile" ON public.users FOR UPDATE TO authenticated USING (id = auth.uid());
