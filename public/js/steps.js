document.addEventListener('DOMContentLoaded', function () {
  window.goToStep = function(n) {
    const steps = {
      1: { element: document.getElementById('step-1'), dot: document.getElementById('dot-1') },
      2: { element: document.getElementById('step-2'), dot: document.getElementById('dot-2') },
      3: { element: document.getElementById('step-3'), dot: document.getElementById('dot-3') },
      4: { element: document.getElementById('step-4'), dot: document.getElementById('dot-4') }
    };
  
    Object.values(steps).forEach(({ element, dot }) => {
      element.classList.remove('active');
      dot.classList.remove('active');
    });
    steps[n].element.classList.add('active');
    steps[n].dot.classList.add('active');
  };

  // Validar contraseñas antes de pasar a paso 3
  function validarContraseñas() {
    const msg_pass = document.getElementById('mensaje-password');
    const password = document.getElementById('password').value;
    const confirm = document.getElementById('confirmPassword').value;
    
    if (password.length < 8) {
      msg_pass.textContent = "La contraseña debe tener al menos 8 caracteres";
      return false;
    }

    if (password !== confirm) {
      msg_pass.textContent = "Las contraseñas no coinciden";
      return false;
    }

    return true;
  }

  // Evento para validar contraseña antes de avanzar a paso 3
  document.getElementById('goToStep3')?.addEventListener('click', () => {
    if (validarContraseñas()) {
      goToStep(3);
    }
  });

  // Botones de navegación
  document.getElementById('backToStep1')?.addEventListener('click', () => goToStep(1));
  document.getElementById('backToStep2')?.addEventListener('click', () => goToStep(2));
  document.getElementById('goToStep4')?.addEventListener('click', () => goToStep(4));
  document.getElementById('backToStep3')?.addEventListener('click', () => goToStep(3));


  // Prevenir envío si no es el último paso
  const originalForm = document.getElementById('dniForm');
  originalForm.addEventListener('submit', function (e) {
    const step4 = document.getElementById('step-4');
    if (!step4.classList.contains('active')) {
      e.preventDefault();
    }
  }, true);
});
