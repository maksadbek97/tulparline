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
          colorScheme: ColorScheme.fromSeed(seedColor: kBlue, brightness: Brightness.light).copyWith(primary: kInk, surface: kBg),
          scaffoldBackgroundColor: kBg,
          fontFamily: null,
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFDDE1EC), width: 1.5)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFDDE1EC), width: 1.5)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: kBlue, width: 1.5)),
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
    (Icons.home_rounded, 'Главная'),
    (Icons.account_balance_wallet_outlined, 'Финансы'),
    (Icons.apps_rounded, 'Сервис'),
    (Icons.person_outline_rounded, 'Профиль'),
  ];

  void goTab(int i) => setState(() => tab = i);

  @override
  Widget build(BuildContext context) {
    final pages = [HomePage(onTab: goTab), const FinancePage(), const ServicePage(), const ProfilePage()];
    return Scaffold(
      body: Stack(children: [
        Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(gradient: RadialGradient(center: const Alignment(.9, -1.1), radius: 1.1, colors: [const Color(0xFFE1E8FB), kBg])))),
        SafeArea(bottom: false, child: IndexedStack(index: tab, children: pages)),
        Positioned(
          left: 14,
          right: 14,
          bottom: 14 + MediaQuery.of(context).padding.bottom,
          child: Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: .97), borderRadius: BorderRadius.circular(34), boxShadow: [BoxShadow(color: const Color(0xFF141E46).withValues(alpha: .28), blurRadius: 34, offset: const Offset(0, 14), spreadRadius: -12)]),
            child: Row(children: [
              for (var i = 0; i < _tabs.length; i++)
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => goTab(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      decoration: BoxDecoration(color: tab == i ? kInk : Colors.transparent, borderRadius: BorderRadius.circular(28)),
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Icon(_tabs[i].$1, size: 23, color: tab == i ? Colors.white : kMut),
                        const SizedBox(height: 3),
                        Text(_tabs[i].$2, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: tab == i ? Colors.white : kMut)),
                      ]),
                    ),
                  ),
                ),
            ]),
          ),
        ),
      ]),
    );
  }
}
