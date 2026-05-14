-- Add is_default to accounts
ALTER TABLE public.accounts ADD COLUMN is_default BOOLEAN DEFAULT false;

-- Add is_default to budgets and migrate is_system
ALTER TABLE public.budgets ADD COLUMN is_default BOOLEAN DEFAULT false;
UPDATE public.budgets SET is_default = is_system;
ALTER TABLE public.budgets DROP COLUMN is_system;

-- Set the first account for each household as default
UPDATE public.accounts a
SET is_default = true
FROM (
  SELECT id, row_number() OVER (PARTITION BY household_id ORDER BY created_at ASC) as rn
  FROM public.accounts
) sub
WHERE a.id = sub.id AND sub.rn = 1;

-- Ensure "Unplanned" budgets are default
UPDATE public.budgets SET is_default = true WHERE name = 'Unplanned';
