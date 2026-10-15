import 'package:flutter/material.dart';

import '../main.dart';
import '../state.dart';
import '../ui.dart';
import 'deposit.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});
  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.card_giftcard, 'Начислен кэшбэк 480 ₸', 'Вчера, 23:59'),
      (Icons.track_changes, 'До цели осталось 5 заказов', 'Сегодня, 17:30'),
      (Icons.emoji_events_outlined, 'Вы поднялись на 2 места в рейтинге', 'Сегодня, 15:10'),
      (Icons.description_outlined, 'Срок страховки истекает через 21 день', '12 окт'),
      (Icons.north_east, 'Окно вывода откроется 1-го числа', '10 окт'),
    ];
    return SubPage(title: 'Уведомления', children: [
      AppCard(child: Column(children: [
        for (final n in items) ListTile(contentPadding: EdgeInsets.zero, leading: toneIcon(n.$1, Tone.blue), title: Text(n.$2, style: const TextStyle(fontWeight: FontWeight.w700)), subtitle: Text(n.$3)),
      ])),
    ]);
  }
}

class DocumentsPage extends StatelessWidget {
  const DocumentsPage({super.key});
  @override
  Widget build(BuildContext context) {
    const docs = [
      ('Водительское удостоверение', '14.03.2019', '14.03.2029', 'Проверен', 'Действителен', ''),
      ('Удостоверение личности', '02.07.2021', '02.07.2031', 'Проверен', 'Действителен', ''),
      ('Страховой полис (ОСАГО)', '04.11.2025', '04.11.2026', 'Проверен', 'Истекает через 21 день', 'Продлите заранее'),
      ('Техосмотр', '10.04.2026', '10.04.2027', 'На проверке', 'Действителен', ''),
      ('Лицензия на перевозки', '20.01.2026', '20.01.2027', 'Проверен', 'Действителен', ''),
    ];
    return SubPage(title: 'Документы', children: [
      for (final d in docs)
        AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Expanded(child: Text(d.$1, style: const TextStyle(fontWeight: FontWeight.w700))), StatusChip(d.$4 == 'На проверке' ? 'Ожидает проверки' : d.$4)]),
          const SizedBox(height: 6),
          Text('Выдан: ${d.$2} · Действует до: ${d.$3}', style: const TextStyle(color: kMut, fontSize: 11.5)),
          const SizedBox(height: 6),
          StatusChip(d.$5),
          if (d.$6.isNotEmpty) note(d.$6),
        ])),
      note('Доступ к персональным данным ограничен ролями сотрудников таксопарка.'),
    ]);
  }
}

class GoalsPage extends StatelessWidget {
  const GoalsPage({super.key});
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    const names = {GoalType.orders: 'Заказы', GoalType.minutes: 'Часы на линии', GoalType.earn: 'Заработок'};
    return SubPage(title: 'Цели', children: [
      note('Цель — личный ориентир. Выполнение цели само по себе не даёт бонус: условия кэшбэка задаются отдельно.'),
      for (final g in s.goals)
        AppCard(child: Builder(builder: (_) {
          final cur = s.goalCurrent(g.type), pct = (cur * 100 / g.target).round().clamp(0, 100);
          final tgt = g.type == GoalType.minutes ? '${g.target ~/ 60} ч' : g.type == GoalType.earn ? money(g.target) : '${g.target}';
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('${names[g.type]} — ${g.period.toLowerCase()}', style: const TextStyle(fontWeight: FontWeight.w700)), Text('Цель: $tgt', style: const TextStyle(color: kMut, fontSize: 11.5))])),
              Switch(value: g.on, activeTrackColor: kBlue, onChanged: (v) {
                g.on = v;
                s.notify();
              }),
            ]),
            const SizedBox(height: 8),
            ClipRRect(borderRadius: BorderRadius.circular(99), child: LinearProgressIndicator(value: pct / 100, minHeight: 12, backgroundColor: const Color(0xFFE7EBF5), color: kBlue)),
            const SizedBox(height: 6),
            Text('$pct% выполнено${g.on ? '' : ' · отключена'}', style: const TextStyle(color: kMut, fontSize: 11.5)),
          ]);
        })),
      AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [h3('История'), const Text('Вчера: 27 из 25 заказов — выполнено ✓\n10 окт: 22 из 25 заказов — не выполнено', style: TextStyle(color: kMut, height: 1.5))])),
    ]);
  }
}

