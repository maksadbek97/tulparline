import 'package:flutter/material.dart';

import '../main.dart';
import '../state.dart';
import '../ui.dart';
import 'deposit.dart';
import 'misc.dart';
import 'rating.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.onTab});
  final ValueChanged<int> onTab;

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final hr = DateTime.now().hour;
    final greet = hr < 5 ? 'Доброй ночи' : hr < 12 ? 'Доброе утро' : hr < 18 ? 'Добрый день' : 'Добрый вечер';
    final inc = s.incomeToday;
    const prev = 34300;
    final dl = ((inc - prev) * 100 / prev).round();
    return ListView(padding: const EdgeInsets.fromLTRB(kM, 4, kM, 80), children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(children: [
          const Avatar(),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('$greet, ${s.first}', style: const TextStyle(fontSize: 17, height: 22 / 17, fontWeight: FontWeight.w600, letterSpacing: -.2)),
            const Text('Хорошего рабочего дня!', style: TextStyle(color: kMut, fontSize: 13, height: 18 / 13)),
          ])),
          _CircleBtn(Icons.notifications_none_rounded, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsPage())), dot: true),
        ]),
      ),
      if (!s.synced) banner('Данные не синхронизированы с Yandex. Показаны последние известные значения (обновлено в 14:20).'),
      DarkCard(
        car: true,
        carTop: 8,
        carWidthFactor: .5,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          GestureDetector(onTap: () => onTab(1), child: const Row(mainAxisSize: MainAxisSize.min, children: [Text('Сегодня', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)), Icon(Icons.chevron_right, color: Colors.white70, size: 16)])),
          const SizedBox(height: 2),
          Text(money(inc), style: const TextStyle(color: Colors.white, fontSize: 32, height: 38 / 32, fontWeight: FontWeight.w700, letterSpacing: -.8)),
          Row(children: [
            const Text('Доход  ', style: TextStyle(color: Colors.white60, fontSize: 13)),
            Text('${dl >= 0 ? '+' : ''}$dl% к вчера', style: const TextStyle(color: Color(0xFF4ADE80), fontSize: 13, fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            _Mini(Icons.directions_car_outlined, '${s.orders}', 'заказов'),
            const SizedBox(width: 6),
            _Mini(Icons.schedule, '${s.minutes ~/ 60}ч ${pad2(s.minutes % 60)}м', 'на линии'),
            const SizedBox(width: 6),
            _Mini(Icons.credit_card, money(s.expenseToday), 'расходы'),
          ]),
        ]),
      ),
      _GoalCard(s: s),
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: _CompetitionCard(s: s)),
        const SizedBox(width: 12),
        Expanded(child: _DepositCard(s: s)),
      ]),
      const SizedBox(height: 12),
      _WorkDayCard(s: s),
    ]);
  }
}

class _CircleBtn extends StatelessWidget {
  const _CircleBtn(this.icon, {required this.onTap, this.dot = false});
  final IconData icon;
  final VoidCallback onTap;
  final bool dot;
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(width: 44, height: 44, child: Center(child: Container(width: 34, height: 34, decoration: const BoxDecoration(color: kFill, shape: BoxShape.circle), child: Stack(alignment: Alignment.center, children: [
          Icon(icon, size: 18, color: kBlue),
          if (dot) Positioned(top: 6, right: 7, child: Container(width: 8, height: 8, decoration: BoxDecoration(color: kRed, shape: BoxShape.circle, border: Border.all(color: kBg, width: 1.5)))),
        ])))),
      );
}

