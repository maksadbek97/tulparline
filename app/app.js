/* Tulpar Line — прототип приложения водителя (ТЗ v2.0). Все данные демонстрационные. */
(function () {
  'use strict';

  // ---------- i18n (прототип: переведены основные подписи, остальное — на русском) ----------
  var KK = {
    'Главная': 'Басты бет', 'Финансы': 'Қаржы', 'Сервис': 'Сервис', 'Профиль': 'Профиль',
    'Баланс': 'Баланс', 'Пополнить': 'Толықтыру', 'Вывести': 'Шығару', '+ Добавить расход': '+ Шығын қосу',
    'За день': 'Күнге', 'Доходы за день': 'Күндік табыс', 'Расходы за день': 'Күндік шығын',
    'Чистый результат за день': 'Күндік таза нәтиже', 'Личная цель на сегодня': 'Бүгінгі жеке мақсат',
    'Документы': 'Құжаттар', 'Цели': 'Мақсаттар', 'Задания': 'Тапсырмалар', 'Рейтинг': 'Рейтинг',
    'График': 'Кесте', 'Автомобиль': 'Көлік', 'Депозит-карта Tulpar Line': 'Tulpar Line депозит-картасы',
    'Пригласи друга': 'Досыңды шақыр', 'Здоровье': 'Денсаулық', 'SOS': 'SOS', 'Поддержка': 'Қолдау',
    'Последние операции': 'Соңғы операциялар', 'Добавить расход': 'Шығын қосу', 'Соревнование': 'Жарыс', 'Настройки': 'Баптаулар', 'Язык': 'Тіл'
  };
  function t(s) { return S.lang === 'kk' && KK[s] ? KK[s] : s; }

  // ---------- helpers ----------
  var $ = function (s, r) { return (r || document).querySelector(s); };
  var NF = new Intl.NumberFormat('ru-RU');
  function money(n) { return (n < 0 ? '−' : '') + NF.format(Math.abs(n)).replace(/ | /g, ' ') + ' ₸'; }
  function esc(s) { return String(s).replace(/[&<>"]/g, function (c) { return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]; }); }
  function pad(n) { return (n < 10 ? '0' : '') + n; }
  var MONTHS = ['января', 'февраля', 'марта', 'апреля', 'мая', 'июня', 'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря'];
  function dmy(d) { return d.getDate() + ' ' + MONTHS[d.getMonth()]; }
  function save(k, v) { try { localStorage.setItem(k, JSON.stringify(v)); } catch (e) {} }
  function load(k, d) { try { var v = localStorage.getItem(k); return v === null ? d : JSON.parse(v); } catch (e) { return d; } }
  function at(dayOffset, h, m) { var d = new Date(); d.setDate(d.getDate() + dayOffset); d.setHours(h, m, 0, 0); return d.getTime(); }
  function qrSvg(text) {
    var q = qrcode(0, 'M'); q.addData(text); q.make();
    var n = q.getModuleCount(), p = '', r, c;
    for (r = 0; r < n; r++) for (c = 0; c < n; c++) if (q.isDark(r, c)) p += 'M' + c + ' ' + r + 'h1v1h-1z';
    return '<svg viewBox="-2 -2 ' + (n + 4) + ' ' + (n + 4) + '" shape-rendering="crispEdges" role="img" aria-label="QR-код"><rect x="-2" y="-2" width="' + (n + 4) + '" height="' + (n + 4) + '" fill="#fff"/><path d="' + p + '" fill="#0b0b0f"/></svg>';
  }
  var uid = 1000;
  function nidn() { return '#' + (1670300 + (++uid)); }
  function nid(p) { return p + '-' + (++uid); }
  var ICONS = {
    home: '<path d="M3 11l9-8 9 8v9a1 1 0 0 1-1 1h-5v-6H9v6H4a1 1 0 0 1-1-1z"/>',
    wallet: '<rect x="3" y="6" width="18" height="14" rx="3"/><path d="M3 10h18M16 15h2"/>',
    grid: '<circle cx="6" cy="6" r="1.3"/><circle cx="12" cy="6" r="1.3"/><circle cx="18" cy="6" r="1.3"/><circle cx="6" cy="12" r="1.3"/><circle cx="12" cy="12" r="1.3"/><circle cx="18" cy="12" r="1.3"/><circle cx="6" cy="18" r="1.3"/><circle cx="12" cy="18" r="1.3"/><circle cx="18" cy="18" r="1.3"/>',
    user: '<circle cx="12" cy="8" r="4"/><path d="M4 21c1-4 4-6 8-6s7 2 8 6"/>',
    bell: '<path d="M6 17v-6a6 6 0 0 1 12 0v6l2 2H4z"/><path d="M10 21h4"/>',
    car: '<path d="M4 17v-5l2.2-5.2A1 1 0 0 1 7.100 6h9.800a1 1 0 0 1 .9.6L20 12v5"/><rect x="3" y="12" width="18" height="5" rx="1.500"/><circle cx="7.500" cy="14.500" r=".8"/><circle cx="16.500" cy="14.500" r=".8"/><path d="M6 17v2.500M18 17v2.500"/>',
    clock: '<circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/>',
    card: '<rect x="3" y="6" width="18" height="13" rx="3"/><path d="M3 10.500h18M7 15h3"/>',
    fuel: '<rect x="5" y="3" width="9" height="18" rx="2"/><path d="M5 10h9M14 8h2.500a1.500 1.500 0 0 1 1.500 1.500V16a1.500 1.500 0 0 0 3 0V9l-3-3"/>',
    wrench: '<path d="M15 3a5 5 0 0 0-4.500 7l-7 7a2.100 2.100 0 0 0 3 3l7-7A5 5 0 0 0 21 8.500l-3 3-3-1-1-3z"/>',
    down: '<path d="M12 4v14M6 12l6 6 6-6"/>',
    up: '<path d="M7 17L17 7M8 7h9v9"/>',
    plus: '<path d="M12 5v14M5 12h14"/>',
    gift: '<rect x="3" y="8" width="18" height="4" rx="1"/><path d="M12 8v13M5 12v8h14v-8M12 8C10 4 6 4 7 7s5 1 5 1zm0 0c2-4 6-4 5-1s-5 1-5 1z"/>',
    doc: '<path d="M7 3h7l4 4v14H7z"/><path d="M14 3v4h4M10 12h5M10 16h5"/>',
    target: '<circle cx="12" cy="12" r="9"/><circle cx="12" cy="12" r="5"/><circle cx="12" cy="12" r="1.200"/>',
    clip: '<rect x="5" y="4" width="14" height="17" rx="2"/><path d="M9 4h6v3H9zM9 14l2 2 4-4"/>',
    trophy: '<path d="M8 4h8v5a4 4 0 0 1-8 0zM8 6H4v1a4 4 0 0 0 4 4M16 6h4v1a4 4 0 0 1-4 4M12 13v4M8 21h8M9 17h6"/>',
    chart: '<path d="M5 20v-8M12 20V5M19 20v-11"/>',
    cal: '<rect x="4" y="5" width="16" height="16" rx="3"/><path d="M4 10h16M9 3v4M15 3v4"/>',
    heart: '<path d="M12 20S4 15 4 9a4.500 4.500 0 0 1 8-2.500A4.500 4.500 0 0 1 20 9c0 6-8 11-8 11z"/>',
    sos: '<rect x="3" y="6" width="18" height="12" rx="3"/><text x="12" y="14.800" font-size="7" font-weight="800" text-anchor="middle" fill="currentColor" stroke="none">SOS</text>',
    headset: '<path d="M4 14v-2a8 8 0 0 1 16 0v2"/><rect x="3" y="14" width="4" height="6" rx="2"/><rect x="17" y="14" width="4" height="6" rx="2"/><path d="M19 20c0 1-2 2-5 2"/>',
    userplus: '<circle cx="10" cy="8" r="4"/><path d="M3 21c1-4 4-6 7-6M18 14v6M15 17h6"/>',
    gear: '<circle cx="12" cy="12" r="3"/><path d="M12 2.500v3M12 18.500v3M2.500 12h3M18.500 12h3M5.300 5.300l2.100 2.100M16.600 16.600l2.100 2.100M18.700 5.300l-2.100 2.100M7.400 16.600l-2.100 2.100"/>',
    lock: '<rect x="5" y="11" width="14" height="10" rx="2"/><path d="M8 11V8a4 4 0 0 1 8 0v3"/>',
    globe: '<circle cx="12" cy="12" r="9"/><path d="M3 12h18M12 3c3.500 3 3.500 15 0 18M12 3c-3.500 3-3.500 15 0 18"/>',
    help: '<circle cx="12" cy="12" r="9"/><path d="M9.500 9.500a2.500 2.500 0 1 1 3.500 2.300c-.7.400-1 1-1 1.700M12 17h.01"/>',
    logout: '<path d="M10 4H6a2 2 0 0 0-2 2v12a2 2 0 0 0 2 2h4M15 8l4 4-4 4M19 12H9"/>',
    chev: '<path d="M9 6l6 6-6 6"/>',
    chevl: '<path d="M15 6l-6 6 6 6"/>',
    chevd: '<path d="M6 9l6 6 6-6"/>',
    eye: '<path d="M2 12s4-7 10-7 10 7 10 7-4 7-10 7S2 12 2 12z"/><circle cx="12" cy="12" r="3"/>',
    eyeoff: '<path d="M2 12s4-7 10-7 10 7 10 7-4 7-10 7S2 12 2 12z"/><circle cx="12" cy="12" r="3"/><path d="M4 4l16 16"/>',
    more: '<circle cx="5" cy="12" r="1.800"/><circle cx="12" cy="12" r="1.800"/><circle cx="19" cy="12" r="1.800"/>',
    trend: '<path d="M7 17L17 7M8 7h9v9"/>',
    tenge: '<path d="M6 6h12M12 6v13M8 10.500h8"/>',
    sun: '<circle cx="12" cy="12" r="4"/><path d="M12 2.500v2.500M12 19v2.500M2.500 12H5M19 12h2.500M5.200 5.200l1.800 1.800M17 17l1.800 1.800M18.800 5.200L17 7M7 17l-1.800 1.800"/>',
    moon: '<path d="M20 14.500A8 8 0 0 1 9.500 4a8 8 0 1 0 10.500 10.500z"/>',
    qr: '<rect x="4" y="4" width="6" height="6" rx="1"/><rect x="14" y="4" width="6" height="6" rx="1"/><rect x="4" y="14" width="6" height="6" rx="1"/><path d="M14 14h3v3M20 14v.01M14 20h.01M17 20h3v-3"/>',
    edit: '<path d="M4 20h4L19 9l-4-4L4 16z"/><path d="M13.5 6.5l4 4"/>',
    coins: '<circle cx="12" cy="12" r="9"/><path d="M8.500 8.500h7M12 8.500v7M9.500 11.500h5"/>'
  };
  function ic(name, cls) { return '<svg class="i ' + (cls || '') + '" viewBox="0 0 24 24" aria-hidden="true">' + ICONS[name] + '</svg>'; }
  var I = ic;
  function logoMark() { return '<svg viewBox="0 0 40 40" aria-hidden="true"><circle cx="20" cy="20" r="20" fill="#fff"/><path d="M20 8l11 24-11-6-11 6z" fill="#0b0b0f" stroke="#0b0b0f" stroke-linejoin="round" stroke-width="2"/></svg>'; }
  function logo() { return '<div class="logo">' + logoMark() + '<div>TULPAR LINE<small>ТАКСОПАРК</small></div></div>'; }
  function carArt(src) { return '<img class="carimg" src="assets/' + (src || 'car-rear.jpg') + '" alt="">'; }
  function avatarSvg() { return '<img src="assets/avatars/a' + S.avatar + '.jpg" alt="Аватар">'; }

  // ---------- state (деньги — целые тенге, без float) ----------
  var now = new Date();
  var firstOfNext = new Date(now.getFullYear(), now.getMonth() + (now.getDate() === 1 ? 0 : 1), 1);
  var S = {
    avatar: 1, lang: 'ru', tab: 'home', route: 'home', hist: [],
    driver: { first: 'Данияр', last: 'Сейтказин', status: 'Активен', car: { make: 'Toyota', model: 'Camry', year: 2021, plate: '777 TLP 02', color: 'Белый', cls: 'Комфорт' } },
    demo: { windowOpen: false, synced: true },
    privacyShowName: true,
    goalType: 'orders', workTab: 'hours', hideBal: false,
    goalTargets: { orders: 25, minutes: 600, earn: 50000 },
    orders: 20, minutes: 400,
    inc: [2400, 3600, 4200, 2800, 1800, 0, 2600, 3100, 2400, 3500, 2900, 3800, 3200, 2100], // часы 6..19
    period: 'day',
    balance: 54300, reserved: 0,
    deposit: { balance: 18640, month: 7200, reserved: 0 },
    expenses: [
      { id: 'EXP-1', amount: 4500, cat: 'Заправка на АЗС', hour: 8, when: '08:10', status: 'ok' },
      { id: 'EXP-2', amount: 1700, cat: 'Обед', hour: 13, when: '13:05', status: 'ok' }
    ],
    ops: [
      { id: '#1670301', acct: 'ya', type: 'Выплата', desc: 'Вывод на ****0716', ts: at(0, 15, 30), amount: -5000, status: 'В обработке', src: 'Выплата' },
      { id: '#1670255', acct: 'ya', type: 'Выплата', desc: 'Вывод на ****0716', ts: at(0, 2, 52), amount: -3229, status: 'Выполнена', src: 'Выплата' },
      { id: '#1669844', acct: 'ya', type: 'Выплата', desc: 'Вывод на ****0716', ts: at(-1, 22, 19), amount: -21614, status: 'Выполнена', src: 'Выплата' },
      { id: '#1669790', acct: 'ya', type: 'Пополнение', desc: 'Пополнение через Kaspi', ts: at(-1, 20, 19), amount: 800, status: 'Отклонена', src: 'Kaspi' },
      { id: '#1669721', acct: 'ya', type: 'Пополнение', desc: 'Пополнение через Kaspi QR', ts: at(-1, 18, 5), amount: 3500, status: 'Выполнена', src: 'Kaspi QR' },
      { id: '#1669402', acct: 'ya', type: 'Пополнение', desc: 'Пополнение через Kaspi', ts: at(-1, 11, 0), amount: 10000, status: 'Выполнена', src: 'Kaspi' },
      { id: '#1668310', acct: 'ya', type: 'Выплата', desc: 'Вывод на ****0716', ts: at(-4, 10, 20), amount: -25000, status: 'Выполнена', src: 'Выплата' },
      { id: 'DEP-3012', acct: 'dep', type: 'Начисление', desc: 'Ежедневный кэшбэк', ts: at(-1, 23, 59), amount: 480, status: 'Начислено', src: 'Лояльность' },
      { id: 'DEP-3005', acct: 'dep', type: 'Начисление', desc: 'Ежедневный кэшбэк', ts: at(-2, 23, 59), amount: 450, status: 'Начислено', src: 'Лояльность' },
      { id: 'DEP-3001', acct: 'dep', type: 'Начисление', desc: 'Ежедневный кэшбэк', ts: at(-3, 23, 59), amount: 524, status: 'Ожидает проверки', src: 'Лояльность' },
      { id: 'DEP-2990', acct: 'dep', type: 'Корректировка', desc: 'Корректировка администратора', ts: at(-4, 12, 0), amount: 200, status: 'Начислено', src: 'Администратор' },
      { id: '#1660012', acct: 'dep', type: 'Выплата', desc: 'Вывод на ****0716', ts: at(-20, 10, 5), amount: -6800, status: 'Выполнена', src: 'Выплата' }
    ],
    cards: [{ id: 'C1', bank: 'Kaspi', last4: '0716', main: true }, { id: 'C2', bank: 'Halyk', last4: '4821', main: false }],
    histTab: 'all', histMode: 'ops', acct: 'ya', qr: null, kp: null,
    dep: [
      { id: 'DEP-3012', type: 'Ежедневный кэшбэк', period: 'Вчера', orders: 27, base: 120000, rate: '0,4%', amount: 480, status: 'Начислено', src: 'Правило v1', comment: '' },
      { id: 'DEP-3005', type: 'Ежедневный кэшбэк', period: '10 окт', orders: 26, base: 112500, rate: '0,4%', amount: 450, status: 'Начислено', src: 'Правило v1', comment: '' },
      { id: 'DEP-3001', type: 'Ежедневный кэшбэк', period: '9 окт', orders: 28, base: 131000, rate: '0,4%', amount: 524, status: 'Ожидает проверки', src: 'Правило v1', comment: 'Синхронизация заказов за день неполная' },
      { id: 'DEP-2990', type: 'Корректировка', period: '8 окт', orders: null, base: null, rate: null, amount: 200, status: 'Начислено', src: 'Администратор', comment: 'Компенсация за сбой синхронизации' }
    ],
    payouts: [],
    goals: [
      { id: 'G1', type: 'orders', period: 'День', target: 25, on: true },
      { id: 'G2', type: 'minutes', period: 'Неделя', target: 3000, on: true },
      { id: 'G3', type: 'earn', period: 'Месяц', target: 900000, on: false }
    ],
    tasks: [
      { id: 'T1', title: '30 заказов за день', desc: 'Выполните 30 заказов за календарный день', period: 'Сегодня', cur: 20, max: 30, reward: 1000, status: 'В процессе' },
      { id: 'T2', title: '10 часов на линии', desc: 'Проведите на линии 10 часов за день', period: 'Сегодня', cur: 400, max: 600, unit: 'min', reward: 700, status: 'В процессе' },
      { id: 'T3', title: '50 заказов за неделю', desc: 'Выполните 50 заказов за неделю', period: 'Неделя', cur: 50, max: 50, reward: 2500, status: 'Ожидает проверки' }
    ],
    notifs: [
      { t: 'Окно вывода откроется 1-го числа', txt: 'С 1 числа месяца можно подать заявку на вывод бонусов с депозит-карты. Следующее окно — ' + dmy(firstOfNext) + '.', ts: at(-5, 12, 0), k: 'withdraw', go: 'deposit', unread: false },
      { t: 'Срок страховки истекает', txt: 'ОСАГО действует до 04.11.2026. Продлите заранее, чтобы не потерять доступ к линии.', ts: at(-3, 9, 0), k: 'doc', go: 'car', unread: false },
      { t: 'Начислен кэшбэк 480 ₸', txt: 'За вчерашний день: 27 заказов, ставка 0,4%. Сумма зачислена на депозит-карту Tulpar Line.', ts: at(-1, 23, 59), k: 'bonus', go: 'deposit', unread: true },
      { t: 'Вывод выполнен', txt: 'Заявка #1669844 на 21 614 ₸ выполнена. Деньги отправлены на карту ****0716.', ts: at(-1, 22, 20), k: 'withdraw', go: 'finance', unread: false },
      { t: 'Вы поднялись на 2 места', txt: 'Теперь вы на 10-м месте из 100 водителей. Так держать!', ts: at(0, 15, 10), k: 'rating', go: 'rating', unread: false },
      { t: 'До цели осталось 5 заказов', txt: 'Вы выполнили 20 из 25 заказов. Ещё 5 — и цель на сегодня достигнута.', ts: at(0, 17, 30), k: 'goal', go: 'goals', unread: true }
    ],
    notifSettings: { shift: true, goal: true, rating: true, bonus: true, withdraw: true, doc: true, club: true },
    sched: [
      { d: 'Пн', on: true, from: '08:00', to: '18:00' }, { d: 'Вт', on: true, from: '08:00', to: '18:00' },
      { d: 'Ср', on: true, from: '08:00', to: '18:00' }, { d: 'Чт', on: true, from: '08:00', to: '18:00' },
      { d: 'Пт', on: true, from: '08:00', to: '18:00' }, { d: 'Сб', on: true, from: '10:00', to: '16:00' },
      { d: 'Вс', on: false, from: '', to: '' }
    ],
    docs: [
      { n: 'Водительское удостоверение', issued: '14.03.2019', until: '14.03.2029', check: 'Проверен', exp: 'Действителен', c: '' },
      { n: 'Удостоверение личности', issued: '02.07.2021', until: '02.07.2031', check: 'Проверен', exp: 'Действителен', c: '' },
      { n: 'Страховой полис (ОСАГО)', issued: '04.11.2025', until: '04.11.2026', check: 'Проверен', exp: 'Истекает через 21 день', c: 'Продлите заранее' },
      { n: 'Техосмотр', issued: '10.04.2026', until: '10.04.2027', check: 'На проверке', exp: 'Действителен', c: '' },
      { n: 'Лицензия на перевозки', issued: '20.01.2026', until: '20.01.2027', check: 'Проверен', exp: 'Действителен', c: '' }
    ],
    invited: [
      { n: 'Ержан А.', st: 'Выполнил 12 из 25 заказов', bonus: 0 },
      { n: 'Мадина К.', st: 'Условие выполнено', bonus: 'ожидает утверждения суммы' }
    ],
    health: { consent: false },
    sos: { contact: 'Айгерим (жена) +7 700 000-00-00', log: [] },
    tickets: [{ id: 'SUP-114', topic: 'Вопрос по начислению', st: 'В работе', d: '12 окт' }, { id: 'SUP-102', topic: 'Документы', st: 'Решено', d: '3 окт' }],
    me: 10,
    car: {
      odo: 84300, tech: '2027-04-10', ins: '2026-11-04',
      services: [
        { id: 'S3', what: 'Замена масла и фильтров', date: '2026-09-12', km: 80100, next: 90100 },
        { id: 'S2', what: 'Замена тормозных колодок', date: '2026-06-03', km: 72400, next: 102400 },
        { id: 'S1', what: 'Сезонная замена шин', date: '2026-04-20', km: 68200, next: null }
      ]
    }
  };
  S.theme = load('tl_theme', 'light'); document.documentElement.setAttribute('data-theme', S.theme);
  S.avatar = load('tl_avatar', 1); S.car = load('tl_car', S.car);
  var rivals = ['Руслан Т.', 'Нурлан Б.', 'Айдос М.', 'Серик О.', 'Данияр С.', 'Талгат Е.', 'Бауыржан К.', 'Алмас Ж.', 'Ерлан Н.', 'Тимур Д.', 'Асхат Р.', 'Марат В.'];

  // ---------- derived ----------
  function incomeToday() { return S.inc.reduce(function (a, b) { return a + b; }, 0); }
  function expToday() { return S.expenses.reduce(function (a, e) { return a + (e.status === 'ok' ? e.amount : 0); }, 0); }
  function available() { return S.balance - S.reserved; }
  function depAvailable() { return S.deposit.balance - S.deposit.reserved; }
  function pseudo(i, base, spread) { return base + ((i * 7919 + 13) % spread); }
  function series() {
    var d = S.period, inc = [], exp = [], labels = [], i;
    if (d === 'day') {
      for (i = 0; i < S.inc.length; i++) { inc.push(S.inc[i]); labels.push(String(6 + i)); exp.push(0); }
      S.expenses.forEach(function (e) { if (e.status === 'ok' && e.hour >= 6 && e.hour < 6 + S.inc.length) exp[e.hour - 6] += e.amount; else if (e.status === 'ok' && e.hour >= 6 + S.inc.length) { while (inc.length <= e.hour - 6) { inc.push(0); exp.push(0); labels.push(String(6 + inc.length - 1)); } exp[e.hour - 6] += e.amount; } });
    } else if (d === 'week') {
      ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'].forEach(function (l, k) { labels.push(l); if (k < 2) { inc.push(pseudo(k, 36000, 9000)); exp.push(pseudo(k, 5000, 3000)); } else if (k === 2) { inc.push(incomeToday()); exp.push(expToday()); } else { inc.push(0); exp.push(0); } });
    } else {
      var n = d === 'month' ? 30 : 14;
      for (i = 0; i < n; i++) { labels.push(i % 5 === 0 ? String(i + 1) : ''); if (i === n - 1) { inc.push(incomeToday()); exp.push(expToday()); } else { inc.push(pseudo(i, 30000, 14000)); exp.push(pseudo(i, 4000, 4500)); } }
    }
    return { inc: inc, exp: exp, labels: labels };
  }
  var PERIOD_LABEL = { day: 'За день', week: 'За неделю', month: 'За месяц', range: 'За период' };

  // ---------- UI primitives ----------
  var screen = $('#screen'), tabbar = $('#tabbar'), sheetWrap = $('#sheetWrap'), sheet = $('#sheet'), toastEl = $('#toast');
  var toastT;
  function toast(m) { toastEl.textContent = m; toastEl.classList.add('on'); clearTimeout(toastT); toastT = setTimeout(function () { toastEl.classList.remove('on'); }, 2600); }
  function openSheet(html) { sheet.innerHTML = html; sheetWrap.hidden = false; sheet.scrollTop = 0; }
  function closeSheet() { sheetWrap.hidden = true; sheet.innerHTML = ''; }
  function chip(txt, kind) { return '<span class="chip chip--' + (kind || '') + '">' + esc(txt) + '</span>'; }
  function statusChip(s) {
    var k = /Начислено|Выполнена|Проверен|Действителен|Решено|Закрыто|выполнено/i.test(s) ? 'ok' : /проверки|обработ|Создана|Новое|В работе|Ожидает|Истекает/i.test(s) ? 'warn' : /Отклонена|Отменён/i.test(s) ? 'err' : 'info';
    return chip(s, k);
  }
  function sw(id, on) { return '<span class="sw"><input type="checkbox" data-sw="' + id + '"' + (on ? ' checked' : '') + '><i></i></span>'; }
  function nav(title, cls) { return '<div class="nav"><button class="navback" data-act="back" aria-label="Назад">' + I('chevl') + '</button><div class="navt ' + (cls || '') + '">' + title + '</div><div class="navr"></div></div>'; }
  function hhmm(ts) { var d = new Date(ts); return pad(d.getHours()) + ':' + pad(d.getMinutes()); }
  function back(label) { return '<button class="back" data-act="back">‹ ' + esc(label || 'Назад') + '</button>'; }
  function syncBanner() { return S.demo.synced ? '' : '<div class="banner">Данные не синхронизированы с Yandex. Показаны последние известные значения (обновлено в 14:20).</div>'; }

  // ---------- routing ----------
  var TOP = { home: 'home', finance: 'finance', service: 'service', profile: 'profile' };
  var PARENT = { documents: 'service', goals: 'service', tasks: 'service', schedule: 'service', car: 'service', deposit: 'service', referral: 'service', health: 'service', sos: 'service', support: 'service', rating: null, notifications: null, settings: 'profile', demo: 'profile', terms: 'profile' };
  function go(r, noPush) {
    if (!noPush) S.hist.push(S.route);
    S.route = r;
    if (TOP[r]) S.tab = r; else if (PARENT[r]) S.tab = PARENT[r];
    render(); screen.scrollTop = r === 'notifications' ? screen.scrollHeight : 0;
  }
  function goBack() { var p = S.hist.pop(); S.route = p || S.tab; render(); }

  function render() {
    var fn = V[S.route] || V.home;
    screen.innerHTML = fn();
    var pg = $('#pager'); if (pg && S.acct === 'dep') pg.scrollLeft = pg.firstElementChild.offsetWidth + 10;
    var tabs = [['home', 'Главная', 'home'], ['finance', 'Финансы', 'wallet'], ['service', 'Сервис', 'grid'], ['profile', 'Профиль', 'user']];
    tabbar.innerHTML = tabs.map(function (x) { return '<button class="tab' + (S.tab === x[0] ? ' on' : '') + '" data-act="tab" data-v="' + x[0] + '">' + ic(x[2]) + '<span>' + t(x[1]) + '</span></button>'; }).join('');
  }

  // ---------- views ----------
  function topBar() {
    var unread = S.notifs.some(function (n) { return n.unread; });
    return '<div class="top"><div class="avatar">' + S.driver.first[0] + S.driver.last[0] + '</div><div class="grow"><b>' + esc(S.driver.first + ' ' + S.driver.last) + '</b><div class="small mut">' + esc(S.driver.car.make + ' ' + S.driver.car.model) + ' · ' + esc(S.driver.car.plate) + '</div></div>' +
      '<button class="iconbtn" data-act="go" data-v="notifications" aria-label="Уведомления">' + ic('bell') + (unread ? '<span class="dot"></span>' : '') + '</button></div>';
  }
  function goalInfo() {
    var g = S.goalType, tg = S.goalTargets[g], cur, main, hint;
    if (g === 'orders') { cur = S.orders; main = cur + ' из ' + tg + ' заказов'; hint = cur >= tg ? 'Цель выполнена — отличная работа!' : 'Осталось ' + (tg - cur) + ' ' + (tg - cur === 1 ? 'заказ' : (tg - cur < 5 ? 'заказа' : 'заказов')) + ' — вы почти у цели'; }
    else if (g === 'minutes') { cur = S.minutes; main = 'Работали ' + Math.floor(cur / 60) + ' ч ' + pad(cur % 60) + ' мин из ' + Math.floor(tg / 60) + ' ч'; hint = cur >= tg ? 'Цель выполнена!' : 'Осталось ' + Math.floor((tg - cur) / 60) + ' ч ' + pad((tg - cur) % 60) + ' мин'; }
    else { cur = incomeToday(); main = 'Заработано ' + money(cur) + ' из ' + money(tg); hint = cur >= tg ? 'Цель выполнена!' : 'Осталось ' + money(tg - cur); }
    return { cur: cur, tg: tg, main: main, hint: hint, pct: Math.min(100, Math.round(cur * 100 / tg)) };
  }
  function cashbackStatus() {
    var left = 25 - S.orders;
    return left > 0 ? 'До кэшбэка осталось ' + left + ' ' + (left === 1 ? 'заказ' : (left < 5 ? 'заказа' : 'заказов')) : 'Условие выполнено';
  }
  function nextWindow() { return S.demo.windowOpen ? 'Сегодня (демо)' : dmy(firstOfNext); }

  var V = {};
  function opTime(o) { var d = new Date(o.ts); return pad(d.getDate()) + '.' + pad(d.getMonth() + 1) + '.' + String(d.getFullYear()).slice(2) + ' ' + pad(d.getHours()) + ':' + pad(d.getMinutes()); }
  function dayLabel(ts) {
    var d = new Date(ts), t0 = new Date(); t0.setHours(0, 0, 0, 0);
    var diff = Math.round((t0 - new Date(d.getFullYear(), d.getMonth(), d.getDate())) / 86400000);
    return diff === 0 ? 'Сегодня' : diff === 1 ? 'Вчера' : dmy(d);
  }
  function opRow(o) {
    var pos = o.amount > 0, x = opIcon(o), cx = o.status === 'Отменён' || o.status === 'Отклонена' ? 'strike' : '';
    var right = o.status === 'Выполнена' || o.status === 'Начислено' ? '<div class="small mut">' + esc(/^#/.test(o.id) ? o.id : '') + '</div>' : statusChip(o.status);
    return '<button class="li" data-act="opDetail" data-v="' + esc(o.id) + '"><span class="ic' + (x[1] ? ' ic--' + x[1] : '') + '">' + I(x[0]) + '</span><span class="grow"><b class="' + cx + '">' + esc(o.desc) + '</b><div class="small mut">' + opTime(o) + '</div></span><span style="text-align:right"><div class="amt ' + (pos ? 'pos' : '') + ' ' + cx + '">' + (pos ? '+' : '−') + money(Math.abs(o.amount)).replace(/^−/, '') + '</div>' + right + '</span></button>';
  }
  function opIcon(o) {
    var d = o.desc || '';
    if (o.type === 'Пополнение') return ['down', 'g'];
    if (o.type === 'Выплата') return ['up', 'b'];
    if (o.type === 'Начисление') return ['gift', 'y'];
    if (o.type === 'Корректировка') return ['doc', 'v'];
    return /Топл|Заправ|бензин|АЗС/i.test(d) ? ['fuel', ''] : /Ремонт|Масл|Шин|Мойк|мойк/i.test(d) ? ['wrench', ''] : ['doc', ''];
  }
  function fmtAmt(v) { return v ? NF.format(+v).replace(/ | /g, ' ') : '0'; }
  function dotsHtml() { return '<i class="' + (S.acct === 'ya' ? 'on' : '') + '"></i><i class="' + (S.acct === 'dep' ? 'on' : '') + '"></i>'; }
  function historyHtml() {
    var mode = '<div class="seg"><button class="' + (S.histMode === 'ops' ? 'on' : '') + '" data-act="histMode" data-v="ops">Транзакции</button><button class="' + (S.histMode === 'exp' ? 'on' : '') + '" data-act="histMode" data-v="exp">Мои расходы</button></div>';
    if (S.histMode === 'exp') {
      var ex = S.expenses.slice().reverse().map(function (e) {
        var x = opIcon({ type: 'Расход', desc: e.cat }), cx = e.status === 'ok' ? '' : 'strike';
        return '<button class="li" data-act="expOpen" data-v="' + e.id + '"><span class="ic">' + I(x[0]) + '</span><span class="grow"><b class="' + cx + '">' + esc(e.cat) + '</b><div class="small mut">Сегодня, ' + e.when + '</div></span><span style="text-align:right"><div class="amt ' + cx + '">−' + money(e.amount).replace(/^−/, '') + '</div>' + (e.status === 'ok' ? '' : chip('Отменён', 'err')) + '</span></button>';
      }).join('');
      return mode + (ex ? '<div class="dayh">Сегодня</div><div class="list">' + ex + '</div>' : '<div class="small mut" style="padding:14px 0">Расходов пока нет.</div>');
    }
    var isYa = S.acct === 'ya';
    var labels = isYa ? [['all', 'Все'], ['in', 'Пополнение'], ['out', 'Вывод']] : [['all', 'Все'], ['in', 'Начисления'], ['out', 'Вывод']];
    var list = S.ops.filter(function (o) { return o.acct === S.acct && (S.histTab === 'all' || (S.histTab === 'in' ? o.amount > 0 : o.amount < 0)); }).sort(function (a, b) { return b.ts - a.ts; });
    var out = '', last = '';
    list.forEach(function (o) { var g = dayLabel(o.ts); if (g !== last) { out += '<div class="dayh">' + g + '</div>'; last = g; } out += opRow(o); });
    return mode + '<div class="hhead"><b>' + (isYa ? 'Яндекс Про' : 'Депозит-карта Tulpar Line') + '</b>' + (isYa ? '<button class="lnk" data-act="cardsOpen">Мои карты ›</button>' : '') + '</div>' +
      '<div class="hfilter">' + labels.map(function (x) { return '<button class="' + (S.histTab === x[0] ? 'on' : '') + '" data-act="histTab" data-v="' + x[0] + '">' + x[1] + '</button>'; }).join('') + '</div>' +
      (out ? '<div class="list">' + out + '</div>' : '<div class="small mut" style="padding:14px 0">Транзакций нет.</div>');
  }
  function cardYa() {
    var amountTxt = S.hideBal ? '••••• ₸' : money(available());
    return '<div class="cardx cardx--ya"><div class="cx-top"><span class="cx-name cx-name--ya"><i class="yadot"></i>Яндекс Про</span><button class="cx-i" data-act="balInfo" aria-label="О балансе">i</button></div>' +
      '<div class="cx-panel"><div class="row between"><small>Доступный баланс</small><button class="eye" data-act="hideBal" aria-label="Скрыть сумму">' + I(S.hideBal ? 'eyeoff' : 'eye') + '</button></div><b class="cx-amt">' + amountTxt + '</b>' + (S.reserved ? '<small class="cx-res">В резерве под заявки: ' + money(S.reserved) + '</small>' : '') + '</div>' +
      '<div class="cx-btns"><button class="cx-btn" data-act="topup">' + I('plus') + 'Пополнить</button><button class="cx-btn" data-act="withdraw">' + I('up') + 'Вывести</button><button class="cx-btn" data-act="qrMenu">' + I('qr') + 'Kaspi QR</button></div></div>';
  }
  function cardDep() {
    return '<div class="cardx cardx--dep"><div class="cx-top"><span class="cx-name">' + logoMark() + 'Tulpar Line</span>' + chip('Депозит-карта', 'info') + '</div>' +
      '<div class="cx-panel"><small>Бонусный баланс от таксопарка</small><b class="cx-amt">' + money(S.deposit.balance) + '</b><small class="cx-res">За месяц: +' + money(S.deposit.month) + ' · окно вывода: ' + nextWindow() + '</small></div>' +
      '<div class="cx-btns cx-btns--2"><button class="cx-btn" data-act="depWithdraw">' + I('up') + 'Вывести</button><button class="cx-btn" data-act="go" data-v="deposit">' + I('gift') + 'Подробнее</button></div></div>';
  }
  function kpOpen(cfg) {
    S.kp = { val: '', cfg: cfg };
    var chips = (cfg.chips || []).map(function (c) { return '<button type="button" class="kchip" data-act="kpChip" data-v="' + c + '">' + (c === -1 ? 'Всё' : fmtAmt(c)) + '</button>'; }).join('');
    var sel = cfg.select ? '<label class="f ksel">' + cfg.select.label + '<select id="kpSel">' + cfg.select.options.map(function (o) { return '<option>' + esc(o) + '</option>'; }).join('') + '</select></label>' : '';
    var keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '000', '0', 'back'].map(function (k) { return '<button type="button" class="key" data-act="kpKey" data-v="' + k + '">' + (k === 'back' ? '⌫' : k) + '</button>'; }).join('');
    openSheet('<div class="kptitle">' + cfg.title + '</div>' + (cfg.sub ? '<div class="small mut" style="text-align:center">' + cfg.sub + '</div>' : '') + '<div class="kpamt"><small>Введите сумму</small><b id="kpAmt">0 ₸</b></div><p class="err" id="fe" style="text-align:center"></p><div class="kchips">' + chips + '</div>' + sel + '<button type="button" class="btn" data-act="kpGo">' + (cfg.cta || 'Продолжить') + '</button><div class="keys">' + keys + '</div>');
  }
  function qrShow(a) {
    S.qr = { amount: a, id: nidn() };
    openSheet('<h3>Покажите QR пассажиру</h3><div class="qrbox">' + qrSvg('TULPAR-DEMO|PAY|' + S.qr.id + '|' + a) + '</div><div class="mid" style="text-align:center">' + money(a) + '</div><div style="text-align:center;margin:6px 0 10px">' + chip('Ожидает оплаты', 'warn') + '</div><button class="btn" data-act="qrPaid">Имитировать оплату (демо)</button><button class="btn btn--ghost" style="margin-top:8px" data-act="closeSheet">Отменить</button><div class="banner banner--info" style="margin-top:12px">Демо: настоящий платёж подтверждает Kaspi. Кнопка выше имитирует подтверждение.</div>');
  }
  function workChart() {
    var hrs = [], i, k, bars = '', peakHour = -1, mx = 1, vals = {};
    for (i = 6; i <= 22; i++) hrs.push(i);
    hrs.forEach(function (h) {
      var inc = S.inc[h - 6], v = 0;
      if (inc !== undefined) v = S.workTab === 'income' ? inc : S.workTab === 'orders' ? Math.round(inc / 1900) : (inc > 0 ? 60 : 0);
      vals[h] = v; if (v > mx) { mx = v; peakHour = h; }
    });
    var tip = S.workTab === 'income' ? 'Лучший час' : S.workTab === 'orders' ? 'Больше всего заказов' : 'Максимум';
    var shape = [.62, 1, .78], off = [18, 30, 22, 36, 26, 14, 32, 20, 28];
    hrs.forEach(function (h, n) {
      for (k = 0; k < 3; k++) {
        var v = vals[h], cls, ht;
        if (v > 0) { cls = 'act'; ht = Math.max(14, Math.round(v * 100 / mx * shape[k])); }
        else { cls = h > 19 ? 'fut' : ''; ht = off[(n * 3 + k) % off.length]; }
        var pk = (h === peakHour && k === 1 && S.workTab !== 'hours') ? ' peak' : '';
        bars += '<i class="' + cls + pk + '" style="height:' + ht + '%" data-tip="' + tip + '"></i>';
      }
    });
    var ax = ''; for (i = 6; i <= 22; i += 2) ax += '<span>' + pad(i) + ':00</span>';
    return '<div class="wd">' + bars + '</div><div class="wx">' + ax + '</div>';
  }
  V.home = function () {
    var g = goalInfo(), hr = new Date().getHours();
    var greet = hr < 5 ? 'Доброй ночи' : hr < 12 ? 'Доброе утро' : hr < 18 ? 'Добрый день' : 'Добрый вечер';
    var unread = S.notifs.some(function (n) { return n.unread; });
    var inc = incomeToday(), prev = 34300, dl = Math.round((inc - prev) * 100 / prev);
    var goalBody = S.goalType === 'orders'
      ? '<div class="goalnum">' + g.cur + ' / ' + g.tg + '<small>заказов</small></div><div class="segbar">' + Array.apply(null, Array(g.tg)).map(function (_, k) { return '<i class="' + (k < g.cur ? 'on' : '') + '"></i>'; }).join('') + '</div>'
      : '<div class="mid" style="margin:4px 0">' + esc(g.main) + '</div><div class="bar" style="margin:8px 0">' + '<i style="width:' + g.pct + '%"></i></div>';
    var pos = Math.round((100 - S.me) * 100 / 99);
    return '<div class="hello"><div class="avatar">' + avatarSvg() + '</div><div class="grow"><h2>' + greet + ',<br>' + esc(S.driver.first) + '!</h2><p>Хорошего рабочего дня!</p></div><button class="iconbtn" data-act="go" data-v="notifications" aria-label="Уведомления">' + I('bell') + (unread ? '<span class="dot"></span>' : '') + '</button></div>' + syncBanner() +
      '<div class="card card--dark hero">' + carArt('car-rear.jpg') + '<button class="link" data-act="tab" data-v="finance">Сегодня ' + I('chev') + '</button><div class="big">' + money(inc) + '</div><div class="lab">Доход</div>' +
      '<div class="delta"><span class="ic">' + I('trend') + '</span><div><b>' + (dl >= 0 ? '+' : '') + dl + '%</b><small>к вчера</small></div></div>' +
      '<div class="minis"><div class="mini">' + I('car') + '<div><b>' + S.orders + '</b><small>заказов</small></div></div><div class="mini">' + I('clock') + '<div><b>' + Math.floor(S.minutes / 60) + 'ч ' + pad(S.minutes % 60) + 'м</b><small>на линии</small></div></div><div class="mini">' + I('card') + '<div><b>' + NF.format(expToday()).replace(/ | /g, ' ') + ' ₸</b><small>расходы</small></div></div></div></div>' +
      '<div class="card"><div class="goalhead"><span class="ic ic--d">' + I('target') + '</span><b>' + t('Личная цель на сегодня') + '</b><button class="btn btn--sm" data-act="goalPick" aria-label="Изменить цель">›</button></div><div class="goalrow"><div class="grow">' + goalBody + '<div class="small mut">' + esc(g.hint) + '</div></div><div class="ring" style="--p:' + g.pct + '"><b>' + g.pct + '%</b></div></div></div>' +
      '<div class="two"><button class="card" data-act="go" data-v="rating"><div class="mc"><span class="ic ic--y">' + I('trophy') + '</span><b>Соревнование</b>' + I('chev') + '</div><div class="small mut">Ваше место среди 100 водителей</div><div class="rankbig">#' + S.me + '<span class="pos-up">↗ +2</span></div><div class="track"><i style="width:' + pos + '%"></i><u style="left:' + pos + '%">' + I('car') + '</u></div><div class="row between small mut"><span>#100</span><span>#1</span></div></button>' +
      '<button class="card dep" data-act="go" data-v="deposit"><div class="mc"><span class="ic ic--b">' + I('gift') + '</span><b>Депозит-карта</b>' + I('chev') + '</div><div class="small mut">Накоплено</div><div class="dsum">' + money(S.deposit.balance) + '</div><div style="margin:8px 0 6px">' + statusChip(cashbackStatus()) + '</div><div class="small mut">Окно вывода: ' + nextWindow() + '</div></button></div>' +
      '<div class="card"><div class="cardhead"><div class="row"><span class="ic ic--b" style="width:34px;height:34px;border-radius:11px">' + I('chart') + '</span><h3>Ваш рабочий день</h3></div><div class="tabsm">' + [['hours', 'По часам'], ['orders', 'По заказам'], ['income', 'По доходу']].map(function (x) { return '<button class="' + (S.workTab === x[0] ? 'on' : '') + '" data-act="workTab" data-v="' + x[0] + '">' + x[1] + '</button>'; }).join('') + '</div></div>' + workChart() +
      '<div class="hint">' + I('clock') + '<div class="grow"><b>Сейчас хороший момент работать</b><small>Демо-подсказка: ожидается высокий спрос до 19:00</small></div>' + I('chev', 'chv') + '</div></div>';
  };

  function chartHtml() {
    var s = series(), mx = 1, d = S.period === 'day';
    s.inc.forEach(function (v, i) { mx = Math.max(mx, v, s.exp[i]); });
    var steps = [1000, 2000, 5000, 10000, 20000, 25000, 50000, 100000], st = 100000, k;
    for (k = 0; k < steps.length; k++) { if (mx / steps[k] <= 3) { st = steps[k]; break; } }
    var top = st * Math.ceil(mx / st), n = top / st, grid = '', j;
    for (j = 0; j <= n; j++) grid += '<div class="g" style="bottom:' + (j * 100 / n) + '%"><span>' + (j * st === 0 ? '0' : (j * st >= 1000 ? (j * st / 1000) + 'K' : j * st)) + '</span></div>';
    var cols = s.inc.map(function (v, i) { return '<div class="col"><i class="inc" style="height:' + Math.round(v * 100 / top) + '%"></i><i class="exp" style="height:' + Math.round(s.exp[i] * 100 / top) + '%"></i></div>'; }).join('');
    var ax = s.labels.map(function (l, i) { return '<span>' + (d ? (i % 3 === 0 ? pad(+l) + ':00' : '') : l) + '</span>'; }).join('');
    return '<div class="fc" role="img" aria-label="График доходов и расходов">' + grid + '<div class="bars">' + cols + '</div></div><div class="fx">' + ax + '</div>';
  }
  function totals() {
    if (S.period === 'day') return { i: incomeToday(), e: expToday() };
    var s = series(), a = 0, b = 0; s.inc.forEach(function (v) { a += v; }); s.exp.forEach(function (v) { b += v; }); return { i: a, e: b };
  }
  V.finance = function () {
    var tt = totals(), pl = S.period === 'day' ? 'за день' : PERIOD_LABEL[S.period].toLowerCase(), net = tt.i - tt.e;
    return '<div class="head"><div><h2>' + t('Финансы') + '</h2><small><b>TULPAR LINE</b>Таксопарк</small></div><button class="pill" data-act="periodPick">' + I('cal') + '<span>' + (S.period === 'day' ? t('За день') : PERIOD_LABEL[S.period]) + '</span>' + I('chevd') + '</button></div>' + syncBanner() +
      '<div class="pager" id="pager">' + cardYa() + cardDep() + '</div><div class="dots" id="dots">' + dotsHtml() + '</div>' +
      '<div class="stats"><div class="stat stat--g"><div class="row"><span class="ic">' + I('trend') + '</span></div><b class="t">Доходы</b><div class="v">' + money(tt.i) + '</div><small>' + pl + '</small></div>' +
      '<div class="stat stat--r"><div class="row"><span class="ic"><svg class="i" viewBox="0 0 24 24"><path d="M7 7l10 10M17 8v9H8"/></svg></span></div><b class="t">Расходы</b><div class="v">' + money(tt.e) + '</div><small>' + pl + '</small></div>' +
      '<div class="stat stat--v"><div class="row"><span class="ic">' + I('chart') + '</span></div><b class="t">Чистый результат</b><div class="v">' + money(net) + '</div><small>' + pl + '</small></div></div>' +
      '<button class="addbtn" data-act="addExpense"><u>' + I('plus') + '</u>' + t('Добавить расход') + I('chev', 'chv') + '</button>' +
      '<div class="card hist" id="hist">' + historyHtml() + '</div>';
  };

  V.service = function () {
    var c = S.driver.car;
    var items = [['documents', 'doc', 'Документы', 'Все файлы', 'b'], ['goals', 'target', 'Цели', 'День и неделя', 'g'], ['tasks', 'clip', 'Задания', 'Награды', 'v'],
      ['rating', 'trophy', 'Рейтинг', 'Ваше место', 'y'], ['schedule', 'cal', 'График', 'Расписание', 'b'], ['car', 'car', 'Автомобиль', 'Обслуживание', 'r'],
      ['deposit', 'tenge', 'Депозит-карта Tulpar Line', 'Бонусы', 'd'], ['referral', 'userplus', 'Пригласи друга', 'Бонусы за друга', 'y'], ['health', 'heart', 'Здоровье', 'Активность', 'r'],
      ['sos', 'sos', 'SOS', 'Экстренно', 'd'], ['support', 'headset', 'Поддержка', '24/7', 'v']];
    return '<div class="head"><div><h2>' + t('Сервис') + '</h2><small><b>TULPAR LINE</b>Таксопарк</small></div><button class="iconbtn" data-act="go" data-v="notifications" aria-label="Уведомления">' + I('bell') + (S.notifs.some(function (n) { return n.unread; }) ? '<span class="dot"></span>' : '') + '</button></div>' +
      '<div class="card card--dark carcard"><div class="glow">' + logoMark() + '</div>' + carArt('car-front.jpg') + '<span class="chevbtn">' + I('chev') + '</span>' + logo() + '<div class="carname">' + esc(c.make + ' ' + c.model) + '</div><div class="carsub">' + c.year + ' • ' + esc(c.cls) + '</div><div class="plate">' + esc(c.plate) + '<small><i></i>KZ</small></div></div>' +
      '<div class="grid3">' + items.map(function (x) { return '<button class="tile" data-act="go" data-v="' + x[0] + '"><span class="top"><span class="ic ic--' + x[4] + '">' + I(x[1]) + '</span>' + I('chev', 'chv') + '</span><b>' + esc(t(x[2])) + '</b><small>' + x[3] + '</small></button>'; }).join('') + '</div>';
  };

  V.profile = function () {
    var rows = [['settings', 'user', 'Личные данные', 'ФИО, телефон, дата рождения'], ['car', 'car', 'Мой автомобиль', 'Информация о машине'], ['documents', 'doc', 'Документы', 'Водительские права, техпаспорт, страховка'],
      ['payMethods', 'wallet', 'Способы выплат', 'Kaspi, реквизиты'], ['settings', 'bell', 'Уведомления', 'Настройки уведомлений'], ['security', 'lock', 'Безопасность', 'Смена пароля, Face ID / Touch ID'],
      ['langSheet', 'globe', t('Язык'), 'Қазақша / Русский'], ['terms', 'gift', 'Условия лояльности', 'Кэшбэк, вывод, правила'], ['support', 'help', 'Помощь', 'Частые вопросы'], ['demo', 'gear', 'Демо-инструменты', 'Только для показа прототипа']];
    return '<div class="head"><div><h2>' + t('Профиль') + '</h2><small><b>TULPAR LINE</b>Таксопарк</small></div><button class="iconbtn themebtn" data-act="themeToggle" aria-label="Сменить тему">' + I(S.theme === 'dark' ? 'moon' : 'sun') + '</button></div>' +
      '<div class="prof"><button class="avatar avatar--lg avbtn" data-act="avatarPick" aria-label="Сменить аватар">' + avatarSvg() + '<span class="avedit">' + I('edit') + '</span></button><div class="grow"><div class="nm">' + esc(S.driver.first) + '<br>' + esc(S.driver.last) + '</div><div class="mut">Водитель</div></div>' +
      '<button class="bonus" data-act="go" data-v="deposit"><span class="ic ic--b">' + I('tenge') + '</span><span><small>Бонусы</small><b>' + NF.format(S.deposit.balance).replace(/ | /g, ' ') + ' ₸</b></span>' + I('chev', 'chv') + '</button></div>' +
      rows.map(function (r) { var act = ['payMethods', 'security', 'langSheet'].indexOf(r[0]) >= 0 ? r[0] : 'go'; return '<button class="row-card" data-act="' + act + '" data-v="' + r[0] + '"><span class="ic">' + I(r[1]) + '</span><span class="grow"><b>' + r[2] + '</b><small>' + r[3] + '</small></span>' + I('chev', 'chv') + '</button>'; }).join('') +
      '<button class="row-card" data-act="logout"><span class="ic">' + I('logout') + '</span><span class="grow"><b>Выйти из аккаунта</b></span>' + I('chev', 'chv') + '</button>';
  };

  V.settings = function () {
    var ns = S.notifSettings;
    var rows = [['shift', 'Начало смены'], ['goal', 'Прогресс цели и заданий'], ['rating', 'Изменение места в рейтинге'], ['bonus', 'Начисления кэшбэка и бонусов'], ['withdraw', 'Окно и статус вывода'], ['doc', 'Истечение документов'], ['club', 'Сообщения таксопарка']];
    return nav(t('Настройки')) +
      '<div class="card"><h3>Тема приложения</h3><div class="seg"><button class="' + (S.theme === 'light' ? 'on' : '') + '" data-act="themeSet" data-v="light">Светлая</button><button class="' + (S.theme === 'dark' ? 'on' : '') + '" data-act="themeSet" data-v="dark">Тёмная</button></div></div>' +
      '<div class="card"><h3>' + t('Язык') + '</h3><div class="seg"><button class="' + (S.lang === 'kk' ? 'on' : '') + '" data-act="lang" data-v="kk">Қазақша</button><button class="' + (S.lang === 'ru' ? 'on' : '') + '" data-act="lang" data-v="ru">Русский</button></div><div class="note">В прототипе на казахский переведены навигация и основные заголовки.</div></div>' +
      '<div class="card"><h3>Личные данные</h3><div class="small mut">Имя: ' + esc(S.driver.first + ' ' + S.driver.last) + '<br>Телефон: +7 700 ••• •• 21<br>ИИН: •••• •••• 1234</div></div>' +
      '<div class="card"><h3>Приватность</h3><div class="row between"><span>Показывать моё имя в рейтинге</span>' + sw('privacy', S.privacyShowName) + '</div><div class="note">Если выключено, в таблице вы отображаетесь как «Водитель №…».</div></div>' +
      '<div class="card"><h3>Уведомления</h3>' + rows.map(function (r) { return '<div class="row between" style="padding:8px 0"><span>' + r[1] + '</span>' + sw('n-' + r[0], ns[r[0]]) + '</div>'; }).join('') + '<div class="note">Финансовые статусы приходят независимо от настроек.</div></div>';
  };

  V.terms = function () {
    return nav('Условия лояльности') + '' + termsBlock();
  };
  function termsBlock() {
    return '<div class="card"><div class="banner">Параметры ниже — предварительные. Их утверждает владелец; в приложении они подтягиваются из админ-панели без выпуска новой версии.</div>' +
      '<ul style="padding-left:18px;margin:0;line-height:1.7"><li>Порог: <b>25 завершённых заказов</b> за календарный день.</li><li>Ставка: <b>0,4%</b> (предварительно).</li><li>Расчётная база: <b>ожидает утверждения владельцем</b> (стоимость заказов / доход таксопарка / иное).</li><li>Расчёт — после окончания дня и проверки данных.</li><li>Учитываются только завершённые и подтверждённые заказы; отменённые и дубликаты — нет.</li><li>Вывод: заявка только <b>1-го числа месяца</b>; сумма резервируется до решения.</li><li>Депозит-карта — внутренняя бонусная запись, не банковская карта.</li><li>Выплаты — по заявке после проверки; мгновенный вывод не гарантируется.</li></ul></div>';
  }

  // --- Deposit ---
  V.deposit = function () {
    var left = 25 - S.orders, st = left > 0 ? cashbackStatus() : 'Условие выполнено';
    var pend = S.payouts.filter(function (p) { return p.status === 'Создана' || p.status === 'На проверке' || p.status === 'В обработке'; });
    var cond = [['Заказов за сегодня', S.orders + ' из 25', S.orders >= 25], ['Заказы подтверждены и синхронизированы', S.demo.synced ? 'да' : 'нет', S.demo.synced], ['Расчёт после окончания дня', 'в 00:10 (предварительно)', null]];
    var hist = S.dep.map(function (d) { return '<button class="li" data-act="depDetail" data-v="' + d.id + '"><span class="ic ic--y">' + I('gift') + '</span><span class="grow"><b>' + esc(d.type) + '</b><div class="small mut">' + esc(d.period) + (d.orders ? ' · ' + d.orders + ' заказов' : '') + '</div></span><span style="text-align:right"><div class="amt ' + (d.amount > 0 ? 'pos' : '') + '">' + (d.amount > 0 ? '+' : '') + money(d.amount) + '</div>' + statusChip(d.status) + '</span></button>'; }).join('');
    var pays = S.payouts.map(function (p) { return '<div class="li"><span class="ic ic--b">' + I('up') + '</span><span class="grow"><b>Заявка ' + p.id + '</b><div class="small mut">' + esc(p.date) + '</div></span><span style="text-align:right"><div class="amt">' + money(p.amount) + '</div>' + statusChip(p.status) + '</span></div>'; }).join('');
    return nav(t('Депозит-карта Tulpar Line')) +
      '<div class="card card--dark" style="padding:20px"><div class="small" style="opacity:.8">Накопленный бонусный баланс</div><div class="big">' + money(S.deposit.balance) + '</div>' +
      '<div class="row between small" style="margin-top:10px;opacity:.9"><span>За этот месяц: <b>' + money(S.deposit.month) + '</b></span><span>В резерве: <b>' + money(S.deposit.reserved) + '</b></span></div>' +
      '<div style="margin-top:12px">' + chip(pend.length ? 'Заявка обрабатывается' : S.demo.windowOpen ? 'Вывод доступен' : 'Вывод доступен 1-го числа', 'info') + ' ' + chip('Накопление активно', 'ok') + '</div></div>' +
      '<div class="banner banner--info">Это отдельный бонусный баланс. Он не входит в основной баланс приложения и в баланс Yandex.</div>' +
      '<div class="card"><div class="row between"><b>Сегодняшнее условие</b>' + statusChip(st) + '</div><div class="bar" style="margin:10px 0"><i style="width:' + Math.min(100, Math.round(S.orders * 4)) + '%"></i></div>' +
      cond.map(function (c) { return '<div class="row between small" style="padding:4px 0"><span>' + c[0] + '</span><b>' + (c[2] === true ? '✓ ' : c[2] === false ? '✗ ' : '') + c[1] + '</b></div>'; }).join('') +
      (left <= 0 ? '<div class="note">Начисление произойдёт после окончания дня и проверки данных. Статус — «Ожидает проверки».</div>' : '') + '</div>' +
      '<div class="card"><h3>Вывод бонусного баланса</h3><div class="small mut">Следующее окно: <b>' + nextWindow() + '</b>. Доступно к заявке: <b>' + money(depAvailable()) + '</b>.</div>' +
      '<button class="btn" style="margin-top:12px" data-act="depWithdraw"' + '>Подать заявку на вывод</button>' +
      '<div class="note">' + (S.demo.windowOpen ? 'Окно открыто (демо-режим).' : 'Вне окна заявка недоступна: заявки принимаются только 1-го числа месяца.') + ' Выплаты обрабатываются вручную после проверки; срок обработки сообщит таксопарк.</div>' + (pays ? '<div class="list">' + pays + '</div>' : '') + '</div>' +
      '<div class="card"><h3>История начислений</h3><div class="list">' + hist + '</div></div>' +
      '<div class="card"><h3>Правила программы</h3>' + termsBlock().replace('<div class="card">', '<div>') + '</div>';
  };

  // --- Rating ---
  V.rating = function () {
    var rows = [], i, names = rivals.slice(), pos = 1, myName = S.privacyShowName ? S.driver.first + ' ' + S.driver.last[0] + '.' : 'Водитель №' + 4821;
    var top = [], k;
    for (k = 1; k <= 12; k++) top.push(k);
    var data = top.map(function (p) {
      var me = p === S.me, ord = 40 - p * 2 + (p > S.me ? 0 : 1) + (me ? S.orders - 20 : 0);
      return { p: p, name: me ? myName : names[(p - (p > S.me ? 2 : 1)) % names.length], orders: me ? S.orders + 0 : Math.max(1, 38 - p * 2), score: me ? S.orders * 10 + 20 : Math.max(10, 380 - p * 20), ch: me ? 2 : ((p * 3) % 5) - 2, me: me };
    });
    var body = data.map(function (r) {
      var ch = r.ch > 0 ? '<span class="up">▲' + r.ch + '</span>' : r.ch < 0 ? '<span class="down">▼' + (-r.ch) + '</span>' : '<span class="mut">—</span>';
      return '<div class="rank ' + (r.me ? 'me' : '') + '"><span>' + r.p + '</span><span>' + esc(r.name) + (r.me ? ' (вы)' : '') + '</span><span>' + r.orders + '</span><span>' + r.score + '</span><span>' + ch + '</span></div>';
    }).join('');
    return nav(t('Рейтинг')) +
      '<div class="card card--dark"><div class="small" style="opacity:.8">Ваше место · период: сегодня</div><div class="big">' + S.me + '-е из 100</div></div>' +
      '<div class="card"><div class="rank head"><span>#</span><span>Водитель</span><span>Заказы</span><span>Баллы</span><span>±</span></div>' + body + '<div class="note">Баллы рейтинга — не деньги и не Coins. Период и критерии настраиваются в админ-панели; по окончании периода результаты уходят в архив. Имена сокращены согласно настройкам приватности.</div></div>';
  };

  // --- Goals ---
  var GT = { orders: ['Заказы', ' заказов'], minutes: ['Часы на линии', ' мин'], earn: ['Заработок', ' ₸'] };
  V.goals = function () {
    var rows = S.goals.map(function (g) {
      var cur = g.type === 'orders' ? S.orders : g.type === 'minutes' ? S.minutes : incomeToday(), pct = Math.min(100, Math.round(cur * 100 / g.target));
      var tgt = g.type === 'minutes' ? Math.round(g.target / 60) + ' ч' : g.type === 'earn' ? money(g.target) : g.target;
      return '<div class="card"><div class="row between"><div><b>' + GT[g.type][0] + ' — ' + g.period.toLowerCase() + '</b><div class="small mut">Цель: ' + tgt + '</div></div>' + sw('goal-' + g.id, g.on) + '</div><div class="bar" style="margin:10px 0 6px"><i style="width:' + pct + '%"></i></div><div class="small mut">' + pct + '% выполнено' + (g.on ? '' : ' · отключена') + '</div></div>';
    }).join('');
    return nav('' + t('Цели') + '') + '<div class="note" style="margin-top:-4px">Цель — личный ориентир. Выполнение цели само по себе не даёт бонус: условия кэшбэка задаются отдельно.</div>' + rows +
      '<button class="btn" data-act="addGoal">+ Новая цель</button><div class="card" style="margin-top:12px"><h3>История</h3><div class="small mut">Вчера: 27 из 25 заказов — выполнено ✓<br>10 окт: 22 из 25 заказов — не выполнено</div></div>';
  };

  // --- Tasks ---
  V.tasks = function () {
    return nav(t('Задания')) + S.tasks.map(function (k) {
      var pct = Math.min(100, Math.round(k.cur * 100 / k.max)), cur = k.unit === 'min' ? Math.floor(k.cur / 60) + ' ч' : k.cur, mx = k.unit === 'min' ? Math.floor(k.max / 60) + ' ч' : k.max;
      return '<div class="card"><div class="row between"><b>' + esc(k.title) + '</b>' + statusChip(k.status) + '</div><div class="small mut" style="margin:4px 0 10px">' + esc(k.desc) + ' · ' + esc(k.period) + '</div><div class="bar"><i style="width:' + pct + '%"></i></div><div class="row between small" style="margin-top:8px"><span>' + cur + ' из ' + mx + '</span><b>Награда: ' + money(k.reward) + '</b></div></div>';
    }).join('') + '<div class="note">Денежная награда начисляется на депозит-карту отдельной операцией после проверки. Совместимость с кэшбэком настраивает администратор.</div>';
  };

  // --- Schedule ---
  V.schedule = function () {
    return nav('' + t('График') + '') + '<div class="card">' + S.sched.map(function (d, i) {
      return '<div class="sched"><b>' + d.d + '</b><div>' + (d.on ? d.from + ' – ' + d.to : '<span class="mut">Выходной</span>') + (i === 2 && d.on ? '<div class="small mut">Факт сегодня: на линии с 08:12 (6 ч 40 мин)</div>' : '') + '</div><span class="row">' + (d.on ? '<button class="btn btn--ghost btn--sm" data-act="editDay" data-v="' + i + '">Изм.</button>' : '') + sw('day-' + i, d.on) + '</span></div>';
    }).join('') + '</div><div class="card"><div class="row between"><span>Напоминание о начале смены</span>' + sw('n-shift', S.notifSettings.shift) + '</div><div class="note">Повторяющееся расписание. Для исключений (разовый выходной) используйте «Изм.» на нужном дне.</div></div>';
  };

  // --- Car & docs ---
  function fmtDate(iso) { if (!iso) return '—'; var p = iso.split('-'); return p[2] + '.' + p[1] + '.' + p[0]; }
  function daysLeft(iso) { return Math.ceil((new Date(iso + 'T00:00:00') - new Date(new Date().toDateString())) / 86400000); }
  function dueChip(iso) {
    var d = daysLeft(iso);
    return d < 0 ? chip('Просрочено', 'err') : d <= 30 ? chip('Осталось ' + d + ' дн.', 'warn') : chip('Действует', 'ok');
  }
  function svcStatus(x) {
    if (!x.next) return null;
    var left = x.next - S.car.odo;
    return left <= 0 ? { t: 'Пора: пробег ' + NF.format(S.car.odo).replace(/\u00a0|\u202f/g, ' ') + ' км', k: 'err' } : left <= 1000 ? { t: 'Скоро: осталось ' + NF.format(left).replace(/\u00a0|\u202f/g, ' ') + ' км', k: 'warn' } : { t: 'Осталось ' + NF.format(left).replace(/\u00a0|\u202f/g, ' ') + ' км', k: 'ok' };
  }
  function km(n) { return NF.format(n).replace(/\u00a0|\u202f/g, ' ') + ' км'; }
  V.car = function () {
    var c = S.driver.car, cr = S.car;
    var svc = cr.services.map(function (x) {
      var st = svcStatus(x);
      return '<button class="li" data-act="svcOpen" data-v="' + x.id + '"><span class="ic ic--b">' + I('wrench') + '</span><span class="grow"><b>' + esc(x.what) + '</b><div class="small mut">' + fmtDate(x.date) + ' · ' + km(x.km) + (x.next ? ' · следующий раз на ' + km(x.next) : '') + '</div>' + (st ? '<div style="margin-top:4px">' + chip(st.t, st.k) + '</div>' : '') + '</span>' + I('chev', 'chv') + '</button>';
    }).join('');
    return nav(t('Автомобиль')) +
      '<div class="card carmini"><img class="carthumb" src="assets/car-front.jpg" alt=""><div class="grow"><b class="mid">' + esc(c.make + ' ' + c.model) + '</b><div class="small mut">' + c.year + ' · ' + esc(c.color) + ' · ' + esc(c.cls) + '</div><div class="plate plate--sm">' + esc(c.plate) + '</div></div></div>' +
      '<button class="card odo" data-act="odoEdit"><span class="ic ic--v">' + I('clock') + '</span><span class="grow"><small class="mut">Пробег сейчас</small><b class="mid">' + km(cr.odo) + '</b></span><span class="mut small">Изменить</span></button>' +
      '<div class="card"><h3>Документы</h3><button class="li" data-act="dateEdit" data-v="tech"><span class="ic ic--g">' + I('doc') + '</span><span class="grow"><b>Техосмотр</b><div class="small mut">до ' + fmtDate(cr.tech) + '</div></span>' + dueChip(cr.tech) + '</button><button class="li" data-act="dateEdit" data-v="ins"><span class="ic ic--y">' + I('lock') + '</span><span class="grow"><b>Страховка</b><div class="small mut">до ' + fmtDate(cr.ins) + '</div></span>' + dueChip(cr.ins) + '</button></div>' +
      '<div class="card"><div class="cardhead"><h3>Обслуживание</h3><button class="lnk" data-act="svcAdd">+ Добавить</button></div>' + (svc ? '<div class="list">' + svc + '</div>' : '<div class="small mut">Записей пока нет. Добавьте, когда меняли масло, колодки или шины.</div>') + '<div class="note">Укажите пробег при замене и на сколько км вперёд — приложение напомнит, когда пора.</div></div>';
  };
  V.documents = function () {
    return nav(t('Документы')) + S.docs.map(function (d) {
      return '<div class="card"><div class="row between"><b>' + esc(d.n) + '</b>' + statusChip(d.check) + '</div><div class="small mut" style="margin:6px 0">Выдан: ' + d.issued + ' · Действует до: ' + d.until + '</div>' + statusChip(d.exp) + (d.c ? '<div class="note">' + esc(d.c) + '</div>' : '') + '</div>';
    }).join('') + '<div class="note">Доступ к персональным данным ограничен ролями сотрудников таксопарка.</div>';
  };

  // --- Referral ---
  V.referral = function () {
    return nav(t('Пригласи друга')) +
      '<div class="card card--dark"><div class="small" style="opacity:.8">Ваша ссылка</div><div class="mid" style="word-break:break-all;margin:6px 0 14px">[APP_DOMAIN]/r/TLP7K2</div><div class="grid2"><button class="btn" data-act="copyRef">Копировать</button><button class="btn btn--light" data-act="shareRef">Поделиться</button></div><div class="small" style="opacity:.7;margin-top:10px">Домен утверждает владелец. Условия и суммы бонусов задаёт администратор.</div></div>' +
      '<div class="card"><h3>Приглашённые</h3>' + S.invited.map(function (p) { return '<div class="li row between"><div><b>' + esc(p.n) + '</b><div class="small mut">' + esc(p.st) + '</div></div>' + (p.bonus ? chip('Бонус: ' + p.bonus, 'warn') : chip('В процессе', 'info')) + '</div>'; }).join('') + '</div>' +
      '<div class="note">Бонус начисляется на депозит-карту только после выполнения условий активации и проверки (защита от самоприглашений и дублей).</div>';
  };

  // --- Health ---
  V.health = function () {
    return nav('' + t('Здоровье') + '') + '<div class="card"><div class="row between"><div class="grow"><b>Доступ к данным здоровья</b><div class="small mut">Apple HealthKit / Google Health Connect. Только с вашего согласия, отзывается в любой момент.</div></div>' + sw('health', S.health.consent) + '</div></div>' +
      (S.health.consent ? '<div class="grid3"><div class="card" style="text-align:center"><div class="mid">6 840</div><div class="small mut">шагов</div></div><div class="card" style="text-align:center"><div class="mid">4,9</div><div class="small mut">км</div></div><div class="card" style="text-align:center"><div class="mid">38</div><div class="small mut">мин актив.</div></div></div><div class="note">Демо-значения. Приложение не даёт медицинских заключений.</div>' : '<div class="banner banner--info">Подключение выключено — данные не запрашиваются.</div>');
  };

  // --- SOS ---
  V.sos = function () {
    return nav('SOS') + '<div class="card" style="text-align:center"><div class="small mut">В экстренной ситуации нажмите и подтвердите</div><button class="sos" data-act="sosPress">SOS</button><div class="small mut">Контакт: ' + esc(S.sos.contact) + '</div><button class="btn btn--ghost btn--sm" style="margin-top:10px" data-act="sosContact">Изменить контакт</button></div>' +
      '<div class="card"><h3>Журнал событий</h3>' + (S.sos.log.length ? S.sos.log.map(function (l) { return '<div class="li row between"><span>' + l.d + '</span>' + chip(l.s, 'warn') + '</div>'; }).join('') : '<div class="small mut">Событий пока нет.</div>') + '</div><div class="note">Приложение не утверждает, что сообщение доставлено, пока доставка не подтверждена. При угрозе жизни звоните 112.</div>';
  };

  // --- Support ---
  V.support = function () {
    return nav('' + t('Поддержка') + '') + '<div class="card"><div class="grid2"><a class="btn btn--sm" style="text-align:center;text-decoration:none" href="tel:+70000000000">📞 Позвонить</a><button class="btn btn--sm btn--dark" data-act="ticket">Обращение</button></div><div class="note">Контакты: +7 (000) 000-00-00, поддержка 24/7 (демо).</div></div>' +
      '<div class="card"><h3>Мои обращения</h3>' + S.tickets.map(function (x) { return '<div class="li row between"><div><b>' + esc(x.topic) + '</b><div class="small mut">' + x.id + ' · ' + x.d + '</div></div>' + statusChip(x.st) + '</div>'; }).join('') + '</div>' +
      '<div class="card"><h3>FAQ</h3>' + [['Когда начисляется кэшбэк?', 'После окончания дня и проверки данных, если выполнен порог заказов.'], ['Когда можно вывести бонусы?', 'Заявку можно подать 1-го числа месяца. Срок выплаты сообщит таксопарк.'], ['Чем депозит-карта отличается от баланса?', 'Это отдельный бонусный баланс таксопарка, а не банковская карта и не баланс Yandex.']].map(function (q) { return '<details class="faq"><summary>' + q[0] + '</summary><p>' + q[1] + '</p></details>'; }).join('') + '</div>';
  };

  // --- Notifications ---
  V.notifications = function () {
    S.notifs.forEach(function (n) { n.unread = false; });
    var list = S.notifs.slice().sort(function (a, b) { return a.ts - b.ts; }), out = '', last = '';
    list.forEach(function (n) {
      var g = dayLabel(n.ts);
      if (g !== last) { out += '<div class="daysep"><span>' + g + '</span></div>'; last = g; }
      out += '<div class="msgrow"><span class="msgav">' + logoMark() + '</span><div class="msg"><b>' + esc(n.t) + '</b><p>' + esc(n.txt) + '</p>' + (n.go ? '<button class="msgact" data-act="go" data-v="' + n.go + '">Открыть ' + I('chev') + '</button>' : '') + '<time>' + hhmm(n.ts) + '</time></div></div>';
    });
    return nav('<span class="navav">' + logoMark() + '</span><span class="navtx"><b>Таксопарк Tulpar Line</b><small>уведомления</small></span>', 'navt--chat') +
      '<div class="chat">' + out + '</div><div class="composer"><button data-act="go" data-v="support">' + I('headset') + 'Написать в поддержку…</button></div>';
  };

  // --- Demo tools ---
  V.demo = function () {
    return nav('Демо-инструменты') + '<div class="banner banner--info">Только для демонстрации прототипа. В реальном приложении этих экранов нет.</div>' +
      '<div class="card"><div class="row between"><div class="grow"><b>Имитировать 1-е число</b><div class="small mut">Открывает окно вывода с депозит-карты</div></div>' + sw('d-window', S.demo.windowOpen) + '</div></div>' +
      '<div class="card"><div class="row between"><div class="grow"><b>Данные Yandex синхронизированы</b><div class="small mut">Выключите, чтобы увидеть честное предупреждение</div></div>' + sw('d-sync', S.demo.synced) + '</div></div>' +
      '<div class="card"><b>Заказы</b><div class="small mut" style="margin:4px 0 10px">Сейчас завершено: ' + S.orders + '. Заказ обновляет цель, рейтинг, кэшбэк-статус и график.</div><div class="grid2"><button class="btn btn--sm" data-act="simOrder">+1 заказ</button><button class="btn btn--sm btn--ghost" data-act="simOrders5">+5 заказов</button></div></div>' +
      '<div class="card"><b>Заявки на вывод</b><div class="small mut" style="margin:4px 0 10px">Последняя заявка: ' + (S.payouts.length ? S.payouts[0].id + ' — ' + S.payouts[0].status : 'нет') + '</div><div class="grid2"><button class="btn btn--sm" data-act="payOk">Выполнить</button><button class="btn btn--sm btn--ghost" data-act="payReject">Отклонить</button></div></div>';
  };

  // ---------- actions ----------
  function addOp(o) { o.ts = o.ts || Date.now(); S.ops.unshift(o); }
  var ACT = {
    avatarPick: function () {
      var g = ''; for (var i = 1; i <= 10; i++) g += '<button class="avopt' + (S.avatar === i ? ' on' : '') + '" data-act="avatarSet" data-v="' + i + '" aria-label="Аватар ' + i + '"><img src="assets/avatars/a' + i + '.jpg" alt=""></button>';
      openSheet('<h3>Выберите аватар</h3><div class="avgrid">' + g + '</div><div class="note">3D-аватар виден в приложении вам и таксопарку.</div>');
    },
    avatarSet: function (v) { S.avatar = +v; save('tl_avatar', S.avatar); closeSheet(); render(); toast('Аватар изменён'); },
    odoEdit: function () {
      openSheet('<h3>Пробег сейчас</h3><form data-form="odo"><label class="f">Километров<input name="km" inputmode="numeric" value="' + S.car.odo + '"></label><p class="err" id="fe"></p><button class="btn" type="submit">Сохранить</button></form>');
    },
    dateEdit: function (v) {
      openSheet('<h3>' + (v === 'tech' ? 'Техосмотр' : 'Страховка') + '</h3><form data-form="cdate" data-k="' + v + '"><label class="f">Действует до<input type="date" name="d" value="' + S.car[v] + '"></label><p class="err" id="fe"></p><button class="btn" type="submit">Сохранить</button></form>');
    },
    svcAdd: function () {
      var today = new Date().toISOString().slice(0, 10);
      openSheet('<h3>Новая запись</h3><form data-form="svc"><label class="f">Что сделали<input name="what" maxlength="60" placeholder="Например: замена масла" autocomplete="off"></label><label class="f">Дата<input type="date" name="date" value="' + today + '"></label><label class="f">Пробег при замене, км<input name="km" inputmode="numeric" value="' + S.car.odo + '"></label><label class="f">Следующая замена на, км<input name="next" inputmode="numeric" placeholder="Например: ' + (S.car.odo + 10000) + '"></label><p class="err" id="fe"></p><button class="btn" type="submit">Сохранить</button></form>');
    },
    svcOpen: function (v) {
      var x = S.car.services.filter(function (y) { return y.id === v; })[0]; if (!x) return;
      openSheet('<h3>' + esc(x.what) + '</h3><div class="list">' + [['Дата', fmtDate(x.date)], ['Пробег при замене', km(x.km)], ['Следующий раз на', x.next ? km(x.next) : '—']].map(function (r) { return '<div class="li row between"><span class="mut">' + r[0] + '</span><b>' + r[1] + '</b></div>'; }).join('') + '</div><button class="btn btn--ghost" style="margin-top:12px" data-act="svcDel" data-v="' + x.id + '">Удалить запись</button>');
    },
    svcDel: function (v) { S.car.services = S.car.services.filter(function (y) { return y.id !== v; }); save('tl_car', S.car); closeSheet(); render(); toast('Запись удалена'); },
    histMode: function (v) { S.histMode = v; var h = $('#hist'); if (h) h.innerHTML = historyHtml(); },
    histTab: function (v) { S.histTab = v; var h = $('#hist'); if (h) h.innerHTML = historyHtml(); },
    cardsOpen: function () {
      openSheet('<h3>Мои карты</h3><div class="list">' + S.cards.map(function (c) { return '<button class="li" data-act="cardOpen" data-v="' + c.id + '"><span class="ic ic--b">' + I('card') + '</span><span class="grow"><b>' + esc(c.bank) + ' ****' + esc(c.last4) + '</b><div class="small mut">Для вывода средств</div></span>' + (c.main ? chip('Основная', 'info') : '') + I('chev', 'chv') + '</button>'; }).join('') + '</div><button class="btn btn--ghost" style="margin-top:10px" data-act="cardAdd">+ Добавить карту</button><div class="note">Хранятся только последние 4 цифры. Полный номер карты приложение не запрашивает.</div>');
    },
    qrMenu: function () {
      openSheet('<h3>Kaspi QR</h3><div class="list"><button class="li" data-act="qrPay"><span class="ic ic--r">' + I('qr') + '</span><span class="grow"><b>Принять оплату на сумму</b><div class="small mut">QR на конкретную сумму</div></span>' + I('chev', 'chv') + '</button><button class="li" data-act="qrStatic"><span class="ic ic--b">' + I('qr') + '</span><span class="grow"><b>Постоянный QR</b><div class="small mut">Пассажир вводит сумму сам</div></span>' + I('chev', 'chv') + '</button></div>');
    },
    kpKey: function (v) {
      if (!S.kp) return; var x = S.kp.val;
      if (v === 'back') x = x.slice(0, -1); else { if (!x && (v === '0' || v === '000')) return; if ((x + v).length > 7) return; x += v; }
      S.kp.val = x; $('#kpAmt').textContent = fmtAmt(x) + ' ₸'; ferr('');
    },
    kpChip: function (v) { if (!S.kp) return; var n = +v === -1 ? S.kp.cfg.all() : +v; S.kp.val = String(n); $('#kpAmt').textContent = fmtAmt(n) + ' ₸'; ferr(''); },
    kpGo: function () {
      if (!S.kp) return; var a = parseInt(S.kp.val || '0', 10), sel = $('#kpSel') ? $('#kpSel').value : '';
      if (!(a > 0)) return ferr('Введите сумму.');
      var e = S.kp.cfg.go(a, sel); if (e) ferr(e);
    },
    cardOpen: function (v) {
      var c = S.cards.filter(function (x) { return x.id === v; })[0]; if (!c) return;
      openSheet('<h3>' + esc(c.bank) + ' ****' + esc(c.last4) + '</h3><div class="note">Номер карты скрыт. Карта используется для вывода средств.</div>' + (c.main ? '' : '<button class="btn" data-act="cardMain" data-v="' + c.id + '">Сделать основной</button>') + '<button class="btn btn--ghost" style="margin-top:10px" data-act="cardDel" data-v="' + c.id + '">Удалить карту</button>');
    },
    cardMain: function (v) { S.cards.forEach(function (c) { c.main = c.id === v; }); closeSheet(); render(); toast('Основная карта изменена'); },
    cardDel: function (v) { S.cards = S.cards.filter(function (c) { return c.id !== v; }); if (S.cards.length && !S.cards.some(function (c) { return c.main; })) S.cards[0].main = true; closeSheet(); render(); toast('Карта удалена'); },
    cardAdd: function () {
      openSheet('<h3>Новая карта</h3><form data-form="card"><label class="f">Банк<select name="bank"><option>Kaspi</option><option>Halyk</option><option>Другой банк</option></select></label><label class="f">Последние 4 цифры карты<input name="last4" inputmode="numeric" maxlength="4" placeholder="0000" autocomplete="off"></label><p class="err" id="fe"></p><button class="btn" type="submit">Добавить</button></form>');
    },
    qrPay: function () {
      kpOpen({ title: 'Принять оплату · Kaspi QR', sub: 'Пассажир сканирует QR в приложении Kaspi', chips: [1000, 2000, 5000, 10000], cta: 'Показать QR',
        go: function (a) { if (a > 1000000) return 'Слишком большая сумма.'; qrShow(a); } });
    },
    qrPaid: function () {
      if (!S.qr) return; var a = S.qr.amount; S.balance += a;
      addOp({ id: nidn(), acct: 'ya', type: 'Пополнение', desc: 'Пополнение через Kaspi QR', amount: a, status: 'Выполнена', src: 'Kaspi QR' });
      S.qr = null; closeSheet(); render(); toast('Оплата получена: ' + money(a) + ' (демо)');
    },
    qrStatic: function () {
      openSheet('<h3>Постоянный QR</h3><div class="qrbox">' + qrSvg('TULPAR-DEMO|DRIVER|TLP7K2') + '</div><div class="small mut" style="text-align:center">Пассажир сканирует код и вводит сумму сам</div><div class="grid2" style="margin-top:12px"><button class="btn btn--ghost" data-act="qrSave">Сохранить</button><button class="btn" data-act="qrShare">Поделиться</button></div><div class="banner banner--info" style="margin-top:12px">Демонстрационный код: он не принимает платежи. Настоящий QR формируется официальным сервисом Kaspi после подключения.</div>');
    },
    qrSave: function () { toast('QR сохранён в Фото (демо)'); },
    qrShare: function () { toast('Откроется системное меню «Поделиться»'); },
    themeToggle: function () {
      S.theme = S.theme === 'dark' ? 'light' : 'dark'; document.documentElement.setAttribute('data-theme', S.theme); save('tl_theme', S.theme); render();
      toast(S.theme === 'dark' ? 'Тёмная тема' : 'Светлая тема');
    },
    themeSet: function (v) { S.theme = v; document.documentElement.setAttribute('data-theme', v); save('tl_theme', v); render(); },
    workTab: function (v) { S.workTab = v; render(); },
    hideBal: function () { S.hideBal = !S.hideBal; render(); },
    periodPick: function () {
      openSheet('<h3>Период</h3><div class="list">' + [['day', 'За день'], ['week', 'За неделю'], ['month', 'За месяц'], ['range', 'Произвольный период']].map(function (x) { return '<button class="li" data-act="periodSet" data-v="' + x[0] + '"><span class="grow"><b>' + x[1] + '</b></span>' + (S.period === x[0] ? chip('Выбрано', 'ok') : '') + '</button>'; }).join('') + '</div>');
    },
    periodSet: function (v) { S.period = v; closeSheet(); render(); },
    balInfo: function () { openSheet('<h3>О балансе</h3><p>Здесь показан баланс приложения Tulpar Line. Яндекс Про и бонусный баланс депозит-карты — отдельные суммы, они не складываются.</p><div class="list"><div class="li row between"><span class="mut">Баланс приложения</span><b>' + money(available()) + '</b></div><div class="li row between"><span class="mut">Баланс Yandex</span><b>не синхронизирован (демо)</b></div><div class="li row between"><span class="mut">Депозит-карта</span><b>' + money(S.deposit.balance) + '</b></div></div>'); },
    allOps: function () { openSheet('<h3>Все операции</h3><div class="list">' + S.ops.map(opRow).join('') + '</div>'); },
    expBreak: function () {
      var tot = 0, rows = S.expenses.filter(function (e) { return e.status === 'ok'; }).map(function (e) { tot += e.amount; return '<div class="li row between"><span>' + esc(e.cat) + '<div class="small mut">' + e.when + '</div></span><b>' + money(e.amount) + '</b></div>'; }).join('');
      openSheet('<h3>Расходы за день</h3><div class="list">' + (rows || '<div class="small mut" style="padding:12px 0">Расходов нет.</div>') + '<div class="li row between"><b>Итого</b><b>' + money(tot) + '</b></div></div>');
    },
    payMethods: function () { openSheet('<h3>Способы выплат</h3><div class="list"><div class="li"><span class="ic ic--b">' + I('wallet') + '</span><span class="grow"><b>Kaspi •• 4821</b><div class="small mut">Реквизиты маскированы</div></span>' + chip('Основной', 'ok') + '</div></div><div class="note">Добавление реквизитов и подтверждение — после согласования платёжного провайдера.</div>'); },
    security: function () { openSheet('<h3>Безопасность</h3><div class="row between" style="padding:10px 0"><span>Вход по Face ID / Touch ID</span>' + sw('faceid', true) + '</div><div class="row between" style="padding:10px 0"><span>Код-пароль</span>' + chip('Включён', 'ok') + '</div><button class="btn btn--ghost" style="margin-top:10px" data-act="closeSheet">Сменить пароль</button>'); },
    langSheet: function () { openSheet('<h3>' + t('Язык') + '</h3><div class="seg"><button class="' + (S.lang === 'kk' ? 'on' : '') + '" data-act="lang" data-v="kk">Қазақша</button><button class="' + (S.lang === 'ru' ? 'on' : '') + '" data-act="lang" data-v="ru">Русский</button></div><div class="note">В прототипе на казахский переведены навигация и основные заголовки.</div>'); },
    tab: function (v) { S.hist = []; go(v, true); },
    go: function (v) { go(v); },
    back: goBack,
    closeSheet: closeSheet,
    period: function (v) { S.period = v; render(); },
    lang: function (v) { S.lang = v; closeSheet(); render(); },
    goalPick: function () {
      openSheet('<h3>Основная цель на сегодня</h3><div class="list">' + [['orders', 'Завершённые заказы', 25], ['minutes', 'Часы работы', 600], ['earn', 'Сумма заработка', 50000]].map(function (g) { return '<button class="li" data-act="goalSet" data-v="' + g[0] + '"><span class="grow"><b>' + g[1] + '</b></span>' + (S.goalType === g[0] ? chip('Выбрано', 'ok') : '') + '</button>'; }).join('') + '</div>');
    },
    goalSet: function (v) { S.goalType = v; closeSheet(); render(); },
    topup: function () {
      kpOpen({ title: 'Пополнить Яндекс Про', sub: 'Текущий баланс: ' + money(available()), chips: [5000, 10000, 20000, 50000], select: { label: 'Способ', options: ['Kaspi', 'Банковская карта'] }, cta: 'Продолжить',
        go: function (a, m) {
          if (a < 500 || a > 1000000) return 'Сумма должна быть от 500 до 1 000 000 ₸.';
          var k = m.indexOf('Kaspi') === 0;
          addOp({ id: nidn(), acct: 'ya', type: 'Пополнение', desc: 'Пополнение через ' + (k ? 'Kaspi' : 'карту'), amount: a, status: 'Создана', src: k ? 'Kaspi' : 'Карта' });
          S.acct = 'ya'; closeSheet(); render(); toast('Платёж создан. Баланс обновится после подтверждения провайдером.');
        } });
    },
    withdraw: function () {
      kpOpen({ title: 'Вывести с Яндекс Про', sub: 'Доступно: ' + money(available()), chips: [5000, 10000, -1], all: function () { return available(); }, select: { label: 'Карта для вывода', options: S.cards.map(function (c) { return c.bank + ' ****' + c.last4; }).concat(S.cards.length ? [] : ['Добавьте карту в «Мои карты»']) }, cta: 'Вывести',
        all: function () { return available(); },
        go: function (a, c) {
          if (!S.cards.length) return 'Сначала добавьте карту в «Мои карты».';
          if (a < 1000) return 'Минимальная сумма — 1 000 ₸.';
          if (a > available()) return 'Сумма больше доступного остатка (' + money(available()) + ').';
          S.reserved += a; var id = nidn();
          S.payouts.unshift({ id: id, amount: a, status: 'Создана', date: 'Сегодня', kind: 'main' });
          addOp({ id: id, acct: 'ya', type: 'Выплата', desc: 'Вывод на ' + (c.split(' ')[1] || '****'), amount: -a, status: 'Создана', src: 'Выплата' });
          S.acct = 'ya'; closeSheet(); render(); toast('Заявка создана, сумма зарезервирована.');
        } });
    },
    addExpense: function () {
      openSheet('<h3>Добавить расход</h3><form data-form="expense"><label class="f">Сумма, ₸<input name="amount" inputmode="numeric" placeholder="0" autocomplete="off"></label><label class="f">На что потратили<input name="desc" maxlength="80" placeholder="Например: заправка, мойка, обед" autocomplete="off"></label><p class="err" id="fe"></p><button class="btn" type="submit">Сохранить</button></form>');
    },
    opDetail: function (v) {
      var o = S.ops.filter(function (x) { return x.id === v; })[0]; if (!o) return;
      var canCancel = /^EXP-/.test(o.ref || '') && o.status !== 'Отменён';
      openSheet('<h3>' + esc(o.desc) + '</h3><div class="list">' + [['ID', o.id], ['Тип', o.type], ['Дата', opTime(o)], ['Сумма', money(o.amount)], ['Источник', o.src]].map(function (r) { return '<div class="li row between"><span class="mut">' + r[0] + '</span><b>' + esc(r[1]) + '</b></div>'; }).join('') + '<div class="li row between"><span class="mut">Статус</span>' + statusChip(o.status) + '</div></div>' + (canCancel ? '<button class="btn btn--ghost" style="margin-top:12px" data-act="cancelExp" data-v="' + o.ref + '">Отменить расход</button><div class="note">Запись не удаляется: статус меняется, действие фиксируется в журнале аудита.</div>' : ''));
    },
    cancelExp: function (v) {
      S.expenses.forEach(function (e) { if (e.id === v) e.status = 'cancel'; });
      closeSheet(); render(); toast('Расход отменён. Запись сохранена в журнале аудита.');
    },
    expOpen: function (v) {
      var e = S.expenses.filter(function (x) { return x.id === v; })[0]; if (!e) return;
      openSheet('<h3>' + esc(e.cat) + '</h3><div class="list">' + [['Сумма', money(e.amount)], ['Время', 'Сегодня, ' + e.when]].map(function (r) { return '<div class="li row between"><span class="mut">' + r[0] + '</span><b>' + esc(r[1]) + '</b></div>'; }).join('') + '<div class="li row between"><span class="mut">Статус</span>' + (e.status === 'ok' ? chip('Учтён', 'ok') : chip('Отменён', 'err')) + '</div></div>' + (e.status === 'ok' ? '<button class="btn btn--ghost" style="margin-top:12px" data-act="cancelExp" data-v="' + e.id + '">Отменить расход</button><div class="note">Запись не удаляется: статус меняется, действие фиксируется в журнале аудита.</div>' : ''));
    },
    depDetail: function (v) {
      var d = S.dep.filter(function (x) { return x.id === v; })[0]; if (!d) return;
      openSheet('<h3>' + esc(d.type) + '</h3><div class="list">' + [['ID', d.id], ['Период', d.period], ['Заказов', d.orders == null ? '—' : d.orders], ['Расчётная база', d.base == null ? '—' : money(d.base)], ['Ставка', d.rate || '—'], ['Сумма', money(d.amount)], ['Источник / версия', d.src]].map(function (r) { return '<div class="li row between"><span class="mut">' + r[0] + '</span><b>' + esc(r[1]) + '</b></div>'; }).join('') + '<div class="li row between"><span class="mut">Статус</span>' + statusChip(d.status) + '</div></div>' + (d.comment ? '<div class="note">Комментарий: ' + esc(d.comment) + '</div>' : '') + '<div class="note">Проведённые записи не удаляются; корректировки оформляются отдельной операцией.</div>');
    },
    depWithdraw: function () {
      if (!S.demo.windowOpen) {
        openSheet('<h3>Вывод пока недоступен</h3><p>Заявки на вывод с депозит-карты принимаются только <b>1-го числа месяца</b>. Следующее окно: <b>' + dmy(firstOfNext) + '</b>.</p><p class="mut small">Накопленные средства останутся на депозит-карте и будут доступны к заявке в открытое окно.</p><button class="btn btn--dark" data-act="closeSheet">Понятно</button>'); return;
      }
      openSheet('<h3>Заявка на вывод с депозит-карты</h3><div class="small mut">Доступно: <b>' + money(depAvailable()) + '</b></div><form data-form="depwd" style="margin-top:12px"><label class="f">Сумма, ₸<input name="amount" inputmode="numeric"></label><p class="err" id="fe"></p><button class="btn" type="submit">Отправить заявку</button><div class="note">Сумма будет зарезервирована. При отказе резерв снимается. Это отдельная заявка, не связанная с выводом основного баланса.</div></form>');
    },
    addGoal: function () {
      openSheet('<h3>Новая цель</h3><form data-form="goal"><label class="f">Что считать<select name="type"><option value="orders">Число заказов</option><option value="minutes">Часы на линии</option><option value="earn">Сумма заработка</option></select></label><label class="f">Период<select name="period"><option>День</option><option>Неделя</option><option>Месяц</option></select></label><label class="f">Цель (заказы / часы / ₸)<input name="target" inputmode="numeric"></label><p class="err" id="fe"></p><button class="btn" type="submit">Создать</button></form>');
    },
    editDay: function (v) {
      var d = S.sched[v];
      openSheet('<h3>' + d.d + ': время работы</h3><form data-form="day" data-i="' + v + '"><div class="grid2"><label class="f">Начало<input type="time" name="from" value="' + d.from + '"></label><label class="f">Конец<input type="time" name="to" value="' + d.to + '"></label></div><p class="err" id="fe"></p><button class="btn" type="submit">Сохранить</button></form>');
    },
    copyRef: function () { try { navigator.clipboard.writeText('[APP_DOMAIN]/r/TLP7K2'); } catch (e) {} toast('Ссылка скопирована'); },
    shareRef: function () { toast('Откроется системное меню «Поделиться»'); },
    sosPress: function () { openSheet('<h3>Отправить сигнал SOS?</h3><p>Будет отправлено сообщение контакту «' + esc(S.sos.contact) + '» с вашей геолокацией (если разрешена).</p><div class="grid2"><button class="btn btn--ghost" data-act="closeSheet">Отмена</button><button class="btn" style="background:#e53935;color:#fff" data-act="sosSend">Отправить</button></div>'); },
    sosSend: function () { var n = new Date(); S.sos.log.unshift({ d: 'Сегодня, ' + pad(n.getHours()) + ':' + pad(n.getMinutes()), s: 'Запрос отправлен, доставка не подтверждена' }); closeSheet(); render(); toast('Запрос отправлен. Доставка пока не подтверждена.'); },
    sosContact: function () { toast('Редактирование контакта — в полной версии'); },
    ticket: function () { openSheet('<h3>Новое обращение</h3><form data-form="ticket"><label class="f">Тема<input name="topic"></label><label class="f">Сообщение<textarea name="text" rows="4"></textarea></label><label class="f">Вложение<input type="file"></label><p class="err" id="fe"></p><button class="btn" type="submit">Отправить</button></form>'); },
    logout: function () { toast('Выход (демо)'); },
    simOrder: function () { simOrders(1); },
    simOrders5: function () { simOrders(5); },
    payOk: function () { var p = S.payouts[0]; if (!p || p.status === 'Выполнена' || p.status === 'Отклонена') return toast('Нет активной заявки'); p.status = 'Выполнена'; S.ops.forEach(function (o) { if (o.id === p.id) o.status = 'Выполнена'; }); if (p.kind === 'dep') { S.deposit.balance -= p.amount; S.deposit.reserved -= p.amount; } else { S.balance -= p.amount; S.reserved -= p.amount; } render(); toast('Заявка выполнена, резерв списан'); },
    payReject: function () { var p = S.payouts[0]; if (!p || p.status === 'Выполнена' || p.status === 'Отклонена') return toast('Нет активной заявки'); p.status = 'Отклонена'; S.ops.forEach(function (o) { if (o.id === p.id) o.status = 'Отклонена'; }); if (p.kind === 'dep') S.deposit.reserved -= p.amount; else S.reserved -= p.amount; render(); toast('Заявка отклонена, резерв снят'); }
  };
  function simOrders(n) {
    if (!S.demo.synced) { toast('Нет синхронизации — заказ не учтён (демо)'); return; }
    for (var i = 0; i < n; i++) { S.orders++; S.inc[S.inc.length - 1] += 1900; }
    S.minutes += 12 * n; if (S.me > 5 && S.orders % 2 === 0) S.me--;
    render(); toast(S.orders >= 25 ? 'Условие кэшбэка выполнено — начисление после окончания дня' : 'Заказ завершён и учтён');
  }

  // ---------- forms ----------
  function parseAmount(v) { var s = String(v).replace(/\s/g, ''); if (!/^\d+$/.test(s)) return NaN; return parseInt(s, 10); }
  function ferr(m) { var e = $('#fe'); if (e) e.textContent = m; }
  var FORMS = {
    depwd: function (f) {
      var a = parseAmount(f.amount.value);
      if (!(a > 0)) return ferr('Введите сумму целым числом.');
      if (a > depAvailable()) return ferr('Сумма больше доступного остатка (' + money(depAvailable()) + ').');
      S.deposit.reserved += a;
      var did = nidn(), mc = S.cards.filter(function (c) { return c.main; })[0];
      S.payouts.unshift({ id: did, amount: a, status: 'В обработке', date: 'Сегодня', kind: 'dep' });
      addOp({ id: did, acct: 'dep', type: 'Выплата', desc: 'Вывод на ****' + (mc ? mc.last4 : '----'), amount: -a, status: 'В обработке', src: 'Выплата' });
      closeSheet(); render(); toast('Заявка отправлена. Сумма зарезервирована.');
    },
    expense: function (f) {
      var a = parseAmount(f.amount.value), d = f.desc.value.trim();
      if (!(a > 0)) return ferr('Введите сумму: целое число больше нуля.');
      if (a > 1000000) return ferr('Слишком большая сумма для одного расхода.');
      if (!d) return ferr('Напишите, на что потратили.');
      var n = new Date(), id = nid('EXP');
      S.expenses.push({ id: id, amount: a, cat: d, hour: n.getHours(), when: pad(n.getHours()) + ':' + pad(n.getMinutes()), status: 'ok' });
      S.period = 'day'; closeSheet(); render(); toast('Расход сохранён: итоги и график обновлены');
    },
    odo: function (f) {
      var k = parseAmount(f.km.value); if (isNaN(k) || k < 0 || k > 2000000) return ferr('Введите пробег числом, например 84300.');
      S.car.odo = k; save('tl_car', S.car); closeSheet(); render(); toast('Пробег обновлён');
    },
    cdate: function (f, el) {
      if (!f.d.value) return ferr('Укажите дату.');
      S.car[el.getAttribute('data-k')] = f.d.value; save('tl_car', S.car); closeSheet(); render(); toast('Сохранено');
    },
    svc: function (f) {
      var w = f.what.value.trim(), k = parseAmount(f.km.value), nx = f.next.value.trim() ? parseAmount(f.next.value) : null;
      if (!w) return ferr('Напишите, что сделали.');
      if (!f.date.value) return ferr('Укажите дату.');
      if (isNaN(k) || k < 0) return ferr('Укажите пробег числом.');
      if (nx !== null && (isNaN(nx) || nx <= k)) return ferr('Следующая замена должна быть больше текущего пробега.');
      S.car.services.unshift({ id: nid('S'), what: w, date: f.date.value, km: k, next: nx });
      if (k > S.car.odo) S.car.odo = k;
      save('tl_car', S.car); closeSheet(); render(); toast('Запись добавлена');
    },
    card: function (f) {
      var l = f.last4.value.trim(); if (!/^\d{4}$/.test(l)) return ferr('Введите ровно 4 последние цифры карты.');
      S.cards.push({ id: nid('C'), bank: f.bank.value, last4: l, main: !S.cards.length }); closeSheet(); render(); toast('Карта добавлена');
    },
    goal: function (f) {
      var a = parseAmount(f.target.value); if (!(a > 0)) return ferr('Укажите цель числом больше нуля.');
      var tg = f.type.value === 'minutes' ? a * 60 : a;
      S.goals.push({ id: nid('G'), type: f.type.value, period: f.period.value, target: tg, on: true }); closeSheet(); render(); toast('Цель создана');
    },
    day: function (f, el) {
      if (!f.from.value || !f.to.value || f.from.value >= f.to.value) return ferr('Укажите корректное время: начало раньше конца.');
      var d = S.sched[+el.getAttribute('data-i')]; d.from = f.from.value; d.to = f.to.value; closeSheet(); render(); toast('График сохранён');
    },
    ticket: function (f) {
      if (!f.topic.value.trim() || !f.text.value.trim()) return ferr('Заполните тему и сообщение.');
      S.tickets.unshift({ id: nid('SUP'), topic: f.topic.value.trim(), st: 'Новое', d: 'Сегодня' }); closeSheet(); render(); toast('Обращение отправлено');
    }
  };

  // ---------- events ----------
  document.addEventListener('click', function (e) {
    var el = e.target.closest('[data-act]'); if (!el) return;
    var fn = ACT[el.getAttribute('data-act')]; if (fn) fn(el.getAttribute('data-v'), el);
  });
  document.addEventListener('submit', function (e) {
    var f = e.target.closest('[data-form]'); if (!f) return; e.preventDefault();
    FORMS[f.getAttribute('data-form')](f, f);
  });
  document.addEventListener('change', function (e) {
    var id = e.target.getAttribute && e.target.getAttribute('data-sw'); if (!id) return; var on = e.target.checked;
    if (id === 'privacy') S.privacyShowName = on;
    else if (id === 'health') { S.health.consent = on; }
    else if (id === 'd-window') S.demo.windowOpen = on;
    else if (id === 'd-sync') S.demo.synced = on;
    else if (id.indexOf('n-') === 0) S.notifSettings[id.slice(2)] = on;
    else if (id.indexOf('goal-') === 0) S.goals.forEach(function (g) { if ('goal-' + g.id === id) g.on = on; });
    else if (id.indexOf('day-') === 0) { var d = S.sched[+id.slice(4)]; d.on = on; if (on && !d.from) { d.from = '09:00'; d.to = '17:00'; } }
    render();
  });
  screen.addEventListener('scroll', function (e) {
    var p = e.target; if (!p || p.id !== 'pager') return;
    var a = Math.round(p.scrollLeft / (p.firstElementChild.offsetWidth + 10)) ? 'dep' : 'ya';
    if (a === S.acct) return; S.acct = a; S.histTab = 'all';
    var h = $('#hist'), d = $('#dots'); if (h) h.innerHTML = historyHtml(); if (d) d.innerHTML = dotsHtml();
  }, true);
  render();
  window.__tl = { go: go, S: S };
})();
