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
    return ListView(padding: const EdgeInsets.fromLTRB(kM, 4, kM, 120), children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(2, 4, 2, 14),
        child: Row(children: [
          const Avatar(),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('$greet,\n${s.first}!', style: const TextStyle(fontSize: 21, height: 26 / 21, fontWeight: FontWeight.w700, letterSpacing: -.5)),
            const Text('Хорошего рабочего дня!', style: TextStyle(color: kMut, fontSize: 14, height: 18 / 14)),
          ])),
          BellButton(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsPage()))),
        ]),
      ),
      if (!s.synced) banner('Данные не синхронизированы с Yandex. Показаны последние известные значения (обновлено в 14:20).'),
      DarkCard(
        car: 'assets/car-rear.png',
        carWidth: .64,
        carTop: -6,
        minHeight: 204,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          GestureDetector(onTap: () => onTab(1), child: const Row(mainAxisSize: MainAxisSize.min, children: [Text('Сегодня', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)), Icon(Icons.chevron_right, color: Colors.white70, size: 17)])),
          const SizedBox(height: 6),
          Text(money(inc), style: const TextStyle(color: Colors.white, fontSize: 40, height: 46 / 40, fontWeight: FontWeight.w700, letterSpacing: -1.4)),
          const Text('Доход', style: TextStyle(color: Colors.white70, fontSize: 16)),
          const SizedBox(height: 8),
          Row(children: [
            Container(width: 32, height: 32, decoration: const BoxDecoration(color: Color(0x4716B05A), shape: BoxShape.circle), child: const Icon(Icons.north_east, color: Color(0xFF34E08A), size: 17)),
            const SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('${dl >= 0 ? '+' : ''}$dl%', style: const TextStyle(color: Colors.white, fontSize: 16, height: 18 / 16, fontWeight: FontWeight.w600)), const Text('к вчера', style: TextStyle(color: Colors.white54, fontSize: 12.5, height: 15 / 12.5))]),
          ]),
          const SizedBox(height: 12),
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
      IntrinsicHeight(
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Expanded(flex: 11, child: _CompetitionCard(s: s)),
          const SizedBox(width: 10),
          Expanded(flex: 10, child: _DepositCard(s: s)),
        ]),
      ),
      const SizedBox(height: 12),
      _WorkDayCard(s: s),
    ]);
  }
}