class TasksPage extends StatelessWidget {
  const TasksPage({super.key});
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final tasks = [
      ('30 заказов за день', 'Выполните 30 заказов за календарный день', s.orders, 30, '${s.orders} из 30', 1000, 'В процессе'),
      ('10 часов на линии', 'Проведите на линии 10 часов за день', s.minutes, 600, '${s.minutes ~/ 60} ч из 10 ч', 700, 'В процессе'),
      ('50 заказов за неделю', 'Выполните 50 заказов за неделю', 50, 50, '50 из 50', 2500, 'Ожидает проверки'),
    ];
    return SubPage(title: 'Задания', children: [
      for (final t in tasks)
        AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Expanded(child: Text(t.$1, style: const TextStyle(fontWeight: FontWeight.w700))), StatusChip(t.$7)]),
          Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Text(t.$2, style: const TextStyle(color: kMut, fontSize: 11.5))),
          ClipRRect(borderRadius: BorderRadius.circular(99), child: LinearProgressIndicator(value: (t.$3 / t.$4).clamp(0, 1), minHeight: 12, backgroundColor: const Color(0xFFE7EBF5), color: kBlue)),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(t.$5, style: const TextStyle(fontSize: 11.5)), Text('Награда: ${money(t.$6)}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11.5))]),
        ])),
      note('Денежная награда начисляется на депозит-карту отдельной операцией после проверки. Совместимость с кэшбэком настраивает администратор.'),
    ]);
  }
}

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});
  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  final days = [
    ['Пн', true, '08:00', '18:00'], ['Вт', true, '08:00', '18:00'], ['Ср', true, '08:00', '18:00'], ['Чт', true, '08:00', '18:00'],
    ['Пт', true, '08:00', '18:00'], ['Сб', true, '10:00', '16:00'], ['Вс', false, '', ''],
  ];
  bool remind = true;

  @override
  Widget build(BuildContext context) => SubPage(title: 'График', children: [
        AppCard(child: Column(children: [
          for (var i = 0; i < days.length; i++)
            Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Row(children: [
              SizedBox(width: 34, child: Text(days[i][0] as String, style: const TextStyle(fontWeight: FontWeight.w700))),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                days[i][1] as bool ? Text('${days[i][2]} – ${days[i][3]}') : const Text('Выходной', style: TextStyle(color: kMut)),
                if (i == 2 && days[i][1] as bool) const Text('Факт сегодня: на линии с 08:12 (6 ч 40 мин)', style: TextStyle(color: kMut, fontSize: 11.5)),
              ])),
              if (days[i][1] as bool) TextButton(onPressed: () => _edit(i), child: const Text('Изм.')),
              Switch(value: days[i][1] as bool, activeTrackColor: kBlue, onChanged: (v) => setState(() {
                days[i][1] = v;
                if (v && (days[i][2] as String).isEmpty) {
                  days[i][2] = '09:00';
                  days[i][3] = '17:00';
                }
              })),
            ])),
        ])),
        AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [const Expanded(child: Text('Напоминание о начале смены')), Switch(value: remind, activeTrackColor: kBlue, onChanged: (v) => setState(() => remind = v))]),
          note('Повторяющееся расписание. Для исключений (разовый выходной) используйте «Изм.» на нужном дне.'),
        ])),
      ]);

  Future<void> _edit(int i) async {
    final from = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 8, minute: 0), helpText: '${days[i][0]}: начало');
    if (from == null || !mounted) return;
    final to = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 18, minute: 0), helpText: '${days[i][0]}: конец');
    if (to == null) return;
    final f = from.hour * 60 + from.minute, t = to.hour * 60 + to.minute;
    if (f >= t) {
      if (mounted) toast(context, 'Начало должно быть раньше конца.');
      return;
    }
    setState(() {
      days[i][2] = '${pad2(from.hour)}:${pad2(from.minute)}';
      days[i][3] = '${pad2(to.hour)}:${pad2(to.minute)}';
    });
  }
}

