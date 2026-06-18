import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_sizes.dart';
import '../../models/models.dart';
import '../../providers/category_provider_firestore.dart';
import '../../providers/item_provider_firestore.dart';
import '../../widgets/item_card.dart';
import '../../widgets/search_bar.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late TextEditingController _searchController;
  List<Item> _searchResults = [];
  final List<String> _selectedFilters = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    setState(() => _isSearching = true);

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        final itemProvider = context.read<ItemProvider>();
        setState(() {
          if (query.isEmpty) {
            _searchResults = itemProvider.items;
          } else {
            _searchResults = itemProvider.items
                .where((item) =>
                    item.name.toLowerCase().contains(query.toLowerCase()) ||
                    item.brand.toLowerCase().contains(query.toLowerCase()))
                .toList();
          }
          _isSearching = false;
        });
      }
    });
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusXLarge),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final categoryProvider = context.watch<CategoryProvider>();
            final categories = categoryProvider.categories;
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppStrings.filters,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: AppSizes.paddingMedium),
                    Text(
                      'Categories',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSizes.paddingSmall),
                    Wrap(
                      spacing: AppSizes.paddingSmall,
                      runSpacing: AppSizes.paddingSmall,
                      children: [
                        ...categories.map(
                          (category) => FilterChip(
                            label: Text(category.name),
                            selected: _selectedFilters.contains(category.id),
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedFilters.add(category.id);
                                } else {
                                  _selectedFilters.remove(category.id);
                                }
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.paddingLarge),
                    Text(
                      AppStrings.sort,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSizes.paddingSmall),
                    Wrap(
                      spacing: AppSizes.paddingSmall,
                      runSpacing: AppSizes.paddingSmall,
                      children: [
                        'Price: Low to High',
                        'Price: High to Low',
                        'Rating',
                      ]
                          .map(
                            (sort) => FilterChip(
                              label: Text(sort),
                              onSelected: (selected) {
                                Navigator.pop(context);
                              },
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: AppSizes.paddingXLarge),
                    SizedBox(
                      width: double.infinity,
                      height: AppSizes.minimumTouchTarget,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Apply Filters'),
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingMedium),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final itemProvider = context.watch<ItemProvider>();
    final visibleResults = _searchController.text.trim().isEmpty
        ? itemProvider.items
        : _searchResults;

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Products'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            child: CustomSearchBar(
              controller: _searchController,
              hintText: AppStrings.searchProducts,
              onChanged: _performSearch,
            ),
          ),
          // Filter Chip
          if (_searchController.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingMedium,
              ),
              child: SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    FilterChip(
                      label: const Text(AppStrings.filters),
                      onSelected: (_) => _showFilterBottomSheet(),
                      avatar: const Icon(Icons.filter_list, size: 18),
                    ),
                  ],
                ),
              ),
            ),
          // Results
          Expanded(
            child: _isSearching
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : visibleResults.isEmpty
                        ? Center(
                            child: Text(
                              _searchController.text.trim().isEmpty
                                  ? 'No products available yet'
                                  : AppStrings.noResults,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.all(
                              AppSizes.paddingMedium,
                            ),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.7,
                              crossAxisSpacing: AppSizes.paddingMedium,
                              mainAxisSpacing: AppSizes.paddingMedium,
                            ),
                            itemCount: visibleResults.length,
                            itemBuilder: (context, index) {
                              final item = visibleResults[index];
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
                          ),
          ),
        ],
      ),
    );
  }
}
