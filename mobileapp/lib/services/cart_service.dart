// services/cart_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/cart_model.dart';

class CartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user's cart
  Future<Cart?> getCart() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final query = await _firestore
          .collection('carts')
          .where('userId', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        return Cart.fromMap(query.docs.first.id, query.docs.first.data());
      }

      // Create new cart if doesn't exist
      return await createCart(user.uid);
    } catch (e) {
      print('Error getting cart: $e');
      return null;
    }
  }

  // Create new cart
  Future<Cart> createCart(String userId) async {
    try {
      final now = DateTime.now();
      final cartData = {
        'userId': userId,
        'items': [],
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
      };

      final docRef = await _firestore.collection('carts').add(cartData);

      return Cart(
        id: docRef.id,
        userId: userId,
        items: [],
        createdAt: now,
        updatedAt: now,
      );
    } catch (e) {
      print('Error creating cart: $e');
      rethrow;
    }
  }

  // Add item to cart
  Future<void> addToCart({
    required String productId,
    required String productName,
    required String productImage,
    required double price,
    String? size,
    String? color,
    int quantity = 1,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    try {
      // Get user's cart
      final cart = await getCart();
      if (cart == null) throw Exception('Cart not found');

      // Check if item already exists in cart
      final existingItemIndex = cart.items.indexWhere(
              (item) => item.productId == productId &&
              item.size == size &&
              item.color == color
      );

      final now = DateTime.now();
      List<CartItem> updatedItems = List.from(cart.items);

      if (existingItemIndex != -1) {
        // Update quantity if item exists
        updatedItems[existingItemIndex].quantity += quantity;
      } else {
        // Add new item
        final newItem = CartItem(
          productId: productId,
          productName: productName,
          productImage: productImage,
          price: price,
          size: size,
          color: color,
          quantity: quantity,
        );
        updatedItems.add(newItem);
      }

      // Update cart in Firestore
      await _firestore.collection('carts').doc(cart.id).update({
        'items': updatedItems.map((item) => item.toMap()).toList(),
        'updatedAt': Timestamp.fromDate(now),
      });

    } catch (e) {
      print('Error adding to cart: $e');
      rethrow;
    }
  }

  // Remove item from cart
  Future<void> removeFromCart(String productId, {String? size, String? color}) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final cart = await getCart();
      if (cart == null) return;

      final updatedItems = cart.items.where((item) {
        if (item.productId != productId) return true;
        if (size != null && item.size != size) return true;
        if (color != null && item.color != color) return true;
        return false;
      }).toList();

      await _firestore.collection('carts').doc(cart.id).update({
        'items': updatedItems.map((item) => item.toMap()).toList(),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

    } catch (e) {
      print('Error removing from cart: $e');
    }
  }

  // Update item quantity
  Future<void> updateQuantity(String productId, int newQuantity,
      {String? size, String? color}) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final cart = await getCart();
      if (cart == null) return;

      final updatedItems = cart.items.map((item) {
        if (item.productId == productId &&
            item.size == size &&
            item.color == color) {
          return CartItem(
            productId: item.productId,
            productName: item.productName,
            productImage: item.productImage,
            price: item.price,
            size: item.size,
            color: item.color,
            quantity: newQuantity,
          );
        }
        return item;
      }).toList();

      await _firestore.collection('carts').doc(cart.id).update({
        'items': updatedItems.map((item) => item.toMap()).toList(),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

    } catch (e) {
      print('Error updating quantity: $e');
    }
  }

  // Clear cart
  Future<void> clearCart() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final cart = await getCart();
      if (cart == null) return;

      await _firestore.collection('carts').doc(cart.id).update({
        'items': [],
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

    } catch (e) {
      print('Error clearing cart: $e');
    }
  }

  // Stream cart changes
  Stream<Cart?> streamCart() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _firestore
        .collection('carts')
        .where('userId', isEqualTo: user.uid)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      return Cart.fromMap(
          snapshot.docs.first.id,
          snapshot.docs.first.data()
      );
    });
  }
}