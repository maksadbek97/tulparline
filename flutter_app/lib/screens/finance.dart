import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../main.dart';
import '../state.dart';
import '../ui.dart';
import 'deposit.dart';
import 'service.dart' show ScreenHead;

IconData _opIcon(String type, String desc) {
  switch (type) {
    case 'Пополнение':
      return Icons.south_rounded;
    case 'Выплата':
      return Icons.north_east_rounded;
    case 'Начисление':
      return Icons.card_giftcard;
    case 'Корректировка':
      return Icons.description_outlined;
    default:
      return RegExp('Топл|Заправ|бензин|АЗС', caseSensitive: false).hasMatch(desc) ? Icons.local_gas_station_outlined : RegExp('Ремонт|Масл|Шин|Мойк', caseSensitive: false).hasMatch(desc) ? Icons.build_outlined : Icons.receipt_long_outlined;
  }
}

Tone _opTone(String type) => switch (type) {
      'Пополнение' => Tone.green,
      'Выплата' => Tone.blue,
      'Начисление' => Tone.amber,
      'Корректировка' => Tone.violet,
      _ => Tone.gray,
    };

String _day(AppState s, DateTime d) {
  final n = DateTime.now();
  final diff = DateTime(n.year, n.month, n.day).difference(DateTime(d.year, d.month, d.day)).inDays;
  return diff == 0 ? 'Сегодня' : diff == 1 ? 'Вчера' : s.dmy(d);
}

/// Строка транзакции: название, дата и время, сумма, ID или статус.
class OpTile extends StatelessWidget {
  const OpTile(this.o, {super.key});
  final Op o;
  @override
  Widget build(BuildContext context) {
    final pos = o.amount > 0;
    final dead = o.status == 'Отклонена' || o.status == 'Отменён';
    final deco = dead ? TextDecoration.lineThrough : null;
    final done = o.status == 'Выполнена' || o.status == 'Начислено';
    return InkWell(
      onTap: () => sheet(context, (ctx) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        h3(o.desc),
        Container(padding: const EdgeInsets.symmetric(horizontal: 14), decoration: BoxDecoration(color: kSolid, borderRadius: BorderRadius.circular(18)), child: Column(children: [kv('ID', o.id), kv('Тип', o.type), kv('Дата', o.date), kv('Сумма', money(o.amount)), kv('Источник', o.src)])),
        const SizedBox(height: 10),
        StatusChip(o.status),
      ])),
      child: Container(
        constraints: const BoxConstraints(minHeight: 52),
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(children: [
          toneIcon(_opIcon(o.type, o.desc), _opTone(o.type)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(o.desc, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15, height: 20 / 15, letterSpacing: -.3, decoration: deco)),
            Text(o.date, style: TextStyle(color: kMut, fontSize: 12, height: 16 / 12)),
          ])),
          const SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('${pos ? '+' : ''}${money(o.amount)}', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, letterSpacing: -.3, color: pos ? kOk : kInk, decoration: deco)),
            if (!done) StatusChip(o.status) else if (o.id.startsWith('#')) Text(o.id, style: TextStyle(color: kMut, fontSize: 12)),
          ]),
        ]),
      ),
    );
  }
}

class FinancePage extends StatefulWidget {
  const FinancePage({super.key});
  @override
  State<FinancePage> createState() => _FinancePageState();
}

class _FinancePageState extends State<FinancePage> {
  late final PageController pc = PageController(viewportFraction: .93);

