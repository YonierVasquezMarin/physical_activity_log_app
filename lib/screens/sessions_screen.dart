import 'package:flutter/material.dart';
import 'package:physical_activity_log_app/components/empty_state_component.dart';
import 'package:physical_activity_log_app/components/training_session_card.dart';
import 'package:physical_activity_log_app/models/training_session.dart';
import 'package:physical_activity_log_app/theme/app_colors.dart';

class SessionsScreen extends StatelessWidget {
  const SessionsScreen({super.key});

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

  static final _testSessions = <TrainingSession>[
    TrainingSession(
      activityIds: [1, 3],
      date: DateTime(2025, 6, 2, 7, 30),
      photoName: 'hombre-lavantando-mancuernas.png',
      observations: 'Ejercicios iniciales de fuerza',
    ),
    TrainingSession(
      activityIds: [2],
      date: DateTime(2025, 6, 2, 18, 0),
      photoName: 'hombre-corriendo.png',
      observations: 'Cardio en cinta',
    ),
    TrainingSession(
      activityIds: [4, 5],
      date: DateTime(2025, 6, 3, 6, 45),
      photoName: 'mujer-lavantando-mancuernas.png',
      observations: 'Rutina de piernas',
    ),
    TrainingSession(
      activityIds: [1],
      date: DateTime(2025, 6, 4, 8, 0),
      photoName: 'hombre-con-musculos-posando-de-frente.png',
      observations: 'Entrenamiento de pecho',
    ),
    TrainingSession(
      activityIds: [3, 6],
      date: DateTime(2025, 6, 5, 17, 30),
      photoName: 'mujer-haciendo-ejercicio-con-mancuerna.png',
      observations: 'Circuito funcional',
    ),
    TrainingSession(
      activityIds: [2, 7],
      date: DateTime(2025, 6, 6, 7, 0),
      photoName: 'hombre-trotando.png',
      observations: 'Trote matutino',
    ),
    TrainingSession(
      activityIds: [1, 2, 3],
      date: DateTime(2025, 6, 6, 19, 15),
      photoName: 'mujer-sonriendo-con-mancuerna.png',
      observations: 'Sesión completa de cuerpo',
    ),
    TrainingSession(
      activityIds: [5],
      date: DateTime(2025, 6, 7, 9, 0),
      photoName: 'hombre-de-color-posando.png',
      observations: 'Estiramientos y movilidad',
    ),
  ];

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
      final dayKey = DateTime(session.date.year, session.date.month, session.date.day);
      grouped.putIfAbsent(dayKey, () => []).add(session);
    }

    for (final daySessions in grouped.values) {
      daySessions.sort((a, b) => a.date.compareTo(b.date));
    }

    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
    return {for (final key in sortedKeys) key: grouped[key]!};
  }

  @override
  Widget build(BuildContext context) {
    final sessions = _testSessions;

    return ColoredBox(
      color: AppColors.screenBackground,
      child: SafeArea(
        child: sessions.isEmpty
            ? const EmptyStateComponent(message: 'Sin sesiones registradas')
            : _SessionsList(
                groupedSessions: _groupByDay(sessions),
              ),
      ),
    );
  }
}

class _SessionsList extends StatelessWidget {
  const _SessionsList({required this.groupedSessions});

  final Map<DateTime, List<TrainingSession>> groupedSessions;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    var colorIndex = 0;

    for (final entry in groupedSessions.entries) {
      children.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 12, top: 8),
          child: Text(
            SessionsScreen._formatDayHeader(entry.key),
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
            backgroundColor: SessionsScreen
                ._cardColors[colorIndex % SessionsScreen._cardColors.length],
          ),
        );
        colorIndex++;
        children.add(const SizedBox(height: 12));
      }
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: children,
    );
  }
}
