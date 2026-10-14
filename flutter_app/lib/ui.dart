import 'package:flutter/material.dart';


const kBlue = Color(0xFF2F6BFF);
const kInk = Color(0xFF0B0B0F);
const kMut = Color(0xFF7B8092);
const kBg = Color(0xFFF4F6FB);
const kLine = Color(0xFFE9ECF3);
const kOk = Color(0xFF13A24A);
const kErr = Color(0xFFE5484D);

List<BoxShadow> get kShadow => [BoxShadow(color: const Color(0xFF1E326E).withValues(alpha: .14), blurRadius: 26, offset: const Offset(0, 10), spreadRadius: -12)];

/// Белая карточка.
class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.padding = const EdgeInsets.all(18), this.onTap, this.margin = const EdgeInsets.only(bottom: 14)});
  final Widget child;
  final EdgeInsets padding, margin;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Container(
        margin: margin,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(26), boxShadow: kShadow),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(26),
          child: InkWell(borderRadius: BorderRadius.circular(26), onTap: onTap, child: Padding(padding: padding, child: child)),
        ),
      );
}

/// Тёмная карточка с лёгким свечением.
class DarkCard extends StatelessWidget {
  const DarkCard({super.key, required this.child, this.padding = const EdgeInsets.all(18), this.car = false, this.carTop, this.carWidthFactor = .8, this.margin = const EdgeInsets.only(bottom: 14)});
  final Widget child;
  final EdgeInsets padding, margin;
  final bool car;
  final double? carTop;
  final double carWidthFactor;
  @override
  Widget build(BuildContext context) => Container(
        margin: margin,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF1B1C22), Color(0xFF050506)]),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(children: [
          Positioned(right: -60, top: -60, child: Container(width: 220, height: 160, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [const Color(0xFF5064A0).withValues(alpha: .35), Colors.transparent])))),
          if (car)
            Positioned(
              right: -24,
              top: carTop,
              bottom: carTop == null ? -6 : null,
              child: LayoutBuilder(builder: (c, _) => SizedBox(width: MediaQuery.of(context).size.width * carWidthFactor * .8, child: const AspectRatio(aspectRatio: 330 / 120, child: CustomPaint(painter: CarPainter())))),
            ),
          Padding(padding: padding, child: child),
        ]),
      );
}

class IconBox extends StatelessWidget {
  const IconBox(this.icon, {super.key, this.bg = const Color(0xFFEEF1F8), this.fg = kInk, this.size = 42});
  final IconData icon;
  final Color bg, fg;
  final double size;
  @override
  Widget build(BuildContext context) => Container(width: size, height: size, decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(size * .33)), child: Icon(icon, color: fg, size: size * .52));
}

class Tone {
  const Tone(this.bg, this.fg);
  final Color bg, fg;
  static const green = Tone(Color(0xFFE3F6EA), Color(0xFF12994A));
  static const red = Tone(Color(0xFFFDE6E7), Color(0xFFD63A40));
  static const blue = Tone(Color(0xFFE4ECFF), kBlue);
  static const amber = Tone(Color(0xFFFFF0D1), Color(0xFFD98A00));
  static const violet = Tone(Color(0xFFECE8FF), Color(0xFF6A4DF0));
  static const dark = Tone(kInk, Colors.white);
  static const gray = Tone(Color(0xFFEEF1F8), kInk);
}

Widget toneIcon(IconData i, Tone t, {double size = 42}) => IconBox(i, bg: t.bg, fg: t.fg, size: size);

