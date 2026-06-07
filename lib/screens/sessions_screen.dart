import 'package:flutter/material.dart';
import 'package:physical_activity_log_app/components/empty_state_component.dart';
import 'package:physical_activity_log_app/components/training_session_card.dart';
import 'package:physical_activity_log_app/models/activity.dart';
import 'package:physical_activity_log_app/models/training_session.dart';
import 'package:physical_activity_log_app/screens/training_session_form_screen.dart';
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
      activities: const [
        Activity(
          categoryId: 1,
          name: 'Press de banca',
          description: '4 series de 10 repeticiones',
        ),
        Activity(
          categoryId: 1,
          name: 'Sentadillas',
          description: '3 series de 12 repeticiones',
        ),
      ],
      date: DateTime(2025, 6, 2, 7, 30),
      photoName: 'hombre-lavantando-mancuernas.png',
      observations: 'Ejercicios iniciales de fuerza',
    ),
    TrainingSession(
      activities: const [
        Activity(
          categoryId: 1,
          name: 'Correr 5 km',
          description: 'Trote continuo en parque',
        ),
      ],
      date: DateTime(2025, 6, 2, 18, 0),
      photoName: 'hombre-corriendo.png',
      observations: 'Cardio en cinta',
    ),
    TrainingSession(
      activities: const [
        Activity(
          categoryId: 1,
          name: 'Peso muerto',
          description: '4 series de 8 repeticiones',
        ),
        Activity(
          categoryId: 1,
          name: 'Estiramientos',
          description: 'Rutina de 10 minutos',
        ),
      ],
      date: DateTime(2025, 6, 3, 6, 45),
      photoName: 'mujer-lavantando-mancuernas.png',
      observations: 'Rutina de piernas',
    ),
    TrainingSession(
      activities: const [
        Activity(
          categoryId: 1,
          name: 'Press inclinado',
          description: '3 series de 12 repeticiones',
        ),
      ],
      date: DateTime(2025, 6, 4, 8, 0),
      photoName: 'hombre-con-musculos-posando-de-frente.png',
      observations: 'Entrenamiento de pecho',
    ),
    TrainingSession(
      activities: const [
        Activity(
          categoryId: 1,
          name: 'Burpees',
          description: '4 rondas de 30 segundos',
        ),
        Activity(
          categoryId: 1,
          name: 'Plancha',
          description: '3 series de 45 segundos',
        ),
      ],
      date: DateTime(2025, 6, 5, 17, 30),
      photoName: 'mujer-haciendo-ejercicio-con-mancuerna.png',
      observations: 'Circuito funcional',
    ),
    TrainingSession(
      activities: const [
        Activity(
          categoryId: 1,
          name: 'Correr 3 km',
          description: 'Ritmo moderado',
        ),
        Activity(
          categoryId: 1,
          name: 'Saltos de cuerda',
          description: '3 series de 2 minutos',
        ),
      ],
      date: DateTime(2025, 6, 6, 7, 0),
      photoName: 'hombre-trotando.png',
      observations: 'Trote matutino',
    ),
    TrainingSession(
      activities: const [
        Activity(
          categoryId: 1,
          name: 'Press de banca',
          description: '3 series de 10 repeticiones',
        ),
        Activity(
          categoryId: 1,
          name: 'Correr 2 km',
          description: 'Calentamiento activo',
        ),
        Activity(
          categoryId: 1,
          name: 'Remo con mancuerna',
          description: '3 series de 12 repeticiones',
        ),
      ],
      date: DateTime(2025, 6, 6, 19, 15),
      photoName: 'mujer-sonriendo-con-mancuerna.png',
      observations: 'Sesión completa de cuerpo',
    ),
    TrainingSession(
      activities: const [
        Activity(
          categoryId: 1,
          name: 'Estiramientos dinámicos',
          description: 'Rutina de 15 minutos',
        ),
      ],
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

  void _openCreateSession(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const TrainingSessionFormScreen(),
      ),
    );
  }

  void _openEditSession(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const TrainingSessionFormScreen(isEditing: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sessions = _testSessions;

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCreateSession(context),
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
        child: sessions.isEmpty
            ? const EmptyStateComponent(
                message: 'Sin sesiones registradas',
                description:
                    'Registra tu primera sesión de entrenamiento para comenzar con tu historial.',
              )
            : _SessionsList(
                groupedSessions: _groupByDay(sessions),
                onSessionTap: (_) => _openEditSession(context),
              ),
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
            onTap: () => onSessionTap(session),
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
