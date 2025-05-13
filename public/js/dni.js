const form = document.getElementById('dniForm');
const dniInput = document.getElementById('dni');
const mensaje = document.getElementById('mensaje');
const validateDniBtn = document.getElementById('validateDni');

// Variable para controlar si el DNI es válido
let dniValido = false;

function verificarDNI(dni) {
  return new Promise((resolve, reject) => {
    if (!dni || dni.length < 8) {
      reject("El DNI debe tener al menos 8 caracteres");
      return;
    }
    
    fetch(`/verificar_dni?dni=${dni}`)
      .then(response => {
        if (!response.ok) throw new Error("Error en la respuesta del servidor");
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
        console.error("Error:", error);
        reject("Error al conectar con el servidor. Por favor, intenta nuevamente.");
      });
  });
}

validateDniBtn.addEventListener('click', function() {
  const dni = dniInput.value.trim();
  
  verificarDNI(dni)
    .then(() => {
      // Si la validación es exitosa
      dniValido = true;
      mensaje.textContent = "DNI válido. Puedes continuar con el registro";
      mensaje.className = ''; // Elimina todas las clases
      mensaje.classList.add("mensaje-exito");
      goToStep(2);
    })
    .catch(error => {
      // Si la validación falla
      dniValido = false;
      mensaje.textContent = error;
      mensaje.className = "mensaje";
    });
});