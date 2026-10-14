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
    'Последние операции': 'Соңғы операциялар', 'Настройки': 'Баптаулар', 'Язык': 'Тіл'
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
  var uid = 1000;
  function nid(p) { return p + '-' + (++uid); }
  function ic(name) {
    var p = {
      home: '<path d="M3 11l9-8 9 8v9a1 1 0 0 1-1 1h-5v-6H9v6H4a1 1 0 0 1-1-1z"/>',
      wallet: '<rect x="3" y="6" width="18" height="14" rx="3"/><path d="M3 10h18M16 15h2"/>',
      grid: '<rect x="4" y="4" width="7" height="7" rx="2"/><rect x="13" y="4" width="7" height="7" rx="2"/><rect x="4" y="13" width="7" height="7" rx="2"/><rect x="13" y="13" width="7" height="7" rx="2"/>',
      user: '<circle cx="12" cy="8" r="4"/><path d="M4 21c1-4 4-6 8-6s7 2 8 6"/>',
      bell: '<path d="M6 17V11a6 6 0 0 1 12 0v6l2 2H4z"/><path d="M10 21h4"/>'
    };
    return '<svg viewBox="0 0 24 24" aria-hidden="true">' + p[name] + '</svg>';
  }

  // ---------- state (деньги — целые тенге, без float) ----------
  var now = new Date();
  var firstOfNext = new Date(now.getFullYear(), now.getMonth() + (now.getDate() === 1 ? 0 : 1), 1);
  var S = {
    lang: 'ru', tab: 'home', route: 'home', hist: [],
    driver: { first: 'Данияр', last: 'Сейтказин', status: 'Активен', car: { make: 'Toyota', model: 'Camry', year: 2021, plate: '777 TLP 02', color: 'Белый', cls: 'Комфорт' } },
    demo: { windowOpen: false, synced: true },
    privacyShowName: true,
    goalType: 'orders',
    goalTargets: { orders: 25, minutes: 600, earn: 50000 },
    orders: 20, minutes: 400,
    inc: [2400, 3600, 4200, 2800, 1800, 0, 2600, 3100, 2400, 3500, 2900, 3800, 3200, 2100], // часы 6..19
    period: 'day',
    balance: 54300, reserved: 0,
    deposit: { balance: 18640, month: 7200, reserved: 0 },
    expenses: [
      { id: 'EXP-1', amount: 4500, cat: 'Топливо', hour: 8, when: '08:10', comment: 'АЗС', receipt: true, status: 'ok' },
      { id: 'EXP-2', amount: 1700, cat: 'Питание', hour: 13, when: '13:05', comment: '', receipt: false, status: 'ok' }
    ],
    ops: [
      { id: 'OP-9003', ref: 'EXP-2', type: 'Расход', desc: 'Питание', date: 'Сегодня, 13:05', amount: -1700, status: 'Выполнена', src: 'Ручной ввод' },
      { id: 'OP-9002', ref: 'EXP-1', type: 'Расход', desc: 'Топливо — АЗС', date: 'Сегодня, 08:10', amount: -4500, status: 'Выполнена', src: 'Ручной ввод' },
      { id: 'OP-9001', type: 'Доход', desc: 'Заказ #48213', date: 'Сегодня, 19:12', amount: 2100, status: 'Выполнена', src: 'Yandex' },
      { id: 'OP-9000', type: 'Доход', desc: 'Заказ #48207', date: 'Сегодня, 18:40', amount: 1900, status: 'Выполнена', src: 'Yandex' },
      { id: 'OP-8995', type: 'Пополнение', desc: 'Пополнение баланса', date: 'Вчера, 21:05', amount: 10000, status: 'Выполнена', src: 'Пополнение' },
      { id: 'OP-8990', type: 'Начисление', desc: 'Ежедневный кэшбэк', date: 'Вчера, 23:59', amount: 480, status: 'Выполнена', src: 'Лояльность' },
      { id: 'OP-8981', type: 'Выплата', desc: 'Вывод на Kaspi •• 4821', date: '11 окт, 10:20', amount: -25000, status: 'Выполнена', src: 'Выплата' },
      { id: 'OP-8970', type: 'Корректировка', desc: 'Корректировка комиссии', date: '10 окт, 12:00', amount: 350, status: 'Выполнена', src: 'Корректировка' }
    ],
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
      { t: 'Начислен кэшбэк 480 ₸', d: 'Вчера, 23:59', k: 'bonus', unread: true },
      { t: 'До цели осталось 5 заказов', d: 'Сегодня, 17:30', k: 'goal', unread: true },
      { t: 'Вы поднялись на 2 места в рейтинге', d: 'Сегодня, 15:10', k: 'rating', unread: false },
      { t: 'Срок страховки истекает через 21 день', d: '12 окт', k: 'doc', unread: false },
      { t: 'Окно вывода откроется 1-го числа', d: '10 окт', k: 'withdraw', unread: false }
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
    me: 10
  };
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
  function back(label) { return '<button class="back" data-act="back">‹ ' + esc(label || 'Назад') + '</button>'; }
  function syncBanner() { return S.demo.synced ? '' : '<div class="banner">Данные не синхронизированы с Yandex. Показаны последние известные значения (обновлено в 14:20).</div>'; }

  // ---------- routing ----------
  var TOP = { home: 'home', finance: 'finance', service: 'service', profile: 'profile' };
  var PARENT = { documents: 'service', goals: 'service', tasks: 'service', schedule: 'service', car: 'service', deposit: 'service', referral: 'service', health: 'service', sos: 'service', support: 'service', rating: null, notifications: null, settings: 'profile', demo: 'profile', terms: 'profile' };
  function go(r, noPush) {
    if (!noPush) S.hist.push(S.route);
    S.route = r;
    if (TOP[r]) S.tab = r; else if (PARENT[r]) S.tab = PARENT[r];
    render(); screen.scrollTop = 0;
  }
  function goBack() { var p = S.hist.pop(); S.route = p || S.tab; render(); }

  function render() {
    var fn = V[S.route] || V.home;
    screen.innerHTML = fn();
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
  V.home = function () {
    var g = goalInfo();
    return topBar() + syncBanner() +
      '<div class="card card--dark"><div class="row between"><b>' + t('Личная цель на сегодня') + '</b><button class="btn btn--light btn--sm" data-act="goalPick">Изменить</button></div>' +
      '<div class="mid" style="margin:12px 0 10px">' + esc(g.main) + '</div><div class="bar"><i style="width:' + g.pct + '%"></i></div>' +
      '<div class="small" style="margin-top:10px;opacity:.85">' + esc(g.hint) + '</div></div>' +
      '<button class="card li" style="border:1px solid var(--line);border-radius:20px;padding:16px" data-act="go" data-v="rating"><span class="ic">🏆</span><span class="grow"><b>Соревнование</b><div class="mid">' + S.me + '-е место из 100</div><div class="small mut">Нажмите, чтобы открыть рейтинг</div></span><span class="mut">›</span></button>' +
      '<button class="card li" style="border:1px solid var(--line);border-radius:20px;padding:16px" data-act="go" data-v="deposit"><span class="ic" style="background:var(--ink);color:var(--y)">₸</span><span class="grow"><b>Депозит-карта Tulpar Line</b><div class="mid">' + money(S.deposit.balance) + '</div><div class="small mut">За месяц: ' + money(S.deposit.month) + ' · окно вывода: ' + nextWindow() + '</div></span><span class="mut">›</span></button>' +
      '<div class="card"><div class="row between"><b>Сегодня</b>' + statusChip(cashbackStatus()) + '</div><div class="grid3" style="margin-top:12px;text-align:center"><div><div class="mid">' + S.orders + '</div><div class="small mut">заказов</div></div><div><div class="mid">' + Math.floor(S.minutes / 60) + ' ч</div><div class="small mut">на линии</div></div><div><div class="mid">' + NF.format(incomeToday()).replace(/ /g, ' ') + '</div><div class="small mut">доход, ₸</div></div></div></div>';
  };

  function chartHtml() {
    var s = series(), mx = 1;
    s.inc.forEach(function (v, i) { mx = Math.max(mx, v, s.exp[i]); });
    var cols = s.inc.map(function (v, i) { return '<div class="col"><i class="inc" style="height:' + Math.round(v * 100 / mx) + '%"></i><i class="exp" style="height:' + Math.round(s.exp[i] * 100 / mx) + '%"></i></div>'; }).join('');
    var ax = s.labels.map(function (l) { return '<span>' + l + '</span>'; }).join('');
    return '<div class="chart" role="img" aria-label="График доходов и расходов">' + cols + '</div><div class="axis">' + ax + '</div><div class="legend"><span><b style="background:#111"></b>Доходы</span><span><b style="background:#FFD400"></b>Расходы</span></div>';
  }
  function totals() {
    if (S.period === 'day') return { i: incomeToday(), e: expToday() };
    var s = series(), a = 0, b = 0; s.inc.forEach(function (v) { a += v; }); s.exp.forEach(function (v) { b += v; }); return { i: a, e: b };
  }
  V.finance = function () {
    var tt = totals(), net = tt.i - tt.e, pl = S.period === 'day' ? 'за день' : PERIOD_LABEL[S.period].toLowerCase();
    var allOps = S.ops.slice();
    var ops = allOps.slice(0, 8).map(function (o) {
      var pos = o.amount > 0;
      return '<button class="li" data-act="opDetail" data-v="' + o.id + '"><span class="ic">' + ({ 'Доход': '🚕', 'Расход': '🧾', 'Пополнение': '⬇️', 'Выплата': '⬆️', 'Начисление': '🎁', 'Корректировка': '✏️' }[o.type] || '•') + '</span><span class="grow"><b class="' + (o.status === 'Отменён' ? 'strike' : '') + '">' + esc(o.desc) + '</b><div class="small mut">' + esc(o.date) + ' · ' + esc(o.src) + '</div></span><span style="text-align:right"><div class="amt ' + (pos ? 'pos' : '') + ' ' + (o.status === 'Отменён' ? 'strike' : '') + '">' + (pos ? '+' : '') + money(o.amount) + '</div>' + statusChip(o.status) + '</span></button>';
    }).join('');
    return '<h2>' + t('Финансы') + '</h2>' + syncBanner() +
      '<div class="card card--dark" style="padding:20px"><div class="small" style="opacity:.8">Tulpar Line Таксопарк</div><div class="small" style="opacity:.8;margin-top:12px">' + t('Баланс') + '</div><div class="big">' + money(available()) + '</div>' +
      (S.reserved ? '<div class="small" style="opacity:.8">В резерве под заявки: ' + money(S.reserved) + '</div>' : '') +
      '<div class="grid2" style="margin-top:16px"><button class="btn" data-act="topup">' + t('Пополнить') + '</button><button class="btn btn--light" data-act="withdraw">' + t('Вывести') + '</button></div>' +
      '<div class="small" style="opacity:.7;margin-top:12px">Баланс приложения. Баланс Yandex и депозит-карта показываются отдельно и в эту сумму не входят.</div></div>' +
      '<div class="seg" role="tablist">' + ['day', 'week', 'month', 'range'].map(function (p) { return '<button class="' + (S.period === p ? 'on' : '') + '" data-act="period" data-v="' + p + '">' + (p === 'day' ? t('За день') : p === 'week' ? 'Неделя' : p === 'month' ? 'Месяц' : 'Период') + '</button>'; }).join('') + '</div>' +
      '<div class="grid3" style="margin-bottom:12px">' +
      '<div class="card" style="margin:0;padding:12px"><div class="small mut">' + (S.period === 'day' ? t('Доходы за день') : 'Доходы ' + pl) + '</div><div class="mid" style="font-size:17px">' + money(tt.i) + '</div></div>' +
      '<div class="card" style="margin:0;padding:12px"><div class="small mut">' + (S.period === 'day' ? t('Расходы за день') : 'Расходы ' + pl) + '</div><div class="mid" style="font-size:17px">' + money(tt.e) + '</div></div>' +
      '<div class="card" style="margin:0;padding:12px;background:var(--y)"><div class="small">' + (S.period === 'day' ? t('Чистый результат за день') : 'Чистый результат ' + pl) + '</div><div class="mid" style="font-size:17px">' + money(net) + '</div></div></div>' +
      '<div class="small mut" style="margin:-4px 0 12px">Доходы − Расходы = Чистый результат</div>' +
      '<button class="btn btn--dark" style="padding:18px;font-size:17px;margin-bottom:14px" data-act="addExpense">' + t('+ Добавить расход') + '</button>' +
      '<div class="card"><h3>' + (S.period === 'day' ? 'По часам' : S.period === 'week' ? 'По дням недели' : 'По дням') + '</h3>' + chartHtml() + (S.period === 'range' ? '<div class="note">Демо: произвольный период — последние 14 дней.</div>' : '') + '</div>' +
      '<div class="card"><h3>' + t('Последние операции') + '</h3><div class="list">' + ops + '</div></div>';
  };

  V.service = function () {
    var c = S.driver.car;
    var items = [['documents', '📄', 'Документы'], ['goals', '🎯', 'Цели'], ['tasks', '✅', 'Задания'], ['rating', '🏆', 'Рейтинг'], ['schedule', '🗓', 'График'], ['car', '🚗', 'Автомобиль'], ['deposit', '₸', 'Депозит-карта Tulpar Line', 'dep'], ['referral', '🎁', 'Пригласи друга'], ['health', '❤️', 'Здоровье'], ['sos', '🆘', 'SOS', 'sos'], ['support', '💬', 'Поддержка']];
    return '<h2>' + t('Сервис') + '</h2>' +
      '<div class="card card--dark"><div class="row between"><div><div class="mid">' + esc(c.make + ' ' + c.model) + '</div><div class="small" style="opacity:.8">' + c.year + ' год · ' + esc(c.color) + ' · ' + esc(c.cls) + '</div></div><span style="font-size:38px">🚕</span></div><div style="margin-top:12px;display:inline-block;background:#fff;color:#111;border-radius:8px;padding:5px 12px;font-weight:800;letter-spacing:.08em">' + esc(c.plate) + '</div></div>' +
      '<div class="grid3">' + items.map(function (x) { return '<button class="tile ' + (x[3] ? 'tile--' + x[3] : '') + '" data-act="go" data-v="' + x[0] + '"><span class="ic">' + x[1] + '</span>' + esc(t(x[2])) + '</button>'; }).join('') + '</div>';
  };

  V.profile = function () {
    return '<h2>' + t('Профиль') + '</h2>' +
      '<div class="card"><div class="row"><div class="avatar avatar--lg">' + S.driver.first[0] + S.driver.last[0] + '</div><div class="grow"><div class="mid">' + esc(S.driver.first + ' ' + S.driver.last) + '</div>' + chip(S.driver.status, 'ok') + '<div class="small mut" style="margin-top:6px">Бонусный баланс: ' + money(S.deposit.balance) + '</div></div></div></div>' +
      '<div class="card"><div class="list">' +
      [['settings', '⚙️', t('Настройки')], ['terms', '📜', 'Условия лояльности'], ['demo', '🧪', 'Демо-инструменты']].map(function (x) { return '<button class="li" data-act="go" data-v="' + x[0] + '"><span class="ic">' + x[1] + '</span><span class="grow"><b>' + x[2] + '</b></span><span class="mut">›</span></button>'; }).join('') +
      '<button class="li" data-act="logout"><span class="ic">🚪</span><span class="grow"><b>Выйти</b></span></button></div></div>';
  };

  V.settings = function () {
    var ns = S.notifSettings;
    var rows = [['shift', 'Начало смены'], ['goal', 'Прогресс цели и заданий'], ['rating', 'Изменение места в рейтинге'], ['bonus', 'Начисления кэшбэка и бонусов'], ['withdraw', 'Окно и статус вывода'], ['doc', 'Истечение документов'], ['club', 'Сообщения таксопарка']];
    return back('Профиль') + '<h2>' + t('Настройки') + '</h2>' +
      '<div class="card"><h3>' + t('Язык') + '</h3><div class="seg"><button class="' + (S.lang === 'kk' ? 'on' : '') + '" data-act="lang" data-v="kk">Қазақша</button><button class="' + (S.lang === 'ru' ? 'on' : '') + '" data-act="lang" data-v="ru">Русский</button></div><div class="note">В прототипе на казахский переведены навигация и основные заголовки.</div></div>' +
      '<div class="card"><h3>Личные данные</h3><div class="small mut">Имя: ' + esc(S.driver.first + ' ' + S.driver.last) + '<br>Телефон: +7 700 ••• •• 21<br>ИИН: •••• •••• 1234</div></div>' +
      '<div class="card"><h3>Приватность</h3><div class="row between"><span>Показывать моё имя в рейтинге</span>' + sw('privacy', S.privacyShowName) + '</div><div class="note">Если выключено, в таблице вы отображаетесь как «Водитель №…».</div></div>' +
      '<div class="card"><h3>Уведомления</h3>' + rows.map(function (r) { return '<div class="row between" style="padding:8px 0"><span>' + r[1] + '</span>' + sw('n-' + r[0], ns[r[0]]) + '</div>'; }).join('') + '<div class="note">Финансовые статусы приходят независимо от настроек.</div></div>';
  };

  V.terms = function () {
    return back('Профиль') + '<h2>Условия лояльности</h2>' + termsBlock();
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
    var hist = S.dep.map(function (d) { return '<button class="li" data-act="depDetail" data-v="' + d.id + '"><span class="ic">🎁</span><span class="grow"><b>' + esc(d.type) + '</b><div class="small mut">' + esc(d.period) + (d.orders ? ' · ' + d.orders + ' заказов' : '') + '</div></span><span style="text-align:right"><div class="amt ' + (d.amount > 0 ? 'pos' : '') + '">' + (d.amount > 0 ? '+' : '') + money(d.amount) + '</div>' + statusChip(d.status) + '</span></button>'; }).join('');
    var pays = S.payouts.map(function (p) { return '<div class="li"><span class="ic">⬆️</span><span class="grow"><b>Заявка ' + p.id + '</b><div class="small mut">' + esc(p.date) + '</div></span><span style="text-align:right"><div class="amt">' + money(p.amount) + '</div>' + statusChip(p.status) + '</span></div>'; }).join('');
    return back('Назад') + '<h2>' + t('Депозит-карта Tulpar Line') + '</h2>' +
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
    return back('Назад') + '<h2>' + t('Рейтинг') + '</h2>' +
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
    return back('Назад') + '<h2>' + t('Цели') + '</h2><div class="note" style="margin-top:-4px">Цель — личный ориентир. Выполнение цели само по себе не даёт бонус: условия кэшбэка задаются отдельно.</div>' + rows +
      '<button class="btn" data-act="addGoal">+ Новая цель</button><div class="card" style="margin-top:12px"><h3>История</h3><div class="small mut">Вчера: 27 из 25 заказов — выполнено ✓<br>10 окт: 22 из 25 заказов — не выполнено</div></div>';
  };

  // --- Tasks ---
  V.tasks = function () {
    return back('Назад') + '<h2>' + t('Задания') + '</h2>' + S.tasks.map(function (k) {
      var pct = Math.min(100, Math.round(k.cur * 100 / k.max)), cur = k.unit === 'min' ? Math.floor(k.cur / 60) + ' ч' : k.cur, mx = k.unit === 'min' ? Math.floor(k.max / 60) + ' ч' : k.max;
      return '<div class="card"><div class="row between"><b>' + esc(k.title) + '</b>' + statusChip(k.status) + '</div><div class="small mut" style="margin:4px 0 10px">' + esc(k.desc) + ' · ' + esc(k.period) + '</div><div class="bar"><i style="width:' + pct + '%"></i></div><div class="row between small" style="margin-top:8px"><span>' + cur + ' из ' + mx + '</span><b>Награда: ' + money(k.reward) + '</b></div></div>';
    }).join('') + '<div class="note">Денежная награда начисляется на депозит-карту отдельной операцией после проверки. Совместимость с кэшбэком настраивает администратор.</div>';
  };

  // --- Schedule ---
  V.schedule = function () {
    return back('Назад') + '<h2>' + t('График') + '</h2><div class="card">' + S.sched.map(function (d, i) {
      return '<div class="sched"><b>' + d.d + '</b><div>' + (d.on ? d.from + ' – ' + d.to : '<span class="mut">Выходной</span>') + (i === 2 && d.on ? '<div class="small mut">Факт сегодня: на линии с 08:12 (6 ч 40 мин)</div>' : '') + '</div><span class="row">' + (d.on ? '<button class="btn btn--ghost btn--sm" data-act="editDay" data-v="' + i + '">Изм.</button>' : '') + sw('day-' + i, d.on) + '</span></div>';
    }).join('') + '</div><div class="card"><div class="row between"><span>Напоминание о начале смены</span>' + sw('n-shift', S.notifSettings.shift) + '</div><div class="note">Повторяющееся расписание. Для исключений (разовый выходной) используйте «Изм.» на нужном дне.</div></div>';
  };

  // --- Car & docs ---
  V.car = function () {
    var c = S.driver.car;
    return back('Назад') + '<h2>' + t('Автомобиль') + '</h2><div class="card"><div style="font-size:60px;text-align:center">🚕</div><div class="list">' +
      [['Марка / модель', c.make + ' ' + c.model], ['Год', c.year], ['Госномер', c.plate], ['Цвет', c.color], ['Класс', c.cls], ['Статус', 'Активен']].map(function (r) { return '<div class="li row between"><span class="mut">' + r[0] + '</span><b>' + esc(r[1]) + '</b></div>'; }).join('') + '</div></div>' +
      '<div class="card"><h3>Напоминания</h3>' + [['Техосмотр', 'до 10.04.2027', 'ok'], ['Страхование', 'до 04.11.2026 — 21 день', 'warn'], ['Масло и фильтры', 'через 1 200 км', 'warn'], ['Шины', 'сезонная замена в ноябре', 'info'], ['Обслуживание', 'ТО-2 через 3 800 км', 'info']].map(function (r) { return '<div class="row between" style="padding:7px 0"><span>' + r[0] + '</span>' + chip(r[1], r[2]) + '</div>'; }).join('') + '</div>';
  };
  V.documents = function () {
    return back('Назад') + '<h2>' + t('Документы') + '</h2>' + S.docs.map(function (d) {
      return '<div class="card"><div class="row between"><b>' + esc(d.n) + '</b>' + statusChip(d.check) + '</div><div class="small mut" style="margin:6px 0">Выдан: ' + d.issued + ' · Действует до: ' + d.until + '</div>' + statusChip(d.exp) + (d.c ? '<div class="note">' + esc(d.c) + '</div>' : '') + '</div>';
    }).join('') + '<div class="note">Доступ к персональным данным ограничен ролями сотрудников таксопарка.</div>';
  };

  // --- Referral ---
  V.referral = function () {
    return back('Назад') + '<h2>' + t('Пригласи друга') + '</h2>' +
      '<div class="card card--dark"><div class="small" style="opacity:.8">Ваша ссылка</div><div class="mid" style="word-break:break-all;margin:6px 0 14px">[APP_DOMAIN]/r/TLP7K2</div><div class="grid2"><button class="btn" data-act="copyRef">Копировать</button><button class="btn btn--light" data-act="shareRef">Поделиться</button></div><div class="small" style="opacity:.7;margin-top:10px">Домен утверждает владелец. Условия и суммы бонусов задаёт администратор.</div></div>' +
      '<div class="card"><h3>Приглашённые</h3>' + S.invited.map(function (p) { return '<div class="li row between"><div><b>' + esc(p.n) + '</b><div class="small mut">' + esc(p.st) + '</div></div>' + (p.bonus ? chip('Бонус: ' + p.bonus, 'warn') : chip('В процессе', 'info')) + '</div>'; }).join('') + '</div>' +
      '<div class="note">Бонус начисляется на депозит-карту только после выполнения условий активации и проверки (защита от самоприглашений и дублей).</div>';
  };

  // --- Health ---
  V.health = function () {
    return back('Назад') + '<h2>' + t('Здоровье') + '</h2><div class="card"><div class="row between"><div class="grow"><b>Доступ к данным здоровья</b><div class="small mut">Apple HealthKit / Google Health Connect. Только с вашего согласия, отзывается в любой момент.</div></div>' + sw('health', S.health.consent) + '</div></div>' +
      (S.health.consent ? '<div class="grid3"><div class="card" style="text-align:center"><div class="mid">6 840</div><div class="small mut">шагов</div></div><div class="card" style="text-align:center"><div class="mid">4,9</div><div class="small mut">км</div></div><div class="card" style="text-align:center"><div class="mid">38</div><div class="small mut">мин актив.</div></div></div><div class="note">Демо-значения. Приложение не даёт медицинских заключений.</div>' : '<div class="banner banner--info">Подключение выключено — данные не запрашиваются.</div>');
  };

  // --- SOS ---
  V.sos = function () {
    return back('Назад') + '<h2>SOS</h2><div class="card" style="text-align:center"><div class="small mut">В экстренной ситуации нажмите и подтвердите</div><button class="sos" data-act="sosPress">SOS</button><div class="small mut">Контакт: ' + esc(S.sos.contact) + '</div><button class="btn btn--ghost btn--sm" style="margin-top:10px" data-act="sosContact">Изменить контакт</button></div>' +
      '<div class="card"><h3>Журнал событий</h3>' + (S.sos.log.length ? S.sos.log.map(function (l) { return '<div class="li row between"><span>' + l.d + '</span>' + chip(l.s, 'warn') + '</div>'; }).join('') : '<div class="small mut">Событий пока нет.</div>') + '</div><div class="note">Приложение не утверждает, что сообщение доставлено, пока доставка не подтверждена. При угрозе жизни звоните 112.</div>';
  };

  // --- Support ---
  V.support = function () {
    return back('Назад') + '<h2>' + t('Поддержка') + '</h2><div class="card"><div class="grid2"><a class="btn btn--sm" style="text-align:center;text-decoration:none" href="tel:+70000000000">📞 Позвонить</a><button class="btn btn--sm btn--dark" data-act="ticket">Обращение</button></div><div class="note">Контакты: +7 (000) 000-00-00, поддержка 24/7 (демо).</div></div>' +
      '<div class="card"><h3>Мои обращения</h3>' + S.tickets.map(function (x) { return '<div class="li row between"><div><b>' + esc(x.topic) + '</b><div class="small mut">' + x.id + ' · ' + x.d + '</div></div>' + statusChip(x.st) + '</div>'; }).join('') + '</div>' +
      '<div class="card"><h3>FAQ</h3>' + [['Когда начисляется кэшбэк?', 'После окончания дня и проверки данных, если выполнен порог заказов.'], ['Когда можно вывести бонусы?', 'Заявку можно подать 1-го числа месяца. Срок выплаты сообщит таксопарк.'], ['Чем депозит-карта отличается от баланса?', 'Это отдельный бонусный баланс таксопарка, а не банковская карта и не баланс Yandex.']].map(function (q) { return '<details class="faq"><summary>' + q[0] + '</summary><p>' + q[1] + '</p></details>'; }).join('') + '</div>';
  };

  // --- Notifications ---
  V.notifications = function () {
    S.notifs.forEach(function (n) { n.unread = false; });
    return back('Назад') + '<h2>Уведомления</h2><div class="card"><div class="list">' + S.notifs.map(function (n) { return '<div class="li"><span class="ic">' + ({ bonus: '🎁', goal: '🎯', rating: '🏆', doc: '📄', withdraw: '⬆️' }[n.k] || '🔔') + '</span><span class="grow"><b>' + esc(n.t) + '</b><div class="small mut">' + esc(n.d) + '</div></span></div>'; }).join('') + '</div></div>';
  };

  // --- Demo tools ---
  V.demo = function () {
    return back('Профиль') + '<h2>Демо-инструменты</h2><div class="banner banner--info">Только для демонстрации прототипа. В реальном приложении этих экранов нет.</div>' +
      '<div class="card"><div class="row between"><div class="grow"><b>Имитировать 1-е число</b><div class="small mut">Открывает окно вывода с депозит-карты</div></div>' + sw('d-window', S.demo.windowOpen) + '</div></div>' +
      '<div class="card"><div class="row between"><div class="grow"><b>Данные Yandex синхронизированы</b><div class="small mut">Выключите, чтобы увидеть честное предупреждение</div></div>' + sw('d-sync', S.demo.synced) + '</div></div>' +
      '<div class="card"><b>Заказы</b><div class="small mut" style="margin:4px 0 10px">Сейчас завершено: ' + S.orders + '. Заказ обновляет цель, рейтинг, кэшбэк-статус и график.</div><div class="grid2"><button class="btn btn--sm" data-act="simOrder">+1 заказ</button><button class="btn btn--sm btn--ghost" data-act="simOrders5">+5 заказов</button></div></div>' +
      '<div class="card"><b>Заявки на вывод</b><div class="small mut" style="margin:4px 0 10px">Последняя заявка: ' + (S.payouts.length ? S.payouts[0].id + ' — ' + S.payouts[0].status : 'нет') + '</div><div class="grid2"><button class="btn btn--sm" data-act="payOk">Выполнить</button><button class="btn btn--sm btn--ghost" data-act="payReject">Отклонить</button></div></div>';
  };

  // ---------- actions ----------
  function addOp(o) { S.ops.unshift(o); }
  var ACT = {
    tab: function (v) { S.hist = []; go(v, true); },
    go: function (v) { go(v); },
    back: goBack,
    closeSheet: closeSheet,
    period: function (v) { S.period = v; render(); },
    lang: function (v) { S.lang = v; render(); },
    goalPick: function () {
      openSheet('<h3>Основная цель на сегодня</h3><div class="list">' + [['orders', 'Завершённые заказы', 25], ['minutes', 'Часы работы', 600], ['earn', 'Сумма заработка', 50000]].map(function (g) { return '<button class="li" data-act="goalSet" data-v="' + g[0] + '"><span class="grow"><b>' + g[1] + '</b></span>' + (S.goalType === g[0] ? chip('Выбрано', 'ok') : '') + '</button>'; }).join('') + '</div>');
    },
    goalSet: function (v) { S.goalType = v; closeSheet(); render(); },
    topup: function () {
      openSheet('<h3>Пополнить баланс</h3><form data-form="topup"><label class="f">Сумма, ₸<input name="amount" inputmode="numeric" placeholder="Например, 10000"></label><label class="f">Способ<select name="method"><option>Kaspi (требуется подтверждённый сценарий провайдера)</option><option>Банковская карта</option></select></label><p class="err" id="fe"></p><button class="btn" type="submit">Создать платёж</button><div class="note">Баланс увеличится только после подтверждения платежа сервером через официальный механизм провайдера. Возврат в приложение — не подтверждение.</div></form>');
    },
    withdraw: function () {
      openSheet('<h3>Вывести с баланса</h3><div class="small mut">Доступно: <b>' + money(available()) + '</b></div><form data-form="withdraw" style="margin-top:12px"><label class="f">Сумма, ₸<input name="amount" inputmode="numeric" placeholder="Минимум 1 000"></label><label class="f">Реквизиты<select name="req"><option>Kaspi •• 4821</option></select></label><p class="err" id="fe"></p><button class="btn" type="submit">Создать заявку</button><div class="note">Лимиты: от 1 000 ₸ (демо, утверждает владелец). Сумма резервируется. Мгновенный вывод не обещается — срок обработки сообщит таксопарк. Статусы: Создана → На проверке → В обработке → Выполнена / Отклонена.</div></form>');
    },
    addExpense: function () {
      var n = new Date(), tm = pad(n.getHours()) + ':' + pad(n.getMinutes());
      openSheet('<h3>Добавить расход</h3><form data-form="expense"><label class="f">Сумма, ₸<input name="amount" inputmode="numeric" placeholder="0"></label><label class="f">Категория<select name="cat">' + ['Топливо', 'Мойка', 'Парковка', 'Ремонт', 'Масло/фильтры', 'Шиномонтаж', 'Питание', 'Штрафы', 'Другое'].map(function (c) { return '<option>' + c + '</option>'; }).join('') + '</select></label><label class="f">Дата и время<input name="when" value="Сегодня, ' + tm + '" readonly></label><label class="f">Комментарий (необязательно)<input name="comment" maxlength="120"></label><label class="f">Фото чека (необязательно)<input name="photo" type="file" accept="image/*"></label><p class="err" id="fe"></p><button class="btn" type="submit">Сохранить расход</button></form>');
    },
    opDetail: function (v) {
      var o = S.ops.filter(function (x) { return x.id === v; })[0]; if (!o) return;
      var canCancel = /^EXP-/.test(o.ref || '') && o.status !== 'Отменён';
      openSheet('<h3>' + esc(o.desc) + '</h3><div class="list">' + [['ID', o.id], ['Тип', o.type], ['Дата', o.date], ['Сумма', money(o.amount)], ['Источник', o.src]].map(function (r) { return '<div class="li row between"><span class="mut">' + r[0] + '</span><b>' + esc(r[1]) + '</b></div>'; }).join('') + '<div class="li row between"><span class="mut">Статус</span>' + statusChip(o.status) + '</div></div>' + (canCancel ? '<button class="btn btn--ghost" style="margin-top:12px" data-act="cancelExp" data-v="' + o.ref + '">Отменить расход</button><div class="note">Запись не удаляется: статус меняется, действие фиксируется в журнале аудита.</div>' : ''));
    },
    cancelExp: function (v) {
      S.expenses.forEach(function (e) { if (e.id === v) e.status = 'cancel'; });
      S.ops.forEach(function (o) { if (o.ref === v) o.status = 'Отменён'; });
      closeSheet(); render(); toast('Расход отменён. Запись сохранена в журнале аудита.');
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
    payOk: function () { var p = S.payouts[0]; if (!p || p.status === 'Выполнена' || p.status === 'Отклонена') return toast('Нет активной заявки'); p.status = 'Выполнена'; if (p.kind === 'dep') { S.deposit.balance -= p.amount; S.deposit.reserved -= p.amount; } else { S.balance -= p.amount; S.reserved -= p.amount; } render(); toast('Заявка выполнена, резерв списан'); },
    payReject: function () { var p = S.payouts[0]; if (!p || p.status === 'Выполнена' || p.status === 'Отклонена') return toast('Нет активной заявки'); p.status = 'Отклонена'; if (p.kind === 'dep') S.deposit.reserved -= p.amount; else S.reserved -= p.amount; render(); toast('Заявка отклонена, резерв снят'); }
  };
  function simOrders(n) {
    if (!S.demo.synced) { toast('Нет синхронизации — заказ не учтён (демо)'); return; }
    for (var i = 0; i < n; i++) { S.orders++; S.inc[S.inc.length - 1] += 1900; addOp({ id: nid('OP'), type: 'Доход', desc: 'Заказ #' + (48214 + S.orders), date: 'Сегодня, сейчас', amount: 1900, status: 'Выполнена', src: 'Yandex' }); }
    S.minutes += 12 * n; if (S.me > 5 && S.orders % 2 === 0) S.me--;
    render(); toast(S.orders >= 25 ? 'Условие кэшбэка выполнено — начисление после окончания дня' : 'Заказ завершён и учтён');
  }

  // ---------- forms ----------
  function parseAmount(v) { var s = String(v).replace(/\s/g, ''); if (!/^\d+$/.test(s)) return NaN; return parseInt(s, 10); }
  function ferr(m) { var e = $('#fe'); if (e) e.textContent = m; }
  var FORMS = {
    topup: function (f) {
      var a = parseAmount(f.amount.value);
      if (!(a > 0)) return ferr('Введите сумму целым числом, больше нуля.');
      if (a < 500 || a > 1000000) return ferr('Сумма должна быть от 500 до 1 000 000 ₸.');
      addOp({ id: nid('OP'), type: 'Пополнение', desc: 'Пополнение баланса', date: 'Сегодня, сейчас', amount: a, status: 'Создана', src: 'Пополнение' });
      closeSheet(); render(); toast('Платёж создан. Баланс обновится после подтверждения провайдером.');
    },
    withdraw: function (f) {
      var a = parseAmount(f.amount.value);
      if (!(a > 0)) return ferr('Введите сумму целым числом.');
      if (a < 1000) return ferr('Минимальная сумма — 1 000 ₸.');
      if (a > available()) return ferr('Сумма больше доступного остатка (' + money(available()) + ').');
      S.reserved += a; var id = nid('WD');
      S.payouts.unshift({ id: id, amount: a, status: 'Создана', date: 'Сегодня', kind: 'main' });
      addOp({ id: id, type: 'Выплата', desc: 'Заявка на вывод', date: 'Сегодня, сейчас', amount: -a, status: 'Создана', src: 'Выплата' });
      closeSheet(); render(); toast('Заявка создана, сумма зарезервирована.');
    },
    depwd: function (f) {
      var a = parseAmount(f.amount.value);
      if (!(a > 0)) return ferr('Введите сумму целым числом.');
      if (a > depAvailable()) return ferr('Сумма больше доступного остатка (' + money(depAvailable()) + ').');
      S.deposit.reserved += a;
      S.payouts.unshift({ id: nid('DWD'), amount: a, status: 'В обработке', date: 'Сегодня', kind: 'dep' });
      closeSheet(); render(); toast('Заявка отправлена. Сумма зарезервирована.');
    },
    expense: function (f) {
      var a = parseAmount(f.amount.value);
      if (!(a > 0)) return ferr('Введите корректную сумму: целое число больше нуля.');
      if (a > 1000000) return ferr('Слишком большая сумма для одного расхода.');
      var n = new Date(), id = nid('EXP');
      S.expenses.push({ id: id, amount: a, cat: f.cat.value, hour: n.getHours(), when: pad(n.getHours()) + ':' + pad(n.getMinutes()), comment: f.comment.value, receipt: !!(f.photo.files && f.photo.files.length), status: 'ok' });
      addOp({ id: nid('OP'), ref: id, type: 'Расход', desc: f.cat.value + (f.comment.value ? ' — ' + f.comment.value : ''), date: 'Сегодня, ' + pad(n.getHours()) + ':' + pad(n.getMinutes()), amount: -a, status: 'Выполнена', src: 'Ручной ввод' });
      S.period = 'day'; closeSheet(); render(); toast('Расход сохранён: итоги и график обновлены');
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
  render();
  window.__tl = { go: go, S: S };
})();
