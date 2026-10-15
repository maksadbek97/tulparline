import 'package:flutter/material.dart';

import '../main.dart';
import '../state.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../ui.dart';
import 'service.dart' show ScreenHead;

IconData _opIcon(Op o) {
  switch (o.type) {
    case 'Доход':
      return Icons.directions_car_outlined;
    case 'Пополнение':
      return Icons.south_rounded;
    case 'Оплата QR':
      return Icons.qr_code_2;
    case 'Выплата':
      return Icons.north_east_rounded;
    case 'Начисление':
      return Icons.card_giftcard;
    case 'Расход':
      return RegExp('Топл|Заправ|бензин|АЗС', caseSensitive: false).hasMatch(o.desc) ? Icons.local_gas_station_outlined : RegExp('Ремонт|Масл|Шин|Мойк', caseSensitive: false).hasMatch(o.desc) ? Icons.build_outlined : Icons.receipt_long_outlined;
    default:
      return Icons.description_outlined;
  }
}

Tone _opTone(Op o) => switch (o.type) {
      'Пополнение' => Tone.green,
      'Оплата QR' => Tone.red,
      'Выплата' => Tone.blue,
      'Начисление' => Tone.amber,
      'Корректировка' => Tone.violet,
      _ => Tone.gray,
    };

class OpTile extends StatelessWidget {
  const OpTile(this.o, {super.key});
  final Op o;
  @override
  Widget build(BuildContext context) {
    final pos = o.amount > 0, cancelled = o.status == 'Отменён';
    final deco = cancelled || o.status == 'Отклонена' ? TextDecoration.lineThrough : null;
    return InkWell(
      onTap: () => _detail(context, o),
      child: Container(
        constraints: const BoxConstraints(minHeight: 50),
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(children: [
          toneIcon(_opIcon(o), _opTone(o)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(o.desc, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15, height: 22 / 17, letterSpacing: -.3, decoration: deco)),
            Text(o.date, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: kMut, fontSize: 13, height: 18 / 14)),
          ])),
          const SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('${pos ? '+' : ''}${money(o.amount)}', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, letterSpacing: -.3, color: pos ? kOk : kInk, decoration: deco)),
            if (o.status != 'Выполнена') StatusChip(o.status) else if (o.id.startsWith('#')) Text(o.id, style: const TextStyle(color: kMut, fontSize: 12)),
          ]),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right, size: 17, color: Color(0xFFB4B9C8)),
        ]),
      ),
    );
  }

  void _detail(BuildContext context, Op o) {
    final s = AppScope.of(context);
    sheet(context, (ctx) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      h3(o.desc),
      kv('ID', o.id), kv('Тип', o.type), kv('Дата', o.date), kv('Сумма', money(o.amount)), kv('Источник', o.src),
      Padding(padding: const EdgeInsets.only(top: 4), child: StatusChip(o.status)),
      if (o.ref != null && o.status != 'Отменён') ...[
        const SizedBox(height: 14),
        PrimaryButton('Отменить расход', outline: true, onPressed: () {
          s.cancelExpense(o.ref!);
          Navigator.pop(ctx);
          toast(context, 'Расход отменён. Запись сохранена в журнале аудита.');
        }),
        note('Запись не удаляется: статус меняется, действие фиксируется в журнале аудита.'),
      ],
    ]));
  }
}