class CarPage extends StatelessWidget {
  const CarPage({super.key});

  static String fmt(DateTime d) => '${pad2(d.day)}.${pad2(d.month)}.${d.year}';
  static String km(int n) => '${money(n).replaceAll('\u00A0₸', '')} км';

  Widget _due(DateTime d) {
    final left = d.difference(DateTime.now()).inDays + 1;
    return StatusChip(left < 0 ? 'Просрочено' : left <= 30 ? 'Осталось $left дн.' : 'Действует');
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return SubPage(title: 'Автомобиль', children: [
      AppCard(
        padding: const EdgeInsets.all(12),
        child: Row(children: [
          ClipRRect(borderRadius: BorderRadius.circular(14), child: Container(width: 92, height: 64, color: Colors.black, child: Image.asset('assets/car-front.png', fit: BoxFit.cover))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${s.carMake} ${s.carModel}', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, letterSpacing: -.3)),
            Text('${s.carYear} · Белый · ${s.carClass}', style: const TextStyle(color: kMut, fontSize: 12)),
            const SizedBox(height: 6),
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1), decoration: BoxDecoration(border: Border.all(color: const Color(0x803C4664), width: 1.5), borderRadius: BorderRadius.circular(7)), child: Text(s.carPlate, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: .6))),
          ])),
        ]),
      ),
      AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        onTap: () => _odo(context, s),
        child: Row(children: [
          toneIcon(Icons.speed, Tone.violet),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Пробег сейчас', style: TextStyle(color: kMut, fontSize: 12)), Text(km(s.odometer), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, letterSpacing: -.3))])),
          const Text('Изменить', style: TextStyle(color: kMut, fontSize: 12)),
        ]),
      ),
      AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        h3('Документы'),
        _DocRow(Icons.description_outlined, Tone.green, 'Техосмотр', 'до ${fmt(s.techUntil)}', _due(s.techUntil), () => _pickDate(context, s.techUntil, s.setTechUntil)),
        const Divider(height: 1, color: kLine),
        _DocRow(Icons.shield_outlined, Tone.amber, 'Страховка', 'до ${fmt(s.insUntil)}', _due(s.insUntil), () => _pickDate(context, s.insUntil, s.setInsUntil)),
      ])),
      AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Expanded(child: Text('Обслуживание', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15))),
          GestureDetector(onTap: () => _addService(context, s), child: const Text('+ Добавить', style: TextStyle(color: kBlue, fontSize: 13))),
        ]),
        const SizedBox(height: 4),
        if (s.services.isEmpty) const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('Записей пока нет. Добавьте, когда меняли масло, колодки или шины.', style: TextStyle(color: kMut, fontSize: 13))),
        for (final x in s.services)
          InkWell(
            onTap: () => _open(context, s, x),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                toneIcon(Icons.build_outlined, Tone.blue),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(x.what, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
                  Text('${fmt(x.date)} · ${km(x.km)}${x.next != null ? ' · следующий раз на ${km(x.next!)}' : ''}', style: const TextStyle(color: kMut, fontSize: 12)),
                  if (x.next != null) Padding(padding: const EdgeInsets.only(top: 4), child: _svcChip(x.next! - s.odometer)),
                ])),
                const Icon(Icons.chevron_right, size: 16, color: Color(0xFFB4B9C8)),
              ]),
            ),
          ),
        note('Укажите пробег при замене и на сколько км вперёд — приложение напомнит, когда пора.'),
      ])),
    ]);
  }

  Widget _svcChip(int left) => StatusChip(left <= 0 ? 'Пора менять' : left <= 1000 ? 'Скоро: осталось ${km(left)}' : 'Осталось ${km(left)}');

  Future<void> _pickDate(BuildContext c, DateTime cur, void Function(DateTime) apply) async {
    final d = await showDatePicker(context: c, initialDate: cur, firstDate: DateTime(2020), lastDate: DateTime(2040));
    if (d != null) apply(d);
  }

  void _odo(BuildContext c, AppState s) {
    final ctl = TextEditingController(text: '${s.odometer}');
    String? err;
    sheet(c, (ctx) => StatefulBuilder(builder: (ctx, set) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      h3('Пробег сейчас'),
      TextField(controller: ctl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Километров')),
      if (err != null) Padding(padding: const EdgeInsets.only(top: 6), child: Text(err!, style: const TextStyle(color: kErr, fontSize: 13))),
      const SizedBox(height: 10),
      PrimaryButton('Сохранить', onPressed: () {
        final e = s.setOdometer(ctl.text);
        if (e != null) return set(() => err = e);
        Navigator.pop(ctx);
        toast(c, 'Пробег обновлён');
      }),
    ])));
  }

  void _addService(BuildContext c, AppState s) {
    final what = TextEditingController(), kmC = TextEditingController(text: '${s.odometer}'), next = TextEditingController();
    var date = DateTime.now();
    String? err;
    sheet(c, (ctx) => StatefulBuilder(builder: (ctx, set) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      h3('Новая запись'),
      TextField(controller: what, maxLength: 60, decoration: const InputDecoration(labelText: 'Что сделали', hintText: 'Например: замена масла')),
      const SizedBox(height: 6),
      GestureDetector(
        onTap: () async {
          final d = await showDatePicker(context: ctx, initialDate: date, firstDate: DateTime(2020), lastDate: DateTime.now());
          if (d != null) set(() => date = d);
        },
        child: Container(height: 46, padding: const EdgeInsets.symmetric(horizontal: 12), alignment: Alignment.centerLeft, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)), child: Row(children: [const Icon(Icons.calendar_today_outlined, size: 16, color: kMut), const SizedBox(width: 8), Text('Дата: ${fmt(date)}')])),
      ),
      const SizedBox(height: 10),
      TextField(controller: kmC, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Пробег при замене, км')),
      const SizedBox(height: 10),
      TextField(controller: next, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Следующая замена на, км', hintText: 'Например: ${s.odometer + 10000}')),
      if (err != null) Padding(padding: const EdgeInsets.only(top: 6), child: Text(err!, style: const TextStyle(color: kErr, fontSize: 13))),
      const SizedBox(height: 10),
      PrimaryButton('Сохранить', onPressed: () {
        final e = s.addService(what.text, date, kmC.text, next.text);
        if (e != null) return set(() => err = e);
        Navigator.pop(ctx);
        toast(c, 'Запись добавлена');
      }),
    ])));
  }

  void _open(BuildContext c, AppState s, ServiceRecord x) {
    sheet(c, (ctx) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      h3(x.what),
      Container(padding: const EdgeInsets.symmetric(horizontal: 14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)), child: Column(children: [kv('Дата', fmt(x.date)), kv('Пробег при замене', km(x.km)), kv('Следующий раз на', x.next == null ? '—' : km(x.next!))])),
      const SizedBox(height: 12),
      PrimaryButton('Удалить запись', outline: true, onPressed: () {
        s.removeService(x.id);
        Navigator.pop(ctx);
        toast(c, 'Запись удалена');
      }),
    ]));
  }
}

