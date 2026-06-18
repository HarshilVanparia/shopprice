import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../models/models.dart';
import '../../providers/category_provider_firestore.dart';
import '../../providers/item_provider_firestore.dart';
import '../../widgets/category_card.dart';
import '../../widgets/item_card.dart';
import '../search/search_screen.dart';
import 'category_products_screen.dart';

class WorkerHomeScreen extends StatefulWidget {
  const WorkerHomeScreen({super.key});

  @override
  State<WorkerHomeScreen> createState() => _WorkerHomeScreenState();
}

class _WorkerHomeScreenState extends State<WorkerHomeScreen> {
  SliverGridDelegateWithFixedCrossAxisCount _gridDelegate(
    double width, {
    required bool forCategories,
  }) {
    final crossAxisCount = width >= 1200
        ? 4
        : width >= 800
            ? 3
            : 2;

    final childAspectRatio = forCategories
        ? (width >= 1200
            ? 1.08
            : width >= 800
                ? 1.04
                : 1.0)
        : (width >= 1200
            ? 0.98
            : width >= 800
                ? 0.94
                : 0.88);

    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: crossAxisCount,
      childAspectRatio: childAspectRatio,
      crossAxisSpacing: AppSizes.paddingMedium,
      mainAxisSpacing: AppSizes.paddingMedium,
    );
  }

  Widget _sectionHeader(
    BuildContext context, {
    required String title,
    String? subtitle,
    Widget? action,
  }) {
    final subtitleWidgets = subtitle == null
        ? <Widget>[]
        : [
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.neutral,
                  ),
            ),
          ];
    final actionWidgets = action == null ? <Widget>[] : [action];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                ...subtitleWidgets,
              ],
            ),
          ),
          ...actionWidgets,
        ],
      ),
    );
  }

  Widget _buildHero(BuildContext context, int categoryCount, int itemCount) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.paddingMedium,
        AppSizes.paddingMedium,
        AppSizes.paddingMedium,
        0,
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.surface,
              AppColors.surfaceVariant.withValues(alpha: 0.75),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.divider),
        ),
        padding: const EdgeInsets.all(AppSizes.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.neutral,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'Browse products with a cleaner, faster layout.',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildStatChip(
                  context,
                  label: 'Categories',
                  value: categoryCount.toString(),
                  icon: Icons.category_outlined,
                ),
                _buildStatChip(
                  context,
                  label: 'Products',
                  value: itemCount.toString(),
                  icon: Icons.inventory_2_outlined,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.neutral,
                  fontWeight: FontWeight.w600,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }

  void _openCategory(Category category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryProductsScreen(category: category),
      ),
    );
  }

  void _openAllProducts() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SearchScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();
    final itemProvider = context.watch<ItemProvider>();

    final categories = categoryProvider.categories;
    final allItems = itemProvider.items;
    final displayedItems = allItems;

    final categoryCounts = <String, int>{};
    for (final item in allItems) {
      categoryCounts[item.category] = (categoryCounts[item.category] ?? 0) + 1;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('ShopPrice'),
        elevation: 0,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _buildHero(context, categories.length, allItems.length),
          ),
          SliverToBoxAdapter(
            child: const SizedBox(height: AppSizes.paddingLarge),
          ),
          SliverToBoxAdapter(
            child: _sectionHeader(
              context,
              title: AppStrings.categories,
              subtitle: 'Tap any category to open its product list.',
            ),
          ),
          SliverToBoxAdapter(
            child: const SizedBox(height: AppSizes.paddingMedium),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingMedium,
            ),
            sliver: SliverLayoutBuilder(
              builder: (context, constraints) {
                return SliverGrid(
                  gridDelegate: _gridDelegate(
                    constraints.crossAxisExtent,
                    forCategories: true,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final category = categories[index];
                      return CategoryCard(
                        icon: category.icon,
                        label: category.name,
                        itemCount: categoryCounts[category.name] ?? 0,
                        onTap: () => _openCategory(category),
                      );
                    },
                    childCount: categories.length,
                  ),
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: const SizedBox(height: AppSizes.paddingLarge),
          ),
          SliverToBoxAdapter(
            child: _sectionHeader(
              context,
              title: 'All Products',
              subtitle: 'Browse every available item in one place.',
              action: TextButton.icon(
                onPressed: _openAllProducts,
                icon: const Icon(Icons.arrow_forward),
                label: const Text(AppStrings.seeAll),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: const SizedBox(height: AppSizes.paddingMedium),
          ),
          if (displayedItems.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.paddingLarge),
                child: Center(
                  child: Text(
                    'No products available yet.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingMedium,
              ),
              sliver: SliverLayoutBuilder(
                builder: (context, constraints) {
                  return SliverGrid(
                    gridDelegate: _gridDelegate(
                      constraints.crossAxisExtent,
                      forCategories: false,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = displayedItems[index];
                        return ItemCard(
                          item: item,
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/item_detail',
                              arguments: item,
                            );
                          },
                        );
                      },
                      childCount: displayedItems.length,
                    ),
                  );
                },
              ),
            ),
          const SliverToBoxAdapter(
            child: SizedBox(height: AppSizes.paddingLarge),
          ),
        ],
      ),
    );
  }
}
