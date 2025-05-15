document.getElementById('login-form').addEventListener('submit', async (e) => {
    e.preventDefault(); // Evita el envío tradicional del formulario
    
    // Obtiene los valores de los campos DNI y contraseña.
    const dni = document.getElementById('dni').value;
    const password = document.getElementById('password').value;

    // Envía una petición POST asíncrona al endpoint /login en el servidor Sinatra.
    try {
        const response = await fetch('/login', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ dni, password })
        });

        const data = await response.json();

        if (data.success) {
            // Redirige al dashboard después de login exitoso
            window.location.href = '/dashboard';
        } else {
            // Muestra error al usuario
            alert(`Error: ${data.message}`);
            document.getElementById('password').value = ''; // Limpia el campo de contraseña
        }
    } catch (error) {
        console.error('Error:', error);
        alert('Error al conectar con el servidor');
    }
});