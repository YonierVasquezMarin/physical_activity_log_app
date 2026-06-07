import 'package:flutter/material.dart';
import 'package:physical_activity_log_app/components/app_bottom_message.dart';
import 'package:physical_activity_log_app/components/button_component.dart';
import 'package:physical_activity_log_app/models/training_session.dart';
import 'package:physical_activity_log_app/theme/app_colors.dart';

class TrainingSessionFormScreen extends StatefulWidget {
  const TrainingSessionFormScreen({
    super.key,
    this.session,
  });

  final TrainingSession? session;

  bool get isViewMode => session != null;

  @override
  State<TrainingSessionFormScreen> createState() =>
      _TrainingSessionFormScreenState();
}

class _TrainingSessionFormScreenState extends State<TrainingSessionFormScreen> {
  static const _categories = <({int id, String name, IconData icon})>[
    (id: 1, name: 'Fuerza', icon: Icons.fitness_center),
    (id: 2, name: 'Cardio', icon: Icons.directions_run),
    (id: 3, name: 'Funcional', icon: Icons.sports_gymnastics),
    (id: 4, name: 'Movilidad', icon: Icons.accessibility_new),
    (id: 5, name: 'Flexibilidad', icon: Icons.self_improvement),
    (id: 6, name: 'HIIT', icon: Icons.bolt),
    (id: 7, name: 'Resistencia', icon: Icons.timer),
    (id: 8, name: 'CrossFit', icon: Icons.sports_martial_arts),
    (id: 9, name: 'Yoga', icon: Icons.spa),
    (id: 10, name: 'Natación', icon: Icons.pool),
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

  late final TextEditingController _observationsController;
  late DateTime _selectedDate;
  late Set<int> _selectedCategoryIds;

  String? _dateError;
  String? _observationsError;
  String? _categoriesError;

  @override
  void initState() {
    super.initState();
    final session = widget.session;
    _observationsController = TextEditingController(
      text: session?.observations ?? '',
    );
    _selectedDate = session?.date ?? DateTime.now();
    _selectedCategoryIds = session?.activityIds.toSet() ?? {};
  }

  @override
  void dispose() {
    _observationsController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final month = _months[date.month - 1];
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '${date.day} de $month ${date.year} · $hour:$minute';
  }

  String _categoryName(int id) {
    return _categories
        .where((category) => category.id == id)
        .map((category) => category.name)
        .firstOrNull ?? 'Categoría $id';
  }

  Future<void> _pickDate() async {
    if (widget.isViewMode) return;

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

  void _toggleCategory(int id) {
    if (widget.isViewMode) return;

    setState(() {
      if (_selectedCategoryIds.contains(id)) {
        _selectedCategoryIds.remove(id);
      } else {
        _selectedCategoryIds.add(id);
      }
      _categoriesError = null;
    });
  }

  bool _validateForm() {
    final observations = _observationsController.text.trim();
    var isValid = true;

    setState(() {
      _observationsError =
          observations.isEmpty ? 'Las observaciones son obligatorias' : null;
      _dateError = null;
      _categoriesError = _selectedCategoryIds.isEmpty
          ? 'Selecciona al menos una categoría'
          : null;
    });

    if (_observationsError != null || _categoriesError != null) {
      isValid = false;
    }

    return isValid;
  }

  void _handleSubmit() {
    if (!_validateForm()) return;

    AppBottomMessage.show(
      context,
      message: 'Formulario válido. El registro estará disponible próximamente.',
      type: AppBottomMessageType.success,
    );
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
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.isViewMode ? 'Detalle de sesión' : 'Nueva sesión',
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
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
                      title: 'Fecha y hora',
                      icon: Icons.calendar_today_outlined,
                      child: _DateField(
                        label: _formatDate(_selectedDate),
                        errorText: _dateError,
                        onTap: _pickDate,
                        readOnly: widget.isViewMode,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _SectionCard(
                      title: 'Observaciones',
                      icon: Icons.notes_outlined,
                      child: _ObservationsField(
                        controller: _observationsController,
                        errorText: _observationsError,
                        readOnly: widget.isViewMode,
                        onChanged: widget.isViewMode
                            ? null
                            : (_) => setState(() => _observationsError = null),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _SectionCard(
                      title: 'Categorías',
                      icon: Icons.category_outlined,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (widget.isViewMode)
                            _ViewCategoriesList(
                              categoryIds: widget.session!.activityIds,
                              categoryName: _categoryName,
                            )
                          else
                            _CategoryGrid(
                              categories: _categories,
                              selectedIds: _selectedCategoryIds,
                              onToggle: _toggleCategory,
                            ),
                          if (_categoriesError != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              _categoriesError!,
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
            if (!widget.isViewMode)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: ButtonComponent(
                  label: 'Guardar sesión',
                  iconData: Icons.check,
                  fullWidth: true,
                  onPressed: _handleSubmit,
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
    required this.readOnly,
    this.errorText,
  });

  final String label;
  final VoidCallback onTap;
  final bool readOnly;
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
            onTap: readOnly ? null : onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: readOnly
                    ? AppColors.screenBackground
                    : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: hasError
                      ? const Color(0xFFD32F2F)
                      : AppColors.inputBorder,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.event,
                    color: readOnly
                        ? AppColors.bodyTextGrey
                        : AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 15,
                        color: readOnly
                            ? AppColors.bodyTextGrey
                            : Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (!readOnly)
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
    required this.readOnly,
    this.errorText,
    this.onChanged,
  });

  final TextEditingController controller;
  final bool readOnly;
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
            color: readOnly ? AppColors.screenBackground : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: hasError
                  ? const Color(0xFFD32F2F)
                  : AppColors.inputBorder,
            ),
          ),
          child: TextField(
            controller: controller,
            readOnly: readOnly,
            onChanged: onChanged,
            maxLines: 4,
            minLines: 3,
            style: TextStyle(
              fontSize: 15,
              color: readOnly ? AppColors.bodyTextGrey : Colors.black87,
              height: 1.4,
            ),
            decoration: InputDecoration(
              hintText: 'Describe tu entrenamiento...',
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

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({
    required this.categories,
    required this.selectedIds,
    required this.onToggle,
  });

  final List<({int id, String name, IconData icon})> categories;
  final Set<int> selectedIds;
  final ValueChanged<int> onToggle;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final category in categories)
          _CategoryChip(
            label: category.name,
            icon: category.icon,
            isSelected: selectedIds.contains(category.id),
            onTap: () => onToggle(category.id),
          ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.12)
                : AppColors.screenBackground,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.inputBorder,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? AppColors.primary : AppColors.bodyTextGrey,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? AppColors.primary : AppColors.bodyTextGrey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ViewCategoriesList extends StatelessWidget {
  const _ViewCategoriesList({
    required this.categoryIds,
    required this.categoryName,
  });

  final List<int> categoryIds;
  final String Function(int id) categoryName;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final id in categoryIds)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              categoryName(id),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
      ],
    );
  }
}