class BellButton extends StatelessWidget {
  const BellButton({super.key, required this.onTap, this.dot = true});
  final VoidCallback onTap;
  final bool dot;
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(width: 42, height: 42, decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: kShadow), child: Stack(alignment: Alignment.center, children: [
          const Icon(Icons.notifications_none_rounded, size: 22),
          if (dot) Positioned(top: 9, right: 10, child: Container(width: 9, height: 9, decoration: BoxDecoration(color: const Color(0xFFFF453A), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)))),
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
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: .12), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withValues(alpha: .1))),
          child: Row(children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 6),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              FittedBox(fit: BoxFit.scaleDown, child: Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16, height: 19 / 16))),
              Text(label, maxLines: 1, softWrap: false, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white54, fontSize: 12.5, height: 15 / 12.5)),
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
          const Expanded(child: Text('Личная цель на сегодня', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17, letterSpacing: -.3))),
          GestureDetector(onTap: () => _pick(context, s), behavior: HitTestBehavior.opaque, child: const Padding(padding: EdgeInsets.all(6), child: Icon(Icons.chevron_right, color: kMut))),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (t == GoalType.orders) ...[
              Text.rich(TextSpan(children: [TextSpan(text: main, style: const TextStyle(fontSize: 36, height: 42 / 36, fontWeight: FontWeight.w700, letterSpacing: -1.2)), const TextSpan(text: '  заказов', style: TextStyle(fontSize: 17, color: kBlue, fontWeight: FontWeight.w500))])),
              const SizedBox(height: 6),
              Row(children: [for (var k = 0; k < tg; k++) Expanded(child: Container(height: 15, margin: const EdgeInsets.symmetric(horizontal: 1.5), decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), gradient: k < cur ? const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF8DB0FF), kBlue]) : null, color: k < cur ? null : kFill)))]),
            ] else ...[
              Text(main, style: const TextStyle(fontSize: 20, height: 26 / 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              ClipRRect(borderRadius: BorderRadius.circular(99), child: LinearProgressIndicator(value: pct / 100, minHeight: 8, backgroundColor: kFill, color: kBlue)),
            ],
            const SizedBox(height: 8),
            Text(hint, style: const TextStyle(color: kMut, fontSize: 13, height: 18 / 13)),
          ])),
          const SizedBox(width: 12),
          SizedBox(width: 82, height: 82, child: Stack(alignment: Alignment.center, children: [
            SizedBox(width: 82, height: 82, child: CircularProgressIndicator(value: pct / 100, strokeWidth: 8, backgroundColor: kFill, color: kBlue, strokeCap: StrokeCap.round)),
            Text('$pct%', style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w700, letterSpacing: -.4)),
          ])),
        ]),
      ]),
    );
  }

  void _pick(BuildContext c, AppState s) {
    sheet(c, (ctx) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      h3('Основная цель на сегодня'),
      Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
        child: Column(children: [
          for (final (i, (g, label)) in [(GoalType.orders, 'Завершённые заказы'), (GoalType.minutes, 'Часы работы'), (GoalType.earn, 'Сумма заработка')].indexed) ...[
            if (i > 0) const Divider(height: 1, indent: 16, color: kLine),
            ListTile(title: Text(label, style: const TextStyle(fontSize: 17)), trailing: s.goalType == g ? const Icon(Icons.check, color: kBlue) : null, onTap: () {
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
      padding: const EdgeInsets.all(14),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RatingPage())),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [toneIcon(Icons.emoji_events_outlined, Tone.amber, size: 28), const SizedBox(width: 8), const Expanded(child: Text('Соревнование', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, letterSpacing: -.3)))]),
        const SizedBox(height: 8),
        const Text('Ваше место среди 100 водителей', style: TextStyle(color: kMut, fontSize: 13, height: 18 / 13)),
        Row(children: [
          Text('#${s.place}', style: const TextStyle(fontSize: 38, height: 42 / 38, fontWeight: FontWeight.w700, letterSpacing: -1.5)),
          const SizedBox(width: 6),
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1), decoration: BoxDecoration(color: const Color(0x2416B05A), borderRadius: BorderRadius.circular(10)), child: const Text('↗ +2', style: TextStyle(color: Color(0xFF0F8A45), fontSize: 13, fontWeight: FontWeight.w600))),
        ]),
        const SizedBox(height: 10),
        LayoutBuilder(builder: (c, box) => SizedBox(height: 26, child: Stack(clipBehavior: Clip.none, children: [
          Positioned(left: 0, right: 0, top: 10, child: Container(height: 6, decoration: BoxDecoration(color: kFill, borderRadius: BorderRadius.circular(9)))),
          Positioned(left: 0, top: 10, child: Container(width: box.maxWidth * pos, height: 6, decoration: BoxDecoration(color: kInk, borderRadius: BorderRadius.circular(9)))),
          Positioned(left: (box.maxWidth - 26) * pos, top: 0, child: Container(width: 26, height: 26, decoration: BoxDecoration(color: kInk, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3), boxShadow: const [BoxShadow(color: Color(0x40000000), blurRadius: 8, offset: Offset(0, 3))]), child: const Icon(Icons.directions_car, color: Colors.white, size: 12))),
        ]))),
        const SizedBox(height: 2),
        const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('#100', style: TextStyle(color: kMut, fontSize: 13)), Text('#1', style: TextStyle(color: kMut, fontSize: 13))]),
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
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xF2E1EBFF), Color(0xE6ECE6FF)]),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DepositPage())),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [toneIcon(Icons.card_giftcard, Tone.blue, size: 28), const SizedBox(width: 8), const Expanded(child: Text('Депозит-карта', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, letterSpacing: -.3)))]),
          const SizedBox(height: 8),
          const Text('Накоплено', style: TextStyle(color: kMut, fontSize: 13, height: 18 / 13)),
          FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text(money(s.depBalance), style: const TextStyle(fontSize: 26, height: 30 / 26, fontWeight: FontWeight.w700, letterSpacing: -1))),
          const SizedBox(height: 8),
          StatusChip(s.cashbackStatus),
          const SizedBox(height: 6),
          Text('Окно вывода: ${s.nextWindowText}', style: const TextStyle(color: kMut, fontSize: 13, height: 18 / 13)),
        ]),
      );
}