  @override
  void dispose() {
    pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final tt = s.totals(), net = tt.inc - tt.exp;
    final pl = s.period == Period.day ? 'за день' : periodLabel[s.period]!.toLowerCase();
    return ListView(padding: const EdgeInsets.fromLTRB(kM, 4, kM, 120), children: [
      ScreenHead('Финансы', trailing: GestureDetector(
        onTap: () => _periodPick(context, s),
        child: Container(height: 34, padding: const EdgeInsets.symmetric(horizontal: 12), decoration: BoxDecoration(color: kSolid, borderRadius: BorderRadius.circular(17), boxShadow: kShadow), child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.calendar_today_outlined, size: 16), const SizedBox(width: 8), Text(periodLabel[s.period]!, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)), const Icon(Icons.keyboard_arrow_down, size: 18)])),
      )),
      if (!s.synced) banner('Данные не синхронизированы с Yandex. Показаны последние известные значения (обновлено в 14:20).'),
      // два отдельных счёта: Яндекс баланс и депозит-карта таксопарка
      LayoutBuilder(builder: (_, cs) {
        final cw = cs.maxWidth * .93 - 10;
        return SizedBox(
          height: cw / 1.62 + 52,
          child: PageView(
            controller: pc,
            padEnds: false,
            onPageChanged: (i) => s.setAcct(i == 0 ? 'ya' : 'dep'),
            children: [_yandex(context, s), _deposit(context, s)],
          ),
        );
      }),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          for (final k in const ['ya', 'dep']) AnimatedContainer(duration: const Duration(milliseconds: 200), margin: const EdgeInsets.symmetric(horizontal: 3), width: s.acct == k ? 18 : 6, height: 6, decoration: BoxDecoration(color: s.acct == k ? kInk : const Color(0x59787F9E), borderRadius: BorderRadius.circular(3))),
        ]),
      ),
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: _Stat(kDark ? const [Color(0x3316B05A), Color(0xEB1E1F26)] : const [Color(0xFFE6F9ED), Color(0xFFF6FDF9)], const Color(0xFF12A050), Icons.trending_up, 'Доходы', pl, money(tt.inc))),
        const SizedBox(width: 10),
        Expanded(child: _Stat(kDark ? const [Color(0x33FF4D5A), Color(0xEB1E1F26)] : const [Color(0xFFFFECEE), Color(0xFFFFF8F8)], const Color(0xFFE0384A), Icons.trending_down, 'Расходы', pl, money(tt.exp))),
        const SizedBox(width: 10),
        Expanded(child: _Stat(kDark ? const [Color(0x406A5CF0), Color(0xEB1E1F26)] : const [Color(0xFFEEEBFF), Color(0xFFF9F8FF)], kIndigo, Icons.bar_chart_rounded, 'Чистый результат', pl, money(net))),
      ]),
      const SizedBox(height: 12),
      GestureDetector(
        onTap: () => _addExpense(context, s),
        child: Container(
          height: 44,
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF1D1E24), Color(0xFF050506)]), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .45), blurRadius: 28, offset: const Offset(0, 16), spreadRadius: -16)]),
          child: Stack(alignment: Alignment.center, children: [
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(width: 24, height: 24, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: const Icon(Icons.add, size: 16, color: kBlack)),
              const SizedBox(width: 12),
              const Text('Добавить расход', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 15)),
            ]),
            const Positioned(right: 16, child: Icon(Icons.chevron_right, color: Colors.white60, size: 20)),
          ]),
        ),
      ),
      AppCard(padding: const EdgeInsets.fromLTRB(14, 12, 14, 8), child: _History(s: s, onCards: () => _cards(context, s))),
    ]);
  }

  // ---------- карточки счетов ----------
  Widget _yandex(BuildContext c, AppState s) => _Slide(
        card: _YandexCard(
          amount: s.hideBalance ? '••••• ₸' : money(s.available),
          note: s.reserved > 0 ? 'В резерве: ${money(s.reserved)}' : null,
          hidden: s.hideBalance,
          onEye: () {
            s.hideBalance = !s.hideBalance;
            s.notify();
          },
          onInfo: () => _info(c, s),
        ),
        pills: [
          _Pill(Icons.add, 'Пополнить', () => _topup(c, s), fill: kYandex, fg: kBlack, line: kYandex),
          _Pill(Icons.north_east, 'Вывести', () => _withdraw(c, s), fill: kSolid, fg: kInk, line: kBorder),
          _Pill(Icons.qr_code_2, 'Kaspi QR', () => _qrMenu(c, s), fill: kSolid, fg: kInk, line: kBorder),
        ],
      );

  Widget _deposit(BuildContext c, AppState s) => _Slide(
        card: _TulparCard(amount: money(s.depBalance), note: 'За месяц +${money(s.depMonth)} · вывод: ${s.nextWindowText}'),
        pills: [
          _Pill(Icons.north_east, 'Вывести', () => DepositPage.withdraw(c, s), fill: kInk, fg: kOn, line: kInk),
          _Pill(Icons.card_giftcard, 'Подробнее', () => Navigator.push(c, MaterialPageRoute(builder: (_) => const DepositPage())), fill: kSolid, fg: kInk, line: kBorder),
        ],
      );

  // ---------- шторки ----------
  void _periodPick(BuildContext c, AppState s) {
    sheet(c, (ctx) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      h3('Период'),
      for (final p in Period.values)
        ListTile(contentPadding: EdgeInsets.zero, title: Text(p == Period.range ? 'Произвольный период' : periodLabel[p]!, style: const TextStyle(fontWeight: FontWeight.w700)), trailing: s.period == p ? const StatusChip('Выбрано') : null, onTap: () {
          s.setPeriod(p);
          Navigator.pop(ctx);
        }),
    ]));
  }

  void _info(BuildContext c, AppState s) {
    sheet(c, (ctx) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      h3('О балансе'),
      const Text('Яндекс баланс и бонусный баланс депозит-карты — отдельные счета, они не складываются.'),
      const SizedBox(height: 10),
      kv('Яндекс баланс', money(s.available)), kv('Депозит-карта', money(s.depBalance)),
    ]));
  }

  void _topup(BuildContext c, AppState s) {
    _keypad(c, title: 'Пополнить Яндекс баланс', sub: 'Текущий баланс: ${money(s.available)}', chips: const [5000, 10000, 20000, 50000], selectLabel: 'Способ', options: const ['Kaspi', 'Банковская карта'], cta: 'Продолжить', go: (a, m) {
      if (a < 500 || a > 1000000) return 'Сумма должна быть от 500 до 1 000 000 ₸.';
      s.topup(a.toString(), m!.startsWith('Kaspi') ? 'Kaspi' : 'карту');
      s.setAcct('ya');
      toast(c, 'Платёж создан. Баланс обновится после подтверждения провайдером.');
      return null;
    });
  }

  void _withdraw(BuildContext c, AppState s) {
    _keypad(c, title: 'Вывести с Яндекс баланса', sub: 'Доступно: ${money(s.available)}', chips: const [5000, 10000, -1], all: () => s.available, selectLabel: 'Карта для вывода', options: s.cards.isEmpty ? const ['Добавьте карту'] : [for (final x in s.cards) x.mask], onManage: () => showCardsSheet(c, s), cta: 'Вывести', go: (a, m) {
      if (s.cards.isEmpty) return 'Сначала добавьте карту в способах выплат.';
      final e = s.withdraw(a.toString(), m!);
      if (e != null) return e;
      toast(c, 'Заявка создана, сумма зарезервирована.');
      return null;
    });
  }

  void _qrMenu(BuildContext c, AppState s) {
    sheet(c, (ctx) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      h3('Kaspi QR'),
      Container(
        decoration: BoxDecoration(color: kSolid, borderRadius: BorderRadius.circular(18)),
        child: Column(children: [
          ListTile(leading: toneIcon(Icons.qr_code_2, Tone.red), title: const Text('Принять оплату на сумму', style: TextStyle(fontWeight: FontWeight.w500)), subtitle: const Text('QR на конкретную сумму', style: TextStyle(fontSize: 12)), trailing: const Icon(Icons.chevron_right, size: 18), onTap: () {
            Navigator.pop(ctx);
            _qrPay(c, s);
          }),
          Divider(height: 1, indent: 16, color: kLine),
          ListTile(leading: toneIcon(Icons.qr_code_2, Tone.blue), title: const Text('Постоянный QR', style: TextStyle(fontWeight: FontWeight.w500)), subtitle: const Text('Пассажир вводит сумму сам', style: TextStyle(fontSize: 12)), trailing: const Icon(Icons.chevron_right, size: 18), onTap: () {
            Navigator.pop(ctx);
            _qrStatic(c);
          }),
        ]),
      ),
    ]));
  }

  void _qrPay(BuildContext c, AppState s) {
    _keypad(c, title: 'Принять оплату · Kaspi QR', sub: 'Пассажир сканирует QR в приложении Kaspi', chips: const [1000, 2000, 5000, 10000], cta: 'Показать QR', go: (a, _) {
      if (a > 1000000) return 'Слишком большая сумма.';
      Future.microtask(() {
        if (c.mounted) _qrShow(c, s, a);
      });
      return null;
    });
  }

  void _qrShow(BuildContext c, AppState s, int a) {
    sheet(c, (ctx) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      h3('Покажите QR пассажиру'),
      Center(child: _QrBox('TULPAR-DEMO|PAY|${s.nidn()}|$a')),
      const SizedBox(height: 8),
      Center(child: Text(money(a), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700))),
      const SizedBox(height: 6),
      const Center(child: StatusChip('Ожидает оплаты')),
      const SizedBox(height: 12),
      PrimaryButton('Имитировать оплату (демо)', onPressed: () {
        s.qrPaid(a);
        s.setAcct('ya');
        Navigator.pop(ctx);
        toast(c, 'Оплата получена: ${money(a)} (демо)');
      }),
      const SizedBox(height: 8),
      PrimaryButton('Отменить', outline: true, onPressed: () => Navigator.pop(ctx)),
      const SizedBox(height: 8),
      banner('Демо: настоящий платёж подтверждает Kaspi. Кнопка выше имитирует подтверждение.', info: true),
    ]));
  }

  void _qrStatic(BuildContext c) {
    sheet(c, (ctx) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      h3('Постоянный QR'),
      const Center(child: _QrBox('TULPAR-DEMO|DRIVER|TLP7K2')),
      const SizedBox(height: 8),
      Center(child: Text('Пассажир сканирует код и вводит сумму сам', style: TextStyle(color: kMut, fontSize: 13))),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: PrimaryButton('Сохранить', outline: true, onPressed: () => toast(c, 'QR сохранён в Фото (демо)'))),
        const SizedBox(width: 10),
        Expanded(child: PrimaryButton('Поделиться', onPressed: () => toast(c, 'Откроется системное меню «Поделиться»'))),
      ]),
      const SizedBox(height: 12),
      banner('Демонстрационный код: он не принимает платежи. Настоящий QR формируется официальным сервисом Kaspi после подключения.', info: true),
    ]));
  }

  void _keypad(BuildContext c, {required String title, String? sub, required List<int> chips, int Function()? all, String? selectLabel, List<String>? options, VoidCallback? onManage, required String cta, required String? Function(int, String?) go}) {
    sheet(c, (ctx) => _Keypad(title: title, sub: sub, chips: chips, all: all, selectLabel: selectLabel, options: options, onManage: onManage, cta: cta, go: (a, m) {
          final e = go(a, m);
          if (e == null) Navigator.pop(ctx);
          return e;
        }));
  }

  void _cards(BuildContext c, AppState s) => showCardsSheet(c, s);

  void _addExpense(BuildContext c, AppState s) {
    final amount = TextEditingController(), desc = TextEditingController();
    String? err;
    sheet(c, (ctx) => StatefulBuilder(builder: (ctx, set) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      h3('Добавить расход'),
      TextField(controller: amount, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Сумма, ₸', hintText: '0')),
      const SizedBox(height: 10),
      TextField(controller: desc, maxLength: 80, decoration: const InputDecoration(labelText: 'На что потратили', hintText: 'Например: заправка, мойка, обед')),
      if (err != null) Padding(padding: const EdgeInsets.only(top: 4), child: Text(err!, style: TextStyle(color: kErr, fontWeight: FontWeight.w600, fontSize: 13))),
      const SizedBox(height: 10),
      PrimaryButton('Сохранить', onPressed: () {
        final e = s.addExpense(amount.text, desc.text);
        if (e != null) return set(() => err = e);
        Navigator.pop(ctx);
        toast(c, 'Расход сохранён: итоги обновлены');
      }),
    ])));
  }
}

