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
    return ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 120), children: [
      Row(children: [
        const Avatar(),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('$greet,\n${s.first}!', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, height: 1.15, letterSpacing: -.4)),
          const Text('Хорошего рабочего дня!', style: TextStyle(color: kMut)),
        ])),
        _BellButton(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsPage()))),
      ]),
      const SizedBox(height: 14),
      if (!s.synced) banner('Данные не синхронизированы с Yandex. Показаны последние известные значения (обновлено в 14:20).'),
      // сегодня
      DarkCard(
        car: true,
        carTop: 24,
        carWidthFactor: .8,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          GestureDetector(onTap: () => onTab(1), child: const Row(mainAxisSize: MainAxisSize.min, children: [Text('Сегодня', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)), Icon(Icons.chevron_right, color: Colors.white, size: 18)])),
          const SizedBox(height: 8),
          Text(money(inc), style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w800, letterSpacing: -1)),
          const Text('Доход', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 10),
          Row(children: [
            IconBox(Icons.trending_up, bg: const Color(0x3313A24A), fg: const Color(0xFF3BE07C)),
            const SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('${dl >= 0 ? '+' : ''}$dl%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)), const Text('к вчера', style: TextStyle(color: Colors.white54, fontSize: 12))]),
          ]),
          const SizedBox(height: 18),
          Row(children: [
            _Mini(Icons.directions_car_outlined, '${s.orders}', 'заказов'),
            const SizedBox(width: 8),
            _Mini(Icons.schedule, '${s.minutes ~/ 60}ч ${pad2(s.minutes % 60)}м', 'на линии'),
            const SizedBox(width: 8),
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
      const SizedBox(height: 14),
      _WorkDayCard(s: s),
    ]);
  }
}

class _BellButton extends StatelessWidget {
  const _BellButton({required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(width: 46, height: 46, decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: kShadow), child: Stack(alignment: Alignment.center, children: [
          const Icon(Icons.notifications_none_rounded),
          Positioned(top: 11, right: 12, child: Container(width: 9, height: 9, decoration: BoxDecoration(color: const Color(0xFFEF4444), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)))),
        ])),
      );
}

