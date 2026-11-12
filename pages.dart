import 'package:flutter/material.dart';
import '../data/hares_database.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      const _WelcomeCard(),
      const SizedBox(height: 14),
      const Row(children: [Expanded(child: _MetricCard(title: 'استخدام اليوم', value: 'بانتظار الصلاحية', icon: Icons.phone_android)), SizedBox(width: 10), Expanded(child: _MetricCard(title: 'مؤشر الالتزام', value: 'سيُحسب لاحقًا', icon: Icons.track_changes))]),
      const SizedBox(height: 14),
      Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('ابدأ يومك بوعي', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 8), const Text('حدد أولوياتك، وابدأ بجلسة تركيز قصيرة. ستظهر إحصاءات الاستخدام بعد ربط صلاحيات Android في المرحلة الثانية.'), const SizedBox(height: 12), FilledButton.icon(onPressed: () => _showFocus(context), icon: const Icon(Icons.timer_outlined), label: const Text('بدء جلسة تركيز تجريبية'))]))),
      const SizedBox(height: 14),
      const _SectionTitle('مبادئ حارس'),
      const _InfoTile(icon: Icons.lock_outline, title: 'خصوصيتك أولًا', subtitle: 'بيانات المرحلة الأولى تحفظ محليًا على الهاتف.'),
      const _InfoTile(icon: Icons.balance, title: 'انضباط بلا مبالغة', subtitle: 'لن ندّعي تقييد التطبيقات قبل تنفيذ واختبار تكامل Android.'),
    ],
  );

  static Future<void> _showFocus(BuildContext context) async {
    final controller = TextEditingController(text: '25');
    final minutes = await showDialog<int>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('جلسة تركيز'),
      content: TextField(controller: controller, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'المدة بالدقائق')),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')), FilledButton(onPressed: () => Navigator.pop(ctx, int.tryParse(controller.text)), child: const Text('حفظ الجلسة'))],
    ));
    if (minutes == null || minutes < 1 || !context.mounted) return;
    final db = await HaresDatabase.instance.database;
    await db.insert('focus_sessions', {'started_at': DateTime.now().toIso8601String(), 'planned_minutes': minutes, 'status': 'planned'});
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم حفظ جلسة تركيز لمدة $minutes دقيقة. المؤقت الفعلي سيُستكمل في مرحلة التركيز.')));
  }
}

class UsagePage extends StatelessWidget {
  const UsagePage({super.key});
  @override
  Widget build(BuildContext context) => const _PageFrame(
    title: 'استخدام الهاتف',
    description: 'ستُعرض هنا إحصاءات التطبيقات ومدة الاستخدام اليومية والأسبوعية بعد إضافة تكامل UsageStatsManager في المرحلة الثانية.',
    icon: Icons.query_stats,
    note: 'لا توجد بيانات استخدام حقيقية في هذه النسخة، ولم تُطلب صلاحية Usage Access بعد.',
  );
}

class DisciplinePage extends StatelessWidget {
  const DisciplinePage({super.key});
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(16), children: [
    const _SectionTitle('مركز الانضباط'),
    const _InfoTile(icon: Icons.shield, title: 'التقييد الفوري', subtitle: 'سيُفعّل بعد اختيار آلية Android المتوافقة واختبارها.'),
    const _InfoTile(icon: Icons.hourglass_bottom, title: 'المهلة الاستثنائية', subtitle: 'المواصفة: مهلة محدودة ومسجلة. القيم الحالية مقترحات وليست نظامًا نشطًا.'),
    const _InfoTile(icon: Icons.history, title: 'سجل التجاوزات', subtitle: 'سيُعرض بعد تفعيل قراءة الاستخدام ومحرك الحدود.'),
    const SizedBox(height: 12),
    const Text('إعدادات مقترحة للمواصفات: 5 دقائق للمهلة الواحدة، ومرتان يوميًا. لم يتم تفعيل منح المهلات في هذه المرحلة.'),
  ]);
}

