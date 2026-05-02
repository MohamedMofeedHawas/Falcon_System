// ignore_for_file: deprecated_member_use

import 'dart:math' as math;

import 'package:falcon_system/core/constants/app_colors.dart';
import 'package:falcon_system/core/constants/app_fonts.dart';
import 'package:falcon_system/core/constants/app_strings.dart';
import 'package:falcon_system/core/services/hive_service.dart';
import 'package:falcon_system/core/widgets/stat_card.dart';
import 'package:falcon_system/features/aerodrome/presentation/screens/aerodrome_list_screen.dart';
import 'package:falcon_system/features/aircraft/presentation/screens/aircraft_list_screen.dart';
import 'package:falcon_system/features/evaluation/presentation/screens/evaluation_list_screen.dart';
import 'package:falcon_system/features/help/presentation/screens/help_screen.dart';
import 'package:falcon_system/features/manager/presentation/screens/manager_list_screen.dart';
import 'package:falcon_system/features/profile/presentation/screens/profile_screen.dart';
import 'package:falcon_system/features/team/presentation/screens/team_list_screen.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  bool _isSidebarExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Row(
          children: [
            // Sidebar
            _buildSidebar(),
            // Main Content
            Expanded(child: _buildMainContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: _isSidebarExpanded ? 250 : 80,
      decoration: BoxDecoration(
        color: AppColors.sidebarBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Logo
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      'F',
                      style: TextStyle(
                        color: AppColors.textWhite,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                if (_isSidebarExpanded) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.systemTitle,
                          style: AppFonts.labelMedium.copyWith(
                            color: AppColors.textWhite,
                            fontWeight: AppFonts.bold,
                          ),
                        ),
                        Text(
                          AppStrings.subtitle,
                          style: AppFonts.labelSmall.copyWith(
                            color: AppColors.textWhite.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Divider(color: AppColors.border),
          // Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildMenuItem(
                  icon: Icons.dashboard_outlined,
                  label: 'لوحة التحكم',
                  index: 0,
                ),
                _buildMenuItem(
                  icon: Icons.flight_takeoff_outlined,
                  label: 'المطارات',
                  index: 1,
                ),
                _buildMenuItem(
                  icon: Icons.people_outline,
                  label: 'المديرين',
                  index: 2,
                ),
                _buildMenuItem(
                  icon: Icons.group_outlined,
                  label: 'فريق الفحص',
                  index: 3,
                ),
                _buildMenuItem(
                  icon: Icons.airplanemode_active_outlined,
                  label: 'الطائرات',
                  index: 4,
                ),
                _buildMenuItem(
                  icon: Icons.assessment_outlined,
                  label: 'التقارير',
                  index: 5,
                ),
                const Spacer(),
                _buildMenuItem(
                  icon: Icons.settings_outlined,
                  label: 'الإعدادات',
                  index: 6,
                ),
                _buildMenuItem(
                  icon: Icons.help_outline,
                  label: 'المساعدة',
                  index: 7,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.sidebarActive : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppColors.textWhite
                  : AppColors.textWhite.withOpacity(0.7),
              size: 24,
            ),
            if (_isSidebarExpanded) ...[
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: AppFonts.labelMedium.copyWith(
                    color: isSelected
                        ? AppColors.textWhite
                        : AppColors.textWhite.withOpacity(0.7),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Container(
      color: AppColors.background,
      child: _buildContent(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مرحباً، المدير العام',
                  style: AppFonts.headline5.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'آخر تحديث: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                  style: AppFonts.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () =>
                setState(() => _isSidebarExpanded = !_isSidebarExpanded),
            icon: Icon(
              _isSidebarExpanded ? Icons.menu_open : Icons.menu,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboardContent();
      case 1:
        return _buildAerodromesContent();
      case 2:
        return _buildManagersContent();
      case 3:
        return _buildTeamContent();
      case 4:
        return _buildAircraftContent();
      case 5:
        return _buildReportsContent();
      case 6:
        return _buildSettingsContent();
      case 7:
        return _buildHelpContent();
      default:
        return _buildDashboardContent();
    }
  }

  Widget _buildDashboardContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'نظرة عامة',
            style: AppFonts.headline6.copyWith(
              color: AppColors.textPrimary,
              fontWeight: AppFonts.bold,
            ),
          ),
          const SizedBox(height: 20),
          // Stats Grid
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 2.2,
            children: [
              StatCard(
                icon: Icons.flight_takeoff,
                label: 'إجمالي المطارات',
                value: HiveService.aerodromeBox.length.toString(),
                sublabel: 'نشط',
                iconColor: AppColors.primary,
              ),
              StatCard(
                icon: Icons.assessment,
                label: 'التقارير المنجزة',
                value: HiveService.evaluationBox.length.toString(),
                sublabel: 'تقرير',
                iconColor: AppColors.success,
              ),
              StatCard(
                icon: Icons.people,
                label: 'المديرين',
                value: HiveService.managerBox.length.toString(),
                sublabel: 'مدير',
                iconColor: AppColors.accent,
              ),
              StatCard(
                icon: Icons.group,
                label: 'فريق الفحص',
                value: HiveService.inspectionMemberBox.length.toString(),
                sublabel: 'عضو',
                iconColor: AppColors.warning,
              ),
              StatCard(
                icon: Icons.airplanemode_active,
                label: 'الطائرات',
                value: HiveService.aircraftBox.length.toString(),
                sublabel: 'طائرة',
                iconColor: AppColors.info,
              ),
              StatCard(
                icon: Icons.trending_up,
                label: 'متوسط التقييم',
                value: '85%',
                sublabel: 'ممتاز',
                iconColor: AppColors.excellent,
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Charts Section
          Row(
            children: [
              Expanded(child: _buildEvaluationDistributionChart()),
              const SizedBox(width: 16),
              Expanded(child: _buildMonthlyEvaluationsChart()),
            ],
          ),
          const SizedBox(height: 24),
          // Recent Activity
          Text(
            'النشاط الأخيرة',
            style: AppFonts.headline6.copyWith(
              color: AppColors.textPrimary,
              fontWeight: AppFonts.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildRecentActivity(),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    final evaluations = HiveService.evaluationBox.values.toList();
    final recentEvaluations = evaluations.take(3).toList();

    if (recentEvaluations.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.inbox_outlined, size: 64, color: AppColors.textHint),
                const SizedBox(height: 16),
                Text(
                  'لا توجد نشاطات حديثة',
                  style: AppFonts.labelMedium.copyWith(
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      children: recentEvaluations.map((evaluation) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _getScoreColor(evaluation.totalScore),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '${evaluation.totalScore.toStringAsFixed(1)}%',
                  style: AppFonts.labelLarge.copyWith(
                    color: AppColors.textWhite,
                    fontWeight: AppFonts.bold,
                  ),
                ),
              ),
            ),
            title: Text(
              evaluation.aerodromeName,
              style: AppFonts.labelMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: AppFonts.bold,
              ),
            ),
            subtitle: Text(
              '${evaluation.evaluationDate.day}/${evaluation.evaluationDate.month}/${evaluation.evaluationDate.year}',
              style: AppFonts.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            trailing: Icon(Icons.arrow_back_ios, color: AppColors.textHint),
          ),
        );
      }).toList(),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 90) return AppColors.excellent;
    if (score >= 75) return AppColors.good;
    if (score >= 60) return AppColors.acceptable;
    return AppColors.unsafe;
  }

  Widget _buildEvaluationDistributionChart() {
    final evaluations = HiveService.evaluationBox.values.toList();

    int excellent = 0;
    int good = 0;
    int acceptable = 0;
    int unsafe = 0;

    for (var evaluation in evaluations) {
      if (evaluation.totalScore >= 90) {
        excellent++;
      } else if (evaluation.totalScore >= 75) {
        good++;
      } else if (evaluation.totalScore >= 60) {
        acceptable++;
      } else {
        unsafe++;
      }
    }

    final total = evaluations.length;
    if (total == 0) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.pie_chart_outline,
                  size: 64,
                  color: AppColors.textHint,
                ),
                const SizedBox(height: 16),
                Text(
                  'لا توجد بيانات',
                  style: AppFonts.labelMedium.copyWith(
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'توزيع التقييمات',
              style: AppFonts.titleMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: AppFonts.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: CustomPaint(
                painter: _PieChartPainter(
                  data: [
                    _PieChartData(AppColors.excellent, excellent, 'ممتاز'),
                    _PieChartData(AppColors.good, good, 'جيد'),
                    _PieChartData(AppColors.acceptable, acceptable, 'مقبول'),
                    _PieChartData(AppColors.unsafe, unsafe, 'غير آمن'),
                  ],
                  total: total,
                ),
                child: const SizedBox.expand(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLegendItem(AppColors.excellent, 'ممتاز', excellent),
                _buildLegendItem(AppColors.good, 'جيد', good),
                _buildLegendItem(AppColors.acceptable, 'مقبول', acceptable),
                _buildLegendItem(AppColors.unsafe, 'غير آمن', unsafe),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label, int count) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          '$label ($count)',
          style: AppFonts.labelSmall.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildMonthlyEvaluationsChart() {
    final evaluations = HiveService.evaluationBox.values.toList();
    final now = DateTime.now();

    // Initialize monthly data for last 6 months
    Map<int, int> monthlyData = {};
    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      monthlyData[month.month] = 0;
    }

    // Count evaluations per month
    for (var evaluation in evaluations) {
      final monthDiff =
          (now.year - evaluation.evaluationDate.year) * 12 +
          now.month -
          evaluation.evaluationDate.month;
      if (monthDiff >= 0 && monthDiff < 6) {
        final month = DateTime(now.year, now.month - monthDiff.toInt(), 1);
        monthlyData[month.month] = (monthlyData[month.month] ?? 0) + 1;
      }
    }

    final months = monthlyData.keys.toList()..sort();
    final values = months.map((m) => monthlyData[m] ?? 0).toList();
    final maxValue = values.isEmpty
        ? 1
        : values.reduce((a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'التقييمات الشهرية',
              style: AppFonts.titleMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: AppFonts.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: CustomPaint(
                painter: _BarChartPainter(
                  values: values,
                  maxValue: maxValue.toDouble() + 1,
                  months: months,
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAerodromesContent() {
    return const AerodromeListScreen();
  }

  Widget _buildManagersContent() {
    return const ManagerListScreen();
  }

  Widget _buildTeamContent() {
    return const TeamListScreen();
  }

  Widget _buildAircraftContent() {
    return const AircraftListScreen();
  }

  Widget _buildReportsContent() {
    return const EvaluationListScreen();
  }

  Widget _buildSettingsContent() {
    return const ProfileScreen();
  }

  Widget _buildHelpContent() {
    return const HelpScreen();
  }
}

class _PieChartData {
  final Color color;
  final int value;
  final String label;

  _PieChartData(this.color, this.value, this.label);
}

class _PieChartPainter extends CustomPainter {
  final List<_PieChartData> data;
  final int total;

  _PieChartPainter({required this.data, required this.total});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 20;
    double startAngle = -math.pi / 2;

    for (var item in data) {
      if (item.value == 0) continue;

      final sweepAngle = (item.value / total) * 2 * math.pi;
      final paint = Paint()
        ..color = item.color
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(_PieChartPainter oldDelegate) {
    return oldDelegate.data != data || oldDelegate.total != total;
  }
}

class _BarChartPainter extends CustomPainter {
  final List<int> values;
  final double maxValue;
  final List<int> months;

  _BarChartPainter({
    required this.values,
    required this.maxValue,
    required this.months,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final padding = 40.0;
    final chartWidth = size.width - padding * 2;
    final chartHeight = size.height - padding * 2;
    final barWidth = chartWidth / values.length - 10;
    final monthNames = [
      '',
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];

    // Draw bars
    for (int i = 0; i < values.length; i++) {
      final barHeight = (values[i] / maxValue) * chartHeight;
      final x = padding + i * (barWidth + 10);
      final y = size.height - padding - barHeight;

      final paint = Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.fill;

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barWidth, barHeight),
        const Radius.circular(4),
      );
      canvas.drawRRect(rect, paint);

      // Draw value on top of bar
      final textPainter = TextPainter(
        text: TextSpan(
          text: values[i].toString(),
          style: AppFonts.labelSmall.copyWith(color: AppColors.textPrimary),
        ),
        textDirection: TextDirection.rtl,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x + barWidth / 2 - textPainter.width / 2, y - 20),
      );

      // Draw month label
      final monthPainter = TextPainter(
        text: TextSpan(
          text: monthNames[months[i]],
          style: AppFonts.labelSmall.copyWith(color: AppColors.textSecondary),
        ),
        textDirection: TextDirection.rtl,
      );
      monthPainter.layout();
      monthPainter.paint(
        canvas,
        Offset(
          x + barWidth / 2 - monthPainter.width / 2,
          size.height - padding + 5,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(_BarChartPainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.maxValue != maxValue ||
        oldDelegate.months != months;
  }
}