/// Статус-чип.
class StatusChip extends StatelessWidget {
  const StatusChip(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) {
    Color bg = const Color(0xFFECEEF5), fg = const Color(0xFF444444);
    if (RegExp(r'Начислено|Выполнена|Проверен|Действителен|Решено|Закрыто|выполнено').hasMatch(text)) {
      bg = const Color(0xFFDFF5E8);
      fg = const Color(0xFF0D7C38);
    } else if (RegExp(r'проверки|обработ|Создана|Новое|В работе|Ожидает|Истекает').hasMatch(text)) {
      bg = const Color(0xFFFFF0C7);
      fg = const Color(0xFF9A6700);
    } else if (RegExp(r'Отклонена|Отменён').hasMatch(text)) {
      bg = const Color(0xFFFDE3E4);
      fg = const Color(0xFFC0292E);
    } else if (RegExp(r'Накоплени|Вывод доступен|Основной|Выбрано').hasMatch(text)) {
      bg = const Color(0xFFE4ECFF);
      fg = const Color(0xFF2150C8);
    }
    return Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(99)), child: Text(text, style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w700)));
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton(this.label, {super.key, this.onPressed, this.light = false, this.outline = false});
  final String label;
  final VoidCallback? onPressed;
  final bool light, outline;
  @override
  Widget build(BuildContext context) {
    final bg = outline ? Colors.white : (light ? Colors.white : kInk);
    final fg = outline || light ? kInk : Colors.white;
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(backgroundColor: bg, foregroundColor: fg, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: outline ? const BorderSide(color: kInk, width: 1.5) : BorderSide.none), textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        child: Text(label),
      ),
    );
  }
}

class LogoMark extends StatelessWidget {
  const LogoMark({super.key, this.size = 36});
  final double size;
  @override
  Widget build(BuildContext context) => SizedBox(width: size, height: size, child: const CustomPaint(painter: _LogoPainter()));
}

class _LogoPainter extends CustomPainter {
  const _LogoPainter();
  @override
  void paint(Canvas c, Size s) {
    final w = s.width / 40;
    c.drawCircle(Offset(s.width / 2, s.height / 2), s.width / 2, Paint()..color = Colors.white);
    final p = Path()
      ..moveTo(20 * w, 8 * w)
      ..lineTo(31 * w, 32 * w)
      ..lineTo(20 * w, 26 * w)
      ..lineTo(9 * w, 32 * w)
      ..close();
    c.drawPath(p, Paint()..color = kInk);
    c.drawPath(p, Paint()..color = kInk..style = PaintingStyle.stroke..strokeWidth = 2 * w..strokeJoin = StrokeJoin.round);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class LogoRow extends StatelessWidget {
  const LogoRow({super.key});
  @override
  Widget build(BuildContext context) => const Row(mainAxisSize: MainAxisSize.min, children: [
        LogoMark(),
        SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('TULPAR LINE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, letterSpacing: 2, fontSize: 14)),
          Text('ТАКСОПАРК', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w600, letterSpacing: 3, fontSize: 9)),
        ]),
      ]);
}

class Avatar extends StatelessWidget {
  const Avatar({super.key, this.size = 56});
  final double size;
  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2), boxShadow: kShadow),
        clipBehavior: Clip.antiAlias,
        child: const CustomPaint(painter: _AvatarPainter()),
      );
}

