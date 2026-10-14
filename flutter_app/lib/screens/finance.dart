import 'package:flutter/material.dart';

import '../main.dart';
import '../state.dart';
import '../ui.dart';
import 'service.dart' show ScreenHead;

IconData _opIcon(Op o) {
  switch (o.type) {
    case 'Доход':
      return Icons.directions_car_outlined;
    case 'Пополнение':
      return Icons.south_rounded;
    case 'Выплата':
      return Icons.north_east_rounded;
    case 'Начисление':
      return Icons.card_giftcard;
    case 'Расход':
      return o.desc.contains('Топл') ? Icons.local_gas_station_outlined : RegExp('Ремонт|Масло|Шино|Мойк').hasMatch(o.desc) ? Icons.build_outlined : Icons.receipt_long_outlined;
    default:
      return Icons.description_outlined;
  }
}

Tone _opTone(Op o) => switch (o.type) {
      'Доход' || 'Пополнение' => Tone.green,
      'Выплата' => Tone.blue,
      'Начисление' => Tone.amber,
      'Расход' => Tone.red,
      _ => Tone.violet,
    };

class OpTile extends StatelessWidget {
  const OpTile(this.o, {super.key});
  final Op o;
  @override
  Widget build(BuildContext context) {
    final pos = o.amount > 0, cancelled = o.status == 'Отменён';
    final deco = cancelled ? TextDecoration.lineThrough : null;
    return InkWell(
      onTap: () => _detail(context, o),
      child: Container(
        constraints: const BoxConstraints(minHeight: 52),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(children: [
          toneIcon(_opIcon(o), _opTone(o)),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(o.desc, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15, height: 20 / 15, decoration: deco)),
            Text('${o.date} · ${o.src}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: kMut, fontSize: 12, height: 16 / 12)),
          ])),
          const SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('${pos ? '+' : ''}${money(o.amount)}', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: pos ? kOk : kInk, decoration: deco)),
            if (o.status != 'Выполнена') StatusChip(o.status),
          ]),
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
    final tt = s.totals(), net = tt.inc - tt.exp, ser = s.series();
    final pl = s.period == Period.day ? 'за день' : periodLabel[s.period]!.toLowerCase();
    return ListView(padding: const EdgeInsets.fromLTRB(kM, 4, kM, 80), children: [
      ScreenHead('Финансы', trailing: GestureDetector(
        onTap: () => _periodPick(context, s),
        child: Container(height: 30, padding: const EdgeInsets.symmetric(horizontal: 10), decoration: BoxDecoration(color: kFill, borderRadius: BorderRadius.circular(15)), child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.calendar_today_outlined, size: 14, color: kBlue), const SizedBox(width: 6), Text(periodLabel[s.period]!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: kBlue)), const Icon(Icons.keyboard_arrow_down, size: 16, color: kBlue)])),
      )),
      if (!s.synced) banner('Данные не синхронизированы с Yandex. Показаны последние известные значения (обновлено в 14:20).'),
      DarkCard(
        car: true,
        carTop: 36,
        carWidthFactor: .48,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const LogoRow(),
            GestureDetector(onTap: () => _info(context, s), child: Container(width: 28, height: 28, decoration: const BoxDecoration(color: Color(0x29FFFFFF), shape: BoxShape.circle), child: const Icon(Icons.more_horiz, color: Colors.white, size: 15))),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            const Text('Баланс', style: TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(width: 6),
            GestureDetector(onTap: () {
              s.hideBalance = !s.hideBalance;
              s.notify();
            }, child: Icon(s.hideBalance ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.white60, size: 15)),
          ]),
          Text(s.hideBalance ? '••••• ₸' : money(s.available), style: const TextStyle(color: Colors.white, fontSize: 32, height: 38 / 32, fontWeight: FontWeight.w700, letterSpacing: -.8)),
          if (s.reserved > 0) Text('В резерве под заявки: ${money(s.reserved)}', style: const TextStyle(color: Colors.white60, fontSize: 12)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _BalBtn(Icons.add, 'Пополнить', true, () => _topup(context, s))),
            const SizedBox(width: 8),
            Expanded(child: _BalBtn(Icons.north_east, 'Вывести', false, () => _withdraw(context, s))),
          ]),
        ]),
      ),
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: _Stat(kGreen, Icons.trending_up, 'Доходы', pl, money(tt.inc))),
        const SizedBox(width: 8),
        Expanded(child: _Stat(kRed, Icons.trending_down, 'Расходы', pl, money(tt.exp))),
        const SizedBox(width: 8),
        Expanded(child: _Stat(kIndigo, Icons.bar_chart_rounded, 'Чистый результат', pl, money(net))),
      ]),
      const SizedBox(height: 12),
      // «Добавить расход» — перед графиком
      GestureDetector(
        onTap: () => _addExpense(context, s),
        child: Container(
          height: 48,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color: kDark),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(width: 22, height: 22, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: const Icon(Icons.add, size: 14, color: kInk)),
            const SizedBox(width: 8),
            const Text('Добавить расход', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
          ]),
        ),
      ),
      AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Expanded(child: Text('Доходы и расходы', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15))),
          MiniTabs(items: const [('day', 'День'), ('week', 'Неделя'), ('month', 'Месяц')], value: s.period.name, onChanged: (v) => s.setPeriod(Period.values.byName(v))),
        ]),
        const SizedBox(height: 8),
        IncomeExpenseChart(inc: ser.inc, exp: ser.exp, labels: ser.labels),
        const SizedBox(height: 10),
        Row(children: [
          _Legend(kBlue, 'Доходы', money(tt.inc)),
          const SizedBox(width: 14),
          _Legend(const Color(0xFFFF8A80), 'Расходы', money(tt.exp)),
          const Spacer(),
          GestureDetector(onTap: () => _breakdown(context, s), child: const Text('Подробнее ›', style: TextStyle(color: kBlue, fontSize: 14))),
        ]),
        if (s.period == Period.range) note('Демо: произвольный период — последние 14 дней.'),
      ])),
      AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Expanded(child: Text('Последние операции', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15))),
          GestureDetector(onTap: () => sheet(context, (ctx) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [h3('Все операции'), Container(padding: const EdgeInsets.symmetric(horizontal: 14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)), child: Column(children: [for (final o in s.ops) OpTile(o)]))])), child: const Text('Все ›', style: TextStyle(color: kBlue, fontSize: 14))),
        ]),
        const SizedBox(height: 4),
        for (final o in s.ops.take(4)) OpTile(o),
      ])),
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

  void _breakdown(BuildContext c, AppState s) {
    final by = <String, int>{};
    var tot = 0;
    for (final e in s.expenses.where((e) => !e.cancelled)) {
      by[e.cat] = (by[e.cat] ?? 0) + e.amount;
      tot += e.amount;
    }
    sheet(c, (ctx) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      h3('Расходы за день по категориям'),
      if (by.isEmpty) const Text('Расходов нет.', style: TextStyle(color: kMut)),
      for (final e in by.entries) kv(e.key, money(e.value)),
      kv('Итого', money(tot)),
    ]));
  }

  void _topup(BuildContext c, AppState s) {
    final ctl = TextEditingController();
    String? err;
    sheet(c, (ctx) => StatefulBuilder(builder: (ctx, set) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      h3('Пополнить баланс'),
      TextField(controller: ctl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Сумма, ₸', hintText: 'Например, 10000')),
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(initialValue: 'Kaspi', decoration: const InputDecoration(labelText: 'Способ'), items: const [DropdownMenuItem(value: 'Kaspi', child: Text('Kaspi (нужен подтверждённый сценарий)')), DropdownMenuItem(value: 'Card', child: Text('Банковская карта'))], onChanged: (_) {}),
      if (err != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(err!, style: const TextStyle(color: kErr, fontWeight: FontWeight.w600))),
      const SizedBox(height: 12),
      PrimaryButton('Создать платёж', onPressed: () {
        final e = s.topup(ctl.text);
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
    sheet(c, (ctx) => StatefulBuilder(builder: (ctx, set) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      h3('Вывести с баланса'),
      Text('Доступно: ${money(s.available)}', style: const TextStyle(color: kMut)),
      const SizedBox(height: 10),
      TextField(controller: ctl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Сумма, ₸', hintText: 'Минимум 1 000')),
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(initialValue: 'k', decoration: const InputDecoration(labelText: 'Реквизиты'), items: const [DropdownMenuItem(value: 'k', child: Text('Kaspi •• 4821'))], onChanged: (_) {}),
      if (err != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(err!, style: const TextStyle(color: kErr, fontWeight: FontWeight.w600))),
      const SizedBox(height: 12),
      PrimaryButton('Создать заявку', onPressed: () {
        final e = s.withdraw(ctl.text);
        if (e != null) return set(() => err = e);
        Navigator.pop(ctx);
        toast(c, 'Заявка создана, сумма зарезервирована.');
      }),
      note('Лимиты: от 1 000 ₸ (демо, утверждает владелец). Мгновенный вывод не обещается — срок обработки сообщит таксопарк. Статусы: Создана → На проверке → В обработке → Выполнена / Отклонена.'),
    ])));
  }

  void _addExpense(BuildContext c, AppState s) {
    final amount = TextEditingController(), comment = TextEditingController();
    var cat = 'Топливо';
    String? err;
    const cats = ['Топливо', 'Мойка', 'Парковка', 'Ремонт', 'Масло/фильтры', 'Шиномонтаж', 'Питание', 'Штрафы', 'Другое'];
    final n = DateTime.now();
    sheet(c, (ctx) => StatefulBuilder(builder: (ctx, set) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      h3('Добавить расход'),
      TextField(controller: amount, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Сумма, ₸')),
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(initialValue: cat, decoration: const InputDecoration(labelText: 'Категория'), items: [for (final x in cats) DropdownMenuItem(value: x, child: Text(x))], onChanged: (v) => cat = v ?? cat),
      const SizedBox(height: 12),
      TextField(readOnly: true, controller: TextEditingController(text: 'Сегодня, ${pad2(n.hour)}:${pad2(n.minute)}'), decoration: const InputDecoration(labelText: 'Дата и время')),
      const SizedBox(height: 12),
      TextField(controller: comment, maxLength: 120, decoration: const InputDecoration(labelText: 'Комментарий (необязательно)')),
      OutlinedButton.icon(onPressed: () => toast(c, 'Фото чека: выбор из камеры/галереи (в этом прототипе не подключён)'), icon: const Icon(Icons.photo_camera_outlined), label: const Text('Фото чека (необязательно)')),
      if (err != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(err!, style: const TextStyle(color: kErr, fontWeight: FontWeight.w600))),
      const SizedBox(height: 12),
      PrimaryButton('Сохранить расход', onPressed: () {
        final e = s.addExpense(amount.text, cat, comment.text.trim());
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
          height: 40,
          decoration: BoxDecoration(color: white ? Colors.white : Colors.white.withValues(alpha: .18), borderRadius: BorderRadius.circular(12)),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, size: 16, color: white ? kInk : Colors.white),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: white ? kInk : Colors.white)),
          ]),
        ),
      );
}

class _Stat extends StatelessWidget {
  const _Stat(this.color, this.icon, this.title, this.sub, this.value);
  final Color color;
  final IconData icon;
  final String title, sub, value;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: kShadow),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          IconBox(icon, bg: color, size: 24),
          const SizedBox(height: 6),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, height: 15 / 12, color: Color(0xFF3C3C43))),
          Text(sub, style: const TextStyle(color: kMut, fontSize: 11, height: 13 / 11)),
          const SizedBox(height: 2),
          FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, height: 20 / 15, letterSpacing: -.3))),
        ]),
      );
}

class _Legend extends StatelessWidget {
  const _Legend(this.color, this.label, this.value);
  final Color color;
  final String label, value;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)), const SizedBox(width: 4), Text(label, style: const TextStyle(color: kMut, fontSize: 12, height: 16 / 12))]),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      ]);
}
