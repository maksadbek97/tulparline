import 'package:flutter/material.dart';

import '../main.dart';
import '../ui.dart';
import 'deposit.dart';
import 'misc.dart';
import 'rating.dart';

/// Заголовок раздела: Title 28/34 + подпись.
class ScreenHead extends StatelessWidget {
  const ScreenHead(this.title, {super.key, this.trailing});
  final String title;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            h2(title),
            const Text.rich(TextSpan(children: [TextSpan(text: 'TULPAR LINE ', style: TextStyle(color: kInk, fontWeight: FontWeight.w600, letterSpacing: .3)), TextSpan(text: 'Таксопарк')]), style: TextStyle(color: kMut, fontSize: 13, height: 18 / 13)),
          ])),
          ?trailing,
        ]),
      );
}

class ServicePage extends StatelessWidget {
  const ServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    // Ровно 11 пунктов в порядке ТЗ.
    final items = <(String, IconData, Tone, WidgetBuilder)>[
      ('Документы', Icons.description_outlined, Tone.blue, (_) => const DocumentsPage()),
      ('Цели', Icons.track_changes, Tone.green, (_) => const GoalsPage()),
      ('Задания', Icons.assignment_turned_in_outlined, Tone.violet, (_) => const TasksPage()),
      ('Рейтинг', Icons.emoji_events_outlined, Tone.amber, (_) => const RatingPage()),
      ('График', Icons.calendar_month_outlined, Tone.blue, (_) => const SchedulePage()),
      ('Автомобиль', Icons.directions_car_outlined, Tone.red, (_) => const CarPage()),
      ('Депозит-карта Tulpar Line', Icons.currency_exchange, Tone.dark, (_) => const DepositPage()),
      ('Пригласи друга', Icons.person_add_alt, Tone.amber, (_) => const ReferralPage()),
      ('Здоровье', Icons.favorite_border, Tone.red, (_) => const HealthPage()),
      ('SOS', Icons.sos, Tone.dark, (_) => const SosPage()),
      ('Поддержка', Icons.headset_mic_outlined, Tone.violet, (_) => const SupportPage()),
    ];
    return ListView(padding: const EdgeInsets.fromLTRB(kM, 4, kM, 80), children: [
      ScreenHead('Сервис', trailing: GestureDetector(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsPage())), child: Container(width: 34, height: 34, decoration: const BoxDecoration(color: kFill, shape: BoxShape.circle), child: const Icon(Icons.notifications_none_rounded, size: 18, color: kBlue)))),
      DarkCard(
        car: true,
        carWidthFactor: .52,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const LogoRow(),
          const SizedBox(height: 10),
          Text('${s.carMake} ${s.carModel}', style: const TextStyle(color: Colors.white, fontSize: 20, height: 25 / 20, fontWeight: FontWeight.w600, letterSpacing: -.3)),
          Text('${s.carYear} • ${s.carClass}', style: const TextStyle(color: Colors.white60, fontSize: 13)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
            decoration: BoxDecoration(border: Border.all(color: Colors.white54), borderRadius: BorderRadius.circular(8)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [Text(s.carPlate, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, letterSpacing: .8, fontSize: 14)), const SizedBox(width: 6), const Text('KZ', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700))]),
          ),
        ]),
      ),
      GridView.count(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.12,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          for (final it in items)
            AppCard(
              margin: EdgeInsets.zero,
              padding: const EdgeInsets.all(10),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: it.$4)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                toneIcon(it.$2, it.$3, size: 30),
                Text(it.$1, maxLines: 3, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5, height: 15 / 12.5)),
              ]),
            ),
        ],
      ),
    ]);
  }
}
