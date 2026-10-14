import 'package:flutter/material.dart';

/// Дизайн-токены (iOS HIG). Сетка 4/8 pt, поля экрана 16, мин. зона касания 44.
/// Типографика: Title 28/34 · Headline 15/20 · Body 15/20 · Footnote 13/18 · Caption 12/16 · Tab 10.
const kBlue = Color(0xFF007AFF);
const kGreen = Color(0xFF34C759);
const kRed = Color(0xFFFF3B30);
const kOrange = Color(0xFFFF9500);
const kIndigo = Color(0xFF5856D6);
const kInk = Color(0xFF000000);
const kDark = Color(0xFF1C1C1E);
const kMut = Color(0xFF8E8E93);
const kBg = Color(0xFFF2F2F7);
const kLine = Color(0x2E3C3C43);
const kFill = Color(0x1F787880);
const kOk = Color(0xFF248A3D);
const kErr = Color(0xFFFF3B30);
const double kM = 16; // поля экрана
const double kR = 16; // радиус карточек

List<BoxShadow> get kShadow => const [BoxShadow(color: Color(0x0A000000), blurRadius: 2, offset: Offset(0, 1))];

/// Белая карточка.
class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.padding = const EdgeInsets.all(14), this.onTap, this.margin = const EdgeInsets.only(bottom: 12)});
  final Widget child;
  final EdgeInsets padding, margin;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Container(
        margin: margin,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(kR), boxShadow: kShadow),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(kR),
          child: InkWell(borderRadius: BorderRadius.circular(kR), onTap: onTap, child: Padding(padding: padding, child: child)),
        ),
      );
}

/// Тёмная карточка.
class DarkCard extends StatelessWidget {
  const DarkCard({super.key, required this.child, this.padding = const EdgeInsets.all(14), this.car = false, this.carTop, this.carWidthFactor = .5, this.margin = const EdgeInsets.only(bottom: 12)});
  final Widget child;
  final EdgeInsets padding, margin;
  final bool car;
  final double? carTop;
  final double carWidthFactor;
  @override
  Widget build(BuildContext context) => Container(
        margin: margin,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(kR), gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF2C2C2E), Color(0xFF101012)])),
        clipBehavior: Clip.antiAlias,
        child: Stack(children: [
          if (car)
            Positioned(
              right: -10,
              top: carTop,
              bottom: carTop == null ? -4 : null,
              child: Opacity(opacity: .7, child: SizedBox(width: 390 * carWidthFactor, child: const AspectRatio(aspectRatio: 330 / 120, child: CustomPaint(painter: CarPainter())))),
            ),
          Padding(padding: padding, child: child),
        ]),
      );
}

/// Иконка в цветной плашке — как в «Настройках» iOS (29–30 pt, радиус ~23%).
class IconBox extends StatelessWidget {
  const IconBox(this.icon, {super.key, this.bg = kMut, this.fg = Colors.white, this.size = 30});
  final IconData icon;
  final Color bg, fg;
  final double size;
  @override
  Widget build(BuildContext context) => Container(width: size, height: size, decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(size * .24)), child: Icon(icon, color: fg, size: size * .58));
}

class Tone {
  const Tone(this.bg, this.fg);
  final Color bg, fg;
  static const green = Tone(kGreen, Colors.white);
  static const red = Tone(kRed, Colors.white);
  static const blue = Tone(kBlue, Colors.white);
  static const amber = Tone(kOrange, Colors.white);
  static const violet = Tone(kIndigo, Colors.white);
  static const dark = Tone(kDark, Colors.white);
  static const gray = Tone(kMut, Colors.white);
}

Widget toneIcon(IconData i, Tone t, {double size = 30}) => IconBox(i, bg: t.bg, fg: t.fg, size: size);