class FinancePage extends StatelessWidget {
  const FinancePage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final tt = s.totals(), net = tt.inc - tt.exp;
    final pl = s.period == Period.day ? 'за день' : periodLabel[s.period]!.toLowerCase();
    return ListView(padding: const EdgeInsets.fromLTRB(kM, 4, kM, 120), children: [
      ScreenHead('Финансы', trailing: GestureDetector(
        onTap: () => _periodPick(context, s),
        child: Container(height: 34, padding: const EdgeInsets.symmetric(horizontal: 12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(17), boxShadow: kShadow), child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.calendar_today_outlined, size: 16), const SizedBox(width: 8), Text(periodLabel[s.period]!, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)), const Icon(Icons.keyboard_arrow_down, size: 20)])),
      )),
      if (!s.synced) banner('Данные не синхронизированы с Yandex. Показаны последние известные значения (обновлено в 14:20).'),
      DarkCard(
        car: 'assets/car-rear.png',
        carWidth: .56,
        carRight: -24,
        carBottom: 30,
        glow: true,
        glowRight: 62,
        glowTop: 14,
        minHeight: 184,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const LogoRow(),
            GestureDetector(onTap: () => _info(context, s), child: Container(width: 28, height: 28, decoration: const BoxDecoration(color: Color(0x24FFFFFF), shape: BoxShape.circle), child: const Icon(Icons.more_horiz, color: Colors.white, size: 16))),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            const Text('Баланс', style: TextStyle(color: Colors.white70, fontSize: 14)),
            const SizedBox(width: 8),
            GestureDetector(onTap: () {
              s.hideBalance = !s.hideBalance;
              s.notify();
            }, child: Icon(s.hideBalance ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.white60, size: 16)),
          ]),
          Text(s.hideBalance ? '••••• ₸' : money(s.available), style: const TextStyle(color: Colors.white, fontSize: 34, height: 46 / 40, fontWeight: FontWeight.w700, letterSpacing: -1.4)),
          if (s.reserved > 0) Text('В резерве под заявки: ${money(s.reserved)}', style: const TextStyle(color: Colors.white60, fontSize: 12)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _BalBtn(Icons.add, 'Пополнить', true, () => _topup(context, s))),
            const SizedBox(width: 10),
            Expanded(child: _BalBtn(Icons.north_east, 'Вывести', false, () => _withdraw(context, s))),
          ]),
        ]),
      ),
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: _Stat(const [Color(0xFFE6F9ED), Color(0xFFF6FDF9)], const Color(0xFF12A050), Icons.trending_up, 'Доходы', pl, money(tt.inc))),
        const SizedBox(width: 10),
        Expanded(child: _Stat(const [Color(0xFFFFECEE), Color(0xFFFFF8F8)], const Color(0xFFE0384A), Icons.trending_down, 'Расходы', pl, money(tt.exp))),
        const SizedBox(width: 10),
        Expanded(child: _Stat(const [Color(0xFFEEEBFF), Color(0xFFF9F8FF)], kIndigo, Icons.bar_chart_rounded, 'Чистый результат', pl, money(net))),
      ]),
      const SizedBox(height: 12),
      // «Добавить расход» — перед графиком
      GestureDetector(
        onTap: () => _addExpense(context, s),
        child: Container(
          height: 44,
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF1D1E24), Color(0xFF050506)]), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .45), blurRadius: 28, offset: const Offset(0, 16), spreadRadius: -16)]),
          child: Stack(alignment: Alignment.center, children: [
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(width: 24, height: 24, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: const Icon(Icons.add, size: 16, color: kInk)),
              const SizedBox(width: 12),
              const Text('Добавить расход', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 16)),
            ]),
            const Positioned(right: 16, child: Icon(Icons.chevron_right, color: Colors.white60, size: 20)),
          ]),
        ),
      ),
      // Принять оплату через Kaspi QR — компактные кнопки на месте графика
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(children: [
          Expanded(flex: 3, child: _QrBtn(Icons.qr_code_2, 'Принять оплату · Kaspi QR', true, () => _qrPay(context, s))),
          const SizedBox(width: 8),
          Expanded(flex: 2, child: _QrBtn(null, 'Постоянный QR', false, () => _qrStatic(context))),
        ]),
      ),
      AppCard(padding: const EdgeInsets.fromLTRB(14, 12, 14, 6), child: _History(s: s, onCard: (c) => _cardOpen(context, s, c), onAddCard: () => _cardAdd(context, s))),
    ]);
  }

  // ----- sheets -----
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
      const Text('Здесь показан баланс приложения Tulpar Line. Баланс Yandex и бонусный баланс депозит-карты — отдельные суммы, они не складываются.'),
      const SizedBox(height: 10),
      kv('Баланс приложения', money(s.available)), kv('Баланс Yandex', 'не синхронизирован (демо)'), kv('Депозит-карта', money(s.depBalance)),
    ]));
  }

  void _topup(BuildContext c, AppState s) {
    final ctl = TextEditingController();
    var method = 'Kaspi';
    String? err;
    sheet(c, (ctx) => StatefulBuilder(builder: (ctx, set) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      h3('Пополнить баланс'),
      TextField(controller: ctl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Сумма, ₸', hintText: 'Например, 10000')),
      const SizedBox(height: 10),
      DropdownButtonFormField<String>(initialValue: method, decoration: const InputDecoration(labelText: 'Способ'), items: const [DropdownMenuItem(value: 'Kaspi', child: Text('Kaspi (нужен подтверждённый сценарий)')), DropdownMenuItem(value: 'карту', child: Text('Банковская карта'))], onChanged: (v) => method = v ?? method),
      if (err != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(err!, style: const TextStyle(color: kErr, fontWeight: FontWeight.w600, fontSize: 13))),
      const SizedBox(height: 10),
      PrimaryButton('Создать платёж', onPressed: () {
        final e = s.topup(ctl.text, method);
        if (e != null) return set(() => err = e);
        Navigator.pop(ctx);
        toast(c, 'Платёж создан. Баланс обновится после подтверждения провайдером.');
      }),
      note('Баланс увеличится только после подтверждения платежа сервером через официальный механизм провайдера. Возврат в приложение — не подтверждение.'),
    ])));
  }

  void _withdraw(BuildContext c, AppState s) {
    final ctl = TextEditingController();
    String? err;
    var card = s.cards.isEmpty ? null : (s.cards.firstWhere((x) => x.main, orElse: () => s.cards.first)).mask;
    sheet(c, (ctx) => StatefulBuilder(builder: (ctx, set) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      h3('Вывести с баланса'),
      Text('Доступно: ${money(s.available)}', style: const TextStyle(color: kMut)),
      const SizedBox(height: 10),
      TextField(controller: ctl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Сумма, ₸', hintText: 'Минимум 1 000')),
      const SizedBox(height: 10),
      if (s.cards.isEmpty)
        const Text('Добавьте карту в «Мои карты», чтобы вывести деньги.', style: TextStyle(color: kMut))
      else
        DropdownButtonFormField<String>(initialValue: card, decoration: const InputDecoration(labelText: 'Карта для вывода'), items: [for (final x in s.cards) DropdownMenuItem(value: x.mask, child: Text(x.mask))], onChanged: (v) => card = v ?? card),
      if (err != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(err!, style: const TextStyle(color: kErr, fontWeight: FontWeight.w600, fontSize: 13))),
      const SizedBox(height: 10),
      PrimaryButton('Создать заявку', onPressed: () {
        if (card == null) return set(() => err = 'Сначала добавьте карту.');
        final e = s.withdraw(ctl.text, card!);
        if (e != null) return set(() => err = e);
        Navigator.pop(ctx);
        toast(c, 'Заявка создана, сумма зарезервирована.');
      }),
      note('Лимиты: от 1 000 ₸ (демо, утверждает владелец). Мгновенный вывод не обещается — срок обработки сообщит таксопарк. Статусы: Создана → На проверке → В обработке → Выполнена / Отклонена.'),
    ])));
  }

  // ----- Kaspi QR -----
  void _qrPay(BuildContext c, AppState s) {
    final ctl = TextEditingController();
    String? err;
    int? amount;
    sheet(c, (ctx) => StatefulBuilder(builder: (ctx, set) {
      if (amount == null) {
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          h3('Принять оплату · Kaspi QR'),
          TextField(controller: ctl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Сумма к оплате, ₸', hintText: '0')),
          if (err != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(err!, style: const TextStyle(color: kErr, fontWeight: FontWeight.w600, fontSize: 13))),
          const SizedBox(height: 10),
          PrimaryButton('Показать QR', onPressed: () {
            final a = int.tryParse(ctl.text.replaceAll(RegExp(r'\s'), ''));
            if (a == null || a <= 0) return set(() => err = 'Введите сумму: целое число больше нуля.');
            if (a > 1000000) return set(() => err = 'Слишком большая сумма.');
            set(() => amount = a);
          }),
          note('Пассажир сканирует QR в приложении Kaspi. Деньги поступят на баланс после подтверждения платежа Kaspi.'),
        ]);
      }
      final a = amount!;
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        h3('Покажите QR пассажиру'),
        Center(child: _QrBox('TULPAR-DEMO|PAY|${s.nidn()}|$a')),
        const SizedBox(height: 10),
        Center(child: Text(money(a), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700))),
        const SizedBox(height: 6),
        const Center(child: StatusChip('Ожидает оплаты')),
        const SizedBox(height: 12),
        PrimaryButton('Имитировать оплату (демо)', onPressed: () {
          s.qrPaid(a);
          Navigator.pop(ctx);
          toast(c, 'Оплата получена: ${money(a)} (демо)');
        }),
        const SizedBox(height: 8),
        PrimaryButton('Отменить', outline: true, onPressed: () => Navigator.pop(ctx)),
        const SizedBox(height: 8),
        banner('Демо: настоящий платёж подтверждает Kaspi. Кнопка выше имитирует подтверждение.', info: true),
      ]);
    }));
  }

  void _qrStatic(BuildContext c) {
    sheet(c, (ctx) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      h3('Постоянный QR'),
      const Center(child: _QrBox('TULPAR-DEMO|DRIVER|TLP7K2')),
      const SizedBox(height: 8),
      const Center(child: Text('Пассажир сканирует код и вводит сумму сам', style: TextStyle(color: kMut, fontSize: 13))),
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

  // ----- карты -----
  void _cardOpen(BuildContext c, AppState s, BankCard card) {
    sheet(c, (ctx) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      h3(card.mask),
      note('Номер карты скрыт. Карта используется для вывода средств.'),
      if (!card.main) ...[
        PrimaryButton('Сделать основной', onPressed: () {
          s.makeMain(card.id);
          Navigator.pop(ctx);
          toast(c, 'Основная карта изменена');
        }),
        const SizedBox(height: 8),
      ],
      PrimaryButton('Удалить карту', outline: true, onPressed: () {
        s.removeCard(card.id);
        Navigator.pop(ctx);
        toast(c, 'Карта удалена');
      }),
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
      if (err != null) Padding(padding: const EdgeInsets.only(top: 4), child: Text(err!, style: const TextStyle(color: kErr, fontWeight: FontWeight.w600, fontSize: 13))),
      const SizedBox(height: 10),
      PrimaryButton('Добавить', onPressed: () {
        final e = s.addCard(bank, ctl.text);
        if (e != null) return set(() => err = e);
        Navigator.pop(ctx);
        toast(c, 'Карта добавлена');
      }),
    ])));
  }

  void _addExpense(BuildContext c, AppState s) {
    final amount = TextEditingController(), desc = TextEditingController();
    String? err;
    sheet(c, (ctx) => StatefulBuilder(builder: (ctx, set) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      h3('Добавить расход'),
      TextField(controller: amount, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Сумма, ₸', hintText: '0')),
      const SizedBox(height: 10),
      TextField(controller: desc, maxLength: 80, decoration: const InputDecoration(labelText: 'На что потратили', hintText: 'Например: заправка, мойка, обед')),
      if (err != null) Padding(padding: const EdgeInsets.only(top: 4), child: Text(err!, style: const TextStyle(color: kErr, fontWeight: FontWeight.w600, fontSize: 13))),
      const SizedBox(height: 10),
      PrimaryButton('Сохранить', onPressed: () {
        final e = s.addExpense(amount.text, desc.text);
        if (e != null) return set(() => err = e);
        Navigator.pop(ctx);
        toast(c, 'Расход сохранён: итоги и график обновлены');
      }),
    ])));
  }
}

