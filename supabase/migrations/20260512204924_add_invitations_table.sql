-- 9. INVITATIONS
CREATE TABLE invitations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    household_id UUID NOT NULL REFERENCES households(id),
    email VARCHAR NOT NULL,
    token UUID NOT NULL DEFAULT uuid_generate_v4(),
    invited_by UUID NOT NULL REFERENCES users(id),
    status VARCHAR DEFAULT 'pending', -- 'pending', 'accepted', 'expired'
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() + INTERVAL '7 days')
);

-- Triggers
CREATE TRIGGER update_invitations_updated_at BEFORE UPDATE ON invitations FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

-- RLS
ALTER TABLE invitations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view invitations they sent" ON invitations
FOR SELECT USING (invited_by = auth.uid());

CREATE POLICY "Users can create invitations for their household" ON invitations
FOR INSERT WITH CHECK (
    household_id IN (SELECT household_id FROM users WHERE id = auth.uid())
);
