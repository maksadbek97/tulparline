(function () {
  var $ = function (s) { return document.querySelector(s); };

  // Mobile menu
  var burger = $('#burger'), nav = $('#nav');
  burger.addEventListener('click', function () {
    var open = nav.classList.toggle('is-open');
    burger.setAttribute('aria-expanded', open);
  });
  nav.addEventListener('click', function (e) {
    if (e.target.tagName === 'A') { nav.classList.remove('is-open'); burger.setAttribute('aria-expanded', false); }
  });

  // Income calculator
  var hours = $('#hours'), days = $('#days'), rate = $('#rate');
  function fmt(n) { return n.toLocaleString('ru-RU') + ' ₽'; }
  function calc() {
    $('#hoursVal').textContent = hours.value;
    $('#daysVal').textContent = days.value;
    $('#rateVal').textContent = rate.value;
    $('#result').textContent = fmt(Math.round(hours.value * days.value * rate.value * 4.33 / 100) * 100);
  }
  [hours, days, rate].forEach(function (el) { el.addEventListener('input', calc); });
  calc();

  // Application form (front-end only: connect to your CRM / backend endpoint)
  var form = $('#form'), msg = $('#formMsg');
  form.addEventListener('submit', function (e) {
    e.preventDefault();
    var name = form.name.value.trim();
    var digits = form.phone.value.replace(/\D/g, '');
    msg.className = 'form__msg';
    if (!name) { msg.textContent = 'Укажите имя.'; msg.classList.add('is-err'); return; }
    if (digits.length < 10) { msg.textContent = 'Введите корректный номер телефона.'; msg.classList.add('is-err'); return; }
    if (!form.agree.checked) { msg.textContent = 'Подтвердите согласие на обработку данных.'; msg.classList.add('is-err'); return; }
    // TODO: отправить данные на сервер, например fetch('/api/lead', {method:'POST', body:new FormData(form)})
    msg.textContent = 'Спасибо, ' + name + '! Мы скоро свяжемся с вами.';
    msg.classList.add('is-ok');
    form.reset();
  });

  $('#year').textContent = new Date().getFullYear();
})();