class _Mini extends StatelessWidget {
  const _Mini(this.icon, this.value, this.label);
  final IconData icon;
  final String value, label;
  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: .12), borderRadius: BorderRadius.circular(18)),
          child: Row(children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 6),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              FittedBox(fit: BoxFit.scaleDown, child: Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14))),
              Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
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
          toneIcon(Icons.track_changes, Tone.dark),
          const SizedBox(width: 10),
          const Expanded(child: Text('Личная цель на сегодня', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16))),
          OutlinedButton(onPressed: () => _pick(context, s), style: OutlinedButton.styleFrom(foregroundColor: kInk, side: const BorderSide(color: kInk, width: 1.5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))), child: const Text('Изменить', style: TextStyle(fontWeight: FontWeight.w700))),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (t == GoalType.orders) ...[
              Text.rich(TextSpan(children: [TextSpan(text: main, style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w800, letterSpacing: -1)), const TextSpan(text: '  заказов', style: TextStyle(fontSize: 16, color: kBlue, fontWeight: FontWeight.w600))])),
              const SizedBox(height: 10),
              Row(children: [for (var k = 0; k < tg; k++) Expanded(child: Container(height: 20, margin: const EdgeInsets.symmetric(horizontal: 1.5), decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), gradient: k < cur ? const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF7AA2FF), kBlue]) : null, color: k < cur ? null : const Color(0xFFE3E8F4))))]),
            ] else ...[
              Text(main, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, height: 1.2)),
              const SizedBox(height: 12),
              ClipRRect(borderRadius: BorderRadius.circular(99), child: LinearProgressIndicator(value: pct / 100, minHeight: 12, backgroundColor: const Color(0xFFE7EBF5), color: kBlue)),
            ],
            const SizedBox(height: 8),
            Text(hint, style: const TextStyle(color: kMut, fontSize: 12.5)),
          ])),
          const SizedBox(width: 12),
          SizedBox(width: 92, height: 92, child: Stack(alignment: Alignment.center, children: [
            SizedBox(width: 92, height: 92, child: CircularProgressIndicator(value: pct / 100, strokeWidth: 9, backgroundColor: const Color(0xFFE3E8F4), color: kBlue, strokeCap: StrokeCap.round)),
            Text('$pct%', style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
          ])),
        ]),
      ]),
    );
  }

  void _pick(BuildContext c, AppState s) {
    sheet(c, (ctx) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      h3('Основная цель на сегодня'),
      for (final (g, label) in [(GoalType.orders, 'Завершённые заказы'), (GoalType.minutes, 'Часы работы'), (GoalType.earn, 'Сумма заработка')])
        ListTile(contentPadding: EdgeInsets.zero, title: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)), trailing: s.goalType == g ? const StatusChip('Выбрано') : null, onTap: () {
          s.goalType = g;
          s.notify();
          Navigator.pop(ctx);
        }),
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
      padding: const EdgeInsets.all(14),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RatingPage())),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [toneIcon(Icons.emoji_events_outlined, Tone.amber, size: 32), const SizedBox(width: 8), const Expanded(child: Text('Соревнование', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)))]),
        const SizedBox(height: 8),
        const Text('Ваше место среди 100 водителей', style: TextStyle(color: kMut, fontSize: 12.5)),
        Row(children: [
          Text('#${s.place}', style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w800, letterSpacing: -1)),
          const SizedBox(width: 6),
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: const Color(0xFFE1F6E9), borderRadius: BorderRadius.circular(10)), child: const Text('▲ +2', style: TextStyle(color: Color(0xFF0D7C38), fontSize: 12, fontWeight: FontWeight.w700))),
        ]),
        const SizedBox(height: 10),
        LayoutBuilder(builder: (c, box) => SizedBox(height: 28, child: Stack(clipBehavior: Clip.none, children: [
          Positioned(left: 0, right: 0, top: 11, child: Container(height: 6, decoration: BoxDecoration(color: const Color(0xFFE3E8F4), borderRadius: BorderRadius.circular(9)))),
          Positioned(left: 0, top: 11, child: Container(width: box.maxWidth * pos, height: 6, decoration: BoxDecoration(color: kInk, borderRadius: BorderRadius.circular(9)))),
          Positioned(left: (box.maxWidth - 28) * pos, top: 0, child: Container(width: 28, height: 28, decoration: BoxDecoration(color: kInk, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3)), child: const Icon(Icons.directions_car, color: Colors.white, size: 13))),
        ]))),
        const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('#100', style: TextStyle(color: kMut, fontSize: 12)), Text('#1', style: TextStyle(color: kMut, fontSize: 12))]),
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
        padding: const EdgeInsets.all(14),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DepositPage())),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [toneIcon(Icons.card_giftcard, Tone.blue, size: 32), const SizedBox(width: 8), const Expanded(child: Text('Депозит-карта', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)))]),
          const SizedBox(height: 8),
          const Text('Накоплено', style: TextStyle(color: kMut, fontSize: 12.5)),
          FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text(money(s.depBalance), style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800, letterSpacing: -.4))),
          const SizedBox(height: 8),
          StatusChip(s.cashbackStatus),
          const SizedBox(height: 6),
          Text('За месяц: ${money(s.depMonth)}\nОкно вывода: ${s.nextWindowText}', style: const TextStyle(color: kMut, fontSize: 12)),
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
          toneIcon(Icons.bar_chart_rounded, Tone.blue, size: 34),
          const SizedBox(width: 8),
          const Expanded(child: Text('Ваш рабочий день', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15))),
          MiniTabs(items: const [('hours', 'Часы'), ('orders', 'Заказы'), ('income', 'Доход')], value: s.workTab, onChanged: (v) {
            s.workTab = v;
            s.notify();
          }),
        ]),
        const SizedBox(height: 14),
        SizedBox(height: 90, child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          for (var i = 0; i < vals.length; i++)
            Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 2), child: FractionallySizedBox(heightFactor: vals[i] == 0 ? .06 : (vals[i] / mx).clamp(.14, 1.0), child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), gradient: vals[i] > 0 ? const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF5D8CFF), kBlue]) : null, color: vals[i] > 0 ? null : (i + 6 > 19 ? const Color(0xFFE9EDF7) : const Color(0xFFDDE4F6))))))),
        ])),
        const SizedBox(height: 6),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [for (var h = 6; h <= 22; h += 2) Text('${pad2(h)}:00', style: const TextStyle(fontSize: 10, color: kMut))]),
      ]),
    );
  }
}
