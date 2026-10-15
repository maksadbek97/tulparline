import 'package:flutter/foundation.dart';

/// Деньги — целые тенге, без double.
String money(int n) {
  final s = n.abs().toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(' ');
    b.write(s[i]);
  }
  return '${n < 0 ? '−' : ''}$b ₸';
}

String pad2(int n) => n < 10 ? '0$n' : '$n';

enum GoalType { orders, minutes, earn }

enum Period { day, week, month, range }

const periodLabel = {
  Period.day: 'За день',
  Period.week: 'За неделю',
  Period.month: 'За месяц',
  Period.range: 'За период',
};

class Expense {
  Expense(this.id, this.amount, this.desc, this.hour, this.time);
  final String id, desc, time;
  final int amount;
  final int hour;
  bool cancelled = false;
}

/// Запись об обслуживании автомобиля.
class ServiceRecord {
  ServiceRecord(this.id, this.what, this.date, this.km, this.next);
  final String id, what;
  final DateTime date;
  final int km;
  final int? next;
}

class Op {
  Op(this.id, this.type, this.desc, this.ts, this.amount, this.status, this.src, [this.ref]);
  final String id, type, desc, src;
  final DateTime ts;
  final int amount;
  String status;
  final String? ref;

  /// «15.10.26 02:52»
  String get date => '${pad2(ts.day)}.${pad2(ts.month)}.${pad2(ts.year % 100)} ${pad2(ts.hour)}:${pad2(ts.minute)}';
}

class BankCard {
  BankCard(this.id, this.bank, this.last4, this.main);
  final String id, bank, last4;
  bool main;
  String get mask => '$bank ****$last4';
}

class DepRecord {
  const DepRecord(this.id, this.type, this.period, this.orders, this.base, this.rate, this.amount, this.status, this.src, this.comment);
  final String id, type, period, status, src, comment;
  final int? orders, base;
  final String? rate;
  final int amount;
}

class Payout {
  Payout(this.id, this.amount, this.status, this.date, this.fromDeposit);
  final String id, date;
  final int amount;
  String status;
  final bool fromDeposit;
}

class Goal {
  Goal(this.type, this.period, this.target, this.on);
  final GoalType type;
  final String period;
  final int target;
  bool on;
}

class Rival {
  const Rival(this.place, this.name, this.orders, this.score, this.change, this.me);
  final int place, orders, score, change;
  final String name;
  final bool me;
}

class AppState extends ChangeNotifier {
  // профиль
  final first = 'Данияр', last = 'Сейтказин';
  final carMake = 'Toyota', carModel = 'Camry', carYear = 2021, carPlate = '777 TLP 02', carClass = 'Комфорт';

  // демо-переключатели
  bool windowOpen = false;
  bool synced = true;
  bool showName = true;
  bool hideBalance = false;
  bool healthConsent = false;
  String lang = 'ru';
  int avatar = 1; // 1..10, 3D-аватарки

  // автомобиль: пробег, документы, обслуживание
  int odometer = 84300;
  DateTime techUntil = DateTime(2027, 4, 10);
  DateTime insUntil = DateTime(2026, 11, 4);
  final List<ServiceRecord> services = [
    ServiceRecord('S3', 'Замена масла и фильтров', DateTime(2026, 9, 12), 80100, 90100),
    ServiceRecord('S2', 'Замена тормозных колодок', DateTime(2026, 6, 3), 72400, 102400),
    ServiceRecord('S1', 'Сезонная замена шин', DateTime(2026, 4, 20), 68200, null),
  ];

  // главная
  GoalType goalType = GoalType.orders;
  final goalTargets = {GoalType.orders: 25, GoalType.minutes: 600, GoalType.earn: 50000};
  int orders = 20;
  int minutes = 400;
  int place = 10;
  String workTab = 'hours';
  // доход по часам 6..19
  final List<int> inc = [2400, 3600, 4200, 2800, 1800, 0, 2600, 3100, 2400, 3500, 2900, 3800, 3200, 2100];

