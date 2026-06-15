import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:physical_activity_log_app/components/empty_state_component.dart';
import 'package:physical_activity_log_app/models/report_summary.dart';
import 'package:physical_activity_log_app/providers/auth_provider.dart';
import 'package:physical_activity_log_app/providers/reports_provider.dart';
import 'package:physical_activity_log_app/theme/app_colors.dart';

enum _ReportPeriodPreset { last7Days, last30Days, last90Days }

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  static const _months = <String>[
    'ene',
    'feb',
    'mar',
    'abr',
    'may',
    'jun',
    'jul',
    'ago',
    'sep',
    'oct',
    'nov',
    'dic',
  ];

  static const _categoryColors = <Color>[
    AppColors.primary,
    Color(0xFF0080F0),
    Color(0xFF30C8F8),
    Color(0xFF6366F1),
    Color(0xFF8B5CF6),
    Color(0xFF14B8A6),
  ];

  _ReportPeriodPreset _selectedPreset = _ReportPeriodPreset.last30Days;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadReport());
  }

  ({DateTime from, DateTime to}) _dateRangeForPreset(_ReportPeriodPreset preset) {
    final now = DateTime.now();
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);
    final days = switch (preset) {
      _ReportPeriodPreset.last7Days => 6,
      _ReportPeriodPreset.last30Days => 29,
      _ReportPeriodPreset.last90Days => 89,
    };
    final fromDate = DateTime(now.year, now.month, now.day - days);
    return (from: fromDate, to: todayEnd);
  }

  Future<void> _loadReport() async {
    final authHeader = context.read<AuthProvider>().authorizationHeader;
    if (authHeader == null) return;

    final range = _dateRangeForPreset(_selectedPreset);
    await context.read<ReportsProvider>().loadSummary(
          authorizationHeader: authHeader,
          from: range.from,
          to: range.to,
        );
  }

  void _onPresetChanged(_ReportPeriodPreset preset) {
    if (_selectedPreset == preset) return;
    setState(() => _selectedPreset = preset);
    _loadReport();
  }

  static String _formatShortDate(DateTime date) {
    final local = date.toLocal();
    return '${local.day} ${_months[local.month - 1]} ${local.year}';
  }

  static String _formatWeekLabel(String week) {
    final parts = week.split('-W');
    if (parts.length != 2) return week;
    return 'Sem. ${parts[1]}';
  }

  static String _formatDecimal(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReportsProvider>();
    final summary = provider.summary;

    return ColoredBox(
      color: AppColors.screenBackground,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Reportes',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    summary != null
                        ? '${_formatShortDate(summary.period.from)} — ${_formatShortDate(summary.period.to)}'
                        : 'Resumen de tu actividad física',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.bodyTextGrey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _PeriodSelector(
                    selected: _selectedPreset,
                    onChanged: _onPresetChanged,
                    isLoading: provider.isLoading,
                  ),
                ],
              ),
            ),
            Expanded(child: _buildBody(provider, summary)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(ReportsProvider provider, ReportSummary? summary) {
    if (provider.isLoading && summary == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (provider.error != null && summary == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_off_outlined,
                size: 48,
                color: AppColors.placeholderGrey.withValues(alpha: 0.7),
              ),
              const SizedBox(height: 16),
              Text(
                provider.error!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.bodyTextGrey,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _loadReport,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (summary == null) {
      return const EmptyStateComponent(
        message: 'Sin datos de reportes',
        description:
            'Registra sesiones de entrenamiento para ver estadísticas y tendencias.',
      );
    }

    if (summary.overview.totalSessions == 0) {
      return RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _loadReport,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 48),
            EmptyStateComponent(
              message: 'Sin actividad en este periodo',
              description:
                  'No hay sesiones registradas en el rango seleccionado. Prueba otro periodo o registra una nueva sesión.',
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadReport,
      child: Stack(
        children: [
          ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              _OverviewSection(summary: summary),
              const SizedBox(height: 16),
              _ConsistencySection(
                consistency: summary.consistency,
                formatWeekLabel: _formatWeekLabel,
              ),
              const SizedBox(height: 16),
              _CategoriesSection(
                categories: summary.categories,
                colors: _categoryColors,
              ),
              const SizedBox(height: 16),
              _TopActivitiesSection(activities: summary.activities),
              const SizedBox(height: 16),
              _GoalsSection(goals: summary.goals),
            ],
          ),
          if (provider.isLoading)
            const Positioned(
              top: 8,
              left: 0,
              right: 0,
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 2.5,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({
    required this.selected,
    required this.onChanged,
    required this.isLoading,
  });

  final _ReportPeriodPreset selected;
  final ValueChanged<_ReportPeriodPreset> onChanged;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _PeriodChip(
          label: '7 días',
          isSelected: selected == _ReportPeriodPreset.last7Days,
          onTap: isLoading ? null : () => onChanged(_ReportPeriodPreset.last7Days),
        ),
        const SizedBox(width: 8),
        _PeriodChip(
          label: '30 días',
          isSelected: selected == _ReportPeriodPreset.last30Days,
          onTap: isLoading ? null : () => onChanged(_ReportPeriodPreset.last30Days),
        ),
        const SizedBox(width: 8),
        _PeriodChip(
          label: '90 días',
          isSelected: selected == _ReportPeriodPreset.last90Days,
          onTap: isLoading ? null : () => onChanged(_ReportPeriodPreset.last90Days),
        ),
      ],
    );
  }
}

class _PeriodChip extends StatelessWidget {
  const _PeriodChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppColors.primary : Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : AppColors.bodyTextGrey,
            ),
          ),
        ),
      ),
    );
  }
}

