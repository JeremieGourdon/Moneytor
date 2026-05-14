-- 1. Function to process recurring templates
CREATE OR REPLACE FUNCTION public.process_recurring_templates()
RETURNS void AS $$
DECLARE
    template RECORD;
    new_tx_id UUID;
    household_owner_id UUID;
BEGIN
    FOR template IN 
        SELECT * FROM public.recurring_templates 
        WHERE is_active = true 
        AND next_execution_date <= CURRENT_DATE
        AND deleted_at IS NULL
    LOOP
        -- a. Generate new transaction ID
        new_tx_id := uuid_generate_v4();
        
        -- b. Find a user to assign as creator (fallback to first member of household)
        SELECT id INTO household_owner_id FROM public.users 
        WHERE household_id = template.household_id 
        ORDER BY created_at ASC LIMIT 1;

        -- c. Create the pending transaction
        INSERT INTO public.transactions (
            id, household_id, account_id, budget_id, project_id, 
            created_by, amount, transaction_date, description, 
            type, status, created_at, updated_at
        ) VALUES (
            new_tx_id, template.household_id, template.account_id, template.budget_id, template.project_id,
            household_owner_id, template.amount, CURRENT_TIMESTAMP, template.description,
            template.type, 'pending', NOW(), NOW()
        );

        -- d. Advance the next_execution_date
        -- Supporting 'monthly' and 'weekly' human-readable strings
        IF template.cron_schedule = 'monthly' THEN
            UPDATE public.recurring_templates 
            SET next_execution_date = next_execution_date + INTERVAL '1 month',
                updated_at = NOW()
            WHERE id = template.id;
        ELSIF template.cron_schedule = 'weekly' THEN
            UPDATE public.recurring_templates 
            SET next_execution_date = next_execution_date + INTERVAL '1 week',
                updated_at = NOW()
            WHERE id = template.id;
        ELSE
            -- Fallback for custom intervals or just disable if unknown
            UPDATE public.recurring_templates 
            SET is_active = false,
                updated_at = NOW()
            WHERE id = template.id;
        END IF;

        -- e. Create notification for all household members
        INSERT INTO public.notifications (
            household_id, user_id, title, body, type, created_at, updated_at
        )
        SELECT template.household_id, u.id, 'Paiement prévu', 
               'Une transaction pour "' || template.description || '" a été générée et attend votre confirmation.', 
               'pending_tx', NOW(), NOW()
        FROM public.users u 
        WHERE u.household_id = template.household_id;

    END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. Schedule the task to run daily at 1 AM
-- We use a SELECT query to call the function
-- First, unschedule if already exists to avoid duplicates during migration retries
SELECT cron.unschedule('process-recurring-templates');
SELECT cron.schedule('process-recurring-templates', '0 1 * * *', 'SELECT public.process_recurring_templates()');
