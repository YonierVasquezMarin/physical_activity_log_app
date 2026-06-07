import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:physical_activity_log_app/components/app_bottom_message.dart';
import 'package:physical_activity_log_app/components/button_component.dart';
import 'package:physical_activity_log_app/components/confirm_dialog_component.dart';
import 'package:physical_activity_log_app/models/activity.dart';
import 'package:physical_activity_log_app/models/training_session.dart';
import 'package:physical_activity_log_app/providers/auth_provider.dart';
import 'package:physical_activity_log_app/providers/training_sessions_provider.dart';
import 'package:physical_activity_log_app/theme/app_colors.dart';

class TrainingSessionFormScreen extends StatefulWidget {
  const TrainingSessionFormScreen({
    super.key,
    this.session,
  });

  final TrainingSession? session;

  bool get isEditing => session != null;

  @override
  State<TrainingSessionFormScreen> createState() =>
      _TrainingSessionFormScreenState();
}

class _ActivityFormEntry {
  _ActivityFormEntry({
    required this.categoryId,
    required this.nameController,
    required this.descriptionController,
  });

  int categoryId;
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  String? nameError;
}

class _TrainingSessionFormScreenState extends State<TrainingSessionFormScreen> {
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

  late final TextEditingController _observationsController;
  late DateTime _selectedDate;
  late List<_ActivityFormEntry> _activities;
  late final String _photoName;

  String? _dateError;
  String? _observationsError;
  String? _activitiesError;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();

