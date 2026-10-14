import 'package:flutter/material.dart';

import '../main.dart';
import '../ui.dart';
import 'deposit.dart';
import 'misc.dart';
import 'rating.dart';

class ServicePage extends StatelessWidget {
  const ServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    // Ровно 11 пунктов в порядке ТЗ.
    final items = <(String, IconData, Tone, String, WidgetBuilder)>[
      ('Документы', Icons.description_outlined, Tone.blue, 'Все документы в одном месте', (_) => const DocumentsPage()),
      ('Цели', Icons.track_changes, Tone.green, 'Цели на день, неделю, месяц', (_) => const GoalsPage()),
      ('Задания', Icons.assignment_turned_in_outlined, Tone.violet, 'Выполняйте и получайте награды', (_) => const TasksPage()),
      ('Рейтинг', Icons.emoji_events_outlined, Tone.amber, 'Ваше место среди водителей', (_) => const RatingPage()),
      ('График', Icons.calendar_month_outlined, Tone.blue, 'Рабочие дни и время', (_) => const SchedulePage()),
      ('Автомобиль', Icons.directions_car_outlined, Tone.red, 'Информация и обслуживание', (_) => const CarPage()),
      ('Депозит-карта Tulpar Line', Icons.currency_exchange, Tone.dark, 'Бонусный баланс', (_) => const DepositPage()),
      ('Пригласи друга', Icons.person_add_alt, Tone.amber, 'Бонусы за новых водителей', (_) => const ReferralPage()),
      ('Здоровье', Icons.favorite_border, Tone.red, 'Шаги и активность', (_) => const HealthPage()),
      ('SOS', Icons.sos, Tone.dark, 'Экстренная помощь', (_) => const SosPage()),
      ('Поддержка', Icons.headset_mic_outlined, Tone.violet, 'Свяжитесь с нами 24/7', (_) => const SupportPage()),
    ];
    return ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 120), children: [
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          h2('Сервис'),
          const Text.rich(TextSpan(children: [TextSpan(text: 'TULPAR LINE ', style: TextStyle(color: kInk, fontWeight: FontWeight.w800)), TextSpan(text: 'Таксопарк')]), style: TextStyle(color: kMut, fontSize: 15)),
        ])),
        GestureDetector(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsPage())), child: Container(width: 46, height: 46, decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: kShadow), child: const Icon(Icons.notifications_none_rounded))),
      ]),
      const SizedBox(height: 14),
      DarkCard(
        car: true,
        carWidthFactor: .85,
        padding: const EdgeInsets.all(18),
        child: SizedBox(
          height: 150,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const LogoRow(),
            const SizedBox(height: 14),
            Text('${s.carMake} ${s.carModel}', style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -.5)),
            Text('${s.carYear} • ${s.carClass}', style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(border: Border.all(color: Colors.white70, width: 1.5), borderRadius: BorderRadius.circular(12)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [Text(s.carPlate, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, letterSpacing: 1, fontSize: 17)), const SizedBox(width: 8), const Text('KZ', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800))]),
            ),
          ]),
        ),
      ),
      GridView.count(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: .8,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          for (final it in items)
            AppCard(
              margin: EdgeInsets.zero,
              padding: const EdgeInsets.fromLTRB(10, 11, 10, 13),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: it.$5)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.start, children: [toneIcon(it.$2, it.$3), const Icon(Icons.chevron_right, size: 18, color: Color(0xFFB3B8C8))]),
                const SizedBox(height: 12),
                Text(it.$1, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.8, height: 1.15)),
                const SizedBox(height: 3),
                Text(it.$4, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(color: kMut, fontSize: 11.5, height: 1.25)),
              ]),
            ),
        ],
      ),
    ]);
  }
}
