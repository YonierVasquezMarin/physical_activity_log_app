import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:physical_activity_log_app/components/empty_state_component.dart';
import 'package:physical_activity_log_app/models/goal.dart';
import 'package:physical_activity_log_app/providers/auth_provider.dart';
import 'package:physical_activity_log_app/providers/goals_provider.dart';
import 'package:physical_activity_log_app/screens/goal_form_screen.dart';
import 'package:physical_activity_log_app/theme/app_colors.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadGoals());
  }

  Future<void> _loadGoals() async {
    final authHeader = context.read<AuthProvider>().authorizationHeader;
    if (authHeader == null) return;

    await context.read<GoalsProvider>().loadGoals(
          authorizationHeader: authHeader,
        );
  }

  Future<void> _openCreateGoal() async {
    final changed = await Navigator.of(context, rootNavigator: true).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => const GoalFormScreen(),
      ),
    );

    if (changed == true && mounted) {
      await _loadGoals();
    }
  }

  Future<void> _openEditGoal(Goal goal) async {
    final changed = await Navigator.of(context, rootNavigator: true).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => GoalFormScreen(goal: goal),
      ),
    );

    if (changed == true && mounted) {
      await _loadGoals();
    }
  }

  static String _formatDateRange(Goal goal) {
    final start = goal.startDate.toLocal();
    final end = goal.endDate.toLocal();
    final startLabel =
        '${start.day} ${_months[start.month - 1]} ${start.year}';
    final endLabel = '${end.day} ${_months[end.month - 1]} ${end.year}';
    return '$startLabel — $endLabel';
  }

  @override
  Widget build(BuildContext context) {
    final goalsProvider = context.watch<GoalsProvider>();
    final goals = goalsProvider.goals;

    return Stack(
      children: [
        SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Text(
                  'Metas',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),
              Expanded(
                child: _buildBody(goalsProvider, goals),
              ),
            ],
          ),
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton.extended(
            heroTag: 'goals-fab',
            onPressed: goalsProvider.isLoading ? null : _openCreateGoal,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 4,
            icon: const Icon(Icons.add),
            label: const Text(
              'Nueva meta',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(GoalsProvider provider, List<Goal> goals) {
    if (provider.isLoading && goals.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (provider.error != null && goals.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
                onPressed: _loadGoals,
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

    if (goals.isEmpty) {
      return const EmptyStateComponent(
        message: 'Sin metas registradas',
        description:
            'Define tu primera meta para mantener el enfoque en tus objetivos de actividad física.',
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadGoals,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        itemCount: goals.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final goal = goals[index];
          return _GoalCard(
            goal: goal,
            dateRangeLabel: _formatDateRange(goal),
            onTap: () => _openEditGoal(goal),
          );
        },
      ),
    );
  }
}

enum _GoalStatus { upcoming, active, finished }

class _GoalCard extends StatelessWidget {
  const _GoalCard({
    required this.goal,
    required this.dateRangeLabel,
    required this.onTap,
  });

  final Goal goal;
  final String dateRangeLabel;
  final VoidCallback onTap;

  _GoalStatus get _status {
    if (goal.isUpcoming) return _GoalStatus.upcoming;
    if (goal.isActive) return _GoalStatus.active;
    return _GoalStatus.finished;
  }

  ({String label, Color background, Color foreground}) get _statusStyle {
    switch (_status) {
      case _GoalStatus.upcoming:
        return (
          label: 'Próxima',
          background: const Color(0xFFE3F2FD),
          foreground: AppColors.primary,
        );
      case _GoalStatus.active:
        return (
          label: 'En curso',
          background: const Color(0xFFE8F5E9),
          foreground: const Color(0xFF2E7D32),
        );
      case _GoalStatus.finished:
        return (
          label: 'Finalizada',
          background: const Color(0xFFF1F5F9),
          foreground: AppColors.bodyTextGrey,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = _statusStyle;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.flag_outlined,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            goal.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: status.background,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            status.label,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: status.foreground,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (goal.description.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        goal.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.bodyTextGrey,
                          height: 1.35,
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 14,
                          color: AppColors.placeholderGrey,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            dateRangeLabel,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.bodyTextGrey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Icon(
                  Icons.chevron_right,
                  color: AppColors.placeholderGrey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