/// Статус-чип (11/14).
class StatusChip extends StatelessWidget {
  const StatusChip(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) {
    Color bg = kFill, fg = const Color(0xFF3C3C43);
    if (RegExp(r'Начислено|Выполнена|Проверен|Действителен|Решено|Закрыто|выполнено').hasMatch(text)) {
      bg = const Color(0x2934C759);
      fg = const Color(0xFF1A8A3A);
    } else if (RegExp(r'проверки|обработ|Создана|Новое|В работе|Ожидает|Истекает').hasMatch(text)) {
      bg = const Color(0x29FF9500);
      fg = const Color(0xFFA35A00);
    } else if (RegExp(r'Отклонена|Отменён').hasMatch(text)) {
      bg = const Color(0x24FF3B30);
      fg = const Color(0xFFC4281E);
    } else if (RegExp(r'Накоплени|Вывод доступен|Основной|Выбрано').hasMatch(text)) {
      bg = const Color(0x1F007AFF);
      fg = const Color(0xFF0062D1);
    }
    return Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(99)), child: Text(text, style: TextStyle(color: fg, fontSize: 11, height: 14 / 11, fontWeight: FontWeight.w600)));
  }
}

/// Основная кнопка: высота 48, радиус 12, 16 semibold.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton(this.label, {super.key, this.onPressed, this.light = false, this.outline = false});
  final String label;
  final VoidCallback? onPressed;
  final bool light, outline;
  @override
  Widget build(BuildContext context) {
    final bg = outline ? kFill : (light ? Colors.white : kBlue);
    final fg = outline ? kBlue : (light ? kInk : Colors.white);
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(backgroundColor: bg, foregroundColor: fg, elevation: 0, padding: EdgeInsets.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        child: Text(label),
      ),
    );
  }
}

class LogoMark extends StatelessWidget {
  const LogoMark({super.key, this.size = 28});
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
          Text('TULPAR LINE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, letterSpacing: 1.6, fontSize: 13)),
          Text('ТАКСОПАРК', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w600, letterSpacing: 3, fontSize: 9)),
        ]),
      ]);
}

class Avatar extends StatelessWidget {
  const Avatar({super.key, this.size = 40});
  final double size;
  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, ),
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

/// Столбчатая диаграмма: доходы (синий) и расходы (коралловый) с осью Y. Высота 120.
class IncomeExpenseChart extends StatelessWidget {
  const IncomeExpenseChart({super.key, required this.inc, required this.exp, required this.labels});
  final List<int> inc, exp;
  final List<String> labels;
  @override
  Widget build(BuildContext context) {
    const h = 120.0;
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
        height: h,
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          SizedBox(
            width: 30,
            child: Stack(clipBehavior: Clip.none, children: [
              for (var j = 0; j <= n; j++) Positioned(bottom: j * h / n - 7, left: 0, right: 5, child: Text(j == 0 ? '0' : '${j * st ~/ 1000}K', textAlign: TextAlign.right, style: const TextStyle(fontSize: 10, height: 14 / 10, color: kMut))),
            ]),
          ),
          Expanded(
            child: Stack(children: [
              for (var j = 0; j <= n; j++) Positioned(bottom: j * h / n, left: 0, right: 0, child: Container(height: .5, color: kLine)),
              Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                for (var i = 0; i < inc.length; i++)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 1),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Expanded(child: FractionallySizedBox(heightFactor: inc[i] / top, child: Container(decoration: const BoxDecoration(color: kBlue, borderRadius: BorderRadius.vertical(top: Radius.circular(2)))))),
                        const SizedBox(width: 1),
                        Expanded(child: FractionallySizedBox(heightFactor: exp[i] / top, child: Container(decoration: const BoxDecoration(color: Color(0xFFFF8A80), borderRadius: BorderRadius.vertical(top: Radius.circular(2)))))),
                      ]),
                    ),
                  ),
              ]),
            ]),
          ),
        ]),
      ),
      const SizedBox(height: 4),
      Padding(
        padding: const EdgeInsets.only(left: 30),
        child: Row(children: [for (final l in labels) Expanded(child: Text(l, softWrap: false, overflow: TextOverflow.visible, style: const TextStyle(fontSize: 10, color: kMut)))]),
      ),
    ]);
  }
}