class _Pill extends StatelessWidget {
  const _Pill(this.icon, this.label, this.onTap, {this.fill, required this.fg, required this.line});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? fill;
  final Color fg, line;
  @override
  Widget build(BuildContext context) {
    final w = GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        decoration: BoxDecoration(color: fill ?? Colors.transparent, borderRadius: BorderRadius.circular(18), border: Border.all(color: line), boxShadow: fill == kSolid ? kShadow : null),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 15, color: fg), const SizedBox(width: 6), Flexible(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: fg, fontSize: 13, fontWeight: FontWeight.w600)))]),
      ),
    );
    return Expanded(child: w);
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.bg, this.color, this.icon, this.title, this.sub, this.value);
  final List<Color> bg;
  final Color color;
  final IconData icon;
  final String title, sub, value;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: bg), borderRadius: BorderRadius.circular(20), border: Border.all(color: kBorder), boxShadow: kShadow),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          IconBox(icon, bg: kDark ? const Color(0x1FFFFFFF) : Colors.white, fg: color, size: 26),
          const SizedBox(height: 6),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, height: 16 / 13)),
          FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, height: 21 / 16, letterSpacing: -.5))),
          Text(sub, style: TextStyle(color: kMut, fontSize: 11, height: 13 / 11)),
        ]),
      );
}

