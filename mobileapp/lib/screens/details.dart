// details.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'cart_screen.dart'; // Import cart screen

class DetailsScreen extends StatelessWidget {
  final String productId;
  final Map<String, dynamic>? initialProductData;

  const DetailsScreen({
    super.key,
    required this.productId,
    this.initialProductData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Added to wishlist'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            icon: const Icon(Icons.favorite_border),
          ),
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Share feature coming soon!'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            icon: const Icon(Icons.share),
          ),
          // Cart icon in app bar
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('carts')
                .where('userId', isEqualTo: "test_user_123")
                .snapshots(),
            builder: (context, snapshot) {
              int cartItemCount = 0;

              if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                final cartData = snapshot.data!.docs.first.data() as Map<String, dynamic>;
                final items = cartData['items'] as List<dynamic>? ?? [];
                cartItemCount = items.fold<int>(0, (sum, item) {
                  final quantity = item['quantity'];
                  if (quantity is int) {
                    return sum + quantity;
                  } else if (quantity is num) {
                    return sum + quantity.toInt();
                  }
                  return sum + 1; // default quantity if not specified
                });
              }

              return Stack(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CartScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.shopping_cart_outlined),
                  ),
                  if (cartItemCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          cartItemCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('complete-flutter-app')
            .doc(productId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return _buildDetailsContent(initialProductData ?? {}, context);
          }

          final productData = snapshot.data!.data() as Map<String, dynamic>? ?? {};
          return _buildDetailsContent(productData, context);
        },
      ),
    );
  }

  Widget _buildDetailsContent(Map<String, dynamic> data, BuildContext context) {
    // Safely extract product details with null checks
    String productName = data['name']?.toString() ?? 'Product Name';
    String productBrand = data['brand']?.toString() ?? 'Brand';
    String productCategory = data['category']?.toString() ?? 'Category';
    String description = data['description']?.toString() ?? 'No description available';

    // Additional details with null safety
    String? productCode = data['code']?.toString();
    String? productSize = data['size']?.toString();
    String? productMaterial = data['material']?.toString();
    String? productWeight = data['weight']?.toString();
    String? productDimensions = data['dimensions']?.toString();
    double? rating = data['rating'] is num ? (data['rating'] as num).toDouble() : null;
    int? reviewCount = data['reviewCount'] is num ? (data['reviewCount'] as num).toInt() : null;
    int? stockQuantity = data['stock'] is num ? (data['stock'] as num).toInt() : null;

    // Price handling with null safety
    double productPrice = 0.0;
    double? originalPrice;
    double discountPercent = 0.0;

    if (data['price'] != null) {
      dynamic priceData = data['price'];
      if (priceData is num) {
        productPrice = priceData.toDouble();
      } else if (priceData is String) {
        productPrice = double.tryParse(priceData) ?? 0.0;
      }
    }

    // Check for discount/original price
    if (data['originalPrice'] != null) {
      dynamic originalPriceData = data['originalPrice'];
      if (originalPriceData is num) {
        originalPrice = originalPriceData.toDouble();
        if (originalPrice > 0 && productPrice > 0) {
          discountPercent = ((originalPrice - productPrice) / originalPrice * 100).roundToDouble();
        }
      }
    }

    // Colors handling with null safety
    List<dynamic> colours = [];
    if (data['colours'] is List) {
      colours = data['colours']!;
    }

    // Images handling with null safety
    List<String> images = [];
    if (data['images'] is List) {
      for (var item in data['images']!) {
        if (item != null) {
          images.add(item.toString());
        }
      }
    } else if (data['imageUrl'] != null) {
      images.add(data['imageUrl']!.toString());
    } else if (data['image'] != null) {
      images.add(data['image']!.toString());
    }

    String mainImage = images.isNotEmpty ? images[0] : '';

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image with indicator
          _buildImageSection(mainImage, images, context),

          // Product Info
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stock Status
                if (stockQuantity != null) ...[
                  _buildStockStatus(stockQuantity),
                  const SizedBox(height: 12),
                ],

                // Name and Brand
                Text(
                  productName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Brand and Category row
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'By $productBrand',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        productCategory,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue[800],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Rating if available
                if (rating != null) ...[
                  _buildRatingSection(rating, reviewCount),
                  const SizedBox(height: 16),
                ],

                // Price Section
                _buildPriceSection(productPrice, originalPrice, discountPercent),

                const SizedBox(height: 24),

                // Description
                _buildDescriptionSection(description),

                const SizedBox(height: 24),

                // Product Details Table
                _buildProductDetailsTable(
                  productCode: productCode,
                  size: productSize,
                  material: productMaterial,
                  weight: productWeight,
                  dimensions: productDimensions,
                ),

                const SizedBox(height: 24),

                // Colours Section
                if (colours.isNotEmpty)
                  _buildColorsSection(colours),

                const SizedBox(height: 24),

                // Additional Images
                if (images.length > 1)
                  _buildAdditionalImagesSection(images),

                const SizedBox(height: 30),

                // Action Buttons - Pass the data for cart functionality
                _buildActionButtons(productName, stockQuantity, data, context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection(String mainImage, List<String> images, BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 350,
          color: Colors.grey[100],
          child: mainImage.isNotEmpty
              ? GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Full screen image viewer coming soon!'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            child: Image.network(
              mainImage,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Icon(
                    Icons.image_not_supported,
                    size: 80,
                    color: Colors.grey,
                  ),
                );
              },
            ),
          )
              : const Center(
            child: Icon(
              Icons.image,
              size: 80,
              color: Colors.grey,
            ),
          ),
        ),
        // Image counter indicator
        if (images.length > 1)
          Positioned(
            bottom: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '1/${images.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStockStatus(int stockQuantity) {
    Color statusColor;
    String statusText;

    if (stockQuantity > 10) {
      statusColor = Colors.green;
      statusText = 'In Stock ($stockQuantity available)';
    } else if (stockQuantity > 0) {
      statusColor = Colors.orange;
      statusText = 'Low Stock ($stockQuantity left)';
    } else {
      statusColor = Colors.red;
      statusText = 'Out of Stock';
    }

    return Row(
      children: [
        Icon(
          Icons.circle,
          color: statusColor,
          size: 12,
        ),
        const SizedBox(width: 8),
        Text(
          statusText,
          style: TextStyle(
            color: statusColor,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildRatingSection(double rating, int? reviewCount) {
    return Row(
      children: [
        // Star rating
        Row(
          children: List.generate(5, (index) {
            return Icon(
              index < rating.floor() ? Icons.star : Icons.star_border,
              color: Colors.amber,
              size: 20,
            );
          }),
        ),
        const SizedBox(width: 8),
        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (reviewCount != null) ...[
          const SizedBox(width: 8),
          Text(
            '($reviewCount reviews)',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPriceSection(double price, double? originalPrice, double discountPercent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '\$${price.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            if (originalPrice != null && originalPrice > price) ...[
              const SizedBox(width: 12),
              Text(
                '\$${originalPrice.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey[500],
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${discountPercent.toStringAsFixed(0)}% OFF',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.red[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        if (originalPrice != null && originalPrice > price)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'You save \$${(originalPrice - price).toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.green[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDescriptionSection(String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: const TextStyle(
            fontSize: 16,
            height: 1.5,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildProductDetailsTable({
    String? productCode,
    String? size,
    String? material,
    String? weight,
    String? dimensions,
  }) {
    final details = <Map<String, String?>>[
      {'label': 'Product Code', 'value': productCode},
      {'label': 'Size', 'value': size},
      {'label': 'Material', 'value': material},
      {'label': 'Weight', 'value': weight},
      {'label': 'Dimensions', 'value': dimensions},
    ].where((detail) => detail['value'] != null && detail['value']!.isNotEmpty).toList();

    if (details.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Product Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: details.map((detail) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        detail['label']!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        detail['value']!,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildColorsSection(List<dynamic> colours) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Available Colors',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: colours.map<Widget>((color) {
            if (color == null) return const SizedBox();

            final colorName = color.toString();
            return Column(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: _getColorFromString(colorName),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey[300]!, width: 2),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  colorName,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAdditionalImagesSection(List<String> images) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'More Images',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: images.length,
            itemBuilder: (context, index) {
              final imageUrl = images[index];
              if (imageUrl.isEmpty) return const SizedBox();

              return GestureDetector(
                onTap: () {
                  // TODO: Make this image the main image
                },
                child: Container(
                  width: 100,
                  height: 100,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.broken_image, size: 30),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(String productName, int? stockQuantity,
      Map<String, dynamic> data, BuildContext context) {
    final isOutOfStock = stockQuantity != null && stockQuantity <= 0;
    final firestore = FirebaseFirestore.instance;
    final testUserId = "test_user_123";

    // State for quantity
    int quantity = 1;

    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          children: [
            Row(
              children: [
                // Quantity Selector
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            if (quantity > 1) {
                              setState(() {
                                quantity--;
                              });
                            }
                          },
                          icon: const Icon(Icons.remove),
                          iconSize: 20,
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              quantity.toString(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              quantity++;
                            });
                          },
                          icon: const Icon(Icons.add),
                          iconSize: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Add to Cart Button
                Expanded(
                  flex: 3,
                  child: ElevatedButton(
                    onPressed: isOutOfStock
                        ? null
                        : () async {
                      try {
                        // Extract product data
                        String productId = data['id']?.toString() ?? '';
                        if (productId.isEmpty) {
                          productId = productId;
                        }

                        String imageUrl = '';
                        if (data['images'] is List && data['images'].isNotEmpty) {
                          imageUrl = data['images'][0]?.toString() ?? '';
                        } else if (data['imageUrl'] != null) {
                          imageUrl = data['imageUrl'].toString();
                        } else if (data['image'] != null) {
                          imageUrl = data['image'].toString();
                        }

                        double price = 0.0;
                        if (data['price'] != null) {
                          dynamic priceData = data['price'];
                          if (priceData is num) {
                            price = priceData.toDouble();
                          } else if (priceData is String) {
                            price = double.tryParse(priceData) ?? 0.0;
                          }
                        }

                        // Find or create cart
                        final cartQuery = await firestore
                            .collection('carts')
                            .where('userId', isEqualTo: testUserId)
                            .limit(1)
                            .get();

                        String? cartId;
                        List<dynamic> currentItems = [];

                        if (cartQuery.docs.isNotEmpty) {
                          cartId = cartQuery.docs.first.id;
                          currentItems = cartQuery.docs.first.data()['items'] ?? [];
                        } else {
                          // Create new cart
                          final now = DateTime.now();
                          final newCart = await firestore.collection('carts').add({
                            'userId': testUserId,
                            'items': [],
                            'createdAt': Timestamp.fromDate(now),
                            'updatedAt': Timestamp.fromDate(now),
                          });
                          cartId = newCart.id;
                        }

                        // Check if item already exists
                        bool itemExists = false;
                        List<dynamic> updatedItems = [];

                        for (var item in currentItems) {
                          if (item['productId'] == productId) {
                            itemExists = true;
                            updatedItems.add({
                              ...item,
                              'quantity': (item['quantity'] ?? 1) + quantity,
                            });
                          } else {
                            updatedItems.add(item);
                          }
                        }

                        if (!itemExists) {
                          updatedItems.add({
                            'productId': productId,
                            'productName': productName,
                            'productImage': imageUrl,
                            'price': price,
                            'quantity': quantity,
                          });
                        }

                        // Update cart
                        await firestore.collection('carts').doc(cartId).update({
                          'items': updatedItems,
                          'updatedAt': Timestamp.fromDate(DateTime.now()),
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Added $productName to cart'),
                            backgroundColor: Colors.green,
                            duration: const Duration(seconds: 2),
                            action: SnackBarAction(
                              label: 'View Cart',
                              textColor: Colors.white,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const CartScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: ${e.toString()}'),
                            backgroundColor: Colors.red,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: isOutOfStock ? Colors.grey : Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      isOutOfStock ? 'Out of Stock' : 'Add to Cart',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Buy Now Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: isOutOfStock
                    ? null
                    : () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Proceeding to buy $productName'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(
                    color: isOutOfStock ? Colors.grey : Colors.blue,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Buy Now',
                  style: TextStyle(
                    fontSize: 16,
                    color: isOutOfStock ? Colors.grey : Colors.blue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Color _getColorFromString(String colorName) {
    final colorMap = {
      'Purple': Colors.purple,
      'Blue': Colors.blue,
      'Black': Colors.black,
      'Pink': Colors.pink,
      'Green': Colors.green,
      'Red': Colors.red,
      'Yellow': Colors.yellow,
      'Orange': Colors.orange,
      'White': Colors.white,
      'Gray': Colors.grey,
      'Brown': Colors.brown,
      'Cyan': Colors.cyan,
      'Teal': Colors.teal,
      'Indigo': Colors.indigo,
      'Amber': Colors.amber,
      'Lime': Colors.lime,
      'Deep Purple': Colors.deepPurple,
      'Light Blue': Colors.lightBlue,
      'Light Green': Colors.lightGreen,
      'Deep Orange': Colors.deepOrange,
    };

    return colorMap[colorName] ?? Colors.grey;
  }
}