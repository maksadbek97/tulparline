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
          textTheme: Typography.blackCupertino.apply(bodyColor: kInk, displayColor: kInk).copyWith(bodyMedium: const TextStyle(fontSize: 15, height: 20 / 15, color: kInk), bodyLarge: const TextStyle(fontSize: 15, height: 20 / 15, color: kInk), titleMedium: const TextStyle(fontSize: 15, color: kInk), labelLarge: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          scaffoldBackgroundColor: kBg,
          fontFamily: null,
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
            labelStyle: const TextStyle(fontSize: 15, color: kMut),
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
    (Icons.home_outlined, Icons.home_rounded, 'Главная'),
    (Icons.account_balance_wallet_outlined, Icons.account_balance_wallet, 'Финансы'),
    (Icons.grid_view_outlined, Icons.grid_view_rounded, 'Сервис'),
    (Icons.person_outline_rounded, Icons.person_rounded, 'Профиль'),
  ];

  void goTab(int i) => setState(() => tab = i);

  @override
  Widget build(BuildContext context) {
    final pages = [HomePage(onTab: goTab), const FinancePage(), const ServicePage(), const ProfilePage()];
    final bottom = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      backgroundColor: kBg,
      body: Stack(children: [
        SafeArea(bottom: false, child: IndexedStack(index: tab, children: pages)),
        // Стандартный iOS tab bar: 49 pt + safe area, полупрозрачный, hairline сверху.
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                height: 49 + bottom,
                padding: EdgeInsets.only(bottom: bottom),
                decoration: const BoxDecoration(color: Color(0xDBF9F9F9), border: Border(top: BorderSide(color: kLine, width: .5))),
                child: Row(children: [
                  for (var i = 0; i < _tabs.length; i++)
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => goTab(i),
                        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Icon(tab == i ? _tabs[i].$2 : _tabs[i].$1, size: 24, color: tab == i ? kBlue : kMut),
                          const SizedBox(height: 2),
                          Text(_tabs[i].$3, style: TextStyle(fontSize: 10, height: 12 / 10, fontWeight: FontWeight.w500, color: tab == i ? kBlue : kMut)),
                        ]),
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