class _QrBox extends StatelessWidget {
  const _QrBox(this.data);
  final String data;
  @override
  Widget build(BuildContext context) => Container(
        width: 210,
        height: 210,
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: kShadow),
        child: QrImageView(data: data, padding: EdgeInsets.zero, backgroundColor: Colors.white),
      );
}

/// Ввод суммы: крупное число, быстрые суммы и цифровая клавиатура.
class _Keypad extends StatefulWidget {
  const _Keypad({required this.title, this.sub, required this.chips, this.all, this.selectLabel, this.options, this.onManage, required this.cta, required this.go});
  final String title, cta;
  final String? sub, selectLabel;
  final List<int> chips;
  final int Function()? all;
  final List<String>? options;
  final VoidCallback? onManage;
  final String? Function(int, String?) go;
  @override
  State<_Keypad> createState() => _KeypadState();
}

class _KeypadState extends State<_Keypad> {
  String val = '';
  String? err, sel;

  @override
  void initState() {
    super.initState();
    sel = widget.options?.first;
  }

  void key(String k) => setState(() {
        err = null;
        if (k == 'back') {
          if (val.isNotEmpty) val = val.substring(0, val.length - 1);
        } else {
          if (val.isEmpty && (k == '0' || k == '000')) return;
          if ((val + k).length > 7) return;
          val += k;
        }
      });