  // финансы
  Period period = Period.day;
  int balance = 54300;
  int reserved = 0;
  final List<Expense> expenses = [
    Expense('EXP-1', 4500, 'Заправка на АЗС', 8, '08:10'),
    Expense('EXP-2', 1700, 'Обед', 13, '13:05'),
  ];
  static DateTime _at(int day, int h, int m) {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day + day, h, m);
  }

  late final List<Op> ops = [
    Op('OP-9001', 'Доход', 'Заказ #48213', _at(0, 19, 12), 2100, 'Выполнена', 'Yandex'),
    Op('OP-9000', 'Доход', 'Заказ #48207', _at(0, 18, 40), 1900, 'Выполнена', 'Yandex'),
    Op('OP-9003', 'Расход', 'Обед', _at(0, 13, 5), -1700, 'Выполнена', 'Ручной ввод', 'EXP-2'),
    Op('OP-9002', 'Расход', 'Заправка на АЗС', _at(0, 8, 10), -4500, 'Выполнена', 'Ручной ввод', 'EXP-1'),
    Op('#1670255', 'Выплата', 'Вывод на ****0716', _at(0, 2, 52), -3229, 'Выполнена', 'Выплата'),
    Op('OP-8990', 'Начисление', 'Ежедневный кэшбэк', _at(-1, 23, 59), 480, 'Выполнена', 'Лояльность'),
    Op('#1669844', 'Выплата', 'Вывод на ****0716', _at(-1, 22, 19), -21614, 'Выполнена', 'Выплата'),
    Op('#1669790', 'Пополнение', 'Пополнение через Kaspi', _at(-1, 20, 19), 800, 'Отклонена', 'Kaspi'),
    Op('#1669721', 'Оплата QR', 'Оплата через Kaspi QR', _at(-1, 18, 5), 3500, 'Выполнена', 'Kaspi QR'),
    Op('#1669402', 'Пополнение', 'Пополнение через Kaspi', _at(-1, 11, 0), 10000, 'Выполнена', 'Kaspi'),
    Op('#1668310', 'Выплата', 'Вывод на ****0716', _at(-4, 10, 20), -25000, 'Выполнена', 'Выплата'),
    Op('OP-8970', 'Корректировка', 'Корректировка комиссии', _at(-5, 12, 0), 350, 'Выполнена', 'Корректировка'),
  ];

  // карты для вывода (хранятся только последние 4 цифры)
  final List<BankCard> cards = [BankCard('C1', 'Kaspi', '0716', true), BankCard('C2', 'Halyk', '4821', false)];
  String histTab = 'all'; // all | in | out | qr
  String histMode = 'ops'; // ops | cards

  // депозит-карта
  int depBalance = 18640;
  int depMonth = 7200;
  int depReserved = 0;
  final List<DepRecord> dep = const [
    DepRecord('DEP-3012', 'Ежедневный кэшбэк', 'Вчера', 27, 120000, '0,4%', 480, 'Начислено', 'Правило v1', ''),
    DepRecord('DEP-3005', 'Ежедневный кэшбэк', '10 окт', 26, 112500, '0,4%', 450, 'Начислено', 'Правило v1', ''),
    DepRecord('DEP-3001', 'Ежедневный кэшбэк', '9 окт', 28, 131000, '0,4%', 524, 'Ожидает проверки', 'Правило v1', 'Синхронизация заказов за день неполная'),
    DepRecord('DEP-2990', 'Корректировка', '8 окт', null, null, null, 200, 'Начислено', 'Администратор', 'Компенсация за сбой синхронизации'),
  ];
  final List<Payout> payouts = [];

  final List<Goal> goals = [
    Goal(GoalType.orders, 'День', 25, true),
    Goal(GoalType.minutes, 'Неделя', 3000, true),
    Goal(GoalType.earn, 'Месяц', 900000, false),
  ];

  int _seq = 1000;
  String nid(String p) => '$p-${++_seq}';
  String nidn() => '#${1670300 + (++_seq)}';

  // ---------- производные ----------
  int get incomeToday => inc.fold(0, (a, b) => a + b);
  int get expenseToday => expenses.where((e) => !e.cancelled).fold(0, (a, e) => a + e.amount);
  int get available => balance - reserved;
  int get depAvailable => depBalance - depReserved;

  DateTime get nextWindow {
    final n = DateTime.now();
    return DateTime(n.year, n.month + (n.day == 1 ? 0 : 1), 1);
  }

  static const _months = ['января', 'февраля', 'марта', 'апреля', 'мая', 'июня', 'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря'];
  String dmy(DateTime d) => '${d.day} ${_months[d.month - 1]}';
  String get nextWindowText => windowOpen ? 'Сегодня (демо)' : dmy(nextWindow);

  String get cashbackStatus {
    final left = 25 - orders;
    if (left <= 0) return 'Условие выполнено';
    return 'До кэшбэка осталось $left ${left == 1 ? 'заказ' : (left < 5 ? 'заказа' : 'заказов')}';
  }

  int goalCurrent(GoalType t) => t == GoalType.orders ? orders : t == GoalType.minutes ? minutes : incomeToday;

  /// Ряды для графика: доходы, расходы, подписи.
  ({List<int> inc, List<int> exp, List<String> labels}) series() {
    final i = <int>[], e = <int>[], l = <String>[];
    int ps(int k, int base, int spread) => base + ((k * 7919 + 13) % spread);
    switch (period) {
      case Period.day:
        for (var k = 0; k < inc.length; k++) {
          i.add(inc[k]);
          e.add(0);
          l.add(k % 3 == 0 ? '${pad2(6 + k)}:00' : '');
        }
        for (final x in expenses.where((x) => !x.cancelled)) {
          final idx = x.hour - 6;
          if (idx >= 0 && idx < e.length) e[idx] += x.amount;
        }
      case Period.week:
        const d = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
        for (var k = 0; k < 7; k++) {
          l.add(d[k]);
          if (k < 2) {
            i.add(ps(k, 36000, 9000));
            e.add(ps(k, 5000, 3000));
          } else if (k == 2) {
            i.add(incomeToday);
            e.add(expenseToday);
          } else {
            i.add(0);
            e.add(0);
          }
        }
      case Period.month || Period.range:
        final n = period == Period.month ? 30 : 14;
        for (var k = 0; k < n; k++) {
          l.add(k % 5 == 0 ? '${k + 1}' : '');
          if (k == n - 1) {
            i.add(incomeToday);
            e.add(expenseToday);
          } else {
            i.add(ps(k, 30000, 14000));
            e.add(ps(k, 4000, 4500));
          }
        }
    }
    return (inc: i, exp: e, labels: l);
  }

  ({int inc, int exp}) totals() {
    if (period == Period.day) return (inc: incomeToday, exp: expenseToday);
    final s = series();
    return (inc: s.inc.fold(0, (a, b) => a + b), exp: s.exp.fold(0, (a, b) => a + b));
  }

  List<Rival> get rating {
    const names = ['Руслан Т.', 'Нурлан Б.', 'Айдос М.', 'Серик О.', 'Данияр С.', 'Талгат Е.', 'Бауыржан К.', 'Алмас Ж.', 'Ерлан Н.', 'Тимур Д.', 'Асхат Р.', 'Марат В.'];
    final my = showName ? '$first ${last[0]}.' : 'Водитель №4821';
    return [
      for (var p = 1; p <= 12; p++)
        p == place
            ? Rival(p, my, orders, orders * 10 + 20, 2, true)
            : Rival(p, names[(p - (p > place ? 2 : 1)) % names.length], (38 - p * 2).clamp(1, 99), (380 - p * 20).clamp(10, 999), (p * 3) % 5 - 2, false),
    ];
  }

  // ---------- действия ----------
  void notify() => notifyListeners();

  void setPeriod(Period p) {
    period = p;
    notifyListeners();
  }

  /// Возвращает текст ошибки или null. Только сумма и описание.
  String? addExpense(String raw, String desc) {
    final a = int.tryParse(raw.replaceAll(RegExp(r'\s'), ''));
    if (a == null || a <= 0) return 'Введите сумму: целое число больше нуля.';
    if (a > 1000000) return 'Слишком большая сумма для одного расхода.';
    final d = desc.trim();
    if (d.isEmpty) return 'Напишите, на что потратили.';
    final now = DateTime.now();
    final id = nid('EXP');
    final t = '${pad2(now.hour)}:${pad2(now.minute)}';
    expenses.add(Expense(id, a, d, now.hour, t));
    ops.insert(0, Op(nid('OP'), 'Расход', d, now, -a, 'Выполнена', 'Ручной ввод', id));
    period = Period.day;
    notifyListeners();
    return null;
  }

  void cancelExpense(String ref) {
    for (final e in expenses) {
      if (e.id == ref) e.cancelled = true;
    }
    for (final o in ops) {
      if (o.ref == ref) o.status = 'Отменён';
    }
    notifyListeners();
  }

  String? topup(String raw, String method) {
    final a = int.tryParse(raw.replaceAll(RegExp(r'\s'), ''));
    if (a == null || a <= 0) return 'Введите сумму целым числом, больше нуля.';
    if (a < 500 || a > 1000000) return 'Сумма должна быть от 500 до 1 000 000 ₸.';
    ops.insert(0, Op(nidn(), 'Пополнение', 'Пополнение через $method', DateTime.now(), a, 'Создана', method));
    notifyListeners();
    return null;
  }

  String? withdraw(String raw, String cardMask) {
    final a = int.tryParse(raw.replaceAll(RegExp(r'\s'), ''));
    if (a == null || a <= 0) return 'Введите сумму целым числом.';
    if (a < 1000) return 'Минимальная сумма — 1 000 ₸.';
    if (a > available) return 'Сумма больше доступного остатка (${money(available)}).';
    reserved += a;
    final id = nidn();
    payouts.insert(0, Payout(id, a, 'Создана', 'Сегодня', false));
    ops.insert(0, Op(id, 'Выплата', 'Вывод на ****${cardMask.split('****').last}', DateTime.now(), -a, 'Создана', 'Выплата'));
    notifyListeners();
    return null;
  }

  String? depWithdraw(String raw) {
    if (!windowOpen) return 'Заявки принимаются только 1-го числа месяца.';
    final a = int.tryParse(raw.replaceAll(RegExp(r'\s'), ''));
    if (a == null || a <= 0) return 'Введите сумму целым числом.';
    if (a > depAvailable) return 'Сумма больше доступного остатка (${money(depAvailable)}).';
    depReserved += a;
    payouts.insert(0, Payout(nid('DWD'), a, 'В обработке', 'Сегодня', true));
    notifyListeners();
    return null;
  }

  void payoutDone() {
    if (payouts.isEmpty) return;
    final p = payouts.first;
    if (p.status == 'Выполнена' || p.status == 'Отклонена') return;
    p.status = 'Выполнена';
    if (p.fromDeposit) {
      depBalance -= p.amount;
      depReserved -= p.amount;
    } else {
      balance -= p.amount;
      reserved -= p.amount;
    }
    notifyListeners();
  }

  void payoutReject() {
    if (payouts.isEmpty) return;
    final p = payouts.first;
    if (p.status == 'Выполнена' || p.status == 'Отклонена') return;
    p.status = 'Отклонена';
    if (p.fromDeposit) {
      depReserved -= p.amount;
    } else {
      reserved -= p.amount;
    }
    notifyListeners();
  }

  void setHistTab(String v) {
    histTab = v;
    notifyListeners();
  }

  void setHistMode(String v) {
    histMode = v;
    notifyListeners();
  }

  String? addCard(String bank, String last4) {
    if (!RegExp(r'^\d{4}$').hasMatch(last4.trim())) return 'Введите ровно 4 последние цифры карты.';
    cards.add(BankCard(nid('C'), bank, last4.trim(), cards.isEmpty));
    notifyListeners();
    return null;
  }

  void makeMain(String id) {
    for (final c in cards) {
      c.main = c.id == id;
    }
    notifyListeners();
  }

  void removeCard(String id) {
    cards.removeWhere((c) => c.id == id);
    if (cards.isNotEmpty && !cards.any((c) => c.main)) cards.first.main = true;
    notifyListeners();
  }

  /// Демо: имитация подтверждения платежа Kaspi QR (в реальности подтверждает провайдер).
  void qrPaid(int amount) {
    balance += amount;
    ops.insert(0, Op(nidn(), 'Оплата QR', 'Оплата через Kaspi QR', DateTime.now(), amount, 'Выполнена', 'Kaspi QR'));
    notifyListeners();
  }

  void setAvatar(int i) {
    avatar = i;
    notifyListeners();
  }

  String? setOdometer(String raw) {
    final k = int.tryParse(raw.replaceAll(RegExp(r'\s'), ''));
    if (k == null || k < 0 || k > 2000000) return 'Введите пробег числом, например 84300.';
    odometer = k;
    notifyListeners();
    return null;
  }

  String? addService(String what, DateTime date, String kmRaw, String nextRaw) {
    final w = what.trim();
    final k = int.tryParse(kmRaw.replaceAll(RegExp(r'\s'), ''));
    final nx = nextRaw.trim().isEmpty ? null : int.tryParse(nextRaw.replaceAll(RegExp(r'\s'), ''));
    if (w.isEmpty) return 'Напишите, что сделали.';
    if (k == null || k < 0) return 'Укажите пробег числом.';
    if (nextRaw.trim().isNotEmpty && (nx == null || nx <= k)) return 'Следующая замена должна быть больше текущего пробега.';
    services.insert(0, ServiceRecord(nid('S'), w, date, k, nx));
    if (k > odometer) odometer = k;
    notifyListeners();
    return null;
  }

  void removeService(String id) {
    services.removeWhere((x) => x.id == id);
    notifyListeners();
  }

  void setTechUntil(DateTime d) {
    techUntil = d;
    notifyListeners();
  }

  void setInsUntil(DateTime d) {
    insUntil = d;
    notifyListeners();
  }

  /// false — нет синхронизации, заказ не учтён.
  bool simOrders(int n) {
    if (!synced) return false;
    for (var i = 0; i < n; i++) {
      orders++;
      inc[inc.length - 1] += 1900;
      ops.insert(0, Op(nid('OP'), 'Доход', 'Заказ #${48214 + orders}', DateTime.now(), 1900, 'Выполнена', 'Yandex'));
    }
    minutes += 12 * n;
    if (place > 5 && orders % 2 == 0) place--;
    notifyListeners();
    return true;
  }
}
