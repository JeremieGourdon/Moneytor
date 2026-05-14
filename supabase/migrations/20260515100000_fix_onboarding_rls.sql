-- Allow authenticated users to insert their own profile
CREATE POLICY "Users can insert their own profile" ON users
    FOR INSERT TO authenticated 
    WITH CHECK (id = auth.uid());

-- Allow authenticated users to create a household
CREATE POLICY "Users can insert a household" ON households
    FOR INSERT TO authenticated 
    WITH CHECK (true);