class _WorkDayCard extends StatelessWidget {
  const _WorkDayCard({required this.s});
  final AppState s;
  @override
  Widget build(BuildContext context) {
    // 17 часов × 3 столбика; активные часы — синие, остальные — серые.
    const shape = [.62, 1.0, .78];
    const off = [.18, .30, .22, .36, .26, .14, .32, .20, .28];
    final bars = <Widget>[];
    var mx = 1, peak = -1;
    final vals = <int>[];
    for (var h = 6; h <= 22; h++) {
      final idx = h - 6;
      var v = 0;
      if (idx < s.inc.length) {
        final inc = s.inc[idx];
        v = s.workTab == 'income' ? inc : s.workTab == 'orders' ? (inc / 1900).round() : (inc > 0 ? 60 : 0);
      }
      vals.add(v);
      if (v > mx) {
        mx = v;
        peak = idx;
      }
    }
    final tip = s.workTab == 'income' ? 'Лучший час' : s.workTab == 'orders' ? 'Больше всего заказов' : '';
    for (var n = 0; n < vals.length; n++) {
      for (var k = 0; k < 3; k++) {
        final v = vals[n];
        final active = v > 0;
        final f = active ? (v / mx * shape[k]).clamp(.16, 1.0) : off[(n * 3 + k) % off.length];
        final isPeak = n == peak && k == 1 && tip.isNotEmpty;
        bars.add(Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 1), child: Stack(clipBehavior: Clip.none, alignment: Alignment.bottomCenter, children: [
          FractionallySizedBox(heightFactor: f, child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(2), gradient: active ? const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF6B9BFF), kBlue]) : null, color: active ? null : const Color(0x33787F9E).withValues(alpha: n + 6 > 19 ? .12 : .2)))),
          if (isPeak) Positioned(bottom: 92 * f + 8, child: Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4), decoration: BoxDecoration(color: kInk, borderRadius: BorderRadius.circular(9)), child: Text(tip, softWrap: false, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)))),
        ]))));
      }
    }
    return AppCard(
      margin: EdgeInsets.zero,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Expanded(child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text('Ваш рабочий день', maxLines: 1, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, letterSpacing: -.3)))),
          MiniTabs(items: const [('hours', 'По часам'), ('orders', 'По заказам'), ('income', 'По доходу')], value: s.workTab, onChanged: (v) {
            s.workTab = v;
            s.notify();
          }),
        ]),
        const SizedBox(height: 26),
        SizedBox(height: 92, child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: bars)),
        const SizedBox(height: 6),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [for (var h = 6; h <= 22; h += 2) Text('${pad2(h)}:00', style: const TextStyle(fontSize: 12, color: kMut))]),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(color: const Color(0x172F6BFF), borderRadius: BorderRadius.circular(18)),
          child: const Row(children: [
            Icon(Icons.schedule, color: kBlue, size: 30),
            SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Сейчас хороший момент работать', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)), Text('Демо-подсказка: ожидается высокий спрос до 19:00', style: TextStyle(fontSize: 13, color: kMut, height: 17 / 13))])),
            Icon(Icons.chevron_right, color: kMut, size: 18),
          ]),
        ),
      ]),
    );
  }
}