class _DocRow extends StatelessWidget {
  const _DocRow(this.icon, this.tone, this.title, this.sub, this.chip, this.onTap);
  final IconData icon;
  final Tone tone;
  final String title, sub;
  final Widget chip;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 9),
          child: Row(children: [
            toneIcon(icon, tone),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)), Text(sub, style: const TextStyle(color: kMut, fontSize: 12))])),
            chip,
          ]),
        ),
      );
}

class ReferralPage extends StatelessWidget {
  const ReferralPage({super.key});
  @override
  Widget build(BuildContext context) => SubPage(title: 'Пригласи друга', children: [
        DarkCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Ваша ссылка', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 4),
          const Text('[APP_DOMAIN]/r/TLP7K2', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: PrimaryButton('Копировать', light: true, onPressed: () => toast(context, 'Ссылка скопирована'))),
            const SizedBox(width: 10),
            Expanded(child: PrimaryButton('Поделиться', light: true, onPressed: () => toast(context, 'Откроется системное меню «Поделиться»'))),
          ]),
          const SizedBox(height: 10),
          const Text('Домен утверждает владелец. Условия и суммы бонусов задаёт администратор.', style: TextStyle(color: Colors.white54, fontSize: 11.5)),
        ])),
        AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          h3('Приглашённые'),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Ержан А.', style: TextStyle(fontWeight: FontWeight.w700)), Text('Выполнил 12 из 25 заказов', style: TextStyle(color: kMut, fontSize: 11.5))]), const StatusChip('В процессе')]),
          const Divider(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Мадина К.', style: TextStyle(fontWeight: FontWeight.w700)), Text('Условие выполнено', style: TextStyle(color: kMut, fontSize: 11.5))]), const StatusChip('Ожидает утверждения суммы')]),
        ])),
        note('Бонус начисляется на депозит-карту только после выполнения условий активации и проверки (защита от самоприглашений и дублей).'),
      ]);
}