class _Mini extends StatelessWidget {
  const _Mini(this.icon, this.value, this.label);
  final IconData icon;
  final String value, label;
  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: .1), borderRadius: BorderRadius.circular(10)),
          child: Row(children: [
            Icon(icon, color: Colors.white70, size: 16),
            const SizedBox(width: 6),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              FittedBox(fit: BoxFit.scaleDown, child: Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13, height: 16 / 13))),
              Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10.5, height: 12 / 10.5)),
            ])),
          ]),
        ),
      );
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({required this.s});
  final AppState s;
  @override
  Widget build(BuildContext context) {
    final t = s.goalType, tg = s.goalTargets[t]!, cur = s.goalCurrent(t);
    final pct = (cur * 100 / tg).round().clamp(0, 100);
    String main, hint;
    switch (t) {
      case GoalType.orders:
        main = '$cur / $tg';
        final left = tg - cur;
        hint = left <= 0 ? 'Цель выполнена — отличная работа!' : 'Осталось $left ${left == 1 ? 'заказ' : left < 5 ? 'заказа' : 'заказов'} — вы почти у цели';
      case GoalType.minutes:
        main = 'Работали ${cur ~/ 60} ч ${pad2(cur % 60)} мин из ${tg ~/ 60} ч';
        hint = cur >= tg ? 'Цель выполнена!' : 'Осталось ${(tg - cur) ~/ 60} ч ${pad2((tg - cur) % 60)} мин';
      case GoalType.earn:
        main = 'Заработано ${money(cur)} из ${money(tg)}';
        hint = cur >= tg ? 'Цель выполнена!' : 'Осталось ${money(tg - cur)}';
    }
    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          toneIcon(Icons.track_changes, Tone.dark, size: 28),
          const SizedBox(width: 8),
          const Expanded(child: Text('Личная цель на сегодня', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15))),
          GestureDetector(onTap: () => _pick(context, s), child: const Padding(padding: EdgeInsets.symmetric(vertical: 6), child: Text('Изменить', style: TextStyle(color: kBlue, fontSize: 15)))),
        ]),
        const SizedBox(height: 6),
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (t == GoalType.orders) ...[
              Text.rich(TextSpan(children: [TextSpan(text: main, style: const TextStyle(fontSize: 28, height: 34 / 28, fontWeight: FontWeight.w700, letterSpacing: -.7)), const TextSpan(text: '  заказов', style: TextStyle(fontSize: 13, color: kMut, fontWeight: FontWeight.w500))])),
              const SizedBox(height: 6),
              Row(children: [for (var k = 0; k < tg; k++) Expanded(child: Container(height: 8, margin: const EdgeInsets.symmetric(horizontal: 1), decoration: BoxDecoration(borderRadius: BorderRadius.circular(2.5), color: k < cur ? kBlue : kFill)))]),
            ] else ...[
              Text(main, style: const TextStyle(fontSize: 15, height: 20 / 15, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              ClipRRect(borderRadius: BorderRadius.circular(99), child: LinearProgressIndicator(value: pct / 100, minHeight: 6, backgroundColor: kFill, color: kBlue)),
            ],
            const SizedBox(height: 6),
            Text(hint, style: const TextStyle(color: kMut, fontSize: 12, height: 16 / 12)),
          ])),
          const SizedBox(width: 12),
          SizedBox(width: 60, height: 60, child: Stack(alignment: Alignment.center, children: [
            SizedBox(width: 60, height: 60, child: CircularProgressIndicator(value: pct / 100, strokeWidth: 6, backgroundColor: kFill, color: kBlue, strokeCap: StrokeCap.round)),
            Text('$pct%', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          ])),
        ]),
      ]),
    );
  }

  void _pick(BuildContext c, AppState s) {
    sheet(c, (ctx) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      h3('Основная цель на сегодня'),
      Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Column(children: [
          for (final (i, (g, label)) in [(GoalType.orders, 'Завершённые заказы'), (GoalType.minutes, 'Часы работы'), (GoalType.earn, 'Сумма заработка')].indexed) ...[
            if (i > 0) const Divider(height: .5, indent: 14, color: kLine),
            ListTile(dense: true, minVerticalPadding: 0, title: Text(label, style: const TextStyle(fontSize: 15)), trailing: s.goalType == g ? const Icon(Icons.check, color: kBlue, size: 20) : null, onTap: () {
              s.goalType = g;
              s.notify();
              Navigator.pop(ctx);
            }),
          ],
        ]),
      ),
    ]));
  }
}

