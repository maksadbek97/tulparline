import 'package:flutter/material.dart';

/// Токены: мягкий стиль Apple по референсу. Поля 12, радиус карточек 22, SF Pro.
const kBlue = Color(0xFF2F6BFF);
const kBlue2 = Color(0xFF5F94FF);
const kGreen = Color(0xFF16B05A);
const kRed = Color(0xFFFF4D5A);
const kOrange = Color(0xFFFF9F0A);
const kIndigo = Color(0xFF6A5CF0);
const kInk = Color(0xFF0B0B0F);
const kDark = Color(0xFF1D1E24);
const kMut = Color(0xFF8A90A3);
const kBg = Color(0xFFF5F7FC);
const kLine = Color(0x1A3C4664);
const kFill = Color(0x24787F9E);
const kOk = Color(0xFF12994A);
const kErr = Color(0xFFFF4D5A);
const double kM = 12;
const double kR = 22;

List<BoxShadow> get kShadow => [BoxShadow(color: const Color(0xFF283C78).withValues(alpha: .2), blurRadius: 32, offset: const Offset(0, 12), spreadRadius: -14), BoxShadow(color: const Color(0xFF283C78).withValues(alpha: .05), blurRadius: 2, offset: const Offset(0, 1))];

/// Мягкая стеклянная карточка.
class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.onTap, this.margin = const EdgeInsets.only(bottom: 12), this.gradient});
  final Widget child;
  final EdgeInsets padding, margin;
  final VoidCallback? onTap;
  final Gradient? gradient;
  @override
  Widget build(BuildContext context) => Container(
        margin: margin,
        decoration: BoxDecoration(color: gradient == null ? Colors.white.withValues(alpha: .9) : null, gradient: gradient, borderRadius: BorderRadius.circular(kR), border: Border.all(color: Colors.white, width: 1), boxShadow: kShadow),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(kR),
          child: InkWell(borderRadius: BorderRadius.circular(kR), onTap: onTap, child: Padding(padding: padding, child: child)),
        ),
      );
}

/// Тёмная карточка: фото машины и круг с логотипом.
class DarkCard extends StatelessWidget {
  const DarkCard({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.car, this.carWidth = .64, this.carRight = -10, this.carTop, this.carBottom, this.glow = false, this.glowTop = 16, this.glowRight = 46, this.minHeight = 0, this.margin = const EdgeInsets.only(bottom: 12)});
  final Widget child;
  final EdgeInsets padding, margin;
  final String? car;
  final double carWidth, carRight, glowTop, glowRight, minHeight;
  final double? carTop, carBottom;
  final bool glow;
  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return Container(
      margin: margin,
      constraints: BoxConstraints(minHeight: minHeight),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(kR),
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF1D1E24), Color(0xFF050506)]),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .4), blurRadius: 40, offset: const Offset(0, 18), spreadRadius: -18)],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(children: [
        Positioned(right: -50, top: -50, child: Container(width: 240, height: 170, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [const Color(0xFF5A6EB4).withValues(alpha: .35), Colors.transparent])))),
        if (glow) Positioned(right: glowRight, top: glowTop, child: const LogoGlow()),
        if (car != null) Positioned(right: carRight, top: carTop, bottom: carBottom, child: CarPhoto(car!, width: w * carWidth)),
        Padding(padding: padding, child: child),
      ]),
    );
  }
}

/// Иконка в мягкой цветной плашке.
class IconBox extends StatelessWidget {
  const IconBox(this.icon, {super.key, this.bg = const Color(0xFFEFF1F6), this.fg = kInk, this.size = 40});
  final IconData icon;
  final Color bg, fg;
  final double size;
  @override
  Widget build(BuildContext context) => Container(width: size, height: size, decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(size * .32)), child: Icon(icon, color: fg, size: size * .52));
}

class Tone {
  const Tone(this.bg, this.fg);
  final Color bg, fg;
  static const green = Tone(Color(0xFFE2F7EA), Color(0xFF12A050));
  static const red = Tone(Color(0xFFFFE7E8), Color(0xFFE0384A));
  static const blue = Tone(Color(0xFFE5EDFF), kBlue);
  static const amber = Tone(Color(0xFFFFEEC9), Color(0xFFD98300));
  static const violet = Tone(Color(0xFFECE9FF), kIndigo);
  static const dark = Tone(kInk, Colors.white);
  static const gray = Tone(Color(0xFFEFF1F6), kInk);
}

Widget toneIcon(IconData i, Tone t, {double size = 40}) => IconBox(i, bg: t.bg, fg: t.fg, size: size);

/// Статус-чип.
class StatusChip extends StatelessWidget {
  const StatusChip(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) {
    Color bg = kFill, fg = const Color(0xFF454A5C);
    if (RegExp(r'Начислено|Выполнена|Проверен|Действителен|Решено|Закрыто|выполнено').hasMatch(text)) {
      bg = const Color(0x2416B05A);
      fg = const Color(0xFF0F8A45);
    } else if (RegExp(r'проверки|обработ|Создана|Новое|В работе|Ожидает|Истекает').hasMatch(text)) {
      bg = const Color(0x29FF9F0A);
      fg = const Color(0xFFA35F00);
    } else if (RegExp(r'Отклонена|Отменён').hasMatch(text)) {
      bg = const Color(0x24FF4D5A);
      fg = const Color(0xFFC8323E);
    } else if (RegExp(r'Накоплени|Вывод доступен|Основной|Выбрано|кэшбэка').hasMatch(text)) {
      bg = const Color(0x1F2F6BFF);
      fg = const Color(0xFF1F55D8);
    }
    return Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(99)), child: Text(text, style: TextStyle(color: fg, fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w600)));
  }
}

