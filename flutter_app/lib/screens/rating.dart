import 'package:flutter/material.dart';

import '../main.dart';
import '../ui.dart';

class RatingPage extends StatelessWidget {
  const RatingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return SubPage(title: 'Рейтинг', children: [
      DarkCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Ваше место · период: сегодня', style: TextStyle(color: Colors.white70, fontSize: 12.5)),
        Text('${s.place}-е из 100', style: const TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.w800, letterSpacing: -1)),
      ])),
      AppCard(padding: const EdgeInsets.all(12), child: Column(children: [
        const Padding(padding: EdgeInsets.symmetric(vertical: 8, horizontal: 6), child: Row(children: [SizedBox(width: 30, child: _H('#')), Expanded(child: _H('ВОДИТЕЛЬ')), SizedBox(width: 52, child: _H('ЗАКАЗЫ')), SizedBox(width: 52, child: _H('БАЛЛЫ')), SizedBox(width: 40, child: _H('±'))])),
        for (final r in s.rating)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
            decoration: BoxDecoration(color: r.me ? const Color(0xFFE4ECFF) : null, borderRadius: BorderRadius.circular(14), border: r.me ? null : const Border(top: BorderSide(color: kLine))),
            child: Row(children: [
              SizedBox(width: 30, child: Text('${r.place}', style: TextStyle(fontWeight: r.me ? FontWeight.w800 : FontWeight.w500))),
              Expanded(child: Text(r.me ? '${r.name} (вы)' : r.name, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: r.me ? FontWeight.w800 : FontWeight.w500))),
              SizedBox(width: 52, child: Text('${r.orders}')),
              SizedBox(width: 52, child: Text('${r.score}')),
              SizedBox(width: 40, child: r.change > 0 ? Text('▲${r.change}', style: const TextStyle(color: kOk)) : r.change < 0 ? Text('▼${-r.change}', style: const TextStyle(color: kErr)) : const Text('—', style: TextStyle(color: kMut))),
            ]),
          ),
        note('Баллы рейтинга — не деньги и не Coins. Период и критерии настраиваются в админ-панели; по окончании периода результаты уходят в архив. Имена сокращены согласно настройкам приватности.'),
      ])),
    ]);
  }
}

class _H extends StatelessWidget {
  const _H(this.t);
  final String t;
  @override
  Widget build(BuildContext context) => Text(t, style: const TextStyle(fontSize: 10.5, color: kMut, fontWeight: FontWeight.w700));
}