class _CompetitionCard extends StatelessWidget {
  const _CompetitionCard({required this.s});
  final AppState s;
  @override
  Widget build(BuildContext context) {
    final pos = (100 - s.place) / 99;
    return AppCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(12),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RatingPage())),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [toneIcon(Icons.emoji_events_outlined, Tone.amber, size: 24), const SizedBox(width: 6), const Expanded(child: Text('Соревнование', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)))]),
        const SizedBox(height: 6),
        const Text('Ваше место среди 100 водителей', style: TextStyle(color: kMut, fontSize: 12, height: 16 / 12)),
        Row(children: [
          Text('#${s.place}', style: const TextStyle(fontSize: 26, height: 30 / 26, fontWeight: FontWeight.w700, letterSpacing: -.6)),
          const SizedBox(width: 6),
          Container(padding: const EdgeInsets.symmetric(horizontal: 6), decoration: BoxDecoration(color: const Color(0x2934C759), borderRadius: BorderRadius.circular(8)), child: const Text('▲ +2', style: TextStyle(color: Color(0xFF1A8A3A), fontSize: 11, fontWeight: FontWeight.w600))),
        ]),
        const SizedBox(height: 8),
        LayoutBuilder(builder: (c, box) => SizedBox(height: 20, child: Stack(clipBehavior: Clip.none, children: [
          Positioned(left: 0, right: 0, top: 8, child: Container(height: 4, decoration: BoxDecoration(color: kFill, borderRadius: BorderRadius.circular(9)))),
          Positioned(left: 0, top: 8, child: Container(width: box.maxWidth * pos, height: 4, decoration: BoxDecoration(color: kBlue, borderRadius: BorderRadius.circular(9)))),
          Positioned(left: (box.maxWidth - 20) * pos, top: 0, child: Container(width: 20, height: 20, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Color(0x4D000000), blurRadius: 4, offset: Offset(0, 1))]), child: const Icon(Icons.directions_car, color: kBlue, size: 11))),
        ]))),
        const SizedBox(height: 2),
        const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('#100', style: TextStyle(color: kMut, fontSize: 10)), Text('#1', style: TextStyle(color: kMut, fontSize: 10))]),
      ]),
    );
  }
}

class _DepositCard extends StatelessWidget {
  const _DepositCard({required this.s});
  final AppState s;
  @override
  Widget build(BuildContext context) => AppCard(
        margin: EdgeInsets.zero,
        padding: const EdgeInsets.all(12),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DepositPage())),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [toneIcon(Icons.card_giftcard, Tone.blue, size: 24), const SizedBox(width: 6), const Expanded(child: Text('Депозит-карта', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)))]),
          const SizedBox(height: 6),
          const Text('Накоплено', style: TextStyle(color: kMut, fontSize: 12, height: 16 / 12)),
          FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text(money(s.depBalance), style: const TextStyle(fontSize: 18, height: 22 / 18, fontWeight: FontWeight.w700, letterSpacing: -.4))),
          const SizedBox(height: 6),
          StatusChip(s.cashbackStatus),
          const SizedBox(height: 4),
          Text('За месяц: ${money(s.depMonth)}\nОкно вывода: ${s.nextWindowText}', style: const TextStyle(color: kMut, fontSize: 11, height: 15 / 11)),
        ]),
      );
}

class _WorkDayCard extends StatelessWidget {
  const _WorkDayCard({required this.s});
  final AppState s;
  @override
  Widget build(BuildContext context) {
    final vals = <int>[];
    for (var h = 6; h <= 22; h++) {
      final idx = h - 6;
      if (idx >= s.inc.length) {
        vals.add(0);
      } else {
        final v = s.inc[idx];
        vals.add(s.workTab == 'income' ? v : s.workTab == 'orders' ? (v / 1900).round() : (v > 0 ? 60 : 0));
      }
    }
    final mx = vals.fold(1, (a, b) => b > a ? b : a);
    return AppCard(
      margin: EdgeInsets.zero,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Expanded(child: Text('Ваш рабочий день', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15))),
          MiniTabs(items: const [('hours', 'Часы'), ('orders', 'Заказы'), ('income', 'Доход')], value: s.workTab, onChanged: (v) {
            s.workTab = v;
            s.notify();
          }),
        ]),
        const SizedBox(height: 12),
        SizedBox(height: 64, child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          for (var i = 0; i < vals.length; i++)
            Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 1.5), child: FractionallySizedBox(heightFactor: vals[i] == 0 ? .06 : (vals[i] / mx).clamp(.14, 1.0), child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(3), color: vals[i] > 0 ? kBlue : (i + 6 > 19 ? kFill.withValues(alpha: .08) : kFill)))))),
        ])),
        const SizedBox(height: 4),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [for (var h = 6; h <= 22; h += 2) Text('${pad2(h)}:00', style: const TextStyle(fontSize: 10, color: kMut))]),
      ]),
    );
  }
}