class _OverviewSection extends StatelessWidget {
  const _OverviewSection({required this.summary});

  final ReportSummary summary;

  @override
  Widget build(BuildContext context) {
    final overview = summary.overview;
    final topCategory = overview.mostFrequentCategory;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary, AppColors.accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.insights,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Resumen general',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _OverviewStat(
                  label: 'Sesiones',
                  value: '${overview.totalSessions}',
                  icon: Icons.fitness_center,
                ),
              ),
              Expanded(
                child: _OverviewStat(
                  label: 'Días activos',
                  value: '${overview.activeDays}',
                  icon: Icons.calendar_today,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _OverviewStat(
                  label: 'Promedio / semana',
                  value: _ReportsScreenState._formatDecimal(
                    overview.averageSessionsPerWeek,
                  ),
                  icon: Icons.trending_up,
                ),
              ),
              Expanded(
                child: _OverviewStat(
                  label: 'Categoría top',
                  value: topCategory?.name ?? '—',
                  icon: Icons.category_outlined,
                  isSmallText: topCategory != null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OverviewStat extends StatelessWidget {
  const _OverviewStat({
    required this.label,
    required this.value,
    required this.icon,
    this.isSmallText = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool isSmallText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.white.withValues(alpha: 0.85), size: 18),
        const SizedBox(height: 6),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: isSmallText ? 15 : 22,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _ConsistencySection extends StatelessWidget {
  const _ConsistencySection({
    required this.consistency,
    required this.formatWeekLabel,
  });

  final ReportConsistency consistency;
  final String Function(String week) formatWeekLabel;

  @override
  Widget build(BuildContext context) {
    final maxCount = consistency.sessionsByWeek.fold<int>(
      0,
      (max, week) => week.count > max ? week.count : max,
    );

    return _SectionCard(
      title: 'Consistencia',
      icon: Icons.local_fire_department_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _MiniStatCard(
                  label: 'Racha actual',
                  value: '${consistency.currentStreakDays} días',
                  color: const Color(0xFFFF6B35),
                  icon: Icons.whatshot,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MiniStatCard(
                  label: 'Mejor racha',
                  value: '${consistency.longestStreakDays} días',
                  color: AppColors.primary,
                  icon: Icons.emoji_events_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _MiniStatCard(
            label: 'Días sin actividad',
            value: '${consistency.inactiveDays} días',
            color: AppColors.bodyTextGrey,
            icon: Icons.nights_stay_outlined,
            fullWidth: true,
          ),
          if (consistency.sessionsByWeek.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text(
              'Sesiones por semana',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.bodyTextGrey,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 120,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final week in consistency.sessionsByWeek)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: _WeekBar(
                          label: formatWeekLabel(week.week),
                          count: week.count,
                          maxCount: maxCount == 0 ? 1 : maxCount,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  const _MiniStatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
    this.fullWidth = false,
  });

  final String label;
  final String value;
  final Color color;
  final IconData icon;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.bodyTextGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WeekBar extends StatelessWidget {
  const _WeekBar({
    required this.label,
    required this.count,
    required this.maxCount,
  });

  final String label;
  final int count;
  final int maxCount;

  @override
  Widget build(BuildContext context) {
    final fraction = count / maxCount;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          '$count',
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.bodyTextGrey,
          ),
        ),
        const SizedBox(height: 4),
        Flexible(
          child: FractionallySizedBox(
            heightFactor: fraction.clamp(0.08, 1.0),
            widthFactor: 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 9,
            color: AppColors.placeholderGrey,
          ),
        ),
      ],
    );
  }
}

class _CategoriesSection extends StatelessWidget {
  const _CategoriesSection({
    required this.categories,
    required this.colors,
  });

  final ReportCategories categories;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Por categoría',
      icon: Icons.pie_chart_outline,
      child: Column(
        children: [
          for (var i = 0; i < categories.breakdown.length; i++)
            Padding(
              padding: EdgeInsets.only(
                bottom: i < categories.breakdown.length - 1 ? 14 : 0,
              ),
              child: _CategoryBar(
                category: categories.breakdown[i],
                color: colors[i % colors.length],
              ),
            ),
        ],
      ),
    );
  }
}

class _CategoryBar extends StatelessWidget {
  const _CategoryBar({
    required this.category,
    required this.color,
  });

  final ReportCategoryBreakdown category;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                category.categoryName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            Text(
              '${category.sessionCount} · ${category.percentage.toStringAsFixed(0)}%',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.bodyTextGrey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: category.percentage / 100,
            minHeight: 8,
            backgroundColor: AppColors.dividerGrey,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _TopActivitiesSection extends StatelessWidget {
  const _TopActivitiesSection({required this.activities});

  final ReportActivities activities;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Actividades más frecuentes',
      icon: Icons.star_outline,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (activities.top.isEmpty)
            const Text(
              'No hay actividades registradas en este periodo.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.bodyTextGrey,
              ),
            )
          else
            for (var i = 0; i < activities.top.length; i++)
              Padding(
                padding: EdgeInsets.only(
                  bottom: i < activities.top.length - 1 ? 10 : 0,
                ),
                child: _TopActivityTile(
                  rank: i + 1,
                  activity: activities.top[i],
                ),
              ),
          if (activities.uniqueActivitiesCount > 0) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.screenBackground,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${activities.uniqueActivitiesCount} actividades únicas en total',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.bodyTextGrey,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TopActivityTile extends StatelessWidget {
  const _TopActivityTile({
    required this.rank,
    required this.activity,
  });

  final int rank;
  final ReportTopActivity activity;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.screenBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$rank',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.activityName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  activity.categoryName,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.bodyTextGrey,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${activity.occurrences}×',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalsSection extends StatelessWidget {
  const _GoalsSection({required this.goals});

  final ReportGoals goals;

  @override
  Widget build(BuildContext context) {
    final hasGoals = goals.activeCount > 0 ||
        goals.expiredCount > 0 ||
        goals.withoutProgressCount > 0;

    return _SectionCard(
      title: 'Metas',
      icon: Icons.flag_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _GoalStatBadge(
                  label: 'Activas',
                  count: goals.activeCount,
                  color: const Color(0xFF2E7D32),
                  background: const Color(0xFFE8F5E9),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _GoalStatBadge(
                  label: 'Vencidas',
                  count: goals.expiredCount,
                  color: const Color(0xFFC62828),
                  background: const Color(0xFFFFEBEE),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _GoalStatBadge(
                  label: 'Sin avance',
                  count: goals.withoutProgressCount,
                  color: AppColors.bodyTextGrey,
                  background: const Color(0xFFF1F5F9),
                ),
              ),
            ],
          ),
          if (goals.items.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Detalle',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.bodyTextGrey,
              ),
            ),
            const SizedBox(height: 10),
            for (var i = 0; i < goals.items.length; i++)
              Padding(
                padding: EdgeInsets.only(
                  bottom: i < goals.items.length - 1 ? 8 : 0,
                ),
                child: _GoalItemTile(goal: goals.items[i]),
              ),
          ] else if (!hasGoals) ...[
            const SizedBox(height: 8),
            const Text(
              'No tienes metas registradas en este periodo.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.bodyTextGrey,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _GoalStatBadge extends StatelessWidget {
  const _GoalStatBadge({
    required this.label,
    required this.count,
    required this.color,
    required this.background,
  });

  final String label;
  final int count;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalItemTile extends StatelessWidget {
  const _GoalItemTile({required this.goal});

  final ReportGoalItem goal;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.screenBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.flag_outlined,
            size: 16,
            color: AppColors.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              goal.title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          Text(
            goal.status,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.bodyTextGrey,
            ),
          ),
        ],
      ),
    );
  }
}
