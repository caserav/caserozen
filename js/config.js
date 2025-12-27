const SUPABASE_URL = 'https://rplieisbxvruijvnxbya.supabase.co';
const SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJwbGllaXNieHZydWlqdm54YnlhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzUyMjMzNzEsImV4cCI6MjA1MDc5OTM3MX0.Af9yH6_J9KuvHDJjMkwkRZQ_CdYglnmR6rI10b8gZf0';
const _supabase = supabase.createClient(SUPABASE_URL, SUPABASE_KEY);

let currentUser = null;
let authInitialized = false;
let isAdmin = false;

async function checkIfAdmin() {
    if (!currentUser) return false;

    try {
        const { data, error } = await _supabase
            .from('administradores')
            .select('id')
            .eq('id', currentUser.id)
            .maybeSingle();

        if (error && error.code !== 'PGRST116') {
            console.error('Error checking admin status:', error);
            return false;
        }

        return !!data;
    } catch (error) {
        console.error('Error checking admin:', error);
        return false;
    }
}
