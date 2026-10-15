import 'package:flutter/material.dart';

import '../main.dart';
import '../ui.dart';
import 'deposit.dart';
import 'home.dart' show BellButton;
import 'misc.dart';
import 'rating.dart';

/// Заголовок раздела: 32/38 + «TULPAR LINE Таксопарк» 16.
class ScreenHead extends StatelessWidget {
  const ScreenHead(this.title, {super.key, this.trailing});
  final String title;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(2, 2, 2, 12),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            h2(title),
            const Text.rich(TextSpan(children: [TextSpan(text: 'TULPAR LINE  ', style: TextStyle(color: kInk, fontWeight: FontWeight.w700)), TextSpan(text: 'Таксопарк')]), style: TextStyle(color: kMut, fontSize: 14, height: 20 / 16)),
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
    final items = <(String, IconData, Tone, String, WidgetBuilder)>[
      ('Документы', Icons.description_outlined, Tone.blue, 'Все файлы', (_) => const DocumentsPage()),
      ('Цели', Icons.track_changes, Tone.green, 'День и неделя', (_) => const GoalsPage()),
      ('Задания', Icons.assignment_turned_in_outlined, Tone.violet, 'Награды', (_) => const TasksPage()),
      ('Рейтинг', Icons.emoji_events_outlined, Tone.amber, 'Ваше место', (_) => const RatingPage()),
      ('График', Icons.calendar_month_outlined, Tone.blue, 'Расписание', (_) => const SchedulePage()),
      ('Автомобиль', Icons.directions_car_outlined, Tone.red, 'Обслуживание', (_) => const CarPage()),
      ('Депозит-карта Tulpar Line', Icons.currency_exchange, Tone.dark, 'Бонусы', (_) => const DepositPage()),
      ('Пригласи друга', Icons.person_add_alt, Tone.amber, 'Бонусы за друга', (_) => const ReferralPage()),
      ('Здоровье', Icons.favorite_border, Tone.red, 'Активность', (_) => const HealthPage()),
      ('SOS', Icons.sos, Tone.dark, 'Экстренно', (_) => const SosPage()),
      ('Поддержка', Icons.headset_mic_outlined, Tone.violet, '24/7', (_) => const SupportPage()),
    ];
    return ListView(padding: const EdgeInsets.fromLTRB(kM, 4, kM, 120), children: [
      ScreenHead('Сервис', trailing: BellButton(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsPage())))),
      DarkCard(
        car: 'assets/car-front.png',
        carWidth: .42,
        carRight: -8,
        carBottom: -6,
        minHeight: 150,
        child: SizedBox(
          width: double.infinity,
          height: 134,
          child: Stack(children: [
            Positioned(right: -4, top: -4, child: Container(width: 30, height: 30, decoration: const BoxDecoration(color: Color(0x24FFFFFF), shape: BoxShape.circle), child: const Icon(Icons.chevron_right, color: Colors.white, size: 18))),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const LogoRow(),
              const SizedBox(height: 10),
              Text('${s.carMake} ${s.carModel}', style: const TextStyle(color: Colors.white, fontSize: 22, height: 27 / 22, fontWeight: FontWeight.w700, letterSpacing: -.9)),
              Text('${s.carYear} • ${s.carClass}', style: const TextStyle(color: Colors.white70, fontSize: 15, height: 22 / 17)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(border: Border.all(color: Colors.white70, width: 1.5), borderRadius: BorderRadius.circular(12)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(s.carPlate, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, letterSpacing: 1.1, fontSize: 17, height: 26 / 22)),
                  const SizedBox(width: 10),
                  Column(mainAxisSize: MainAxisSize.min, children: [Container(width: 18, height: 11, decoration: BoxDecoration(color: const Color(0xFF00AFCA), borderRadius: BorderRadius.circular(2))), const SizedBox(height: 2), const Text('KZ', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700, height: 12 / 10))]),
                ]),
              ),
            ]),
          ]),
        ),
      ),
      GridView.count(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.0,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          for (final it in items)
            AppCard(
              margin: EdgeInsets.zero,
              padding: const EdgeInsets.all(10),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: it.$5)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.start, children: [toneIcon(it.$2, it.$3, size: 36), const Padding(padding: EdgeInsets.only(top: 4), child: Icon(Icons.chevron_right, size: 16, color: Color(0xFFB4B9C8)))]),
                const SizedBox(height: 8),
                Text(it.$1, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, height: 19 / 16, letterSpacing: -.3)),
                const SizedBox(height: 3),
                Expanded(child: Text(it.$4, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: kMut, fontSize: 11.5, height: 16 / 12.5))),
              ]),
            ),
        ],
      ),
    ]);
  }
}
