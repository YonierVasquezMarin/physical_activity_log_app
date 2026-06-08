import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:physical_activity_log_app/components/empty_state_component.dart';
import 'package:physical_activity_log_app/models/category.dart';
import 'package:physical_activity_log_app/providers/auth_provider.dart';
import 'package:physical_activity_log_app/providers/categories_provider.dart';
import 'package:physical_activity_log_app/providers/training_sessions_provider.dart';
import 'package:physical_activity_log_app/screens/category_form_screen.dart';
import 'package:physical_activity_log_app/theme/app_colors.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCategories());
  }

  Future<void> _loadCategories() async {
    final authHeader = context.read<AuthProvider>().authorizationHeader;
    if (authHeader == null) return;

    await context.read<CategoriesProvider>().loadCategories(
          authorizationHeader: authHeader,
        );

    if (!mounted) return;

    context.read<TrainingSessionsProvider>().syncCategories(
          context.read<CategoriesProvider>().categories,
        );
  }

  Future<void> _openCreateCategory() async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => const CategoryFormScreen(),
      ),
    );

    if (changed == true && mounted) {
      await _loadCategories();
    }
  }

  Future<void> _openEditCategory(Category category) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => CategoryFormScreen(category: category),
      ),
    );

    if (changed == true && mounted) {
      await _loadCategories();
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesProvider = context.watch<CategoriesProvider>();
    final categories = categoriesProvider.categories;

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
        title: const Text(
          'Categorías',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: categoriesProvider.isLoading ? null : _openCreateCategory,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add),
        label: const Text(
          'Nueva categoría',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: _buildBody(categoriesProvider, categories),
      ),
    );
  }

  Widget _buildBody(CategoriesProvider provider, List<Category> categories) {
    if (provider.isLoading && categories.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (provider.error != null && categories.isEmpty) {
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
                onPressed: _loadCategories,
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

    if (categories.isEmpty) {
      return const EmptyStateComponent(
        message: 'Sin categorías registradas',
        description:
            'Crea tu primera categoría para organizar tus actividades físicas.',
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadCategories,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final category = categories[index];
          return _CategoryCard(
            category: category,
            onTap: () => _openEditCategory(category),
          );
        },
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.onTap,
  });

  final Category category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.category_outlined,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    if (category.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        category.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.bodyTextGrey,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ],
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
    );
  }
}