class HealthPage extends StatelessWidget {
  const HealthPage({super.key});
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return SubPage(title: 'Здоровье', children: [
      AppCard(child: Row(children: [
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Доступ к данным здоровья', style: TextStyle(fontWeight: FontWeight.w700)), Text('Apple HealthKit / Google Health Connect. Только с вашего согласия, отзывается в любой момент.', style: TextStyle(color: kMut, fontSize: 11.5))])),
        Switch(value: s.healthConsent, activeTrackColor: kBlue, onChanged: (v) {
          s.healthConsent = v;
          s.notify();
        }),
      ])),
      if (s.healthConsent) ...[
        Row(children: [
          for (final x in const [('6 840', 'шагов'), ('4,9', 'км'), ('38', 'мин актив.')]) Expanded(child: AppCard(margin: const EdgeInsets.only(right: 8, bottom: 8), padding: const EdgeInsets.all(12), child: Column(children: [Text(x.$1, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)), Text(x.$2, style: const TextStyle(color: kMut, fontSize: 11.5))]))),
        ]),
        note('Демо-значения. Приложение не даёт медицинских заключений.'),
      ] else
        banner('Подключение выключено — данные не запрашиваются.', info: true),
    ]);
  }
}

class SosPage extends StatefulWidget {
  const SosPage({super.key});
  @override
  State<SosPage> createState() => _SosPageState();
}

