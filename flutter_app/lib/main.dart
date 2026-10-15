import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/finance.dart';
import 'screens/home.dart';
import 'screens/profile.dart';
import 'screens/service.dart';
import 'state.dart';
import 'ui.dart';

void main() => runApp(const TulparApp());

/// Доступ к состоянию из любого виджета.
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child}) : super(notifier: state);
  static AppState of(BuildContext c) => c.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;
}

class TulparApp extends StatefulWidget {
  const TulparApp({super.key});
  @override
  State<TulparApp> createState() => _TulparAppState();
}

class _TulparAppState extends State<TulparApp> {
  final state = AppState();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.dark));
    return AppScope(
      state: state,
      child: MaterialApp(
        title: 'Tulpar Line',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: kBlue, brightness: Brightness.light).copyWith(primary: kBlue, surface: kBg),
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
          textTheme: Typography.blackCupertino.apply(bodyColor: kInk, displayColor: kInk).copyWith(bodyMedium: const TextStyle(fontSize: 14, height: 20 / 15, color: kInk), bodyLarge: const TextStyle(fontSize: 14, height: 20 / 15, color: kInk), titleMedium: const TextStyle(fontSize: 14, color: kInk), labelLarge: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          scaffoldBackgroundColor: kBg,
          fontFamily: null,
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
            labelStyle: const TextStyle(fontSize: 14, color: kMut),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: kBlue, width: 1.5)),
          ),
        ),
        home: const Shell(),
      ),
    );
  }
}

/// Нижнее меню: ровно 4 раздела, без пункта «Заказы».
class Shell extends StatefulWidget {
  const Shell({super.key});
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int tab = 0;
  static const _tabs = [
    (Icons.home_outlined, 'Главная'),
    (Icons.account_balance_wallet_outlined, 'Финансы'),
    (Icons.apps_rounded, 'Сервис'),
    (Icons.person_outline_rounded, 'Профиль'),
  ];

  void goTab(int i) => setState(() => tab = i);

  @override
  Widget build(BuildContext context) {
    final pages = [HomePage(onTab: goTab), const FinancePage(), const ServicePage(), const ProfilePage()];
    final bottom = MediaQuery.of(context).padding.bottom;
    Widget blob(Alignment a, Color c) => Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(gradient: RadialGradient(center: a, radius: .9, colors: [c, Colors.transparent]))));
    return Scaffold(
      backgroundColor: kBg,
      body: Stack(children: [
        blob(const Alignment(1.1, -1.05), const Color(0x8CBECDFF)),
        blob(const Alignment(-1.2, -.2), const Color(0x66D7CDFF)),
        blob(const Alignment(.8, 1.1), const Color(0x73C8E1FF)),
        SafeArea(bottom: false, child: IndexedStack(index: tab, children: pages)),
        // Плавающее стеклянное меню: 62 pt, радиус 31, активный пункт — тёмная «таблетка».
        Positioned(
          left: kM,
          right: kM,
          bottom: 12 + bottom,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 26, sigmaY: 26),
              child: Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: .82), borderRadius: BorderRadius.circular(28), border: Border.all(color: Colors.white), boxShadow: [BoxShadow(color: const Color(0xFF1E2D64).withValues(alpha: .3), blurRadius: 40, offset: const Offset(0, 18), spreadRadius: -14)]),
                child: Row(children: [
                  for (var i = 0; i < _tabs.length; i++)
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => goTab(i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: 44,
                          decoration: BoxDecoration(color: tab == i ? kInk : Colors.transparent, borderRadius: BorderRadius.circular(22)),
                          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Icon(_tabs[i].$1, size: 22, color: tab == i ? Colors.white : const Color(0xFF7E8497)),
                            Text(_tabs[i].$2, style: TextStyle(fontSize: 11, height: 14 / 11.5, fontWeight: FontWeight.w500, color: tab == i ? Colors.white : const Color(0xFF7E8497))),
                          ]),
                        ),
                      ),
                    ),
                ]),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
