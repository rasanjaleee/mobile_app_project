import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'details.dart';
import 'checkout_screen.dart'; // Import from separate file

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCategory = "All";

  // Reference to categories collection
  final CollectionReference categoriesCollection =
  FirebaseFirestore.instance.collection('App-Category');

  // Reference to products collection
  final CollectionReference productsCollection =
  FirebaseFirestore.instance.collection('complete-flutter-app');

  // Reference to features collection
  final CollectionReference featuresCollection =
  FirebaseFirestore.instance.collection('Features');

  // Dynamic query for filtered products with case-insensitive matching
  Query get filteredProducts {
    if (selectedCategory == "All") {
      return productsCollection;
    } else {
      // We'll filter in memory for case-insensitive matching
      return productsCollection;
    }
  }

  // Query for features products
  Query get featuresProducts => featuresCollection.limit(10);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fixed Header
              _buildHeader(),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search Bar
                    _buildSearchBar(),
                    const SizedBox(height: 20),

                    // Categories Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Categories",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            _showAllCategories();
                          },
                          child: const Text(
                            "View All",
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Categories List (Horizontal Scroll)
                    _buildCategoriesList(),
                    const SizedBox(height: 20),

                    // Features Section (only show when no category is selected)
                    if (selectedCategory == "All") ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Features",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: const Text(
                              "View All",
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],
                  ],
                ),
              ),

              // Features Products (only show when no category is selected)
              if (selectedCategory == "All") ...[
                _buildFeaturesList(),
                const SizedBox(height: 20),
              ],

              // Main Products Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selectedCategory == "All"
                          ? "All Products"
                          : "$selectedCategory Products",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        _debugProductsStructure();
                      },
                      child: const Text(
                        "View All",
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Main Products List
              _buildProductsList(),
              const SizedBox(height: 20),

              // Test Button for navigation (remove after testing)
              Padding(
                padding: const EdgeInsets.all(15),
                child: ElevatedButton(
                  onPressed: () {
                    // Test navigation to checkout screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CheckoutScreen(
                          product: {
                            'id': 'test_product_123',
                            'name': 'Test Product',
                            'price': 29.99,
                            'image': 'https://via.placeholder.com/200',
                            'brand': 'Test Brand',
                            'category': 'Test Category',
                          },
                        ),
                      ),
                    );
                  },
                  child: const Text('TEST: Navigate to Checkout'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _debugProductsStructure() async {
    try {
      print('\n=== DEBUGGING PRODUCTS ===');

      // Get all products
      final productsSnapshot = await productsCollection.get();
      print('Total products: ${productsSnapshot.docs.length}');

      // Get all categories
      final categoriesSnapshot = await categoriesCollection.get();
      print('Total categories: ${categoriesSnapshot.docs.length}');

      if (productsSnapshot.docs.isEmpty) {
        print('NO PRODUCTS FOUND in complete-flutter-app!');
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('No Products'),
            content: const Text('No products found in complete-flutter-app collection.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return;
      }

      // Show first few products
      print('\n=== SAMPLE PRODUCTS ===');
      for (var i = 0; i < min(5, productsSnapshot.docs.length); i++) {
        var doc = productsSnapshot.docs[i];
        var data = doc.data() as Map<String, dynamic>? ?? {};
        print('\nProduct ${i + 1} (ID: ${doc.id}):');
        print('All fields: ${data.keys.toList()}');
        for (var key in data.keys) {
          print('  $key: ${data[key]}');
        }
      }

      // Check what categories exist in products
      Set<String> productCategories = {};
      for (var doc in productsSnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>? ?? {};
        String? category = data['category']?.toString();
        if (category != null && category.isNotEmpty) {
          productCategories.add(category);
        }
      }

      print('\n=== CATEGORIES FOUND IN PRODUCTS ===');
      if (productCategories.isEmpty) {
        print('NO CATEGORIES FOUND in any product!');
        print('Products need a "category" field.');
      } else {
        for (var category in productCategories) {
          print('- "$category"');
        }
      }

      // Check what categories are in App-Category
      List<String> appCategories = [];
      for (var doc in categoriesSnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>? ?? {};
        String categoryName = data['category']?.toString() ??
            data['name']?.toString() ??
            data['title']?.toString() ??
            doc.id;
        appCategories.add(categoryName);
      }

      print('\n=== CATEGORIES IN APP-CATEGORY ===');
      for (var category in appCategories) {
        print('- "$category"');
      }

      // Show in dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Products Debug'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Total Products: ${productsSnapshot.docs.length}'),
                Text('Total Categories: ${categoriesSnapshot.docs.length}'),
                const SizedBox(height: 10),

                if (productCategories.isNotEmpty) ...[
                  const Text('Categories in Products:'),
                  for (var category in productCategories)
                    Text('- "$category"'),
                  const SizedBox(height: 10),
                ] else ...[
                  const Text('⚠️ NO CATEGORIES IN PRODUCTS'),
                  const Text('Products need a "category" field'),
                  const SizedBox(height: 10),
                ],

                const Text('Categories in App-Category:'),
                for (var category in appCategories)
                  Text('- "$category"'),
                const SizedBox(height: 10),

                Text('Selected: "$selectedCategory"'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );

    } catch (e) {
      print('Debug error: $e');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text('Debug error: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  // Categories List Widget
  StreamBuilder<QuerySnapshot<Object?>> _buildCategoriesList() {
    return StreamBuilder(
      stream: categoriesCollection.snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: 100,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return SizedBox(
            height: 100,
            child: Center(child: Text('Error loading categories')),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return SizedBox(
            height: 100,
            child: Center(child: Text('No categories found')),
          );
        }

        return SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: snapshot.data!.docs.length + 1, // +1 for "All" category
            itemBuilder: (context, index) {
              // First item is "All" category
              if (index == 0) {
                return _buildCategoryItem("All", Iconsax.category, 0);
              }

              var categoryDoc = snapshot.data!.docs[index - 1];
              var data = categoryDoc.data() as Map<String, dynamic>? ?? {};

              // Try multiple field names for category name
              String categoryName = data['category']?.toString() ??
                  data['name']?.toString() ??
                  data['title']?.toString() ??
                  categoryDoc.id;

              return _buildCategoryItem(
                  categoryName, _getCategoryIcon(categoryName), index);
            },
          ),
        );
      },
    );
  }

  Widget _buildCategoryItem(String name, IconData icon, int index) {
    bool isSelected = selectedCategory == name;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = name;
        });
      },
      child: Container(
        width: 80,
        margin: EdgeInsets.only(right: 12, left: index == 0 ? 0 : 0),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue : Colors.blue[50],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.blue[700],
                size: 32,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.blue : Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsList() {
    return StreamBuilder(
      stream: filteredProducts.snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: 280,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return SizedBox(
            height: 280,
            child: Center(
              child: Text(
                'Error loading products',
                style: TextStyle(color: Colors.red),
              ),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return SizedBox(
            height: 280,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 50, color: Colors.grey[400]),
                  const SizedBox(height: 10),
                  Text(
                    selectedCategory == "All"
                        ? 'No products found'
                        : 'No products found for "$selectedCategory"',
                    style: TextStyle(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Check if products have matching "category" field',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      _debugProductsStructure();
                    },
                    child: const Text('Debug Products'),
                  ),
                ],
              ),
            ),
          );
        }

        // Filter products by category in memory (case-insensitive)
        List<DocumentSnapshot> filteredDocs;
        if (selectedCategory == "All") {
          filteredDocs = snapshot.data!.docs;
        } else {
          filteredDocs = snapshot.data!.docs.where((doc) {
            var data = doc.data() as Map<String, dynamic>? ?? {};
            String productCategory = data['category']?.toString() ?? '';
            return productCategory.trim().toLowerCase() ==
                selectedCategory.toLowerCase();
          }).toList();
        }

        if (filteredDocs.isEmpty) {
          return SizedBox(
            height: 280,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 50, color: Colors.grey[400]),
                  const SizedBox(height: 10),
                  Text(
                    'No products found for "$selectedCategory"',
                    style: TextStyle(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Make sure products have category: "$selectedCategory"',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      _debugProductsStructure();
                    },
                    child: const Text('Debug Products Structure'),
                  ),
                ],
              ),
            ),
          );
        }

        return SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            itemCount: filteredDocs.length,
            itemBuilder: (context, index) {
              var product = filteredDocs[index];
              return _buildProductCard(product);
            },
          ),
        );
      },
    );
  }

  Widget _buildFeaturesList() {
    return StreamBuilder(
      stream: featuresProducts.snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: 280,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return SizedBox(
            height: 280,
            child: Center(
              child: Text(
                'Error loading features',
                style: TextStyle(color: Colors.red),
              ),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return SizedBox(
            height: 280,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star, size: 50, color: Colors.grey[400]),
                  const SizedBox(height: 10),
                  Text(
                    'No features items',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          );
        }

        return SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var product = snapshot.data!.docs[index];
              return _buildProductCard(product);
            },
          ),
        );
      },
    );
  }

  Widget _buildProductCard(DocumentSnapshot product) {
    Map<String, dynamic>? nullableData = product.data() as Map<String, dynamic>?;
    Map<String, dynamic> data = nullableData ?? {};

    String productName = data['name']?.toString() ?? 'Product Name';
    String productBrand = data['brand']?.toString() ?? 'Brand';
    String productCategory = data['category']?.toString() ?? 'Category';

    double productPrice = 0.0;
    if (data['price'] != null) {
      dynamic priceData = data['price'];
      if (priceData is num) {
        productPrice = priceData.toDouble();
      } else if (priceData is String) {
        productPrice = double.tryParse(priceData) ?? 0.0;
      }
    }

    String imageUrl = '';
    if (data['imageUrl'] is String && data['imageUrl'] != null) {
      imageUrl = data['imageUrl']!;
    } else if (data['images'] is List && data['images'].isNotEmpty) {
      dynamic imagesData = data['images'];
      if (imagesData is List && imagesData.isNotEmpty) {
        imageUrl = imagesData[0]?.toString() ?? '';
      }
    }

    return GestureDetector(
      onTap: () {
        // Navigate to DetailsScreen when product card is tapped
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailsScreen(
              productId: product.id,
              initialProductData: data,
            ),
          ),
        );
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: imageUrl.isNotEmpty
                      ? Image.network(
                    imageUrl,
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 140,
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.image,
                          size: 50,
                          color: Colors.grey,
                        ),
                      );
                    },
                  )
                      : Container(
                    height: 140,
                    color: Colors.grey[200],
                    child: const Icon(
                      Icons.image,
                      size: 50,
                      color: Colors.grey,
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () {
                      // Handle favorite button separately to prevent navigation
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Added $productName to favorites'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.favorite_border,
                        size: 18,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    productBrand,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    productCategory,
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${productPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      // ADD BUY NOW BUTTON HERE
                      Row(
                        children: [
                          // Add to Cart Button (existing)
                          GestureDetector(
                            onTap: () {
                              // Handle add to cart separately to prevent navigation
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('$productName added to cart'),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.shopping_cart, // Using Material icon
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8), // Space between buttons
                          // Buy Now Button (NEW)
                          GestureDetector(
                            onTap: () {
                              // DEBUG: Print to console
                              print('=== BUY NOW BUTTON CLICKED ===');
                              print('Product: $productName');
                              print('Price: $productPrice');
                              print('Image URL: $imageUrl');

                              // Navigate to CheckoutScreen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CheckoutScreen(
                                    product: {
                                      'id': product.id,
                                      'name': productName,
                                      'price': productPrice,
                                      'image': imageUrl,
                                      'brand': productBrand,
                                      'category': productCategory,
                                    },
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.green, // Green color for Buy Now
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.shopping_bag, // Using Material icon
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAllCategories() {
    // Simple implementation - you can expand this
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Showing all categories for: $selectedCategory'),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[700]!, Colors.blue[500]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.location_on,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Deliver to',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
              Text(
                'New York',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(
              Icons.notifications,
              color: Colors.white,
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: TextField(
        decoration: InputDecoration(
          filled: true,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            icon: const Icon(Icons.settings, color: Colors.blue),
            onPressed: () {},
          ),
          fillColor: Colors.white,
          hintText: "Search Products...",
          hintStyle: const TextStyle(color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'electronics':
        return Icons.computer;
      case 'fashion':
      case 'clothing':
      case 'fashions':
        return Icons.person;
      case 'sports':
        return Icons.sports;
      case 'shoes':
        return Icons.shopping_bag;
      case 'accessories':
        return Icons.watch;
      case 'jewelry':
        return Icons.diamond;
      case 'bags':
        return Icons.work;
      case 'books':
        return Icons.book;
      case 'toys':
        return Icons.toys;
      case 'automotive':
        return Icons.directions_car;
      default:
        return Icons.category;
    }
  }
}