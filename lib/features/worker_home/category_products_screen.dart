import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/theme/app_colors.dart';
import '../../models/models.dart';
import '../../providers/item_provider_firestore.dart';
import '../../widgets/item_card.dart';

class CategoryProductsScreen extends StatelessWidget {
  final Category category;

  const CategoryProductsScreen({super.key, required this.category});

  List<Item> _itemsForCategory(List<Item> items) {
    return items.where((item) => item.category == category.name).toList();
  }

  SliverGridDelegateWithFixedCrossAxisCount _gridDelegate(double width) {
    final crossAxisCount = width >= 1200
        ? 4
        : width >= 800
            ? 3
            : 2;

    final childAspectRatio = width >= 1200
        ? 0.98
        : width >= 800
            ? 0.94
            : 0.88;

    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: crossAxisCount,
      childAspectRatio: childAspectRatio,
      crossAxisSpacing: AppSizes.paddingMedium,
      mainAxisSpacing: AppSizes.paddingMedium,
    );
  }

  Widget _hero(BuildContext context, int itemCount) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.paddingMedium,
        AppSizes.paddingMedium,
        AppSizes.paddingMedium,
        0,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSizes.paddingLarge),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                category.icon,
                style: const TextStyle(fontSize: 26),
              ),
            ),
            const SizedBox(width: AppSizes.paddingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$itemCount products available in this category.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.neutral,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _itemsForCategory(context.watch<ItemProvider>().items);

    return Scaffold(
      appBar: AppBar(
        title: Text(category.name),
        elevation: 0,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _hero(context, items.length)),
          SliverToBoxAdapter(
            child: const SizedBox(height: AppSizes.paddingLarge),
          ),
          if (items.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.paddingLarge),
                child: Center(
                  child: Text(
                    'No items found in ${category.name}.',
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
                    gridDelegate: _gridDelegate(constraints.crossAxisExtent),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = items[index];
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
                      childCount: items.length,
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