class WellbeingPage extends StatelessWidget {
  const WellbeingPage({super.key});
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(16), children: const [
    _SectionTitle('العافية الرقمية'),
    _InfoTile(icon: Icons.bedtime_outlined, title: 'النوم والراحة', subtitle: 'إعداد مواعيد النوم والاستيقاظ سيضاف في مرحلة العافية.'),
    _InfoTile(icon: Icons.visibility_outlined, title: 'راحة العين', subtitle: 'تذكير قاعدة 20-20-20 سيضاف في مرحلة العافية.'),
    _InfoTile(icon: Icons.auto_awesome, title: 'العادات الإيجابية', subtitle: 'تسجيل العادات محليًا متاح في قاعدة البيانات، وستضاف واجهته لاحقًا.'),
  ]);
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool strict = true;
  bool loaded = false;
  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    final s = await HaresDatabase.instance.getSettings();
    if (mounted) setState(() { strict = (s['strict_mode'] as int? ?? 1) == 1; loaded = true; });
  }
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(16), children: [
    const _SectionTitle('الإعدادات'),
    if (!loaded) const LinearProgressIndicator(),
    SwitchListTile(value: strict, onChanged: (v) async { await HaresDatabase.instance.updateStrictMode(v); if (mounted) setState(() => strict = v); }, title: const Text('تفضيل الانضباط الصارم'), subtitle: const Text('يحفظ تفضيلك فقط؛ لا يفعّل حظر التطبيقات في المرحلة الأولى.'), secondary: const Icon(Icons.shield_moon_outlined)),
    const _InfoTile(icon: Icons.storage_outlined, title: 'التخزين', subtitle: 'قاعدة بيانات محلية SQLite على الجهاز.'),
    const _InfoTile(icon: Icons.cloud_off_outlined, title: 'العمل دون إنترنت', subtitle: 'الواجهات والإعدادات الأساسية لا تحتاج اتصالًا.'),
    const _InfoTile(icon: Icons.info_outline, title: 'الإصدار', subtitle: 'HARES 1.0.0 – المرحلة الأولى'),
  ]);
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard();
  @override
  Widget build(BuildContext context) => Card(child: Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), gradient: const LinearGradient(colors: [Color(0xFF1D3154), Color(0xFF101B35)])), child: const Row(children: [Icon(Icons.shield_moon, color: Color(0xFFD6AE59), size: 42), SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('مرحبًا بك في حارس', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), SizedBox(height: 5), Text('توازنك يبدأ بقرار واعٍ.', style: TextStyle(color: Color(0xFFD6AE59))) ]))])));
}

class _MetricCard extends StatelessWidget {
  final String title, value; final IconData icon;
  const _MetricCard({required this.title, required this.value, required this.icon});
  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, color: const Color(0xFFD6AE59)), const SizedBox(height: 10), Text(title, style: const TextStyle(color: Colors.white70)), const SizedBox(height: 6), Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))])));
}

class _SectionTitle extends StatelessWidget {
  final String text; const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 10), child: Text(text, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Color(0xFFD6AE59))));
}

class _InfoTile extends StatelessWidget {
  final IconData icon; final String title, subtitle;
  const _InfoTile({required this.icon, required this.title, required this.subtitle});
  @override
  Widget build(BuildContext context) => Card(child: ListTile(leading: Icon(icon, color: const Color(0xFFD6AE59)), title: Text(title), subtitle: Text(subtitle)));
}

class _PageFrame extends StatelessWidget {
  final String title, description, note; final IconData icon;
  const _PageFrame({required this.title, required this.description, required this.note, required this.icon});
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.all(20), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 54, color: const Color(0xFFD6AE59)), const SizedBox(height: 16), Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)), const SizedBox(height: 12), Text(description, textAlign: TextAlign.center), const SizedBox(height: 18), Card(child: Padding(padding: const EdgeInsets.all(14), child: Text(note, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70))))]));
}