class _SosPageState extends State<SosPage> {
  final log = <String>[];
  @override
  Widget build(BuildContext context) => SubPage(title: 'SOS', children: [
        AppCard(child: Column(children: [
          const Text('В экстренной ситуации нажмите и подтвердите', style: TextStyle(color: kMut)),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _press,
            child: Container(width: 150, height: 150, decoration: BoxDecoration(color: const Color(0xFFE53935), shape: BoxShape.circle, border: Border.all(color: const Color(0xFFFBC4C3), width: 8)), alignment: Alignment.center, child: const Text('SOS', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700))),
          ),
          const SizedBox(height: 16),
          const Text('Контакт: Айгерим (жена) +7 700 000-00-00', style: TextStyle(color: kMut)),
        ])),
        AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          h3('Журнал событий'),
          if (log.isEmpty) const Text('Событий пока нет.', style: TextStyle(color: kMut)),
          for (final l in log) Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(l), const StatusChip('Запрос отправлен, доставка не подтверждена')])),
        ])),
        note('Приложение не утверждает, что сообщение доставлено, пока доставка не подтверждена. При угрозе жизни звоните 112.'),
      ]);

  void _press() {
    sheet(context, (ctx) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      h3('Отправить сигнал SOS?'),
      const Text('Будет отправлено сообщение контакту с вашей геолокацией (если разрешена).'),
      const SizedBox(height: 14),
      Row(children: [
        Expanded(child: PrimaryButton('Отмена', outline: true, onPressed: () => Navigator.pop(ctx))),
        const SizedBox(width: 10),
        Expanded(child: FilledButton(style: FilledButton.styleFrom(backgroundColor: const Color(0xFFE53935), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))), onPressed: () {
          final n = DateTime.now();
          setState(() => log.insert(0, 'Сегодня, ${pad2(n.hour)}:${pad2(n.minute)}'));
          Navigator.pop(ctx);
          toast(context, 'Запрос отправлен. Доставка пока не подтверждена.');
        }, child: const Text('Отправить', style: TextStyle(fontWeight: FontWeight.w700)))),
      ]),
    ]));
  }
}

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});
  @override
  Widget build(BuildContext context) => SubPage(title: 'Поддержка', children: [
        AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: PrimaryButton('Позвонить', outline: true, onPressed: () => toast(context, '+7 (000) 000-00-00 (демо)'))),
            const SizedBox(width: 10),
            Expanded(child: PrimaryButton('Обращение', onPressed: () => toast(context, 'Форма обращения: тема, текст, вложения'))),
          ]),
          note('Контакты: +7 (000) 000-00-00, поддержка 24/7 (демо).'),
        ])),
        AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          h3('Мои обращения'),
          for (final t in const [('Вопрос по начислению', 'SUP-114 · 12 окт', 'В работе'), ('Документы', 'SUP-102 · 3 окт', 'Решено')])
            ListTile(contentPadding: EdgeInsets.zero, title: Text(t.$1, style: const TextStyle(fontWeight: FontWeight.w700)), subtitle: Text(t.$2), trailing: StatusChip(t.$3)),
        ])),
        AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          h3('FAQ'),
          for (final q in const [('Когда начисляется кэшбэк?', 'После окончания дня и проверки данных, если выполнен порог заказов.'), ('Когда можно вывести бонусы?', 'Заявку можно подать 1-го числа месяца. Срок выплаты сообщит таксопарк.'), ('Чем депозит-карта отличается от баланса?', 'Это отдельный бонусный баланс таксопарка, а не банковская карта и не баланс Yandex.')])
            ExpansionTile(tilePadding: EdgeInsets.zero, title: Text(q.$1, style: const TextStyle(fontWeight: FontWeight.w600)), shape: const Border(), collapsedShape: const Border(), childrenPadding: const EdgeInsets.only(bottom: 10), expandedCrossAxisAlignment: CrossAxisAlignment.start, children: [Text(q.$2, style: const TextStyle(color: kMut))]),
        ])),
      ]);
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final n = {'Начало смены': true, 'Прогресс цели и заданий': true, 'Изменение места в рейтинге': true, 'Начисления кэшбэка и бонусов': true, 'Окно и статус вывода': true, 'Истечение документов': true, 'Сообщения таксопарка': true};
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return SubPage(title: 'Настройки', back: 'Профиль', children: [
      AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        h3('Язык'),
        SegmentedButton<String>(segments: const [ButtonSegment(value: 'kk', label: Text('Қазақша')), ButtonSegment(value: 'ru', label: Text('Русский'))], selected: {s.lang}, onSelectionChanged: (v) {
          s.lang = v.first;
          s.notify();
        }),
        note('В прототипе полный перевод на казахский не подключён: он добавляется через файлы локализации.'),
      ])),
      AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [h3('Личные данные'), Text('Имя: ${s.first} ${s.last}\nТелефон: +7 700 ••• •• 21\nИИН: •••• •••• 1234', style: const TextStyle(color: kMut, height: 1.5))])),
      AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        h3('Приватность'),
        Row(children: [const Expanded(child: Text('Показывать моё имя в рейтинге')), Switch(value: s.showName, activeTrackColor: kBlue, onChanged: (v) {
          s.showName = v;
          s.notify();
        })]),
        note('Если выключено, в таблице вы отображаетесь как «Водитель №…».'),
      ])),
      AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        h3('Уведомления'),
        for (final e in n.entries) Row(children: [Expanded(child: Text(e.key)), Switch(value: e.value, activeTrackColor: kBlue, onChanged: (v) => setState(() => n[e.key] = v))]),
        note('Финансовые статусы приходят независимо от настроек.'),
      ])),
    ]);
  }
}

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});
  @override
  Widget build(BuildContext context) => SubPage(title: 'Условия лояльности', back: 'Профиль', children: [termsCard()]);
}

