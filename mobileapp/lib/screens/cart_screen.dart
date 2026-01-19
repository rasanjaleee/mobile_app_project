// cart_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class CartItem {
  final String productId;
  final String productName;
  final String productImage;
  final double price;
  final String? size;
  final String? color;
  int quantity;

  CartItem({
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
    this.size,
    this.color,
    this.quantity = 1,
  });

  double get totalPrice => price * quantity;
}

class _CartScreenState extends State<CartScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _testUserId = "test_user_123"; // For testing without auth
  String? _cartId;
  List<CartItem> _cartItems = [];
  double _totalAmount = 0.0;
  int _itemCount = 0;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    try {
      final query = await _firestore
          .collection('carts')
          .where('userId', isEqualTo: _testUserId)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        _cartId = query.docs.first.id;
        _updateCartFromData(query.docs.first.data());
      } else {
        await _createCart();
      }
    } catch (e) {
      print('Error loading cart: $e');
    }
  }

  Future<void> _createCart() async {
    try {
      final now = DateTime.now();
      final cartData = {
        'userId': _testUserId,
        'items': [],
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
      };

      final docRef = await _firestore.collection('carts').add(cartData);
      _cartId = docRef.id;
      setState(() {
        _cartItems = [];
        _totalAmount = 0.0;
        _itemCount = 0;
      });
    } catch (e) {
      print('Error creating cart: $e');
    }
  }

  void _updateCartFromData(Map<String, dynamic> data) {
    final itemsData = data['items'] as List<dynamic>? ?? [];

    setState(() {
      _cartItems = itemsData.map((itemData) {
        return CartItem(
          productId: itemData['productId']?.toString() ?? '',
          productName: itemData['productName']?.toString() ?? 'Product',
          productImage: itemData['productImage']?.toString() ?? '',
          price: (itemData['price'] ?? 0.0).toDouble(),
          size: itemData['size']?.toString(),
          color: itemData['color']?.toString(),
          quantity: (itemData['quantity'] ?? 1).toInt(),
        );
      }).toList();

      _totalAmount = _cartItems.fold(0, (sum, item) => sum + item.totalPrice);
      _itemCount = _cartItems.fold(0, (sum, item) => sum + item.quantity);
    });
  }

  Future<void> _updateCartInFirestore() async {
    if (_cartId == null) return;

    try {
      final itemsData = _cartItems.map((item) {
        return {
          'productId': item.productId,
          'productName': item.productName,
          'productImage': item.productImage,
          'price': item.price,
          'size': item.size,
          'color': item.color,
          'quantity': item.quantity,
        };
      }).toList();

      await _firestore.collection('carts').doc(_cartId).update({
        'items': itemsData,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      _updateCartFromData({'items': itemsData});
    } catch (e) {
      print('Error updating cart: $e');
    }
  }

  Future<void> _addToCart({
    required String productId,
    required String productName,
    required String productImage,
    required double price,
    String? size,
    String? color,
    int quantity = 1,
  }) async {
    if (_cartId == null) {
      await _createCart();
    }

    final existingIndex = _cartItems.indexWhere(
          (item) => item.productId == productId &&
          item.size == size &&
          item.color == color,
    );

    if (existingIndex != -1) {
      _cartItems[existingIndex].quantity += quantity;
    } else {
      _cartItems.add(CartItem(
        productId: productId,
        productName: productName,
        productImage: productImage,
        price: price,
        size: size,
        color: color,
        quantity: quantity,
      ));
    }

    await _updateCartInFirestore();
  }

  Future<void> _removeFromCart(int index) async {
    if (index < 0 || index >= _cartItems.length) return;

    _cartItems.removeAt(index);
    await _updateCartInFirestore();
  }

  Future<void> _updateQuantity(int index, int newQuantity) async {
    if (index < 0 || index >= _cartItems.length) return;

    if (newQuantity <= 0) {
      await _removeFromCart(index);
    } else {
      _cartItems[index].quantity = newQuantity;
      await _updateCartInFirestore();
    }
  }

  Future<void> _clearCart() async {
    if (_cartId == null) return;

    try {
      await _firestore.collection('carts').doc(_cartId).update({
        'items': [],
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      setState(() {
        _cartItems = [];
        _totalAmount = 0.0;
        _itemCount = 0;
      });
    } catch (e) {
      print('Error clearing cart: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        actions: [
          if (_cartItems.isNotEmpty)
            IconButton(
              onPressed: _showClearCartDialog,
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Clear Cart',
            ),
        ],
      ),
      body: _cartItems.isEmpty ? _buildEmptyCart() : _buildCartWithItems(),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 20),
          const Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Add some products to get started',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Continue Shopping'),
          ),
        ],
      ),
    );
  }

  Widget _buildCartWithItems() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _cartItems.length,
            itemBuilder: (context, index) {
              final item = _cartItems[index];
              return _buildCartItem(item, index);
            },
          ),
        ),
        _buildCartSummary(),
      ],
    );
  }

  Widget _buildCartItem(CartItem item, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[200],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  item.productImage.isNotEmpty
                      ? item.productImage
                      : 'https://via.placeholder.com/80',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(child: Icon(Icons.image));
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  if (item.color != null || item.size != null)
                    Text(
                      '${item.color ?? ''} ${item.size ?? ''}'.trim(),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),

                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${item.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),

                      // Quantity Controls
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                _updateQuantity(index, item.quantity - 1);
                              },
                              icon: const Icon(Icons.remove, size: 18),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                item.quantity.toString(),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                _updateQuantity(index, item.quantity + 1);
                              },
                              icon: const Icon(Icons.add, size: 18),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Total: \$${item.totalPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Remove Button
            IconButton(
              onPressed: () {
                _showRemoveItemDialog(index, item.productName);
              },
              icon: const Icon(Icons.close, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Items',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                '$_itemCount',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Subtotal',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                '\$${_totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Shipping',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                'Calculated at checkout',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                _showCheckoutDialog();
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.green,
              ),
              child: const Text(
                'Proceed to Checkout',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRemoveItemDialog(int index, String productName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Item'),
        content: Text('Remove $productName from cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _removeFromCart(index);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Item removed from cart'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text(
              'Remove',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearCartDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cart'),
        content: const Text('Are you sure you want to clear all items from your cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _clearCart();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cart cleared'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text(
              'Clear',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showCheckoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Checkout'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Order Summary:'),
            const SizedBox(height: 10),
            Text('Items: $_itemCount'),
            Text('Total: \$${_totalAmount.toStringAsFixed(2)}'),
            const SizedBox(height: 20),
            const Text('Checkout feature will be implemented soon!'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Proceeding to checkout...'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }
}