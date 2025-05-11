const form = document.getElementById('dniForm'); // obtiene todos los datos del formulario
const mensaje = document.getElementById('mensaje');

function verificarDNI(dni) {
  return new Promise((resolve, reject) => {
    if (dni.length < 8) {
      reject("El DNI debe tener al menos 8 caracteres"); // se rechaza la solicitud, y pasa para el catch
      return;
    }
    
    fetch(`/verificar_dni?dni=${dni}`)
      .then(response => {
        if (!response.ok) throw new Error("Error en la respuesta");
        return response.json();
      })
      .then(data => {
        if (data.existe) {
          reject("El DNI ya está registrado"); 
        } else {
          resolve();
        }
      })
      .catch(error => {
        reject("Error al conectar con el servidor");
      });
  });
}

form.addEventListener('submit', function(event) {
  event.preventDefault();
  const dni = document.getElementById('dni').value;
  
  // Limpiar mensaje previo
  mensaje.textContent = "";
  
  verificarDNI(dni)
    .then(() => {
      // Si la validación es exitosa, enviar el formulario
      form.submit();
    })
    .catch(error => {
      // Mostrar error solo cuando se intenta enviar
      mensaje.textContent = error;
      mensaje.style.color = "red";
    });
});