import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/category_provider.dart';
import '../providers/auth_provider.dart';
import 'templates/template_list_screen.dart';
import '../widgets/white_scaffold.dart';
import './profile_screen.dart'; // Import ProfileScreen

class HomeScreen extends ConsumerStatefulWidget {
  static const routeName = '/home';
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;
  String _searchQuery = '';
  final List<String> _filters = ['New', 'Popular', 'Trending'];
  String _selectedFilter = 'New';
  final TextEditingController _searchController = TextEditingController();

  void _onTab(int index) {
    setState(() => _selectedIndex = index);
  }

  void _onDrawerTap(int index) {
    Navigator.of(context).pop(); // Close drawer
    if (index == 3) {
      // Branding
      // TODO: Implement Branding screen navigation
      return;
    }
    if (index == 4) {
      // Logout
      ref.read(authProvider.notifier).logout();
      Navigator.of(context).pushReplacementNamed('/login');
      return;
    }
    setState(() => _selectedIndex = index);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    return WhiteScaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: _selectedIndex != 0 ? 50 : 150,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App logo and name
            Row(
              children: [
                Image.asset(
                  'assets/images/logo/logo1.png',
                  width: 36,
                  height: 36,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.image),
                ),
                const SizedBox(width: 12),
              ],
            ),
            if (_selectedIndex == 0) ...[
              const SizedBox(height: 12),
              // Search bar
              TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  hintText: 'Search templates or categories',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                ),
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              // Filter chips
              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _filters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final filter = _filters[i];
                    return ChoiceChip(
                      label: Text(filter),
                      selected: _selectedFilter == filter,
                      onSelected: (selected) {
                        setState(() => _selectedFilter = filter);
                      },
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
      body: _selectedIndex == 3
          ? ProfileScreen() // Use const for ProfileScreen to ensure correct context
          : _selectedIndex == 0
              ? categoriesAsync.when(
                  data: (categories) {
                    final filteredCategories = categories.where((cat) =>
                      _searchQuery.isEmpty ||
                      (cat['name'] ?? '').toLowerCase().contains(_searchQuery.toLowerCase())
                    ).toList();
                    return ListView(
                      padding: const EdgeInsets.only(top: 8, bottom: 80),
                      children: [
                        // Expandable category list
                        ...filteredCategories.map((category) => Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                category['category'] ?? '',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Builder(
                                builder: (context) {
                                  final subcategories = category['subcategories'] ?? [];
                                  if (subcategories.isEmpty) {
                                    return const Padding(
                                      padding: EdgeInsets.all(16),
                                      child: Text('No subcategories.'),
                                    );
                                  }
                                  return SizedBox(
                                    height: 120,
                                    child: ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: subcategories.length,
                                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                                      itemBuilder: (context, j) {
                                        final subcat = subcategories[j];
                                        return GestureDetector(
                                          onTap: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (_) => TemplateListScreen(
                                                  categoryName: category['name'] ?? '',
                                                  subcategoryName: subcat['name'] ?? '',
                                                ),
                                              ),
                                            );
                                          },
                                          child: SizedBox(
                                            width: 100,
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                ClipRRect(
                                                  borderRadius: BorderRadius.circular(12),
                                                  child: subcat['thumbnailUrl'] != null
                                                      ? CachedNetworkImage(
                                                    imageUrl: subcat['thumbnailUrl'],
                                                    width: 80,
                                                    height: 80,
                                                    fit: BoxFit.cover,
                                                    errorWidget: (context, url, error) =>
                                                    const Icon(Icons.broken_image),
                                                  )
                                                      : Container(
                                                    width: 80,
                                                    height: 80,
                                                    color: Colors.grey[300],
                                                    child: const Icon(Icons.broken_image),
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                SizedBox(
                                                  width: 80,
                                                  child: Text(
                                                    subcat['name'] ?? '',
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(fontSize: 10),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        )),
                        // Optional: Category Grid
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 1.2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            itemCount: filteredCategories.length,
                            itemBuilder: (context, i) {
                              final cat = filteredCategories[i];
                              return GestureDetector(
                                onTap: () {
                                  // Quick access to category
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => TemplateListScreen(
                                        categoryName: cat['name'] ?? '',
                                        subcategoryName: '',
                                      ),
                                    ),
                                  );
                                },
                                child: Card(
                                  elevation: 2,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      cat['iconUrl'] != null
                                          ? CachedNetworkImage(
                                              imageUrl: cat['iconUrl'],
                                              width: 48,
                                              height: 48,
                                              errorWidget: (context, url, error) => const Icon(Icons.image),
                                            )
                                          : const Icon(Icons.category, size: 48),
                                      const SizedBox(height: 8),
                                      Text(
                                        cat['name'] ?? '',
                                        style: const TextStyle(fontWeight: FontWeight.w500),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, st) => Center(child: Text('Failed to load categories')),
                )
              : const Center(child: Text('Coming soon...')),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                // TODO: Implement upload custom template flow
              },
              icon: const Icon(Icons.upload_file),
              label: const Text('Upload Your Own Template'),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        backgroundColor: Colors.white70,
        onTap: _onTab,
        type: BottomNavigationBarType.fixed, // ensures all labels show
        selectedItemColor: Colors.black87,     // active tab color
        unselectedItemColor: Colors.black45,    // inactive tab color
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.design_services),
            label: 'My Designs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.branding_watermark),
            label: 'Branding',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
