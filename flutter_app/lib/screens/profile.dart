import 'package:flutter/material.dart';

import '../main.dart';
import '../state.dart';
import '../ui.dart';
import 'deposit.dart';
import 'misc.dart';
import 'service.dart';

void _pickAvatar(BuildContext c, AppState s) {
  sheet(c, (ctx) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    h3('Выберите аватар'),
    GridView.count(
      crossAxisCount: 5,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        for (var i = 1; i <= 10; i++)
          GestureDetector(
            onTap: () {
              s.setAvatar(i);
              Navigator.pop(ctx);
              toast(c, 'Аватар изменён');
            },
            child: Container(
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: s.avatar == i ? kBlue : Colors.transparent, width: 3), boxShadow: kShadow),
              child: ClipOval(child: Image.asset('assets/avatars/a$i.jpg', fit: BoxFit.cover)),
            ),
          ),
      ],
    ),
    note('3D-аватар виден в приложении вам и таксопарку.'),
  ]));
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    void push(Widget w) => Navigator.push(context, MaterialPageRoute(builder: (_) => w));
    final rows = <(IconData, String, String, VoidCallback)>[
      (Icons.person_outline, 'Личные данные', 'ФИО, телефон, дата рождения', () => push(const SettingsPage())),
      (Icons.directions_car_outlined, 'Мой автомобиль', 'Информация о машине', () => push(const CarPage())),
      (Icons.description_outlined, 'Документы', 'Водительские права, техпаспорт, страховка', () => push(const DocumentsPage())),
      (Icons.account_balance_wallet_outlined, 'Способы выплат', 'Kaspi, реквизиты', () => sheet(context, (_) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [h3('Способы выплат'), Container(padding: const EdgeInsets.symmetric(horizontal: 14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)), child: kv('Kaspi •• 4821', 'Основной')), note('Реквизиты маскированы. Добавление — после согласования платёжного провайдера.')]))),
      (Icons.notifications_none, 'Уведомления', 'Настройки уведомлений', () => push(const SettingsPage())),
      (Icons.lock_outline, 'Безопасность', 'Смена пароля, Face ID / Touch ID', () => toast(context, 'Face ID / Touch ID подключаются в полной версии')),
      (Icons.language, 'Язык', 'Қазақша / Русский', () => push(const SettingsPage())),
      (Icons.card_giftcard, 'Условия лояльности', 'Кэшбэк, вывод, правила', () => push(const TermsPage())),
      (Icons.help_outline, 'Помощь', 'Частые вопросы', () => push(const SupportPage())),
      (Icons.science_outlined, 'Демо-инструменты', 'Только для показа прототипа', () => push(const DemoPage())),
      (Icons.logout, 'Выйти из аккаунта', '', () => toast(context, 'Выход (демо)')),
    ];
    return ListView(padding: const EdgeInsets.fromLTRB(kM, 4, kM, 120), children: [
      ScreenHead('Профиль', trailing: GestureDetector(onTap: () => push(const SettingsPage()), child: Container(width: 38, height: 38, decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: kShadow), child: const Icon(Icons.settings_outlined, size: 20)))),
      Padding(
        padding: const EdgeInsets.fromLTRB(2, 0, 2, 12),
        child: Row(children: [
          GestureDetector(
            onTap: () => _pickAvatar(context, s),
            child: Stack(clipBehavior: Clip.none, children: [
              Avatar(size: 64, index: s.avatar),
              Positioned(right: -2, bottom: -2, child: Container(width: 22, height: 22, decoration: BoxDecoration(color: kInk, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)), child: const Icon(Icons.edit, color: Colors.white, size: 11))),
            ]),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('${s.first}\n${s.last}', style: const TextStyle(fontSize: 17, height: 24 / 20, fontWeight: FontWeight.w700, letterSpacing: -.5)), const Text('Водитель', style: TextStyle(color: kMut, fontSize: 14))])),
          GestureDetector(
            onTap: () => push(const DepositPage()),
            child: Container(
              padding: const EdgeInsets.fromLTRB(8, 8, 12, 8),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: .9), borderRadius: BorderRadius.circular(20), boxShadow: kShadow),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                IconBox(Icons.currency_exchange, bg: Tone.blue.bg, fg: kBlue, size: 28),
                const SizedBox(width: 6),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Бонусы', style: TextStyle(color: kMut, fontSize: 11.5, height: 15 / 12.5)), Text(money(s.depBalance), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, height: 22 / 18, letterSpacing: -.5))]),
              ]),
            ),
          ),
        ]),
      ),
      for (final r in rows)
        AppCard(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          onTap: r.$4,
          child: Row(children: [
            toneIcon(r.$1, Tone.gray),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(r.$2, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, height: 21 / 17, letterSpacing: -.3)), if (r.$3.isNotEmpty) Text(r.$3, style: const TextStyle(color: kMut, fontSize: 12, height: 17 / 13))])),
            const Icon(Icons.chevron_right, size: 17, color: Color(0xFFB4B9C8)),
          ]),
        ),
    ]);
  }
}