class _AvatarPainter extends CustomPainter {
  const _AvatarPainter();
  @override
  void paint(Canvas c, Size s) {
    final k = s.width / 64;
    Paint f(int v) => Paint()..color = Color(v);
    c.drawRect(Offset.zero & s, f(0xFFE3E8F4));
    c.drawPath(Path()..moveTo(6 * k, 64 * k)..quadraticBezierTo(8 * k, 45 * k, 32 * k, 45 * k)..quadraticBezierTo(56 * k, 45 * k, 58 * k, 64 * k)..close(), f(0xFF16171B));
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(27 * k, 37 * k, 10 * k, 10 * k), Radius.circular(4 * k)), f(0xFFDFB08A));
    c.drawOval(Rect.fromCenter(center: Offset(32 * k, 27 * k), width: 24 * k, height: 28 * k), f(0xFFF2CBA8));
    c.drawPath(Path()..moveTo(19 * k, 27 * k)..quadraticBezierTo(17 * k, 10 * k, 33 * k, 10 * k)..quadraticBezierTo(47 * k, 10 * k, 45 * k, 25 * k)..quadraticBezierTo(40 * k, 18 * k, 33 * k, 19 * k)..quadraticBezierTo(24 * k, 19 * k, 19 * k, 27 * k)..close(), f(0xFF1B1410));
    c.drawCircle(Offset(27 * k, 29 * k), 1.5 * k, f(0xFF2A1D17));
    c.drawCircle(Offset(37 * k, 29 * k), 1.5 * k, f(0xFF2A1D17));
    c.drawArc(Rect.fromLTWH(28 * k, 33 * k, 8 * k, 5 * k), .3, 2.5, false, Paint()..color = const Color(0xFFA15D4A)..style = PaintingStyle.stroke..strokeWidth = 1.7 * k..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

/// Седан в профиль с красным задним фонарём.
class CarPainter extends CustomPainter {
  const CarPainter();
  @override
  void paint(Canvas c, Size s) {
    final k = s.width / 330;
    c.save();
    c.scale(k);
    c.drawOval(Rect.fromCenter(center: const Offset(165, 112), width: 280, height: 12), Paint()..color = Colors.black.withValues(alpha: .35));
    final body = Path()
      ..moveTo(16, 88)
      ..quadraticBezierTo(16, 76, 28, 73)
      ..lineTo(64, 63)
      ..lineTo(98, 36)
      ..quadraticBezierTo(106, 30, 118, 30)
      ..lineTo(188, 30)
      ..quadraticBezierTo(204, 30, 214, 40)
      ..lineTo(240, 62)
      ..lineTo(276, 70)
      ..quadraticBezierTo(290, 73, 290, 86)
      ..lineTo(290, 90)
      ..quadraticBezierTo(290, 96, 284, 96)
      ..lineTo(274, 96)
      ..arcToPoint(const Offset(222, 96), radius: const Radius.circular(26), clockwise: false)
      ..lineTo(106, 96)
      ..arcToPoint(const Offset(54, 96), radius: const Radius.circular(26), clockwise: false)
      ..lineTo(24, 96)
      ..quadraticBezierTo(16, 96, 16, 88)
      ..close();
    c.drawPath(body, Paint()..shader = const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF6A707E), Color(0xFF23262D), Color(0xFF07080A)], stops: [0, .45, 1]).createShader(const Rect.fromLTWH(0, 30, 330, 70)));
    c.drawPath(body, Paint()..color = const Color(0xFF8D97AD).withValues(alpha: .55)..style = PaintingStyle.stroke..strokeWidth = 1.2);
    c.drawPath(Path()..moveTo(96, 60)..lineTo(120, 40)..quadraticBezierTo(126, 35, 135, 35)..lineTo(185, 35)..quadraticBezierTo(193, 35, 205, 43)..lineTo(223, 60)..close(), Paint()..color = const Color(0xFF9DB2D4).withValues(alpha: .28));
    for (final x in [80.0, 248.0]) {
      c.drawCircle(Offset(x, 96), 22, Paint()..color = const Color(0xFF08090B));
      c.drawCircle(Offset(x, 96), 11, Paint()..color = const Color(0xFF5B6070));
    }
    c.drawCircle(const Offset(290, 76), 34, Paint()..shader = RadialGradient(colors: [const Color(0xFFFF3B30).withValues(alpha: .85), Colors.transparent]).createShader(Rect.fromCircle(center: const Offset(290, 76), radius: 34)));
    c.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(274, 72, 26, 6), const Radius.circular(3)), Paint()..color = const Color(0xFFFF5A4F));
    c.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

/// Столбчатая диаграмма: доходы (синий) и расходы (розовый) с осью Y.
class IncomeExpenseChart extends StatelessWidget {
  const IncomeExpenseChart({super.key, required this.inc, required this.exp, required this.labels});
  final List<int> inc, exp;
  final List<String> labels;
  @override
  Widget build(BuildContext context) {
    var mx = 1;
    for (var i = 0; i < inc.length; i++) {
      if (inc[i] > mx) mx = inc[i];
      if (exp[i] > mx) mx = exp[i];
    }
    const steps = [1000, 2000, 5000, 10000, 20000, 25000, 50000, 100000];
    var st = 100000;
    for (final s in steps) {
      if (mx / s <= 3) {
        st = s;
        break;
      }
    }
    final n = (mx / st).ceil();
    final top = st * n;
    return Column(children: [
      SizedBox(
        height: 150,
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          SizedBox(
            width: 34,
            child: Stack(children: [
              for (var j = 0; j <= n; j++)
                Positioned(bottom: j * 150 / n - 7, left: 0, right: 4, child: Text(j == 0 ? '0' : '${j * st ~/ 1000}K', textAlign: TextAlign.right, style: const TextStyle(fontSize: 10, color: kMut))),
            ]),
          ),
          Expanded(
            child: Stack(children: [
              for (var j = 0; j <= n; j++) Positioned(bottom: j * 150 / n, left: 0, right: 0, child: Container(height: 1, color: kLine)),
              Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                for (var i = 0; i < inc.length; i++)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 1),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Expanded(child: FractionallySizedBox(heightFactor: inc[i] / top, child: Container(decoration: const BoxDecoration(borderRadius: BorderRadius.vertical(top: Radius.circular(4)), gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF5D8CFF), kBlue]))))),
                        const SizedBox(width: 1),
                        Expanded(child: FractionallySizedBox(heightFactor: exp[i] / top, child: Container(decoration: const BoxDecoration(borderRadius: BorderRadius.vertical(top: Radius.circular(4)), gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFFF9A9E), Color(0xFFFF6B72)]))))),
                      ]),
                    ),
                  ),
              ]),
            ]),
          ),
        ]),
      ),
      const SizedBox(height: 6),
      Padding(
        padding: const EdgeInsets.only(left: 34),
        child: Row(children: [for (final l in labels) Expanded(child: Text(l, softWrap: false, overflow: TextOverflow.visible, style: const TextStyle(fontSize: 10, color: kMut)))]),
      ),
    ]);
  }
}

