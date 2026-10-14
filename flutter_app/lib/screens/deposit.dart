import 'package:flutter/material.dart';

import '../main.dart';
import '../state.dart';
import '../ui.dart';

const termsLines = [
  'Порог: 25 завершённых заказов за календарный день.',
  'Ставка: 0,4% (предварительно).',
  'Расчётная база: ожидает утверждения владельцем (стоимость заказов / доход таксопарка / иное).',
  'Расчёт — после окончания дня и проверки данных.',
  'Учитываются только завершённые и подтверждённые заказы; отменённые и дубликаты — нет.',
  'Вывод: заявка только 1-го числа месяца; сумма резервируется до решения.',
  'Депозит-карта — внутренняя бонусная запись, не банковская карта.',
  'Выплаты — по заявке после проверки; мгновенный вывод не гарантируется.',
];

Widget termsCard() => AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      banner('Параметры ниже — предварительные. Их утверждает владелец; в приложении они подтягиваются из админ-панели без выпуска новой версии.', info: true),
      for (final l in termsLines) Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('•  '), Expanded(child: Text(l, style: const TextStyle(height: 1.35)))])),
    ]));

class DepositPage extends StatelessWidget {
  const DepositPage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final left = 25 - s.orders;
    final pending = s.payouts.any((p) => p.fromDeposit && !{'Выполнена', 'Отклонена'}.contains(p.status));
    return SubPage(title: 'Депозит-карта Tulpar Line', children: [
      DarkCard(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Накопленный бонусный баланс', style: TextStyle(color: Colors.white70, fontSize: 12)),
        Text(money(s.depBalance), style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w700, letterSpacing: -1)),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('За этот месяц: ${money(s.depMonth)}', style: const TextStyle(color: Colors.white, fontSize: 12)), Text('В резерве: ${money(s.depReserved)}', style: const TextStyle(color: Colors.white, fontSize: 12))]),
        const SizedBox(height: 12),
        Wrap(spacing: 6, runSpacing: 6, children: [StatusChip(pending ? 'Заявка обрабатывается' : s.windowOpen ? 'Вывод доступен' : 'Вывод доступен 1-го числа'), const StatusChip('Накопление активно')]),
      ])),
      banner('Это отдельный бонусный баланс. Он не входит в основной баланс приложения и в баланс Yandex.', info: true),
      AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [const Expanded(child: Text('Сегодняшнее условие', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15))), StatusChip(s.cashbackStatus)]),
        const SizedBox(height: 10),
        ClipRRect(borderRadius: BorderRadius.circular(99), child: LinearProgressIndicator(value: (s.orders / 25).clamp(0, 1), minHeight: 12, backgroundColor: const Color(0xFFE7EBF5), color: kBlue)),
        const SizedBox(height: 10),
        kv('Заказов за сегодня', '${s.orders} из 25'),
        kv('Заказы подтверждены и синхронизированы', s.synced ? '✓ да' : '✗ нет'),
        kv('Расчёт после окончания дня', 'в 00:10 (предварительно)'),
        if (left <= 0) note('Начисление произойдёт после окончания дня и проверки данных. Статус — «Ожидает проверки».'),
      ])),
      AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        h3('Вывод бонусного баланса'),
        Text('Следующее окно: ${s.nextWindowText}. Доступно к заявке: ${money(s.depAvailable)}.', style: const TextStyle(color: kMut)),
        const SizedBox(height: 12),
        PrimaryButton('Подать заявку на вывод', onPressed: () => _withdraw(context, s)),
        note('${s.windowOpen ? 'Окно открыто (демо-режим).' : 'Вне окна заявка недоступна: заявки принимаются только 1-го числа месяца.'} Выплаты обрабатываются вручную после проверки; срок обработки сообщит таксопарк.'),
        for (final p in s.payouts.where((p) => p.fromDeposit))
          ListTile(contentPadding: EdgeInsets.zero, leading: toneIcon(Icons.north_east, Tone.blue), title: Text('Заявка ${p.id}', style: const TextStyle(fontWeight: FontWeight.w700)), subtitle: Text(p.date), trailing: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.end, children: [Text(money(p.amount), style: const TextStyle(fontWeight: FontWeight.w700)), StatusChip(p.status)])),
      ])),
      AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        h3('История начислений'),
        for (final d in s.dep)
          InkWell(
            onTap: () => sheet(context, (ctx) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              h3(d.type),
              kv('ID', d.id), kv('Период', d.period), kv('Заказов', d.orders?.toString() ?? '—'), kv('Расчётная база', d.base == null ? '—' : money(d.base!)), kv('Ставка', d.rate ?? '—'), kv('Сумма', money(d.amount)), kv('Источник / версия', d.src),
              StatusChip(d.status),
              if (d.comment.isNotEmpty) note('Комментарий: ${d.comment}'),
              note('Проведённые записи не удаляются; корректировки оформляются отдельной операцией.'),
            ])),
            child: Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: Row(children: [
              toneIcon(Icons.card_giftcard, Tone.amber),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(d.type, style: const TextStyle(fontWeight: FontWeight.w700)), Text('${d.period}${d.orders != null ? ' · ${d.orders} заказов' : ''}', style: const TextStyle(color: kMut, fontSize: 12))])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text('+${money(d.amount)}', style: const TextStyle(fontWeight: FontWeight.w700, color: kOk)), StatusChip(d.status)]),
            ])),
          ),
      ])),
      h3('Правила программы'),
      termsCard(),
    ]);
  }

  void _withdraw(BuildContext c, AppState s) {
    if (!s.windowOpen) {
      sheet(c, (ctx) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        h3('Вывод пока недоступен'),
        Text('Заявки на вывод с депозит-карты принимаются только 1-го числа месяца. Следующее окно: ${s.dmy(s.nextWindow)}.'),
        note('Накопленные средства останутся на депозит-карте и будут доступны к заявке в открытое окно.'),
        PrimaryButton('Понятно', onPressed: () => Navigator.pop(ctx)),
      ]));
      return;
    }
    final ctl = TextEditingController();
    String? err;
    sheet(c, (ctx) => StatefulBuilder(builder: (ctx, set) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      h3('Заявка на вывод с депозит-карты'),
      Text('Доступно: ${money(s.depAvailable)}', style: const TextStyle(color: kMut)),
      const SizedBox(height: 10),
      TextField(controller: ctl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Сумма, ₸')),
      if (err != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(err!, style: const TextStyle(color: kErr, fontWeight: FontWeight.w600))),
      const SizedBox(height: 12),
      PrimaryButton('Отправить заявку', onPressed: () {
        final e = s.depWithdraw(ctl.text);
        if (e != null) return set(() => err = e);
        Navigator.pop(ctx);
        toast(c, 'Заявка отправлена. Сумма зарезервирована.');
      }),
      note('Сумма будет зарезервирована. При отказе резерв снимается. Это отдельная заявка, не связанная с выводом основного баланса.'),
    ])));
  }
}
