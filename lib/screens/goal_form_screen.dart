import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:physical_activity_log_app/components/app_bottom_message.dart';
import 'package:physical_activity_log_app/components/button_component.dart';
import 'package:physical_activity_log_app/components/confirm_dialog_component.dart';
import 'package:physical_activity_log_app/models/goal.dart';
import 'package:physical_activity_log_app/providers/auth_provider.dart';
import 'package:physical_activity_log_app/providers/goals_provider.dart';
import 'package:physical_activity_log_app/theme/app_colors.dart';

class GoalFormScreen extends StatefulWidget {
  const GoalFormScreen({
    super.key,
    this.goal,
  });

  final Goal? goal;

  bool get isEditing => goal != null;

  @override
  State<GoalFormScreen> createState() => _GoalFormScreenState();
}

class _GoalFormScreenState extends State<GoalFormScreen> {
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

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late DateTime _startDate;
  late DateTime _endDate;

  String? _titleError;
  String? _descriptionError;
  String? _dateRangeError;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.goal?.title ?? '');
    _descriptionController = TextEditingController(
      text: widget.goal?.description ?? '',
    );

    if (widget.isEditing) {
      _startDate = widget.goal!.startDate.toLocal();
      _endDate = widget.goal!.endDate.toLocal();
    } else {
      final now = DateTime.now();
      _startDate = DateTime(now.year, now.month, now.day);
      _endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final month = _months[date.month - 1];
    return '${date.day} de $month ${date.year}';
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
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

    if (picked == null || !mounted) return;

    setState(() {
      _startDate = DateTime(picked.year, picked.month, picked.day);
      if (_endDate.isBefore(_startDate)) {
        _endDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          23,
          59,
          59,
        );
      }
      _dateRangeError = null;
    });
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate.isBefore(_startDate) ? _startDate : _endDate,
      firstDate: _startDate,
      lastDate: DateTime(2035),
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

    if (picked == null || !mounted) return;

    setState(() {
      _endDate = DateTime(
        picked.year,
        picked.month,
        picked.day,
        23,
        59,
        59,
      );
      _dateRangeError = null;
    });
  }

  bool _validateForm() {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    final titleError =
        title.isEmpty ? 'Ingresa un título para la meta.' : null;
    final descriptionError =
        description.isEmpty ? 'Ingresa una descripción para la meta.' : null;
    final dateRangeError =
        _endDate.isBefore(_startDate) ? 'La fecha fin debe ser posterior a la fecha inicio.' : null;

    setState(() {
      _titleError = titleError;
      _descriptionError = descriptionError;
      _dateRangeError = dateRangeError;
    });

    return titleError == null &&
        descriptionError == null &&
        dateRangeError == null;
  }

  Future<void> _handleSubmit() async {
    if (!_validateForm()) return;

    final authHeader = context.read<AuthProvider>().authorizationHeader;
    if (authHeader == null) return;

    setState(() => _isSubmitting = true);

    try {
      final provider = context.read<GoalsProvider>();
      final title = _titleController.text.trim();
      final description = _descriptionController.text.trim();

      if (widget.isEditing) {
        await provider.updateGoal(
          authorizationHeader: authHeader,
          id: widget.goal!.id,
          title: title,
          description: description,
          startDate: _startDate,
          endDate: _endDate,
        );
      } else {
        await provider.createGoal(
          authorizationHeader: authHeader,
          title: title,
          description: description,
          startDate: _startDate,
          endDate: _endDate,
        );
      }

      if (!mounted) return;

      AppBottomMessage.show(
        context,
        message: widget.isEditing
            ? 'Meta actualizada correctamente.'
            : 'Meta creada correctamente.',
        type: AppBottomMessageType.success,
      );
      Navigator.of(context, rootNavigator: true).pop(true);
    } catch (error) {
      if (!mounted) return;

      AppBottomMessage.show(
        context,
        message: context.read<GoalsProvider>().resolveErrorMessage(error),
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
    if (authHeader == null || widget.goal == null) return;

    setState(() => _isSubmitting = true);

    try {
      await context.read<GoalsProvider>().deleteGoal(
            authorizationHeader: authHeader,
            id: widget.goal!.id,
          );

      if (!mounted) return;

      AppBottomMessage.show(
        context,
        message: 'Meta eliminada correctamente.',
        type: AppBottomMessageType.success,
      );
      Navigator.of(context, rootNavigator: true).pop(true);
    } catch (error) {
      if (!mounted) return;

      AppBottomMessage.show(
        context,
        message: context.read<GoalsProvider>().resolveErrorMessage(error),
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
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: AppBar(
        backgroundColor: AppColors.screenBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          color: AppColors.primary,
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
        ),
        title: Text(
          widget.isEditing ? 'Editar meta' : 'Nueva meta',
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
                          message: '¿Deseas eliminar esta meta?',
                          onConfirm: _handleDelete,
                        ),
                icon: const Icon(Icons.delete_outline, size: 20),
                color: const Color(0xFFD32F2F),
                tooltip: 'Eliminar meta',
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionCard(
                      title: 'Título',
                      icon: Icons.flag_outlined,
                      child: _GoalTextField(
                        controller: _titleController,
                        hintText: 'Ej. Correr 30 km en el mes',
                        errorText: _titleError,
                        onChanged: (_) => setState(() => _titleError = null),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _SectionCard(
                      title: 'Descripción',
                      icon: Icons.notes_outlined,
                      child: _GoalTextField(
                        controller: _descriptionController,
                        hintText: 'Describe tu objetivo...',
                        errorText: _descriptionError,
                        maxLines: 4,
                        minLines: 3,
                        onChanged: (_) =>
                            setState(() => _descriptionError = null),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _SectionCard(
                      title: 'Periodo',
                      icon: Icons.date_range_outlined,
                      child: Column(
                        children: [
                          _DatePickerTile(
                            label: 'Fecha inicio',
                            value: _formatDate(_startDate),
                            onTap: _pickStartDate,
                          ),
                          const SizedBox(height: 12),
                          _DatePickerTile(
                            label: 'Fecha fin',
                            value: _formatDate(_endDate),
                            onTap: _pickEndDate,
                          ),
                          if (_dateRangeError != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              _dateRangeError!,
                              style: const TextStyle(
                                color: Color(0xFFD32F2F),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: AbsorbPointer(
                absorbing: _isSubmitting,
                child: Opacity(
                  opacity: _isSubmitting ? 0.7 : 1,
                  child: ButtonComponent(
                    label: _isSubmitting
                        ? (widget.isEditing ? 'Guardando...' : 'Creando...')
                        : (widget.isEditing
                            ? 'Guardar cambios'
                            : 'Crear meta'),
                    iconData:
                        widget.isEditing ? Icons.save_outlined : Icons.add,
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
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

class _GoalTextField extends StatelessWidget {
  const _GoalTextField({
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
  final ValueChanged<String>? onChanged;
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
              contentPadding: const EdgeInsets.all(16),
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

class _DatePickerTile extends StatelessWidget {
  const _DatePickerTile({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.screenBackground,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.bodyTextGrey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.calendar_today_outlined,
                size: 18,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