    if (widget.isEditing) {
      final session = widget.session!;
      _observationsController = TextEditingController(
        text: session.observations,
      );
      _selectedDate = session.date.toLocal();
      _photoName = session.photoName;
      _activities = session.activities
          .map((activity) => _activityToEntry(activity))
          .toList();
    } else {
      _observationsController = TextEditingController();
      _selectedDate = DateTime.now();
      _photoName = '';
      _activities = [];
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCategories());
  }

  Future<void> _loadCategories() async {
    final authHeader = context.read<AuthProvider>().authorizationHeader;
    if (authHeader == null) return;

    try {
      await context.read<TrainingSessionsProvider>().loadCategories(
            authorizationHeader: authHeader,
          );
    } catch (error) {
      if (!mounted) return;

      AppBottomMessage.show(
        context,
        message: context
            .read<TrainingSessionsProvider>()
            .resolveErrorMessage(error),
        type: AppBottomMessageType.error,
      );
    }
  }

  List<({int id, String name})> _mapCategories(
    TrainingSessionsProvider provider,
  ) {
    return [
      for (final category in provider.categories)
        (id: category.id, name: category.name),
    ];
  }

  _ActivityFormEntry _activityToEntry(Activity activity) {
    return _ActivityFormEntry(
      categoryId: activity.categoryId,
      nameController: TextEditingController(text: activity.name),
      descriptionController: TextEditingController(text: activity.description),
    );
  }

  @override
  void dispose() {
    _observationsController.dispose();
    for (final entry in _activities) {
      entry.nameController.dispose();
      entry.descriptionController.dispose();
    }
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final month = _months[date.month - 1];
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '${date.day} de $month ${date.year} · $hour:$minute';
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.primary,
                ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDate),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.primary,
                ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime == null || !mounted) return;

    setState(() {
      _selectedDate = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
      _dateError = null;
    });
  }

  void _addActivity(List<({int id, String name})> categories) {
    if (categories.isEmpty) return;

    setState(() {
      _activities.add(
        _ActivityFormEntry(
          categoryId: categories.first.id,
          nameController: TextEditingController(),
          descriptionController: TextEditingController(),
        ),
      );
      _activitiesError = null;
    });
  }

  void _removeActivity(int index) {
    setState(() {
      final entry = _activities.removeAt(index);
      entry.nameController.dispose();
      entry.descriptionController.dispose();
      _activitiesError = null;
    });
  }

  void _updateActivityCategory(int index, int? categoryId) {
    if (categoryId == null) return;

    setState(() {
      _activities[index].categoryId = categoryId;
    });
  }

  bool _validateForm() {
    final observations = _observationsController.text.trim();
    var isValid = true;

    setState(() {
      _observationsError =
          observations.isEmpty ? 'Las observaciones son obligatorias' : null;
      _dateError = null;
      _activitiesError =
          _activities.isEmpty ? 'Agrega al menos una actividad' : null;

      for (final entry in _activities) {
        final name = entry.nameController.text.trim();
        entry.nameError = name.isEmpty ? 'El nombre es obligatorio' : null;
        if (entry.nameError != null) {
          isValid = false;
        }
      }
    });

    if (_observationsError != null || _activitiesError != null) {
      isValid = false;
    }

    return isValid;
  }

  List<Activity> _buildActivities() {
    return _activities
        .map(
          (entry) => Activity(
            categoryId: entry.categoryId,
            name: entry.nameController.text.trim(),
            description: entry.descriptionController.text.trim(),
          ),
        )
        .toList();
  }

  Future<void> _handleSubmit() async {
    if (!_validateForm()) return;

    final authHeader = context.read<AuthProvider>().authorizationHeader;
    if (authHeader == null) return;

    setState(() => _isSubmitting = true);

    try {
      final provider = context.read<TrainingSessionsProvider>();
      final activities = _buildActivities();
      final observations = _observationsController.text.trim();

      if (widget.isEditing) {
        await provider.updateSession(
          authorizationHeader: authHeader,
          id: widget.session!.id!,
          activities: activities,
          date: _selectedDate,
          photoName: _photoName,
          observations: observations,
        );
      } else {
        await provider.createSession(
          authorizationHeader: authHeader,
          activities: activities,
          date: _selectedDate,
          observations: observations,
        );
      }

      if (!mounted) return;

      AppBottomMessage.show(
        context,
        message: widget.isEditing
            ? 'Sesión actualizada correctamente.'
            : 'Sesión registrada correctamente.',
        type: AppBottomMessageType.success,
      );
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;

      AppBottomMessage.show(
        context,
        message: context
            .read<TrainingSessionsProvider>()
            .resolveErrorMessage(error),
        type: AppBottomMessageType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _handleDelete() async {
    final authHeader = context.read<AuthProvider>().authorizationHeader;
    if (authHeader == null || widget.session?.id == null) return;

    setState(() => _isSubmitting = true);

    try {
      await context.read<TrainingSessionsProvider>().deleteSession(
            authorizationHeader: authHeader,
            id: widget.session!.id!,
          );

      if (!mounted) return;

      AppBottomMessage.show(
        context,
        message: 'Sesión eliminada correctamente.',
        type: AppBottomMessageType.success,
      );
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;

      AppBottomMessage.show(
        context,
        message: context
            .read<TrainingSessionsProvider>()
            .resolveErrorMessage(error),
        type: AppBottomMessageType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionsProvider = context.watch<TrainingSessionsProvider>();
    final categories = _mapCategories(sessionsProvider);
    final isLoadingCategories =
        sessionsProvider.isLoadingCategories && categories.isEmpty;

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: AppBar(
        backgroundColor: AppColors.screenBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          color: AppColors.primary,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.isEditing ? 'Editar sesión' : 'Nueva sesión',
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          if (widget.isEditing)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                onPressed: _isSubmitting
                    ? null
                    : () => ConfirmDialogComponent.show(
                          context,
                          message: '¿Deseas eliminar esta sesión?',
                          onConfirm: _handleDelete,
                        ),
                icon: const Icon(Icons.delete_outline, size: 20),
                color: const Color(0xFFD32F2F),
                tooltip: 'Eliminar sesión',
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: isLoadingCategories
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionCard(
                      title: 'Fecha y hora',
                      icon: Icons.calendar_today_outlined,
                      child: _DateField(
                        label: _formatDate(_selectedDate),
                        errorText: _dateError,
                        onTap: _pickDate,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _SectionCard(
                      title: 'Observaciones',
                      icon: Icons.notes_outlined,
                      child: _ObservationsField(
                        controller: _observationsController,
                        errorText: _observationsError,
                        onChanged: (_) =>
                            setState(() => _observationsError = null),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _SectionCard(
                      title: 'Actividades',
                      icon: Icons.directions_run_outlined,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_activities.isEmpty)
                            const Padding(
                              padding: EdgeInsets.only(bottom: 12),
                              child: Text(
                                'Aún no hay actividades. Agrega la primera para esta sesión.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.bodyTextGrey,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          for (var i = 0; i < _activities.length; i++) ...[
                            if (i > 0) const SizedBox(height: 12),
                            _ActivityCard(
                              index: i,
                              entry: _activities[i],
                              categories: categories,
                              onCategoryChanged: (categoryId) =>
                                  _updateActivityCategory(i, categoryId),
                              onRemove: () => _removeActivity(i),
                              onNameChanged: () => setState(
                                () => _activities[i].nameError = null,
                              ),
                            ),
                          ],
                          if (_activitiesError != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              _activitiesError!,
                              style: const TextStyle(
                                color: Color(0xFFD32F2F),
                                fontSize: 12,
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          _AddActivityButton(
                            onPressed: categories.isEmpty || _isSubmitting
                                ? null
                                : () => _addActivity(categories),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: AbsorbPointer(
                absorbing: _isSubmitting || categories.isEmpty,
                child: Opacity(
                  opacity: _isSubmitting || categories.isEmpty ? 0.7 : 1,
                  child: ButtonComponent(
                    label: _isSubmitting
                        ? (widget.isEditing
                            ? 'Actualizando...'
                            : 'Guardando...')
                        : (widget.isEditing
                            ? 'Actualizar sesión'
                            : 'Guardar sesión'),
                    iconData: Icons.check,
                    fullWidth: true,
                    onPressed: _handleSubmit,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
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
                child: Icon(icon, size: 18, color: AppColors.primary),
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
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.onTap,
    this.errorText,
  });

  final String label;
  final VoidCallback onTap;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null && errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: hasError
                      ? const Color(0xFFD32F2F)
                      : AppColors.inputBorder,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.event,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.placeholderGrey,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Text(
            errorText!,
            style: const TextStyle(
              color: Color(0xFFD32F2F),
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }
}

class _ObservationsField extends StatelessWidget {
  const _ObservationsField({
    required this.controller,
    this.errorText,
    this.onChanged,
  });

  final TextEditingController controller;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null && errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: hasError
                  ? const Color(0xFFD32F2F)
                  : AppColors.inputBorder,
            ),
          ),
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            maxLines: 4,
            minLines: 3,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black87,
              height: 1.4,
            ),
            decoration: const InputDecoration(
              hintText: 'Describe tu entrenamiento...',
              hintStyle: TextStyle(
                color: AppColors.placeholderGrey,
                fontSize: 15,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Text(
            errorText!,
            style: const TextStyle(
              color: Color(0xFFD32F2F),
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({
    required this.index,
    required this.entry,
    required this.categories,
    required this.onCategoryChanged,
    required this.onRemove,
    required this.onNameChanged,
  });

  final int index;
  final _ActivityFormEntry entry;
  final List<({int id, String name})> categories;
  final ValueChanged<int?> onCategoryChanged;
  final VoidCallback onRemove;
  final VoidCallback onNameChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.screenBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Actividad ${index + 1}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.delete_outline, size: 20),
                color: const Color(0xFFD32F2F),
                tooltip: 'Eliminar actividad',
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Categoría',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.bodyTextGrey,
            ),
          ),
          const SizedBox(height: 6),
          _CategoryDropdown(
            value: entry.categoryId,
            categories: categories,
            onChanged: onCategoryChanged,
          ),
          const SizedBox(height: 12),
          const Text(
            'Nombre',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.bodyTextGrey,
            ),
          ),
          const SizedBox(height: 6),
          _ActivityTextField(
            controller: entry.nameController,
            hintText: 'Ej. Correr 5 km',
            errorText: entry.nameError,
            onChanged: onNameChanged,
          ),
          const SizedBox(height: 12),
          const Text(
            'Descripción',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.bodyTextGrey,
            ),
          ),
          const SizedBox(height: 6),
          _ActivityTextField(
            controller: entry.descriptionController,
            hintText: 'Ej. Trote continuo en parque',
            maxLines: 3,
            minLines: 2,
          ),
        ],
      ),
    );
  }
}

class _CategoryDropdown extends StatelessWidget {
  const _CategoryDropdown({
    required this.value,
    required this.categories,
    required this.onChanged,
  });

  final int value;
  final List<({int id, String name})> categories;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
          items: [
            for (final category in categories)
              DropdownMenuItem<int>(
                value: category.id,
                child: Text(
                  category.name,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
              ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _ActivityTextField extends StatelessWidget {
  const _ActivityTextField({
    required this.controller,
    required this.hintText,
    this.errorText,
    this.onChanged,
    this.maxLines = 1,
    this.minLines = 1,
  });

  final TextEditingController controller;
  final String hintText;
  final String? errorText;
  final VoidCallback? onChanged;
  final int maxLines;
  final int minLines;

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null && errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasError
                  ? const Color(0xFFD32F2F)
                  : AppColors.inputBorder,
            ),
          ),
          child: TextField(
            controller: controller,
            onChanged: onChanged != null ? (_) => onChanged!() : null,
            maxLines: maxLines,
            minLines: minLines,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black87,
              height: 1.4,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(
                color: AppColors.placeholderGrey,
                fontSize: 15,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Text(
            errorText!,
            style: const TextStyle(
              color: Color(0xFFD32F2F),
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }
}

class _AddActivityButton extends StatelessWidget {
  const _AddActivityButton({required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.35),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, size: 20, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                'Agregar actividad',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
