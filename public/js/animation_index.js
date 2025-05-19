  function splitTextAnimation() {
    const elements = document.querySelectorAll('.split-text');

    elements.forEach(el => {
      const text = el.dataset.text || '';
      el.innerHTML = '';

      let index = 0;
      text.split(' ').forEach(word => {
        const wordSpan = document.createElement('span');
        wordSpan.style.whiteSpace = 'nowrap';

        word.split('').forEach(letter => {
          const span = document.createElement('span');
          span.textContent = letter;
          span.style.transitionDelay = `${index * 100}ms`; // Delay between letters
          wordSpan.appendChild(span);
          index++;
        });

        const space = document.createElement('span');
        space.classList.add('space');
        space.innerHTML = '&nbsp;';
        wordSpan.appendChild(space);

        el.appendChild(wordSpan);
      });

      const observer = new IntersectionObserver(
        ([entry], obs) => {
          if (entry.isIntersecting) {
            el.classList.add('visible');
            obs.unobserve(el);
          }
        },
        {
          threshold: 0.1,
          rootMargin: '-100px',
        }
      );

      observer.observe(el);
    });
  }

  document.addEventListener('DOMContentLoaded', splitTextAnimation);