/// Основная кнопка: высота 50, радиус 16.
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
      height: 50,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(backgroundColor: bg, foregroundColor: fg, elevation: 0, padding: EdgeInsets.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: outline ? const BorderSide(color: kInk, width: 1.5) : BorderSide.none), textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17)),
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
          Text('TULPAR LINE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, letterSpacing: 2.1, fontSize: 13)),
          Text('ТАКСОПАРК', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w600, letterSpacing: 3, fontSize: 9)),
        ]),
      ]);
}

class Avatar extends StatelessWidget {
  const Avatar({super.key, this.size = 62});
  final double size;
  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFFDFE3EE), boxShadow: [BoxShadow(color: const Color(0xFF283C78).withValues(alpha: .35), blurRadius: 18, offset: const Offset(0, 6), spreadRadius: -6)]),
        clipBehavior: Clip.antiAlias,
        child: Image.asset('assets/avatar.jpg', fit: BoxFit.cover),
      );
}

/// Фото машины на тёмном фоне: чёрный фон картинки «растворяется» в карточке.
class CarPhoto extends StatelessWidget {
  const CarPhoto(this.asset, {super.key, required this.width});
  final String asset;
  final double width;
  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: ShaderMask(
          blendMode: BlendMode.dstIn,
          shaderCallback: (r) => const LinearGradient(begin: Alignment.centerRight, end: Alignment.centerLeft, stops: [.55, 1], colors: [Colors.white, Colors.transparent]).createShader(r),
          child: Image.asset(asset, width: width, fit: BoxFit.cover),
        ),
      );
}

/// Белый круг с логотипом (декор тёмных карточек).
class LogoGlow extends StatelessWidget {
  const LogoGlow({super.key});
  @override
  Widget build(BuildContext context) => Container(
        width: 96,
        height: 96,
        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.white.withValues(alpha: .3), blurRadius: 50)]),
        alignment: Alignment.center,
        child: const SizedBox(width: 56, height: 56, child: CustomPaint(painter: _GlowLogoPainter())),
      );
}

class _GlowLogoPainter extends CustomPainter {
  const _GlowLogoPainter();
  @override
  void paint(Canvas c, Size s) {
    final w = s.width / 40;
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
    const h = 128.0;
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
            width: 36,
            child: Stack(clipBehavior: Clip.none, children: [
              for (var j = 0; j <= n; j++) Positioned(bottom: j * h / n - 7, left: 0, right: 5, child: Text(j == 0 ? '0' : '${j * st ~/ 1000}K', textAlign: TextAlign.right, style: const TextStyle(fontSize: 12, height: 16 / 12, color: kMut))),
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
                        Expanded(child: FractionallySizedBox(heightFactor: inc[i] / top, child: Container(decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF6B9BFF), kBlue]), borderRadius: BorderRadius.vertical(top: Radius.circular(4)))))),
                        const SizedBox(width: 1),
                        Expanded(child: FractionallySizedBox(heightFactor: exp[i] / top, child: Container(decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFFFB3B8), Color(0xFFFF7A85)]), borderRadius: BorderRadius.vertical(top: Radius.circular(4)))))),
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
        padding: const EdgeInsets.only(left: 36),
        child: Row(children: [for (final l in labels) Expanded(child: Text(l, softWrap: false, overflow: TextOverflow.visible, style: const TextStyle(fontSize: 12, color: kMut)))]),
      ),
    ]);
  }
}

/// Переключатель: тёмная активная «таблетка».
class MiniTabs extends StatelessWidget {
  const MiniTabs({super.key, required this.items, required this.value, required this.onChanged});
  final List<(String, String)> items;
  final String value;
  final ValueChanged<String> onChanged;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(color: const Color(0x21787F9E), borderRadius: BorderRadius.circular(14)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          for (final (k, label) in items)
            GestureDetector(
              onTap: () => onChanged(k),
              child: Container(
                height: 30,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(color: value == k ? kInk : Colors.transparent, borderRadius: BorderRadius.circular(11)),
                child: Text(label, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500, color: value == k ? Colors.white : const Color(0xFF5A6075))),
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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(kM, 8, kM, 24 + MediaQuery.of(ctx).viewInsets.bottom),
        child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 36, height: 5, margin: const EdgeInsets.only(bottom: 10), decoration: BoxDecoration(color: const Color(0x4D3C3C43), borderRadius: BorderRadius.circular(3)))),
          b(ctx),
        ])),
      ),
    );

Widget h2(String t) => Text(t, style: const TextStyle(fontSize: 32, height: 38 / 32, fontWeight: FontWeight.w700, letterSpacing: -.9));
Widget h3(String t) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(t, style: const TextStyle(fontSize: 17, height: 22 / 17, fontWeight: FontWeight.w600)));
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
            Text(title, style: const TextStyle(fontSize: 26, height: 32 / 26, fontWeight: FontWeight.w700, letterSpacing: -.5)),
            const SizedBox(height: 12),
            ...children,
          ]),
        ),
      );
}
