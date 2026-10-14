import 'package:flutter/material.dart';

import '../main.dart';
import '../state.dart';
import '../ui.dart';
import 'deposit.dart';
import 'misc.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    void push(Widget w) => Navigator.push(context, MaterialPageRoute(builder: (_) => w));
    final rows = <(IconData, String, String, VoidCallback)>[
      (Icons.person_outline, 'Личные данные', 'ФИО, телефон, дата рождения', () => push(const SettingsPage())),
      (Icons.directions_car_outlined, 'Мой автомобиль', 'Информация о машине', () => push(const CarPage())),
      (Icons.description_outlined, 'Документы', 'Права, техпаспорт, страховка', () => push(const DocumentsPage())),
      (Icons.account_balance_wallet_outlined, 'Способы выплат', 'Kaspi, реквизиты', () => sheet(context, (_) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [h3('Способы выплат'), kv('Kaspi •• 4821', 'Основной'), note('Реквизиты маскированы. Добавление — после согласования платёжного провайдера.')]))),
      (Icons.notifications_none, 'Уведомления', 'Настройки уведомлений', () => push(const SettingsPage())),
      (Icons.lock_outline, 'Безопасность', 'Смена пароля, Face ID / Touch ID', () => toast(context, 'Face ID / Touch ID подключаются в полной версии')),
      (Icons.language, 'Язык', 'Қазақша / Русский', () => push(const SettingsPage())),
      (Icons.card_giftcard, 'Условия лояльности', 'Кэшбэк, вывод, правила', () => push(const TermsPage())),
      (Icons.help_outline, 'Помощь', 'Частые вопросы', () => push(const SupportPage())),
      (Icons.science_outlined, 'Демо-инструменты', 'Только для показа прототипа', () => push(const DemoPage())),
      (Icons.logout, 'Выйти из аккаунта', '', () => toast(context, 'Выход (демо)')),
    ];
    return ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 120), children: [
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          h2('Профиль'),
          const Text.rich(TextSpan(children: [TextSpan(text: 'TULPAR LINE ', style: TextStyle(color: kInk, fontWeight: FontWeight.w800)), TextSpan(text: 'Таксопарк')]), style: TextStyle(color: kMut, fontSize: 15)),
        ])),
        GestureDetector(onTap: () => push(const SettingsPage()), child: Container(width: 46, height: 46, decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: kShadow), child: const Icon(Icons.settings_outlined))),
      ]),
      const SizedBox(height: 16),
      Row(children: [
        const Avatar(size: 76),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('${s.first}\n${s.last}', style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, height: 1.15)), const Text('Водитель', style: TextStyle(color: kMut))])),
      ]),
      const SizedBox(height: 16),
      AppCard(
        padding: const EdgeInsets.all(12),
        onTap: () => push(const DepositPage()),
        child: Row(children: [
          toneIcon(Icons.currency_exchange, Tone.blue),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Бонусный баланс', style: TextStyle(color: kMut, fontSize: 12)), Text(money(s.depBalance), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17))])),
          const Icon(Icons.chevron_right, color: Color(0xFFB3B8C8)),
        ]),
      ),
      for (final r in rows)
        AppCard(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          onTap: r.$4,
          child: Row(children: [
            toneIcon(r.$1, Tone.gray),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(r.$2, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15.5)), if (r.$3.isNotEmpty) Text(r.$3, style: const TextStyle(color: kMut, fontSize: 12.5))])),
            const Icon(Icons.chevron_right, size: 18, color: Color(0xFFB3B8C8)),
          ]),
        ),
    ]);
  }
}
