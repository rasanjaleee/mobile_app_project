// settings_screen.dart
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Settings state variables
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _autoPlayVideos = false;
  bool _saveHistory = true;
  bool _biometricLogin = false;
  bool _dataSaver = false;

  String _selectedLanguage = 'English';
  String _selectedCurrency = 'USD';
  String _selectedTheme = 'System Default';

  double _cacheSize = 256.5; // in MB

  final List<String> _languages = [
    'English',
    'Spanish',
    'French',
    'German',
    'Chinese',
    'Japanese',
    'Arabic',
  ];

  final List<String> _currencies = [
    'USD',
    'EUR',
    'GBP',
    'INR',
    'JPY',
    'CAD',
    'AUD',
  ];

  final List<String> _themes = [
    'System Default',
    'Light',
    'Dark',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Profile Section
            _buildUserProfileSection(),
            const SizedBox(height: 24),

            // Account Settings
            _buildSectionHeader('Account Settings'),
            _buildSettingsCard([
              _buildSettingsItem(
                icon: Iconsax.profile_circle,
                title: 'Edit Profile',
                subtitle: 'Update your personal information',
                trailing: const Icon(Iconsax.arrow_right_3, size: 18),
                onTap: _editProfile,
              ),
              _buildDivider(),
              _buildSettingsItem(
                icon: Iconsax.location,
                title: 'Shipping Addresses',
                subtitle: 'Manage your delivery addresses',
                trailing: const Icon(Iconsax.arrow_right_3, size: 18),
                onTap: _manageAddresses,
              ),
              _buildDivider(),
              _buildSettingsItem(
                icon: Iconsax.card,
                title: 'Payment Methods',
                subtitle: 'Add or remove payment options',
                trailing: const Icon(Iconsax.arrow_right_3, size: 18),
                onTap: _managePayments,
              ),
              _buildDivider(),
              _buildSettingsItem(
                icon: Iconsax.gift,
                title: 'My Orders',
                subtitle: 'View your order history',
                trailing: const Icon(Iconsax.arrow_right_3, size: 18),
                onTap: _viewOrders,
              ),
              _buildDivider(),
              _buildSettingsItem(
                icon: Iconsax.heart,
                title: 'Wishlist',
                subtitle: 'View your saved items',
                trailing: const Icon(Iconsax.arrow_right_3, size: 18),
                onTap: _viewWishlist,
              ),
            ]),
            const SizedBox(height: 24),

            // App Preferences
            _buildSectionHeader('App Preferences'),
            _buildSettingsCard([
              _buildSettingsItem(
                icon: Iconsax.notification,
                title: 'Notifications',
                subtitle: 'Push notifications and alerts',
                trailing: Switch(
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  },
                  activeColor: Colors.blue,
                ),
                onTap: () {
                  setState(() {
                    _notificationsEnabled = !_notificationsEnabled;
                  });
                },
              ),
              _buildDivider(),
              _buildSettingsItem(
                icon: Iconsax.moon,
                title: 'Dark Mode',
                subtitle: 'Toggle dark theme',
                trailing: Switch(
                  value: _darkModeEnabled,
                  onChanged: (value) {
                    setState(() {
                      _darkModeEnabled = value;
                    });
                  },
                  activeColor: Colors.blue,
                ),
                onTap: () {
                  setState(() {
                    _darkModeEnabled = !_darkModeEnabled;
                  });
                },
              ),
              _buildDivider(),
              _buildSettingsItem(
                icon: Iconsax.global,
                title: 'Language',
                subtitle: _selectedLanguage,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _selectedLanguage,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Iconsax.arrow_right_3, size: 18),
                  ],
                ),
                onTap: _changeLanguage,
              ),
              _buildDivider(),
              _buildSettingsItem(
                icon: Iconsax.dollar_circle,
                title: 'Currency',
                subtitle: _selectedCurrency,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _selectedCurrency,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Iconsax.arrow_right_3, size: 18),
                  ],
                ),
                onTap: _changeCurrency,
              ),
            ]),
            const SizedBox(height: 24),

            // Privacy & Security
            _buildSectionHeader('Privacy & Security'),
            _buildSettingsCard([
              _buildSettingsItem(
                icon: Iconsax.lock,
                title: 'Privacy Policy',
                subtitle: 'Read our privacy policy',
                trailing: const Icon(Iconsax.arrow_right_3, size: 18),
                onTap: _viewPrivacyPolicy,
              ),
              _buildDivider(),
              _buildSettingsItem(
                icon: Iconsax.shield_tick,
                title: 'Terms of Service',
                subtitle: 'Read our terms and conditions',
                trailing: const Icon(Iconsax.arrow_right_3, size: 18),
                onTap: _viewTerms,
              ),
              _buildDivider(),
              _buildSettingsItem(
                icon: Iconsax.finger_cricle,
                title: 'Biometric Login',
                subtitle: 'Use fingerprint or face ID',
                trailing: Switch(
                  value: _biometricLogin,
                  onChanged: (value) {
                    setState(() {
                      _biometricLogin = value;
                    });
                  },
                  activeColor: Colors.blue,
                ),
                onTap: () {
                  setState(() {
                    _biometricLogin = !_biometricLogin;
                  });
                },
              ),
              _buildDivider(),
              _buildSettingsItem(
                icon: Iconsax.eye,
                title: 'Data Saver',
                subtitle: 'Reduce data usage',
                trailing: Switch(
                  value: _dataSaver,
                  onChanged: (value) {
                    setState(() {
                      _dataSaver = value;
                    });
                  },
                  activeColor: Colors.blue,
                ),
                onTap: () {
                  setState(() {
                    _dataSaver = !_dataSaver;
                  });
                },
              ),
            ]),
            const SizedBox(height: 24),

            // App Settings
            _buildSectionHeader('App Settings'),
            _buildSettingsCard([
              _buildSettingsItem(
                icon: Iconsax.video,
                title: 'Auto-play Videos',
                subtitle: 'Play videos automatically',
                trailing: Switch(
                  value: _autoPlayVideos,
                  onChanged: (value) {
                    setState(() {
                      _autoPlayVideos = value;
                    });
                  },
                  activeColor: Colors.blue,
                ),
                onTap: () {
                  setState(() {
                    _autoPlayVideos = !_autoPlayVideos;
                  });
                },
              ),
              _buildDivider(),
              _buildSettingsItem(
                icon: Iconsax.save_2,
                title: 'Save History',
                subtitle: 'Save your browsing history',
                trailing: Switch(
                  value: _saveHistory,
                  onChanged: (value) {
                    setState(() {
                      _saveHistory = value;
                    });
                  },
                  activeColor: Colors.blue,
                ),
                onTap: () {
                  setState(() {
                    _saveHistory = !_saveHistory;
                  });
                },
              ),
              _buildDivider(),
              _buildSettingsItem(
                icon: Iconsax.trash,
                title: 'Clear Cache',
                subtitle: '${_cacheSize.toStringAsFixed(1)} MB',
                trailing: TextButton(
                  onPressed: _clearCache,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  ),
                  child: const Text(
                    'Clear',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
                onTap: _clearCache,
              ),
            ]),
            const SizedBox(height: 24),

            // Support Section
            _buildSectionHeader('Support'),
            _buildSettingsCard([
              _buildSettingsItem(
                icon: Iconsax.headphone,
                title: 'Help Center',
                subtitle: 'Get help with common issues',
                trailing: const Icon(Iconsax.arrow_right_3, size: 18),
                onTap: _openHelpCenter,
              ),
              _buildDivider(),
              _buildSettingsItem(
                icon: Iconsax.message_question,
                title: 'Contact Us',
                subtitle: 'Get in touch with our team',
                trailing: const Icon(Iconsax.arrow_right_3, size: 18),
                onTap: _contactUs,
              ),
              _buildDivider(),
              _buildSettingsItem(
                icon: Iconsax.star,
                title: 'Rate App',
                subtitle: 'Rate us on app store',
                trailing: const Icon(Iconsax.arrow_right_3, size: 18),
                onTap: _rateApp,
              ),
              _buildDivider(),
              _buildSettingsItem(
                icon: Iconsax.share,
                title: 'Share App',
                subtitle: 'Share with friends',
                trailing: const Icon(Iconsax.arrow_right_3, size: 18),
                onTap: _shareApp,
              ),
            ]),
            const SizedBox(height: 24),

            // About Section
            _buildSectionHeader('About'),
            _buildSettingsCard([
              _buildSettingsItem(
                icon: Iconsax.info_circle,
                title: 'About App',
                subtitle: 'Version 1.0.0 (Build 123)',
                trailing: const Icon(Iconsax.arrow_right_3, size: 18),
                onTap: _aboutApp,
              ),
            ]),
            const SizedBox(height: 32),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _showLogoutDialog,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Log Out',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Delete Account Button
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: _showDeleteAccountDialog,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Delete Account',
                  style: TextStyle(
                    fontSize: 14,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // App Version
            Center(
              child: Text(
                'ShopApp v1.0.0',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildUserProfileSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // User Avatar
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(35),
            ),
            child: const Icon(
              Iconsax.profile_circle,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'John Doe',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'john.doe@example.com',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Gold Member',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '12 Orders',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Edit Button
          IconButton(
            onPressed: _editProfile,
            icon: const Icon(Iconsax.edit_2, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: Colors.blue,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),

            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Trailing Widget
            trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 1,
        color: Colors.grey[200],
      ),
    );
  }

  // Action Methods
  void _editProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit Profile feature coming soon!')),
    );
  }

  void _manageAddresses() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Address management coming soon!')),
    );
  }

  void _managePayments() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Payment management coming soon!')),
    );
  }

  void _viewOrders() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Order history coming soon!')),
    );
  }

  void _viewWishlist() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Wishlist coming soon!')),
    );
  }

  void _changeLanguage() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Language',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ListView.builder(
                shrinkWrap: true,
                itemCount: _languages.length,
                itemBuilder: (context, index) {
                  final language = _languages[index];
                  return ListTile(
                    leading: const Icon(Iconsax.global),
                    title: Text(language),
                    trailing: _selectedLanguage == language
                        ? const Icon(Iconsax.tick_circle, color: Colors.green)
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedLanguage = language;
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _changeCurrency() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Currency',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ListView.builder(
                shrinkWrap: true,
                itemCount: _currencies.length,
                itemBuilder: (context, index) {
                  final currency = _currencies[index];
                  return ListTile(
                    leading: const Icon(Iconsax.dollar_circle),
                    title: Text(currency),
                    trailing: _selectedCurrency == currency
                        ? const Icon(Iconsax.tick_circle, color: Colors.green)
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedCurrency = currency;
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _viewPrivacyPolicy() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening Privacy Policy...')),
    );
  }

  void _viewTerms() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening Terms of Service...')),
    );
  }

  void _clearCache() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: Text('Clear ${_cacheSize.toStringAsFixed(1)} MB of cache?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _cacheSize = 0.0;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cache cleared successfully'),
                  backgroundColor: Colors.green,
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

  void _openHelpCenter() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening Help Center...')),
    );
  }

  void _contactUs() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Contact us at support@shopapp.com')),
    );
  }

  void _rateApp() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening app store...')),
    );
  }

  void _shareApp() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sharing app...')),
    );
  }

  void _aboutApp() {
    showAboutDialog(
      context: context,
      applicationName: 'ShopApp',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2024 ShopApp. All rights reserved.',
      children: [
        const SizedBox(height: 20),
        const Text('Your one-stop shopping destination'),
        const SizedBox(height: 10),
        Text(
          'Features:\n• Browse thousands of products\n• Secure payment options\n• Fast delivery\n• 24/7 customer support',
          style: TextStyle(color: Colors.grey[600]),
        ),
      ],
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Logged out successfully'),
                  backgroundColor: Colors.green,
                ),
              );
              // In real app: FirebaseAuth.instance.signOut();
            },
            child: const Text(
              'Log Out',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'This action cannot be undone. All your data will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account deletion requested'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: const Text(
              'Delete Account',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}