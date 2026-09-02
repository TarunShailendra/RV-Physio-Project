import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/glass_theme.dart';
import '../../../core/widgets/app_bottom_navigation.dart';
import '../../../l10n/app_localizations.dart';
import '../dashboard_notifier.dart';
import '../models/dashboard_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardNotifier>().loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<DashboardNotifier>();
    final data = notifier.data;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.dashboard),
        backgroundColor: const Color(0xFF00897B),
        foregroundColor: Colors.white,
      ),
      bottomNavigationBar: const AppBottomNavigation(),
      body: data == null && notifier.isLoading
          ? const Center(child: CircularProgressIndicator())
          : data == null
          ? const Center(child: Text('Failed to load dashboard'))
          : GlassBackground(
              child: SafeArea(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _GreetingCard(data: data, l10n: l10n),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            label: l10n.thisWeek,
                            value:
                                '${data.exercisesCompletedThisWeek}/${data.exercisesTargetThisWeek} ${l10n.exercises}',
                            icon: Icons.fitness_center,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            label: l10n.adherence,
                            value:
                                '${data.adherencePercentage.toStringAsFixed(0)}%',
                            icon: Icons.trending_up,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _WeeklyAdherenceChart(data: data, l10n: l10n),
                    if (data.iciqScorePre > 0) ...[
                      const SizedBox(height: 16),
                      _IciqComparison(data: data, l10n: l10n),
                    ],
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.4),
                              ),
                            ),
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: () => context.go('/bladder-diary'),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.edit_note, size: 20),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      l10n.logBladderDiary,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF00897B,
                                  ).withValues(alpha: 0.5),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF00897B),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: () => context.go('/exercise'),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.play_arrow, size: 20),
                                  const SizedBox(width: 8),
                                  Text(l10n.startExercise),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _GreetingCard extends StatelessWidget {
  const _GreetingCard({required this.data, required this.l10n});

  final DashboardModel data;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      opacity: 0.12,
      borderRadius: 20,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Text(
              l10n.weekXofY(data.currentWeek, data.totalWeeks),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Icon(Icons.spa, color: Colors.white70, size: 28),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      opacity: 0.12,
      borderRadius: 20,
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.labelMedium?.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyAdherenceChart extends StatelessWidget {
  const _WeeklyAdherenceChart({required this.data, required this.l10n});

  final DashboardModel data;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      opacity: 0.12,
      borderRadius: 20,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.weeklyAdherence,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                minY: 0,
                maxY: 100,
                gridData: FlGridData(
                  drawVerticalLine: false,
                  horizontalInterval: 25,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.white.withValues(alpha: 0.1),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: 25,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}%',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 11,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final week = value.toInt() + 1;
                        if (week < 1 || week > data.weeklyAdherence.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            l10n.week(week),
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 11,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: [
                  for (
                    var index = 0;
                    index < data.weeklyAdherence.length;
                    index++
                  )
                    BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: data.weeklyAdherence[index],
                          width: 18,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                          color: data.weeklyAdherence[index] > 0
                              ? const Color(0xFF4DB6AC)
                              : Colors.white.withValues(alpha: 0.15),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IciqComparison extends StatelessWidget {
  const _IciqComparison({required this.data, required this.l10n});

  final DashboardModel data;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      opacity: 0.12,
      borderRadius: 20,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              l10n.iciqComparison(data.iciqScorePre, data.iciqScorePost),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.white),
            ),
          ),
          const Icon(Icons.arrow_downward, color: Color(0xFF80CBC4)),
        ],
      ),
    );
  }
}