  @override
  Widget build(BuildContext context) {
    final amount = val.isEmpty ? 0 : int.parse(val);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Center(child: Text(widget.title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700))),
      if (widget.sub != null) Center(child: Text(widget.sub!, style: TextStyle(color: kMut, fontSize: 12))),
      Container(
        margin: const EdgeInsets.only(top: 10, bottom: 2),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: kSolid, borderRadius: BorderRadius.circular(18)),
        child: Column(children: [Text('Введите сумму', style: TextStyle(color: kMut, fontSize: 12)), Text(money(amount), style: const TextStyle(fontSize: 34, height: 42 / 34, fontWeight: FontWeight.w700, letterSpacing: -1))]),
      ),
      SizedBox(height: 22, child: Center(child: Text(err ?? '', style: TextStyle(color: kErr, fontSize: 13, fontWeight: FontWeight.w600)))),
      Wrap(alignment: WrapAlignment.center, spacing: 6, runSpacing: 6, children: [
        for (final c in widget.chips)
          GestureDetector(
            onTap: () => setState(() {
              err = null;
              val = (c == -1 ? widget.all!() : c).toString();
            }),
            child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6), decoration: BoxDecoration(color: kSolid, borderRadius: BorderRadius.circular(15), boxShadow: kShadow), child: Text(c == -1 ? 'Всё' : money(c).replaceAll(' ₸', ''), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
          ),
      ]),
      if (widget.options != null) ...[
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(initialValue: sel, decoration: InputDecoration(labelText: widget.selectLabel), items: [for (final o in widget.options!) DropdownMenuItem(value: o, child: Text(o))], onChanged: (v) => sel = v),
        if (widget.onManage != null) Align(alignment: Alignment.centerLeft, child: TextButton(onPressed: widget.onManage, style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 4), minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap), child: Text('Добавить или удалить карту', style: TextStyle(color: kBlue, fontSize: 13)))),
      ],
      const SizedBox(height: 10),
      PrimaryButton(widget.cta, onPressed: () {
        if (amount <= 0) return setState(() => err = 'Введите сумму.');
        final e = widget.go(amount, sel);
        if (e != null) setState(() => err = e);
      }),
      const SizedBox(height: 10),
      GridView.count(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 2.4,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          for (final k in const ['1', '2', '3', '4', '5', '6', '7', '8', '9', '000', '0', 'back'])
            GestureDetector(
              onTap: () => key(k),
              child: Container(decoration: BoxDecoration(color: kSolid, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Color(0x0F000000), blurRadius: 2, offset: Offset(0, 1))]), alignment: Alignment.center, child: k == 'back' ? const Icon(Icons.backspace_outlined, size: 20) : Text(k, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500))),
            ),
        ],
      ),
    ]);
  }
}

/// Транзакции выбранного счёта + «Мои расходы».
class _History extends StatelessWidget {
  const _History({required this.s, required this.onCards});
  final AppState s;
  final VoidCallback onCards;