class DemoPage extends StatelessWidget {
  const DemoPage({super.key});
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return SubPage(title: 'Демо-инструменты', back: 'Профиль', children: [
      banner('Только для демонстрации прототипа. В реальном приложении этих экранов нет.', info: true),
      AppCard(child: Row(children: [const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Имитировать 1-е число', style: TextStyle(fontWeight: FontWeight.w700)), Text('Открывает окно вывода с депозит-карты', style: TextStyle(color: kMut, fontSize: 11.5))])), Switch(value: s.windowOpen, activeTrackColor: kBlue, onChanged: (v) {
        s.windowOpen = v;
        s.notify();
      })])),
      AppCard(child: Row(children: [const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Данные Yandex синхронизированы', style: TextStyle(fontWeight: FontWeight.w700)), Text('Выключите, чтобы увидеть предупреждение', style: TextStyle(color: kMut, fontSize: 11.5))])), Switch(value: s.synced, activeTrackColor: kBlue, onChanged: (v) {
        s.synced = v;
        s.notify();
      })])),
      AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Заказы', style: TextStyle(fontWeight: FontWeight.w700)),
        Text('Сейчас завершено: ${s.orders}. Заказ обновляет цель, рейтинг, статус кэшбэка и график.', style: const TextStyle(color: kMut, fontSize: 11.5)),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: PrimaryButton('+1 заказ', onPressed: () => _sim(context, s, 1))),
          const SizedBox(width: 10),
          Expanded(child: PrimaryButton('+5 заказов', outline: true, onPressed: () => _sim(context, s, 5))),
        ]),
      ])),
      AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Заявки на вывод', style: TextStyle(fontWeight: FontWeight.w700)),
        Text('Последняя заявка: ${s.payouts.isEmpty ? 'нет' : '${s.payouts.first.id} — ${s.payouts.first.status}'}', style: const TextStyle(color: kMut, fontSize: 11.5)),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: PrimaryButton('Выполнить', onPressed: s.payoutDone)),
          const SizedBox(width: 10),
          Expanded(child: PrimaryButton('Отклонить', outline: true, onPressed: s.payoutReject)),
        ]),
      ])),
    ]);
  }

  void _sim(BuildContext c, AppState s, int n) {
    final ok = s.simOrders(n);
    toast(c, !ok ? 'Нет синхронизации — заказ не учтён (демо)' : s.orders >= 25 ? 'Условие кэшбэка выполнено — начисление после окончания дня' : 'Заказ завершён и учтён');
  }
}