class _BalBtn extends StatelessWidget {
  const _BalBtn(this.icon, this.label, this.white, this.onTap);
  final IconData icon;
  final String label;
  final bool white;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          height: 38,
          decoration: BoxDecoration(color: white ? Colors.white : Colors.white.withValues(alpha: .16), borderRadius: BorderRadius.circular(19)),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(width: 22, height: 22, decoration: BoxDecoration(color: white ? kInk : const Color(0xFF0B0B0F), shape: BoxShape.circle), child: Icon(icon, size: 13, color: Colors.white)),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15, color: white ? kInk : Colors.white)),
          ]),
        ),
      );
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
        decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: bg), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white), boxShadow: kShadow),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          IconBox(icon, bg: Colors.white, fg: color, size: 26),
          const SizedBox(height: 6),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, height: 18 / 15)),
          FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, height: 24 / 19, letterSpacing: -.6))),
          Text(sub, style: const TextStyle(color: kMut, fontSize: 11.5, height: 15 / 12.5)),
        ]),
      );
}

class _QrBtn extends StatelessWidget {
  const _QrBtn(this.icon, this.label, this.red, this.onTap);
  final IconData? icon;
  final String label;
  final bool red;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          height: 40,
          decoration: BoxDecoration(color: red ? const Color(0xFFF14635) : Colors.white.withValues(alpha: .9), borderRadius: BorderRadius.circular(14), boxShadow: red ? [BoxShadow(color: const Color(0xFFF14635).withValues(alpha: .45), blurRadius: 20, offset: const Offset(0, 10), spreadRadius: -12)] : kShadow),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            if (icon != null) ...[Icon(icon, size: 18, color: Colors.white), const SizedBox(width: 8)],
            Flexible(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: red ? Colors.white : kInk))),
          ]),
        ),
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