  Widget _seg(List<(String, String)> items, String cur, void Function(String) on) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(color: kFill, borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          for (final (k, label) in items)
            Expanded(child: GestureDetector(
              onTap: () => on(k),
              child: Container(height: 30, alignment: Alignment.center, decoration: BoxDecoration(color: cur == k ? kInk : Colors.transparent, borderRadius: BorderRadius.circular(10)), child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: cur == k ? kOn : kMut))),
            )),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    final mode = _seg(const [('ops', 'Транзакции'), ('exp', 'Мои расходы')], s.histMode, s.setHistMode);
    if (s.histMode == 'exp') {
      final list = s.expenses.reversed.toList();
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        mode,
        if (list.isEmpty) Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Text('Расходов пока нет.', style: TextStyle(color: kMut))) else Padding(padding: EdgeInsets.only(top: 2, bottom: 2), child: Text('Сегодня', style: TextStyle(color: kMut, fontSize: 13, fontWeight: FontWeight.w600))),
        for (final e in list)
          InkWell(
            onTap: () => sheet(context, (ctx) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              h3(e.desc),
              Container(padding: const EdgeInsets.symmetric(horizontal: 14), decoration: BoxDecoration(color: kSolid, borderRadius: BorderRadius.circular(18)), child: Column(children: [kv('Сумма', money(e.amount)), kv('Время', 'Сегодня, ${e.time}')])),
              const SizedBox(height: 10),
              StatusChip(e.cancelled ? 'Отменён' : 'Выполнена'),
              if (!e.cancelled) ...[
                const SizedBox(height: 12),
                PrimaryButton('Отменить расход', outline: true, onPressed: () {
                  s.cancelExpense(e.id);
                  Navigator.pop(ctx);
                  toast(context, 'Расход отменён. Запись сохранена в журнале аудита.');
                }),
                note('Запись не удаляется: статус меняется, действие фиксируется в журнале аудита.'),
              ],
            ])),
            child: Container(
              constraints: const BoxConstraints(minHeight: 52),
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Row(children: [
                toneIcon(_opIcon('Расход', e.desc), Tone.gray),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(e.desc, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15, decoration: e.cancelled ? TextDecoration.lineThrough : null)), Text('Сегодня, ${e.time}', style: TextStyle(color: kMut, fontSize: 12))])),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text('−${money(e.amount)}', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, decoration: e.cancelled ? TextDecoration.lineThrough : null)), if (e.cancelled) const StatusChip('Отменён')]),
              ]),
            ),
          ),
      ]);
    }
    final isYa = s.acct == 'ya';
    final labels = isYa ? const [('all', 'Все'), ('in', 'Пополнение'), ('out', 'Вывод')] : const [('all', 'Все'), ('in', 'Начисления'), ('out', 'Вывод')];
    final list = s.ops.where((o) => o.acct == s.acct && (s.histTab == 'all' || (s.histTab == 'in' ? o.amount > 0 : o.amount < 0))).toList()..sort((a, b) => b.ts.compareTo(a.ts));
    final rows = <Widget>[];
    String? last;
    for (final o in list) {
      final g = _day(s, o.ts);
      if (g != last) {
        rows.add(Padding(padding: const EdgeInsets.only(top: 10, bottom: 2), child: Text(g, style: TextStyle(color: kMut, fontSize: 13, fontWeight: FontWeight.w600))));
        last = g;
      }
      rows.add(OpTile(o));
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      mode,
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(isYa ? 'Яндекс баланс' : 'Депозит-карта Tulpar Line', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
        if (isYa) GestureDetector(onTap: onCards, child: const Text('Мои карты ›', style: TextStyle(color: kBlue, fontSize: 13))),
      ]),
      const SizedBox(height: 8),
      Row(children: [
        for (final (k, label) in labels)
          GestureDetector(
            onTap: () => s.setHistTab(k),
            child: Container(margin: const EdgeInsets.only(right: 6), height: 30, padding: const EdgeInsets.symmetric(horizontal: 12), alignment: Alignment.center, decoration: BoxDecoration(color: s.histTab == k ? kInk : kFill, borderRadius: BorderRadius.circular(15)), child: Text(label, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500, color: s.histTab == k ? kOn : kMut))),
          ),
      ]),
      if (rows.isEmpty) Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Text('Транзакций нет.', style: TextStyle(color: kMut))),
      ...rows,
    ]);
  }
}

// ---------- карты счетов ----------
class _Slide extends StatelessWidget {
  const _Slide({required this.card, required this.pills});
  final Widget card;
  final List<Widget> pills;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(right: 10),
        child: Column(children: [
          AspectRatio(aspectRatio: 1.62, child: card),
          const SizedBox(height: 10),
          Row(children: [for (var i = 0; i < pills.length; i++) ...[if (i > 0) const SizedBox(width: 8), pills[i]]]),
        ]),
      );
}

