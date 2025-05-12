document.addEventListener('DOMContentLoaded', function() {
    // Elementos DOM para los pasos
    const step1 = document.getElementById('step-1');
    const step2 = document.getElementById('step-2');
    const step3 = document.getElementById('step-3');
    const step4 = document.getElementById('step-4');
    const dot1 = document.getElementById('dot-1');
    const dot2 = document.getElementById('dot-2');
    const dot3 = document.getElementById('dot-3');
    const dot4 = document.getElementById('dot-4'); 

    const validateDniBtn = document.getElementById('validateDni');
    const backToStep1Btn = document.getElementById('backToStep1');
    const goToStep3Btn = document.getElementById('goToStep3');
    const backToStep2Btn = document.getElementById('backToStep2');
    const goToStep4Btn = document.getElementById('goToStep4');
    const backToStep3Btn = document.getElementById('backToStep3');
    const passwordInput = document.getElementById('password');
    const confirmPasswordInput = document.getElementById('confirmPassword');
    
    // Función para ir al paso 2 después de validar DNI
    window.checkAndGoToStep2 = function () {
        if (dniValido) { // Asumiendo que la variable dniValido está definida en alguna parte
          step1.classList.remove('active');
          step2.classList.add('active');
          dot1.classList.remove('active');
          dot2.classList.add('active');
        }
    }

    // Validar contraseñas
    function validarContraseñas() {
      if (passwordInput.value !== confirmPasswordInput.value) {
        alert('Las contraseñas no coinciden');
        return false;
      }
      
      if (passwordInput.value.length < 8) {
        alert('La contraseña debe tener al menos 8 caracteres');
        return false;
      }
      
      return true;
    }
    
    // Event listeners para navegación
    validateDniBtn.addEventListener('click', function() {
      // Simulamos un clic en el botón submit original para activar tu validación
      const submitEvent = new Event('submit');
      document.getElementById('dniForm').dispatchEvent(submitEvent);
      
      // Esperamos un poco para que se procese la validación
      setTimeout(checkAndGoToStep2, 500);
    });
    
    backToStep1Btn.addEventListener('click', function() {
      step2.classList.remove('active');
      step1.classList.add('active');
      dot2.classList.remove('active');
      dot1.classList.add('active');
    });
    
    goToStep3Btn.addEventListener('click', function() {
      if (validarContraseñas()) {
        step2.classList.remove('active');
        step3.classList.add('active');
        dot2.classList.remove('active');
        dot3.classList.add('active');
      }
    });
    
    backToStep2Btn.addEventListener('click', function() {
      step3.classList.remove('active');
      step2.classList.add('active');
      dot3.classList.remove('active');
      dot2.classList.add('active');
    });
    
    // Agregar el comportamiento para ir al paso 4
    goToStep4Btn.addEventListener('click', function() {
      step3.classList.remove('active');
      step4.classList.add('active');
      dot3.classList.remove('active');
      dot4.classList.add('active');
    });

    backToStep3Btn.addEventListener('click', function() {
      step4.classList.remove('active');
      step3.classList.add('active');
      dot4.classList.remove('active');
      dot3.classList.add('active');
    });
    
    // Modificar el comportamiento del formulario original
    const originalForm = document.getElementById('dniForm');
    originalForm.addEventListener('submit', function(e) {
      // Si no estamos en el último paso, prevenimos el envío
      if (!step4.classList.contains('active')) {
        e.preventDefault();
      }
    }, true); // Usamos true para capturar el evento antes de tu manejador
});