/// История операций + «Мои карты»: фильтры, группировка по дням, ID и статусы.
class _History extends StatelessWidget {
  const _History({required this.s, required this.onCard, required this.onAddCard});
  final AppState s;
  final void Function(BankCard) onCard;
  final VoidCallback onAddCard;

  String _day(DateTime d) {
    final n = DateTime.now();
    final diff = DateTime(n.year, n.month, n.day).difference(DateTime(d.year, d.month, d.day)).inDays;
    return diff == 0 ? 'Сегодня' : diff == 1 ? 'Вчера' : s.dmy(d);
  }

  @override
  Widget build(BuildContext context) {
    final tabs = Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(color: const Color(0x21787F9E), borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        for (final (k, label) in const [('ops', 'История операций'), ('cards', 'Мои карты')])
          Expanded(child: GestureDetector(
            onTap: () => s.setHistMode(k),
            child: Container(height: 30, alignment: Alignment.center, decoration: BoxDecoration(color: s.histMode == k ? kInk : Colors.transparent, borderRadius: BorderRadius.circular(10)), child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: s.histMode == k ? Colors.white : const Color(0xFF5A6075)))),
          )),
      ]),
    );
    if (s.histMode == 'cards') {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        tabs,
        for (final c in s.cards)
          InkWell(
            onTap: () => onCard(c),
            child: Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Row(children: [
              toneIcon(Icons.credit_card, Tone.blue),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(c.mask, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)), const Text('Для вывода средств', style: TextStyle(color: kMut, fontSize: 12))])),
              if (c.main) const StatusChip('Основная'),
              const Icon(Icons.chevron_right, size: 16, color: Color(0xFFB4B9C8)),
            ])),
          ),
        const SizedBox(height: 6),
        PrimaryButton('+ Добавить карту', outline: true, onPressed: onAddCard),
        note('Хранятся только последние 4 цифры. Полный номер карты приложение не запрашивает.'),
      ]);
    }
    final type = {'all': null, 'in': 'Пополнение', 'out': 'Выплата', 'qr': 'Оплата QR'}[s.histTab];
    final list = s.ops.where((o) => type == null || o.type == type).toList()..sort((a, b) => b.ts.compareTo(a.ts));
    final rows = <Widget>[];
    String? last;
    for (final o in list) {
      final g = _day(o.ts);
      if (g != last) {
        rows.add(Padding(padding: const EdgeInsets.only(top: 10, bottom: 2), child: Text(g, style: const TextStyle(color: kMut, fontSize: 13, fontWeight: FontWeight.w600))));
        last = g;
      }
      rows.add(OpTile(o));
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      tabs,
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: [
          for (final (k, label) in const [('all', 'Все'), ('in', 'Пополнение'), ('out', 'Вывод'), ('qr', 'Оплаты QR')])
            GestureDetector(
              onTap: () => s.setHistTab(k),
              child: Container(margin: const EdgeInsets.only(right: 6), height: 30, padding: const EdgeInsets.symmetric(horizontal: 12), alignment: Alignment.center, decoration: BoxDecoration(color: s.histTab == k ? kInk : const Color(0x21787F9E), borderRadius: BorderRadius.circular(15)), child: Text(label, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500, color: s.histTab == k ? Colors.white : const Color(0xFF4A5066)))),
            ),
        ]),
      ),
      if (rows.isEmpty) const Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Text('Операций нет.', style: TextStyle(color: kMut))),
      ...rows,
    ]);
  }
}
