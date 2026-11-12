import 'package:flutter/material.dart';
import '../data/hares_database.dart';
import 'pages.dart';

class HaresShell extends StatefulWidget {
  const HaresShell({super.key});
  @override
  State<HaresShell> createState() => _HaresShellState();
}

class _HaresShellState extends State<HaresShell> {
  int index = 0;
  bool strict = true;
  bool loading = true;

  final pages = const [
    HomePage(),
    UsagePage(),
    DisciplinePage(),
    WellbeingPage(),
    SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final settings = await HaresDatabase.instance.getSettings();
    if (!mounted) return;
    setState(() {
      strict = (settings['strict_mode'] as int? ?? 1) == 1;
      loading = false;
    });
  }

  Future<void> _setStrict(bool value) async {
    await HaresDatabase.instance.updateStrictMode(value);
    if (mounted) setState(() => strict = value);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('حارس', style: TextStyle(fontWeight: FontWeight.bold)),
          actions: [
            IconButton(
              tooltip: 'حالة التطبيق',
              onPressed: () => showAboutDialog(
                context: context,
                applicationName: 'حارس - HARES',
                applicationVersion: '1.0.0 - المرحلة الأولى',
                children: const [Text('نسخة تأسيسية تعمل بالتخزين المحلي. مراقبة الاستخدام والتقييد الفعلي لم يتم تفعيلهما بعد.')],
              ),
              icon: const Icon(Icons.shield_outlined),
            ),
          ],
        ),
        body: loading ? const Center(child: CircularProgressIndicator()) : pages[index],
        bottomNavigationBar: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: (value) => setState(() => index = value),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'الرئيسية'),
            NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart), label: 'الاستخدام'),
            NavigationDestination(icon: Icon(Icons.shield_outlined), selectedIcon: Icon(Icons.shield), label: 'الانضباط'),
            NavigationDestination(icon: Icon(Icons.self_improvement_outlined), selectedIcon: Icon(Icons.self_improvement), label: 'العافية'),
            NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'الإعدادات'),
          ],
        ),
      ),
    );
  }
}
