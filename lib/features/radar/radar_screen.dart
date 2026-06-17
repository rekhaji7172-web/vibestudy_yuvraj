import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_utils.dart';
import '../../data/providers/app_provider.dart';
import '../../shared/widgets/shared_widgets.dart';

class RadarScreen extends StatelessWidget {
  const RadarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (ctx, provider, _) {
        return Scaffold(
          backgroundColor: AppColors.deepNavy,
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              const SliverAppBar(
                pinned: true,
                backgroundColor: AppColors.deepNavy,
                title: Text('Revision Radar',
                  style: TextStyle( color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 20)),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: _WeeklyChart(provider: provider),
                ).animate().fadeIn(duration: 400.ms),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: _StatsOverview(provider: provider),
                ).animate(delay: 100.ms).fadeIn(),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  child: SectionHeader(title: 'Subject Breakdown'),
                ).animate(delay: 150.ms).fadeIn(),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: _SubjectBreakdown(provider: provider),
                ).animate(delay: 200.ms).fadeIn(),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  child: SectionHeader(title: 'Recent Sessions'),
                ).animate(delay: 250.ms).fadeIn(),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx2, i) {
                      final session = provider.sessions[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _SessionTile(session: session),
                      ).animate(delay: (i * 40).ms).fadeIn(duration: 300.ms);
                    },
                    childCount: provider.sessions.length > 10 ? 10 : provider.sessions.length,
                  ),
                ),
              ),
              if (provider.sessions.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: GlassCard(
                      child: const Text(
                        'No study sessions yet. Start your first Focus Timer session!',
                        textAlign: TextAlign.center,
                        style: TextStyle( color: AppColors.textSecondary, fontSize: 14),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _WeeklyChart extends StatelessWidget {
  final AppProvider provider;

  const _WeeklyChart({required this.provider});

  List<double> _getWeeklyData() {
    final now = DateTime.now();
    final data = List<double>.filled(7, 0);
    for (var session in provider.sessions) {
      final diff = now.difference(session.date).inDays;
      if (diff < 7) {
        final dayIndex = 6 - diff;
        data[dayIndex] += session.durationMinutes.toDouble();
      }
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    final data = _getWeeklyData();
    final maxVal = data.reduce((a, b) => a > b ? a : b);
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final now = DateTime.now();
    final weekdays = List.generate(7, (i) {
      final d = now.subtract(Duration(days: 6 - i));
      return days[d.weekday - 1];
    });

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Weekly Focus (minutes)',
            style: TextStyle( color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                maxY: maxVal == 0 ? 60 : maxVal * 1.3,
                backgroundColor: Colors.transparent,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxVal == 0 ? 15 : maxVal / 3,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: AppColors.textMuted.withOpacity(0.15),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (v, _) => Text(
                        v.toInt().toString(),
                        style: const TextStyle( color: AppColors.textMuted, fontSize: 10),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) => Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          weekdays[v.toInt()],
                          style: const TextStyle( color: AppColors.textSecondary, fontSize: 10),
                        ),
                      ),
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: data.asMap().entries.map((e) => BarChartGroupData(
                  x: e.key,
                  barRods: [
                    BarChartRodData(
                      toY: e.value,
                      gradient: e.value > 0
                          ? const LinearGradient(
                              colors: [AppColors.indigoPrimary, AppColors.purpleAccent],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            )
                          : null,
                      color: e.value == 0 ? AppColors.cardElevated : null,
                      width: 24,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                    ),
                  ],
                )).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsOverview extends StatelessWidget {
  final AppProvider provider;

  const _StatsOverview({required this.provider});

  @override
  Widget build(BuildContext context) {
    final totalMin = provider.user.totalFocusMinutes;
    final sessions = provider.sessions.length;
    final streak = provider.user.streak;
    final tasksCompleted = provider.tasks.where((t) => t.isCompleted).length;

    return Row(
      children: [
        Expanded(child: _MiniStat(value: AppUtils.formatMinutes(totalMin), label: 'Total Focus', color: AppColors.indigoPrimary)),
        const SizedBox(width: 10),
        Expanded(child: _MiniStat(value: '$sessions', label: 'Sessions', color: AppColors.cyanGlow)),
        const SizedBox(width: 10),
        Expanded(child: _MiniStat(value: '$streak', label: 'Streak', color: AppColors.orangeAccent)),
        const SizedBox(width: 10),
        Expanded(child: _MiniStat(value: '$tasksCompleted', label: 'Tasks Done', color: AppColors.mintGreen)),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _MiniStat({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Text(value, style: TextStyle( color: color, fontWeight: FontWeight.w800, fontSize: 18)),
          const SizedBox(height: 4),
          Text(label, textAlign: TextAlign.center, style: const TextStyle( color: AppColors.textMuted, fontSize: 10)),
        ],
      ),
    );
  }
}

class _SubjectBreakdown extends StatelessWidget {
  final AppProvider provider;

  const _SubjectBreakdown({required this.provider});

  @override
  Widget build(BuildContext context) {
    final Map<String, int> subjectMinutes = {};
    for (var s in provider.sessions) {
      subjectMinutes[s.subject] = (subjectMinutes[s.subject] ?? 0) + s.durationMinutes;
    }

    if (subjectMinutes.isEmpty) {
      return GlassCard(
        child: const Text('Complete some focus sessions to see your subject breakdown.',
          style: TextStyle( color: AppColors.textSecondary, fontSize: 13)),
      );
    }

    final total = subjectMinutes.values.fold(0, (a, b) => a + b);
    final colors = [AppColors.indigoPrimary, AppColors.purpleAccent, AppColors.cyanGlow, AppColors.mintGreen, AppColors.amberAccent];

    return GlassCard(
      child: Column(
        children: subjectMinutes.entries.toList().asMap().entries.map((entry) {
          final i = entry.key;
          final e = entry.value;
          final ratio = e.value / total;
          final color = colors[i % colors.length];
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                        const SizedBox(width: 8),
                        Text(e.key, style: const TextStyle( color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w500)),
                      ],
                    ),
                    Text('${AppUtils.formatMinutes(e.value)} (${(ratio * 100).round()}%)',
                      style: const TextStyle( color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: ratio,
                    backgroundColor: AppColors.textMuted.withOpacity(0.15),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  final dynamic session;

  const _SessionTile({required this.session});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.indigoPrimary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.timer_rounded, color: AppColors.indigoPrimary, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(session.subject,
                  style: const TextStyle( color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 2),
                Text(AppUtils.timeAgo(session.date),
                  style: const TextStyle( color: AppColors.textMuted, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.indigoPrimary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(AppUtils.formatMinutes(session.durationMinutes),
              style: const TextStyle( color: AppColors.indigoPrimary, fontWeight: FontWeight.w700, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