/// Небольшой переключатель-«таблетка».
class MiniTabs extends StatelessWidget {
  const MiniTabs({super.key, required this.items, required this.value, required this.onChanged});
  final List<(String, String)> items;
  final String value;
  final ValueChanged<String> onChanged;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(color: const Color(0xFFEEF1F8), borderRadius: BorderRadius.circular(14)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          for (final (k, label) in items)
            GestureDetector(
              onTap: () => onChanged(k),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: value == k ? kInk : Colors.transparent, borderRadius: BorderRadius.circular(11)),
                child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: value == k ? Colors.white : const Color(0xFF5D6377))),
              ),
            ),
        ]),
      );
}

void toast(BuildContext c, String m) {
  ScaffoldMessenger.of(c)
    ..clearSnackBars()
    ..showSnackBar(SnackBar(content: Text(m), behavior: SnackBarBehavior.floating, backgroundColor: kInk, margin: const EdgeInsets.fromLTRB(18, 0, 18, 100), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))));
}

Future<T?> sheet<T>(BuildContext c, Widget Function(BuildContext) b) => showModalBottomSheet<T>(
      context: c,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(18, 10, 18, 24 + MediaQuery.of(ctx).viewInsets.bottom),
        child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 12), decoration: BoxDecoration(color: const Color(0xFFD4D8E4), borderRadius: BorderRadius.circular(2)))),
          b(ctx),
        ])),
      ),
    );

Widget h2(String t) => Text(t, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800, letterSpacing: -.8));
Widget h3(String t) => Padding(padding: const EdgeInsets.only(bottom: 10), child: Text(t, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)));
Widget note(String t) => Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Text(t, style: const TextStyle(fontSize: 12.5, color: kMut, height: 1.35)));
Widget kv(String k, String v) => Padding(padding: const EdgeInsets.symmetric(vertical: 9), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Flexible(child: Text(k, style: const TextStyle(color: kMut))), const SizedBox(width: 12), Flexible(child: Text(v, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w700)))]));
Widget banner(String t, {bool info = false}) => Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: info ? const Color(0xFFE4ECFF) : const Color(0xFFFFF1C9), borderRadius: BorderRadius.circular(16)), child: Text(t, style: TextStyle(fontSize: 13, color: info ? const Color(0xFF1F3F94) : const Color(0xFF5D4300))));

/// Каркас подэкрана с кнопкой «Назад».
class SubPage extends StatelessWidget {
  const SubPage({super.key, required this.title, required this.children, this.back = 'Назад'});
  final String title, back;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: kBg,
        body: SafeArea(
          child: ListView(padding: const EdgeInsets.fromLTRB(16, 4, 16, 40), children: [
            Align(alignment: Alignment.centerLeft, child: TextButton.icon(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.chevron_left, color: kBlue), label: Text(back, style: const TextStyle(fontWeight: FontWeight.w700, color: kBlue)))),
            h2(title),
            const SizedBox(height: 14),
            ...children,
          ]),
        ),
      );
}