/// Сегментированный переключатель (iOS segmented control, высота 24).
class MiniTabs extends StatelessWidget {
  const MiniTabs({super.key, required this.items, required this.value, required this.onChanged});
  final List<(String, String)> items;
  final String value;
  final ValueChanged<String> onChanged;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(color: kFill, borderRadius: BorderRadius.circular(8)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          for (final (k, label) in items)
            GestureDetector(
              onTap: () => onChanged(k),
              child: Container(
                height: 24,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(color: value == k ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(6), boxShadow: value == k ? const [BoxShadow(color: Color(0x24000000), blurRadius: 2, offset: Offset(0, 1))] : null),
                child: Text(label, style: TextStyle(fontSize: 12, fontWeight: value == k ? FontWeight.w600 : FontWeight.w500)),
              ),
            ),
        ]),
      );
}

void toast(BuildContext c, String m) {
  ScaffoldMessenger.of(c)
    ..clearSnackBars()
    ..showSnackBar(SnackBar(content: Text(m, style: const TextStyle(fontSize: 14)), behavior: SnackBarBehavior.floating, backgroundColor: const Color(0xF01C1C1E), elevation: 0, margin: const EdgeInsets.fromLTRB(16, 0, 16, 70), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))));
}

/// Нижняя шторка в стиле iOS (скругление 12, «ручка» 36×5, фон grouped).
Future<T?> sheet<T>(BuildContext c, Widget Function(BuildContext) b) => showModalBottomSheet<T>(
      context: c,
      isScrollControlled: true,
      backgroundColor: kBg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(kM, 8, kM, 24 + MediaQuery.of(ctx).viewInsets.bottom),
        child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 36, height: 5, margin: const EdgeInsets.only(bottom: 10), decoration: BoxDecoration(color: const Color(0x4D3C3C43), borderRadius: BorderRadius.circular(3)))),
          b(ctx),
        ])),
      ),
    );

Widget h2(String t) => Text(t, style: const TextStyle(fontSize: 28, height: 34 / 28, fontWeight: FontWeight.w700, letterSpacing: -.6));
Widget h3(String t) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(t, style: const TextStyle(fontSize: 15, height: 20 / 15, fontWeight: FontWeight.w600)));
Widget note(String t) => Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Text(t, style: const TextStyle(fontSize: 12, color: kMut, height: 16 / 12)));
Widget kv(String k, String v) => Padding(padding: const EdgeInsets.symmetric(vertical: 7), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Flexible(child: Text(k, style: const TextStyle(color: kMut, fontSize: 14))), const SizedBox(width: 12), Flexible(child: Text(v, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)))]));
Widget banner(String t, {bool info = false}) => Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), decoration: BoxDecoration(color: info ? const Color(0x1A007AFF) : const Color(0x24FF9500), borderRadius: BorderRadius.circular(12)), child: Text(t, style: TextStyle(fontSize: 13, height: 18 / 13, color: info ? const Color(0xFF0A4AA3) : const Color(0xFF6B3D00))));

/// Каркас подэкрана: «‹ Назад», заголовок 24/30.
class SubPage extends StatelessWidget {
  const SubPage({super.key, required this.title, required this.children, this.back = 'Назад'});
  final String title, back;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: kBg,
        body: SafeArea(
          child: ListView(padding: const EdgeInsets.fromLTRB(kM, 0, kM, 40), children: [
            Align(alignment: Alignment.centerLeft, child: TextButton.icon(onPressed: () => Navigator.pop(context), style: TextButton.styleFrom(padding: const EdgeInsets.only(right: 8), minimumSize: const Size(44, 36)), icon: const Icon(Icons.chevron_left, color: kBlue, size: 26), label: Text(back, style: const TextStyle(fontSize: 16, color: kBlue)))),
            Text(title, style: const TextStyle(fontSize: 24, height: 30 / 24, fontWeight: FontWeight.w700, letterSpacing: -.5)),
            const SizedBox(height: 12),
            ...children,
          ]),
        ),
      );
}
