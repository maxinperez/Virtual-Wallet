// Tu código original con pequeñas modificaciones
const form = document.getElementById('dniForm');
const mensaje = document.getElementById('mensaje');

function verificarDNI(dni) {
  return new Promise((resolve, reject) => {
    if (dni.length < 8) {
      reject("El DNI debe tener al menos 8 caracteres");
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
  // Solo procesamos el evento si estamos en el primer paso
  if (document.getElementById('step-1').classList.contains('active')) {
    event.preventDefault();
    const dni = document.getElementById('dni').value;

    
    verificarDNI(dni)
      .then(() => {
        // Si la validación es exitosa, mostramos mensaje y avanzamos al paso 2
        dniValido = true;
        mensaje.textContent = "DNI válido. Puedes continuar con el registro";
        mensaje.style.backgroundColor = "#dcfce7";
        mensaje.style.color = "#15803d";
        mensaje.style.borderColor = "#bbf7d0";
        window.checkAndGoToStep2();
      })
      .catch(error => {
        // Mostrar error
        dniValido = false;
        mensaje.textContent = error;
        mensaje.style.backgroundColor = "#fee2e2";
        mensaje.style.color = "#b91c1c";
        mensaje.style.borderColor = "#fecaca";
      });
  }
});