import 'package:flutter/material.dart';

import '../main.dart';
import '../state.dart';
import '../ui.dart';
import 'deposit.dart';
import 'misc.dart';
import 'service.dart';

/// Строка списка iOS: плашка-иконка 30, заголовок 15, шеврон, высота ≥ 44.
class ListRow extends StatelessWidget {
  const ListRow(this.icon, this.tone, this.title, {super.key, this.onTap, this.last = false, this.destructive = false, this.trailing});
  final IconData icon;
  final Tone tone;
  final String title;
  final VoidCallback? onTap;
  final bool last, destructive;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.only(left: 14),
          child: Container(
            constraints: const BoxConstraints(minHeight: 44),
            padding: const EdgeInsets.only(right: 14),
            decoration: BoxDecoration(border: last ? null : const Border(bottom: BorderSide(color: kLine, width: .5))),
            child: Row(children: [
              toneIcon(icon, tone),
              const SizedBox(width: 12),
              Expanded(child: Text(title, style: TextStyle(fontSize: 15, color: destructive ? kRed : kInk))),
              ?trailing,
              if (!destructive) const Icon(Icons.chevron_right, size: 18, color: Color(0xFFC4C4C7)),
            ]),
          ),
        ),
      );
}

Widget group(List<Widget> rows) => Container(margin: const EdgeInsets.only(bottom: 12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)), clipBehavior: Clip.antiAlias, child: Column(children: rows));

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    void push(Widget w) => Navigator.push(context, MaterialPageRoute(builder: (_) => w));
    final rows = <(IconData, String, VoidCallback)>[
      (Icons.person_outline, 'Личные данные', () => push(const SettingsPage())),
      (Icons.directions_car_outlined, 'Мой автомобиль', () => push(const CarPage())),
      (Icons.description_outlined, 'Документы', () => push(const DocumentsPage())),
      (Icons.account_balance_wallet_outlined, 'Способы выплат', () => sheet(context, (_) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [h3('Способы выплат'), group([Padding(padding: const EdgeInsets.all(14), child: kv('Kaspi •• 4821', 'Основной'))]), note('Реквизиты маскированы. Добавление — после согласования платёжного провайдера.')]))),
      (Icons.notifications_none, 'Уведомления', () => push(const SettingsPage())),
      (Icons.lock_outline, 'Безопасность', () => toast(context, 'Face ID / Touch ID подключаются в полной версии')),
      (Icons.language, 'Язык', () => push(const SettingsPage())),
      (Icons.card_giftcard, 'Условия лояльности', () => push(const TermsPage())),
      (Icons.help_outline, 'Помощь', () => push(const SupportPage())),
      (Icons.science_outlined, 'Демо-инструменты', () => push(const DemoPage())),
    ];
    return ListView(padding: const EdgeInsets.fromLTRB(kM, 4, kM, 80), children: [
      ScreenHead('Профиль', trailing: GestureDetector(onTap: () => push(const SettingsPage()), child: Container(width: 34, height: 34, decoration: const BoxDecoration(color: kFill, shape: BoxShape.circle), child: const Icon(Icons.settings_outlined, size: 18, color: kBlue)))),
      Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Row(children: [
          const Avatar(size: 64),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('${s.first} ${s.last}', style: const TextStyle(fontSize: 20, height: 25 / 20, fontWeight: FontWeight.w600, letterSpacing: -.3)), const Text('Водитель', style: TextStyle(color: kMut, fontSize: 13))])),
        ]),
      ),
      group([
        InkWell(
          onTap: () => push(const DepositPage()),
          child: Padding(padding: const EdgeInsets.all(12), child: Row(children: [
            toneIcon(Icons.currency_exchange, Tone.blue),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Бонусный баланс', style: TextStyle(color: kMut, fontSize: 12, height: 15 / 12)), Text(money(s.depBalance), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17, height: 22 / 17))])),
            const Icon(Icons.chevron_right, size: 18, color: Color(0xFFC4C4C7)),
          ])),
        ),
      ]),
      group([for (final (i, r) in rows.indexed) ListRow(r.$1, Tone.gray, r.$2, onTap: r.$3, last: i == rows.length - 1)]),
      group([ListRow(Icons.logout, Tone.gray, 'Выйти из аккаунта', destructive: true, last: true, onTap: () => toast(context, 'Выход (демо)'))]),
    ]);
  }
}