class _YaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size z) {
    final sx = z.width / 340, sy = z.height / 200;
    Offset o(double x, double y) => Offset(x * sx, y * sy);
    canvas.drawRect(Offset.zero & z, Paint()..shader = const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF34383A), Color(0xFF262829), Color(0xFF1D1E1F)], stops: [0, .55, 1]).createShader(Offset.zero & z));
    final p = Path()..moveTo(o(-10, -10).dx, o(-10, -10).dy);
    void l(double x, double y) => p.lineTo(x * sx, y * sy);
    void q(double cx, double cy, double x, double y) => p.quadraticBezierTo(cx * sx, cy * sy, x * sx, y * sy);
    l(18, -10); l(74, 54); q(110, 78, 146, 54); l(196, -10); l(226, -10); l(160, 70); q(134, 100, 160, 130); l(226, 210); l(196, 210); l(146, 146); q(110, 122, 74, 146); l(18, 210); l(-10, 210); l(46, 146); q(90, 100, 46, 54);
    p.close();
    canvas.drawPath(p, Paint()..color = const Color(0xFFF5B800));
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _WingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size z) {
    final sx = z.width / 340, sy = z.height / 200;
    final line = Paint()..style = PaintingStyle.stroke..strokeWidth = 1.4..strokeCap = StrokeCap.round;
    const arcs = [
      [10.0, 200.0, 70.0, 150.0, 120.0, 90.0, 230.0, 40.0, .34],
      [40.0, 200.0, 100.0, 160.0, 150.0, 110.0, 250.0, 66.0, .26],
      [70.0, 200.0, 130.0, 170.0, 180.0, 128.0, 270.0, 92.0, .2],
      [100.0, 200.0, 160.0, 178.0, 205.0, 146.0, 290.0, 118.0, .15],
      [130.0, 200.0, 185.0, 186.0, 230.0, 164.0, 310.0, 144.0, .1],
    ];
    for (final a in arcs) {
      line.color = Colors.white.withValues(alpha: a[8]);
      canvas.drawPath(Path()..moveTo(a[0] * sx, a[1] * sy)..cubicTo(a[2] * sx, a[3] * sy, a[4] * sx, a[5] * sy, a[6] * sx, a[7] * sy), line);
    }
    line.strokeWidth = 1.2;
    line.color = Colors.white.withValues(alpha: .08);
    canvas.drawCircle(Offset(262 * sx, 52 * sy), 64 * sx, line);
    line.color = Colors.white.withValues(alpha: .05);
    canvas.drawCircle(Offset(262 * sx, 52 * sy), 96 * sx, line);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _YandexCard extends StatelessWidget {
  const _YandexCard({required this.amount, required this.hidden, required this.onEye, required this.onInfo, this.note});
  final String amount;
  final String? note;
  final bool hidden;
  final VoidCallback onEye, onInfo;
  @override
  Widget build(BuildContext context) => Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .5), blurRadius: 30, offset: const Offset(0, 16), spreadRadius: -16)]),
        child: LayoutBuilder(builder: (_, cs) => Stack(children: [
              Positioned.fill(child: CustomPaint(painter: _YaPainter())),
              const Positioned(right: 14, top: 10, child: Text('Яндекс Про', style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w700, letterSpacing: -.6))),
              Positioned(
                right: 14,
                bottom: 36,
                width: cs.maxWidth * .72,
                child: Column(crossAxisAlignment: CrossAxisAlignment.end, mainAxisSize: MainAxisSize.min, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    const Text('Доступный баланс', style: TextStyle(color: Color(0xB3FFFFFF), fontSize: 11.5)),
                    const SizedBox(width: 6),
                    GestureDetector(onTap: onEye, child: Icon(hidden ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.white70, size: 16)),
                  ]),
                  FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerRight, child: Text(amount, style: const TextStyle(color: Colors.white, fontSize: 38, height: 44 / 38, fontWeight: FontWeight.w700, letterSpacing: -1.4))),
                  if (note != null) Text(note!, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xB3FFFFFF), fontSize: 11.5)),
                ]),
              ),
              Positioned(right: 12, bottom: 10, child: GestureDetector(onTap: onInfo, child: Container(width: 22, height: 22, decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0x40000000), border: Border.all(color: Colors.white54)), alignment: Alignment.center, child: const Text('i', style: TextStyle(color: Colors.white, fontSize: 12, fontStyle: FontStyle.italic, fontWeight: FontWeight.w600))))),
            ])),
      );
}

