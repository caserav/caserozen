// js/auth.js

/**
 * Inicializa la autenticación y gestiona el acceso
 */
async function initializeAuth() {
    console.log("Inicializando sistema de acceso...");

    // 1. Intentamos obtener la sesión real (si existe)
    const session = supabase.auth.session();

    if (session) {
        console.log("Sesión real detectada para:", session.user.email);
        setupUserUI(session.user);
    } else {
        // 2. MODO TEMERARIO: Si no hay login, forzamos uno falso
        console.warn("No hay sesión. Forzando entrada como invitado...");
        
        const guestUser = {
            id: 'guest-id-12345', // ID ficticio
            email: 'invitado@housezen.com',
            user_metadata: { full_name: 'Invitado HouseZen' }
        };
        
        setupUserUI(guestUser);
    }
}

/**
 * Configura la interfaz según el usuario (real o falso)
 */
function setupUserUI(user) {
    // Guardamos el usuario globalmente para que app.js pueda usarlo
    window.currentUser = user;

    // Cambiamos lo que se ve en pantalla
    const loginSection = document.getElementById('login-section');
    const mainAppSection = document.getElementById('app-section');

    if (loginSection) loginSection.classList.add('hidden');
    if (mainAppSection) mainAppSection.classList.remove('hidden');

    // Lanzamos la carga de datos desde app.js
    if (typeof fetchIncidents === 'function') {
        fetchIncidents();
    }
}

/**
 * Función de Login (la dejamos por si quieres volver a usar Google)
 */
async function loginWithGoogle() {
    const { error } = await supabase.auth.signIn({
        provider: 'google'
    }, {
        redirectTo: REDIRECT_URL
    });

    if (error) {
        console.error("Error en login:", error.message);
        alert("Error al conectar con Google: " + error.message);
    }
}

/**
 * Función de Cerrar Sesión
 */
async function logout() {
    await supabase.auth.signOut();
    window.location.reload(); // Recarga la página para volver al estado inicial
}

// Escuchar cambios de estado (opcional, por robustez)
supabase.auth.onAuthStateChange((event, session) => {
    if (event === 'SIGNED_IN' || event === 'TOKEN_REFRESHED') {
        initializeAuth();
    }
});
