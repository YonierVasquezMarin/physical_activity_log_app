import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:physical_activity_log_app/components/empty_state_component.dart';
import 'package:physical_activity_log_app/components/training_session_card.dart';
import 'package:physical_activity_log_app/models/training_session.dart';
import 'package:physical_activity_log_app/providers/auth_provider.dart';
import 'package:physical_activity_log_app/providers/training_sessions_provider.dart';
import 'package:physical_activity_log_app/screens/training_session_form_screen.dart';
import 'package:physical_activity_log_app/theme/app_colors.dart';

class SessionsScreen extends StatefulWidget {
  const SessionsScreen({super.key});

  @override
  State<SessionsScreen> createState() => _SessionsScreenState();
}

class _SessionsScreenState extends State<SessionsScreen> {
  static const _cardColors = <Color>[
    Color(0xFFE3F2FD),
    Color(0xFFEDE7F6),
    Color(0xFFFCE4EC),
    Color(0xFFE0F7FA),
    Color(0xFFF1F8E9),
  ];

  static const _weekdays = <String>[
    'lunes',
    'martes',
    'miércoles',
    'jueves',
    'viernes',
    'sábado',
    'domingo',
  ];

  static const _months = <String>[
    'enero',
    'febrero',
    'marzo',
    'abril',
    'mayo',
    'junio',
    'julio',
    'agosto',
    'septiembre',
    'octubre',
    'noviembre',
    'diciembre',
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) => _loadSessions());
  }

  Future<void> _loadSessions() async {
    final authHeader = context.read<AuthProvider>().authorizationHeader;

    if (authHeader == null) return;

    await context.read<TrainingSessionsProvider>().loadSessions(
          authorizationHeader: authHeader,
        );
  }

  static String _formatDayHeader(DateTime date) {
    final weekday = _weekdays[date.weekday - 1];
    final month = _months[date.month - 1];
    return '$weekday, ${date.day} de $month';
  }

  static Map<DateTime, List<TrainingSession>> _groupByDay(
    List<TrainingSession> sessions,
  ) {
    final grouped = <DateTime, List<TrainingSession>>{};

    for (final session in sessions) {
      final localDate = session.date.toLocal();
      final dayKey =
          DateTime(localDate.year, localDate.month, localDate.day);
      grouped.putIfAbsent(dayKey, () => []).add(session);
    }

    for (final daySessions in grouped.values) {
      daySessions.sort(
        (a, b) => a.date.toLocal().compareTo(b.date.toLocal()),
      );
    }

    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
    return {for (final key in sortedKeys) key: grouped[key]!};
  }

  Future<void> _openCreateSession() async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => const TrainingSessionFormScreen(),
      ),
    );

    if (changed == true && mounted) {
      await _loadSessions();
    }
  }

  Future<void> _openEditSession(TrainingSession session) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => TrainingSessionFormScreen(session: session),
      ),
    );

    if (changed == true && mounted) {
      await _loadSessions();
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionsProvider = context.watch<TrainingSessionsProvider>();
    final sessions = sessionsProvider.sessions;

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: sessionsProvider.isLoadingSessions ? null : _openCreateSession,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add),
        label: const Text(
          'Nueva sesión',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: _buildBody(sessionsProvider, sessions),
      ),
    );
  }

  Widget _buildBody(
    TrainingSessionsProvider sessionsProvider,
    List<TrainingSession> sessions,
  ) {
    if (sessionsProvider.isLoadingSessions && sessions.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (sessionsProvider.sessionsError != null && sessions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                sessionsProvider.sessionsError!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.bodyTextGrey,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _loadSessions,
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

    if (sessions.isEmpty) {
      return const EmptyStateComponent(
        message: 'Sin sesiones registradas',
        description:
            'Registra tu primera sesión de entrenamiento para comenzar con tu historial.',
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadSessions,
      child: _SessionsList(
        groupedSessions: _groupByDay(sessions),
        onSessionTap: _openEditSession,
      ),
    );
  }
}

class _SessionsList extends StatelessWidget {
  const _SessionsList({
    required this.groupedSessions,
    required this.onSessionTap,
  });

  final Map<DateTime, List<TrainingSession>> groupedSessions;
  final ValueChanged<TrainingSession> onSessionTap;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    var colorIndex = 0;

    for (final entry in groupedSessions.entries) {
      children.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 12, top: 8),
          child: Text(
            _SessionsScreenState._formatDayHeader(entry.key),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.bodyTextGrey,
            ),
          ),
        ),
      );

      for (final session in entry.value) {
        children.add(
          TrainingSessionCard(
            session: session,
            backgroundColor: _SessionsScreenState
                ._cardColors[colorIndex % _SessionsScreenState._cardColors.length],
            onTap: () => onSessionTap(session),
          ),
        );
        colorIndex++;
        children.add(const SizedBox(height: 12));
      }
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: children,
    );
  }
}
