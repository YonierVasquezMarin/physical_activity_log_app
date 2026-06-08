import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:physical_activity_log_app/components/app_bottom_message.dart';
import 'package:physical_activity_log_app/components/button_component.dart';
import 'package:physical_activity_log_app/components/confirm_dialog_component.dart';
import 'package:physical_activity_log_app/models/category.dart';
import 'package:physical_activity_log_app/providers/auth_provider.dart';
import 'package:physical_activity_log_app/providers/categories_provider.dart';
import 'package:physical_activity_log_app/providers/training_sessions_provider.dart';
import 'package:physical_activity_log_app/theme/app_colors.dart';

class CategoryFormScreen extends StatefulWidget {
  const CategoryFormScreen({
    super.key,
    this.category,
  });

  final Category? category;

  bool get isEditing => category != null;

  @override
  State<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends State<CategoryFormScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;

  String? _nameError;
  String? _descriptionError;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _descriptionController = TextEditingController(
      text: widget.category?.description ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _syncCategoriesWithSessions() {
    final categories = context.read<CategoriesProvider>().categories;
    context.read<TrainingSessionsProvider>().syncCategories(categories);
  }

  bool _validateForm() {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();

    final nameError =
        name.isEmpty ? 'Ingresa un nombre para la categoría.' : null;
    final descriptionError = description.isEmpty
        ? 'Ingresa una descripción para la categoría.'
        : null;

    setState(() {
      _nameError = nameError;
      _descriptionError = descriptionError;
    });

    return nameError == null && descriptionError == null;
  }

  Future<void> _handleSubmit() async {
    if (!_validateForm()) return;

    final authHeader = context.read<AuthProvider>().authorizationHeader;
    if (authHeader == null) return;

    setState(() => _isSubmitting = true);

    try {
      final provider = context.read<CategoriesProvider>();
      final name = _nameController.text.trim();
      final description = _descriptionController.text.trim();

      if (widget.isEditing) {
        await provider.updateCategory(
          authorizationHeader: authHeader,
          id: widget.category!.id,
          name: name,
          description: description,
        );
      } else {
        await provider.createCategory(
          authorizationHeader: authHeader,
          name: name,
          description: description,
        );
      }

      if (!mounted) return;

      _syncCategoriesWithSessions();

      AppBottomMessage.show(
        context,
        message: widget.isEditing
            ? 'Categoría actualizada correctamente.'
            : 'Categoría creada correctamente.',
        type: AppBottomMessageType.success,
      );
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;

      AppBottomMessage.show(
        context,
        message: context.read<CategoriesProvider>().resolveErrorMessage(error),
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
    if (authHeader == null || widget.category == null) return;

    setState(() => _isSubmitting = true);

    try {
      await context.read<CategoriesProvider>().deleteCategory(
            authorizationHeader: authHeader,
            id: widget.category!.id,
          );

      if (!mounted) return;

      _syncCategoriesWithSessions();

      AppBottomMessage.show(
        context,
        message: 'Categoría eliminada correctamente.',
        type: AppBottomMessageType.success,
      );
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;

      AppBottomMessage.show(
        context,
        message: context.read<CategoriesProvider>().resolveErrorMessage(error),
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
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.isEditing ? 'Editar categoría' : 'Nueva categoría',
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
                          message: '¿Deseas eliminar esta categoría?',
                          onConfirm: _handleDelete,
                        ),
                icon: const Icon(Icons.delete_outline, size: 20),
                color: const Color(0xFFD32F2F),
                tooltip: 'Eliminar categoría',
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
                      title: 'Nombre',
                      icon: Icons.label_outline,
                      child: _CategoryTextField(
                        controller: _nameController,
                        hintText: 'Ej. Cardio intenso',
                        errorText: _nameError,
                        onChanged: (_) => setState(() => _nameError = null),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _SectionCard(
                      title: 'Descripción',
                      icon: Icons.notes_outlined,
                      child: _CategoryTextField(
                        controller: _descriptionController,
                        hintText: 'Describe brevemente la categoría...',
                        errorText: _descriptionError,
                        maxLines: 4,
                        minLines: 3,
                        onChanged: (_) =>
                            setState(() => _descriptionError = null),
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
                            : 'Crear categoría'),
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

class _CategoryTextField extends StatelessWidget {
  const _CategoryTextField({
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