class _TulparCard extends StatelessWidget {
  const _TulparCard({required this.amount, required this.note});
  final String amount, note;
  @override
  Widget build(BuildContext context) => Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), gradient: const RadialGradient(center: Alignment(.7, -1), radius: 1.5, colors: [Color(0xFF2C2C31), Color(0xFF121216), Color(0xFF09090B)], stops: [0, .55, 1]), border: Border.all(color: const Color(0x1FFFFFFF)), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .55), blurRadius: 30, offset: const Offset(0, 16), spreadRadius: -16)]),
        child: LayoutBuilder(builder: (_, cs) => Stack(children: [
              Positioned.fill(child: CustomPaint(painter: _WingPainter())),
              Positioned(right: -18, top: -22, child: Opacity(opacity: .1, child: Container(width: 190, height: 190, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: .6)), alignment: Alignment.center, child: const Icon(Icons.navigation, size: 110, color: Colors.white)))),
              Positioned(left: 14, top: 12, child: Row(children: [
                Container(width: 24, height: 24, decoration: const BoxDecoration(color: Color(0x8CFFFFFF), shape: BoxShape.circle), alignment: Alignment.center, child: const Icon(Icons.navigation, size: 13, color: kBlack)),
                const SizedBox(width: 8),
                const Text('Tulpar Line', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: .1)),
              ])),
              Positioned(
                left: 14,
                right: 14,
                bottom: 12,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                  const Text('Депозит-карта · бонус от таксопарка', style: TextStyle(color: Color(0xB3FFFFFF), fontSize: 11.5)),
                  FittedBox(fit: BoxFit.scaleDown, child: Text(amount, style: const TextStyle(color: Colors.white, fontSize: 38, height: 44 / 38, fontWeight: FontWeight.w700, letterSpacing: -1.4))),
                  Text(note, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xB3FFFFFF), fontSize: 11.5)),
                ]),
              ),
            ])),
      );
}

// ---------- способы выплат: добавить / удалить карту ----------
void showCardsSheet(BuildContext c, AppState s) {
  sheet(c, (ctx) => AnimatedBuilder(animation: s, builder: (_, _) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        h3('Способы выплат'),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(color: kSolid, borderRadius: BorderRadius.circular(18)),
          child: s.cards.isEmpty
              ? Padding(padding: const EdgeInsets.symmetric(vertical: 14), child: Text('Карт пока нет. Добавьте карту, чтобы выводить деньги.', style: TextStyle(color: kMut, fontSize: 13)))
              : Column(children: [
                  for (final x in s.cards)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(children: [
                        toneIcon(Icons.credit_card, Tone.blue),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(x.mask, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
                          if (x.main) Text('Основная · для вывода', style: TextStyle(color: kMut, fontSize: 12)) else GestureDetector(onTap: () {
                            s.makeMain(x.id);
                            toast(c, 'Основная карта изменена');
                          }, child: Text('Сделать основной', style: TextStyle(color: kBlue, fontSize: 12))),
                        ])),
                        GestureDetector(onTap: () => _cardAskDel(c, s, x), child: Container(width: 36, height: 36, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0x1FFF4D5A)), child: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFFF4D5A)))),
                      ]),
                    ),
                ]),
        ),
        const SizedBox(height: 12),
        PrimaryButton('+ Добавить карту', onPressed: () => _cardAdd(c, s)),
        note('Хранятся только банк и последние 4 цифры. Полный номер карты приложение не запрашивает.'),
      ])));
}

void _cardAskDel(BuildContext c, AppState s, BankCard card) {
  sheet(c, (ctx) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        h3('Удалить карту?'),
        note('${card.mask} будет удалена из способов выплат. Уже созданные заявки не изменятся.'),
        PrimaryButton('Удалить', onPressed: () {
          s.removeCard(card.id);
          Navigator.pop(ctx);
          toast(c, 'Карта удалена');
        }),
        const SizedBox(height: 8),
        PrimaryButton('Отмена', outline: true, onPressed: () => Navigator.pop(ctx)),
      ]));
}

void _cardAdd(BuildContext c, AppState s) {
  final ctl = TextEditingController();
  var bank = 'Kaspi';
  String? err;
  sheet(c, (ctx) => StatefulBuilder(builder: (ctx, set) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        h3('Новая карта'),
        DropdownButtonFormField<String>(initialValue: bank, decoration: const InputDecoration(labelText: 'Банк'), items: const [DropdownMenuItem(value: 'Kaspi', child: Text('Kaspi')), DropdownMenuItem(value: 'Halyk', child: Text('Halyk')), DropdownMenuItem(value: 'Другой банк', child: Text('Другой банк'))], onChanged: (v) => bank = v ?? bank),
        const SizedBox(height: 10),
        TextField(controller: ctl, keyboardType: TextInputType.number, maxLength: 4, decoration: const InputDecoration(labelText: 'Последние 4 цифры карты', hintText: '0000')),
        if (err != null) Padding(padding: const EdgeInsets.only(top: 4), child: Text(err!, style: TextStyle(color: kErr, fontWeight: FontWeight.w600, fontSize: 13))),
        const SizedBox(height: 10),
        PrimaryButton('Добавить', onPressed: () {
          final e = s.addCard(bank, ctl.text);
          if (e != null) return set(() => err = e);
          Navigator.pop(ctx);
          toast(c, 'Карта добавлена');
        }),
      ])));
}
