// ============================================================================
// EcoKart - Eco-Friendly Marketplace (Flutter + Provider)
// ============================================================================

import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'secrets.dart';

// ----------------------------------------------------------------------------
// Theme & settings
// ----------------------------------------------------------------------------
const Color kGreen = Color(0xFF225942);
const Color kLightGreen = Color(0xFFE8F3EB);
const Color kMidGreen = Color(0xFF2F7D5B);
const Color kDark = Color(0xFF16221E);
const Color kBg = Color(0xFFFBFAF8);
const Color kRed = Color(0xFFCF4030);
const Color kBorder = Color(0xFFE2EBE5);
const Color kMuted = Color(0xFF6B7280);
const Color kGold = Color(0xFFF59E0B);

const String kCurrency = '₹';
const double kFreeDeliveryAbove = 499.0;
const double kDeliveryFee = 40.0;
const double kMaxPrice = 2500;

// The Unsplash Access Key is kept in lib/secrets.dart (not uploaded to GitHub).

/// Hand-picked Unsplash search words for each product (more accurate than
/// searching the full product name).
const Map<String, String> kUnsplashQueries = {
  'p1': 'beeswax wrap',
  'p2': 'metal drinking straws',
  'p3': 'kitchen compost bin',
  'p4': 'glass storage jars pantry',
  'p5': 'bamboo cutlery set',
  'p6': 'cast iron skillet',
  'p7': 'coconut shell bowl',
  'p8': 'copper water jug',
  'p9': 'clay cooking pot',
  'p10': 'brass spice box',
  'p11': 'silicone food covers',
  'p12': 'wooden cooking spatulas',
  'p13': 'compostable bags',
  'p14': 'linen bread bag',
  'p15': 'bamboo cutting board',
  'p16': 'ceramic water filter',
  'p17': 'handmade soap bars',
  'p18': 'safety razor',
  'p19': 'konjac sponge',
  'p20': 'natural loofah',
  'p21': 'bamboo toothbrush',
  'p22': 'wooden hair comb',
  'p23': 'shampoo bar',
  'p24': 'reusable cotton pads',
  'p25': 'natural deodorant jar',
  'p26': 'sisal bath strap',
  'p27': 'charcoal tooth powder',
  'p28': 'herbal toothpaste',
  'p29': 'tongue scraper',
  'p30': 'clay face mask',
  'p31': 'shaving brush',
  'p32': 'lip balm tube',
  'p33': 'insulated steel bottle',
  'p34': 'cork yoga mat',
  'p35': 'collapsible coffee cup',
  'p36': 'copper water bottle',
  'p37': 'canvas backpack',
  'p38': 'steel tiffin lunch box',
  'p39': 'jute duffle bag',
  'p40': 'bamboo travel mug',
  'p41': 'solar power bank',
  'p42': 'thermal flask tea',
  'p43': 'portable travel cutlery',
  'p44': 'cotton drawstring backpack',
  'p45': 'silicone snack bags',
  'p46': 'straw sun hat',
  'p47': 'dish soap bottle',
  'p48': 'dishcloth sponge cloth',
  'p49': 'coconut coir scrubber',
  'p50': 'soy candle',
  'p51': 'wool dryer balls',
  'p52': 'natural floor cleaner',
  'p53': 'brass diya lamp',
  'p54': 'bottle cleaning brush',
  'p55': 'bamboo desk organizer',
  'p56': 'jute rug',
  'p57': 'essential oil diffuser',
  'p58': 'cotton bath towel',
  'p59': 'incense holder',
  'p60': 'natural mosquito repellent',
  'p61': 'solar string lights',
  'p62': 'notebook journal',
  'p63': 'seedling pots',
  'p64': 'vegetable seeds',
  'p65': 'wooden pencils',
  'p66': 'terracotta planter',
  'p67': 'coco coir soil',
  'p68': 'kraft paper wrapping',
  'p69': 'macrame plant hanger',
  'p70': 'neem oil spray',
  'p71': 'brass plant mister',
  'p72': 'wildflower seed balls',
  'p73': 'wicker basket',
  'p74': 'compost fertilizer',
  'p75': 'fabric scrunchies',
  'p76': 'organic cotton t-shirt',
  'p77': 'canvas sneakers',
  'p78': 'linen shirt',
  'p79': 'khadi kurta',
  'p80': 'jute tote bag',
  'p81': 'hemp baseball cap',
  'p82': 'wool scarf',
  'p83': 'bamboo socks',
  'p84': 'canvas tote bag',
  'p85': 'denim sling bag',
  'p86': 'sunglasses case',
  'p87': 'wooden hair stick',
  'p88': 'baby onesie',
  'p89': 'wooden teething ring',
  'p90': 'beeswax crayons',
  'p91': 'wooden rainbow toy',
  'p92': 'bamboo baby plate',
  'p93': 'baby swaddle blanket',
  'p94': 'cloth diaper',
  'p95': 'baby soap',
  'p96': 'crochet rattle toy',
  'p97': 'baby wipes',
  'p98': 'wooden alphabet blocks',
  'p99': 'kids sun hat',
  'p100': 'toddler sippy cup',
};

String fmt(double v) => '$kCurrency${v.round()}';

final ValueNotifier<int> kTab = ValueNotifier<int>(0);
const int kHomeTab = 0;
const int kWishlistTab = 1;
const int kOrdersTab = 2;
const int kCartTab = 3;
const int kAccountTab = 4;

/// Pops back to the main shell and switches tab.
void goToTab(BuildContext context, int tab) {
  Navigator.of(context).popUntil((r) => r.isFirst);
  kTab.value = tab;
}

// ----------------------------------------------------------------------------
// Date helpers
// ----------------------------------------------------------------------------
const List<String> _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];
const List<String> _weekdays = [
  'Mon',
  'Tue',
  'Wed',
  'Thu',
  'Fri',
  'Sat',
  'Sun'
];

String formatDate(DateTime d) =>
    '${_weekdays[d.weekday - 1]}, ${d.day} ${_months[d.month - 1]} ${d.year}';

String formatDateTime(DateTime d) {
  final int h = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final String m = d.minute.toString().padLeft(2, '0');
  final String ap = d.hour >= 12 ? 'PM' : 'AM';
  return '${d.day} ${_months[d.month - 1]} ${d.year} · $h:$m $ap';
}

// ============================================================================
// MODELS
// ============================================================================
class Product {
  final String id;
  final String name;
  final String brand;
  final double price;
  final double mrp;
  final String emoji;
  final String category;
  final String material;
  final double rating;
  final int reviews;
  final String? badge;
  final String certTag;
  final String shortDesc;
  final String description;

  const Product(
    this.id,
    this.name,
    this.brand,
    this.price,
    this.mrp,
    this.emoji,
    this.category,
    this.material,
    this.rating,
    this.reviews,
    this.badge,
    this.certTag,
    this.shortDesc,
    this.description,
  );

  int get discountPercent => (((mrp - price) / mrp) * 100).round();

  static const int imageCount = 5;

  /// Local picture [index] (1-5) of this product, bundled in assets/products/.
  String assetPath(int index) =>
      'assets/products/${id}_${(index % imageCount) + 1}.jpg';

  /// Search words for Unsplash, taken from the product name.
  String get searchTerm {
    final curated = kUnsplashQueries[id];
    if (curated != null) return curated;
    const skip = {
      'Set',
      'Pack',
      'Of',
      'With',
      'And',
      'The',
      'For',
      'Reusable',
      'Organic',
      'Natural',
      'Eco',
      'Friendly',
      'Certified',
      'GOTS',
    };
    final cleaned = name
        .replaceAll(RegExp(r'\(.*?\)'), ' ')
        .replaceAll(RegExp(r'[^A-Za-z ]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return cleaned.split(' ').where((w) => !skip.contains(w)).join(' ');
  }

  /// Shorter backup query (last two words, usually the item itself).
  String get searchTermShort {
    final w = searchTerm.split(' ');
    return w.length > 2 ? w.sublist(w.length - 2).join(' ') : searchTerm;
  }
}

class CartItem {
  final Product product;
  int quantity;
  CartItem({required this.product, this.quantity = 1});
  double get subtotal => product.price * quantity;
  double get mrpTotal => product.mrp * quantity;
}

class CustomerDetails {
  final String fullName;
  final String phone;
  final String email;
  final String line1;
  final String line2;
  final String landmark;
  final String city;
  final String state;
  final String pincode;

  const CustomerDetails({
    required this.fullName,
    required this.phone,
    required this.email,
    required this.line1,
    required this.line2,
    required this.landmark,
    required this.city,
    required this.state,
    required this.pincode,
  });

  String get addressLine => [
        line1,
        if (line2.isNotEmpty) line2,
        if (landmark.isNotEmpty) 'Near $landmark',
        '$city, $state - $pincode',
      ].join(', ');

  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'phone': phone,
        'email': email,
        'line1': line1,
        'line2': line2,
        'landmark': landmark,
        'city': city,
        'state': state,
        'pincode': pincode,
      };

  factory CustomerDetails.fromJson(Map<String, dynamic> j) => CustomerDetails(
        fullName: (j['fullName'] ?? '') as String,
        phone: (j['phone'] ?? '') as String,
        email: (j['email'] ?? '') as String,
        line1: (j['line1'] ?? '') as String,
        line2: (j['line2'] ?? '') as String,
        landmark: (j['landmark'] ?? '') as String,
        city: (j['city'] ?? '') as String,
        state: (j['state'] ?? '') as String,
        pincode: (j['pincode'] ?? '') as String,
      );
}

/// One order = one product line. Ordering 2 products creates 2 orders.
class OrderModel {
  final String id;
  final String userEmail;
  final DateTime placedAt;
  final Product product;
  final int quantity;
  final double deliveryShare;
  final String paymentMethod;
  final CustomerDetails details;

  const OrderModel({
    required this.id,
    required this.userEmail,
    required this.placedAt,
    required this.product,
    required this.quantity,
    required this.deliveryShare,
    required this.paymentMethod,
    required this.details,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'userEmail': userEmail,
        'placedAt': placedAt.toIso8601String(),
        'productId': product.id,
        'quantity': quantity,
        'deliveryShare': deliveryShare,
        'paymentMethod': paymentMethod,
        'details': details.toJson(),
      };

  static OrderModel? fromJson(Map<String, dynamic> j) {
    final matches = kProducts.where((p) => p.id == j['productId']);
    if (matches.isEmpty) return null;
    return OrderModel(
      id: j['id'] as String,
      userEmail: j['userEmail'] as String,
      placedAt: DateTime.parse(j['placedAt'] as String),
      product: matches.first,
      quantity: (j['quantity'] as num).toInt(),
      deliveryShare: (j['deliveryShare'] as num).toDouble(),
      paymentMethod: j['paymentMethod'] as String,
      details: CustomerDetails.fromJson(j['details'] as Map<String, dynamic>),
    );
  }

  static const List<String> stepNames = [
    'Order Placed',
    'Packed',
    'Shipped',
    'Out for Delivery',
    'Delivered',
  ];
  static const List<String> stepShort = [
    'Placed',
    'Packed',
    'Shipped',
    'On the way',
    'Delivered',
  ];

  double get itemsTotal => product.price * quantity;
  double get mrpTotal => product.mrp * quantity;
  double get total => itemsTotal + deliveryShare;
  double get savings => mrpTotal - itemsTotal;

  /// Demo tracking: the order moves to the next step every minute.
  int get step {
    final m = DateTime.now().difference(placedAt).inMinutes;
    return (m + 1).clamp(1, 5).toInt();
  }

  String get status => stepNames[step - 1];
  DateTime stepTime(int s) => placedAt.add(Duration(minutes: s - 1));
  DateTime get expectedDelivery => placedAt.add(const Duration(days: 3));
}

class UserModel {
  final String name;
  final String email;
  final String avatarInitials;
  final int treesPlanted;
  final double plasticSavedKg;

  const UserModel({
    required this.name,
    required this.email,
    required this.avatarInitials,
    this.treesPlanted = 12,
    this.plasticSavedKg = 28.5,
  });
}

class CategoryItem {
  final String name;
  final String emoji;
  const CategoryItem(this.name, this.emoji);
}

const List<CategoryItem> kCategories = [
  CategoryItem('All', '🌱'),
  CategoryItem('Kitchen', '🍴'),
  CategoryItem('Bath & Body', '🧼'),
  CategoryItem('On the go', '🎒'),
  CategoryItem('Home & Cleaning', '🧹'),
  CategoryItem('Garden & Paper', '🪴'),
  CategoryItem('Apparel & Accessories', '👕'),
  CategoryItem('Kids & Baby', '👶'),
];

const List<String> kIndianStates = [
  'Andhra Pradesh',
  'Arunachal Pradesh',
  'Assam',
  'Bihar',
  'Chhattisgarh',
  'Goa',
  'Gujarat',
  'Haryana',
  'Himachal Pradesh',
  'Jharkhand',
  'Karnataka',
  'Kerala',
  'Madhya Pradesh',
  'Maharashtra',
  'Manipur',
  'Meghalaya',
  'Mizoram',
  'Nagaland',
  'Odisha',
  'Punjab',
  'Rajasthan',
  'Sikkim',
  'Tamil Nadu',
  'Telangana',
  'Tripura',
  'Uttar Pradesh',
  'Uttarakhand',
  'West Bengal',
  'Andaman and Nicobar Islands',
  'Chandigarh',
  'Dadra and Nagar Haveli and Daman and Diu',
  'Delhi',
  'Jammu and Kashmir',
  'Ladakh',
  'Lakshadweep',
  'Puducherry',
];

// ============================================================================
// PRODUCT IMAGE WIDGET (Unsplash photo if available, else bundled picture)
// ============================================================================
class ProductImageWidget extends StatelessWidget {
  final Product product;
  final int index;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;

  const ProductImageWidget({
    Key? key,
    required this.product,
    this.index = 0,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = 8.0,
  }) : super(key: key);

  Widget _emojiTile() {
    return Container(
      width: width,
      height: height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE8F3EB), Color(0xFFCFE6D8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: FittedBox(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Text(product.emoji, style: const TextStyle(fontSize: 56)),
          ),
        ),
      ),
    );
  }

  Widget _asset() => Image.asset(
        product.assetPath(index),
        width: width,
        height: height,
        fit: fit,
        gaplessPlayback: true,
        errorBuilder: (context, error, stack) => _emojiTile(),
      );

  @override
  Widget build(BuildContext context) {
    final photos = context.watch<UnsplashProvider>().photosFor(product);
    final Widget child;
    if (photos != null && photos.isNotEmpty) {
      child = Image.network(
        photos[index % photos.length].url,
        width: width,
        height: height,
        fit: fit,
        gaplessPlayback: true,
        loadingBuilder: (context, img, progress) =>
            progress == null ? img : _asset(),
        errorBuilder: (context, error, stack) => _asset(),
      );
    } else {
      child = _asset();
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: child,
    );
  }
}

// ============================================================================
// PROVIDERS
// ============================================================================

class _UserAccount {
  final String name;
  final String email;
  final String passwordHash;
  final int treesPlanted;
  final double plasticSavedKg;

  const _UserAccount({
    required this.name,
    required this.email,
    required this.passwordHash,
    this.treesPlanted = 1,
    this.plasticSavedKg = 0.5,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'hash': passwordHash,
        'trees': treesPlanted,
        'plastic': plasticSavedKg,
      };

  factory _UserAccount.fromJson(Map<String, dynamic> j) => _UserAccount(
        name: j['name'] as String,
        email: j['email'] as String,
        passwordHash: (j['hash'] as String?) ?? '',
        treesPlanted: (j['trees'] as num?)?.toInt() ?? 1,
        plasticSavedKg: (j['plastic'] as num?)?.toDouble() ?? 0.5,
      );
}

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  final Map<String, _UserAccount> _users = {};
  SharedPreferences? _prefs;

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  /// Loads saved accounts and restores the last session.
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final raw = _prefs!.getString('ecokart_users');
    if (raw != null) {
      try {
        final list = jsonDecode(raw) as List<dynamic>;
        for (final e in list) {
          final u = _UserAccount.fromJson(e as Map<String, dynamic>);
          _users[u.email] = u;
        }
      } catch (_) {}
    }
    final cur = _prefs!.getString('ecokart_current');
    if (cur != null && _users.containsKey(cur)) {
      _setUser(_users[cur]!, persist: false);
    } else {
      notifyListeners();
    }
  }

  void _saveUsers() {
    _prefs?.setString('ecokart_users',
        jsonEncode(_users.values.map((u) => u.toJson()).toList()));
  }

  static String _hash(String email, String password) =>
      sha256.convert(utf8.encode('ecokart:$email:$password')).toString();

  void _setUser(_UserAccount u, {bool persist = true}) {
    _currentUser = UserModel(
      name: u.name,
      email: u.email,
      avatarInitials: _initials(u.name),
      treesPlanted: u.treesPlanted,
      plasticSavedKg: u.plasticSavedKg,
    );
    if (persist) _prefs?.setString('ecokart_current', u.email);
    notifyListeners();
  }

  /// Sign in with email + password. Returns an error message or null.
  String? login(String email, String password) {
    final id = email.trim().toLowerCase();
    if (id.isEmpty || password.isEmpty) {
      return 'Please enter your email and password.';
    }
    final user = _users[id];
    if (user == null) {
      return 'No account found for this email. Please create an account.';
    }
    if (user.passwordHash != _hash(user.email, password)) {
      return 'Incorrect password. Please try again.';
    }
    _setUser(user);
    return null;
  }

  /// Create an account with email + password. Returns an error or null.
  String? register(String email, String password) {
    final cleanEmail = email.trim().toLowerCase();
    final valid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(cleanEmail);
    if (!valid) return 'Please enter a valid email address.';
    if (password.length < 6) return 'Password must be at least 6 characters.';
    if (_users.containsKey(cleanEmail)) {
      return 'An account with this email already exists. Please sign in.';
    }
    final uname = cleanEmail.split('@').first;
    final display = uname.isEmpty
        ? 'Eco User'
        : '${uname[0].toUpperCase()}${uname.substring(1)}';
    final acc = _UserAccount(
      name: display,
      email: cleanEmail,
      passwordHash: _hash(cleanEmail, password),
    );
    _users[cleanEmail] = acc;
    _saveUsers();
    _setUser(acc);
    return null;
  }

  Future<void> logout() async {
    _currentUser = null;
    _prefs?.remove('ecokart_current');
    notifyListeners();
  }

  static String _initials(String name) {
    final parts = name.trim().split(' ').where((s) => s.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }
}

class UnsplashPhoto {
  final String url;
  final String credit;
  final String link;
  const UnsplashPhoto(this.url, this.credit, this.link);

  Map<String, dynamic> toJson() => {'u': url, 'c': credit, 'l': link};
  factory UnsplashPhoto.fromJson(Map<String, dynamic> j) =>
      UnsplashPhoto(j['u'] as String, j['c'] as String, j['l'] as String);
}

/// Finds Unsplash photos for each product by searching its name, and
/// remembers them on the device so each product is searched only once.
class UnsplashProvider extends ChangeNotifier {
  final Map<String, List<UnsplashPhoto>> _cache = {};
  final Set<String> _loading = {};
  final Set<String> _failed = {};
  SharedPreferences? _prefs;

  bool get enabled => kUnsplashAccessKey.isNotEmpty;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final raw = _prefs!.getString('ecokart_unsplash_v2');
    if (raw != null) {
      try {
        final m = jsonDecode(raw) as Map<String, dynamic>;
        m.forEach((k, v) {
          _cache[k] = (v as List<dynamic>)
              .map((e) => UnsplashPhoto.fromJson(e as Map<String, dynamic>))
              .toList();
        });
      } catch (_) {}
    }
    notifyListeners();
  }

  /// Cached photos for [p], or null while loading / when unavailable.
  List<UnsplashPhoto>? photosFor(Product p) {
    if (!enabled) return null;
    final cached = _cache[p.id];
    if (cached != null) return cached;
    if (!_loading.contains(p.id) && !_failed.contains(p.id)) {
      _loading.add(p.id);
      Future.microtask(() => _fetch(p));
    }
    return null;
  }

  Future<List<UnsplashPhoto>> _search(String query) async {
    final uri = Uri.https('api.unsplash.com', '/search/photos', {
      'query': query,
      'per_page': '5',
      'orientation': 'squarish',
      'content_filter': 'high',
      'client_id': kUnsplashAccessKey,
    });
    final res = await http.get(uri).timeout(const Duration(seconds: 12));
    if (res.statusCode != 200) throw Exception('HTTP ${res.statusCode}');
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final results = (data['results'] as List<dynamic>?) ?? <dynamic>[];
    return results.map((r) {
      final m = r as Map<String, dynamic>;
      final urls = m['urls'] as Map<String, dynamic>;
      final user = m['user'] as Map<String, dynamic>;
      final links = m['links'] as Map<String, dynamic>?;
      return UnsplashPhoto('${urls['regular']}', '${user['name']}',
          '${links?['html'] ?? 'https://unsplash.com'}');
    }).toList();
  }

  Future<void> _fetch(Product p) async {
    try {
      var photos = await _search(p.searchTerm);
      if (photos.isEmpty) photos = await _search(p.searchTermShort);
      if (photos.isNotEmpty) {
        _cache[p.id] = photos;
        _prefs?.setString(
            'ecokart_unsplash_v2',
            jsonEncode(_cache.map(
                (k, v) => MapEntry(k, v.map((e) => e.toJson()).toList()))));
      } else {
        _failed.add(p.id);
      }
    } catch (_) {
      _failed.add(p.id);
    }
    _loading.remove(p.id);
    notifyListeners();
  }
}

class WishlistProvider extends ChangeNotifier {
  final Set<String> _ids = {};

  int get count => _ids.length;
  bool isWishlisted(String id) => _ids.contains(id);

  void toggle(String id) {
    if (!_ids.remove(id)) _ids.add(id);
    notifyListeners();
  }

  List<Product> getProducts(List<Product> all) =>
      all.where((p) => _ids.contains(p.id)).toList();
}

class CartProvider extends ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => _items;
  int get itemCount => _items.values.fold(0, (sum, i) => sum + i.quantity);
  bool isInCart(String id) => _items.containsKey(id);
  int getProductQuantity(String id) => _items[id]?.quantity ?? 0;

  double get itemsSubtotal =>
      _items.values.fold(0.0, (sum, i) => sum + i.subtotal);
  double get mrpTotal => _items.values.fold(0.0, (sum, i) => sum + i.mrpTotal);
  double get deliveryFee =>
      (itemsSubtotal >= kFreeDeliveryAbove || _items.isEmpty)
          ? 0.0
          : kDeliveryFee;
  double get totalAmount => itemsSubtotal + deliveryFee;
  double get totalSavings => mrpTotal - itemsSubtotal;
  double get freeDeliveryProgress =>
      (itemsSubtotal / kFreeDeliveryAbove).clamp(0.0, 1.0);
  double get amountNeededForFreeDelivery =>
      (kFreeDeliveryAbove - itemsSubtotal).clamp(0.0, kFreeDeliveryAbove);

  void addItem(Product p) {
    if (_items.containsKey(p.id)) {
      _items[p.id]!.quantity++;
    } else {
      _items[p.id] = CartItem(product: p, quantity: 1);
    }
    notifyListeners();
  }

  void removeItem(String id) {
    if (!_items.containsKey(id)) return;
    if (_items[id]!.quantity > 1) {
      _items[id]!.quantity--;
    } else {
      _items.remove(id);
    }
    notifyListeners();
  }

  void deleteItem(String id) {
    _items.remove(id);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}

class AddressProvider extends ChangeNotifier {
  final Map<String, CustomerDetails> _byEmail = {};
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final raw = _prefs!.getString('ecokart_addresses');
    if (raw != null) {
      try {
        final m = jsonDecode(raw) as Map<String, dynamic>;
        m.forEach((k, v) {
          _byEmail[k] = CustomerDetails.fromJson(v as Map<String, dynamic>);
        });
      } catch (_) {}
    }
    notifyListeners();
  }

  CustomerDetails? forUser(String email) => _byEmail[email.toLowerCase()];

  void save(String email, CustomerDetails d) {
    _byEmail[email.toLowerCase()] = d;
    _prefs?.setString('ecokart_addresses',
        jsonEncode(_byEmail.map((k, v) => MapEntry(k, v.toJson()))));
    notifyListeners();
  }
}

class OrdersProvider extends ChangeNotifier {
  final List<OrderModel> _orders = [];
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final raw = _prefs!.getString('ecokart_orders');
    if (raw != null) {
      try {
        for (final e in jsonDecode(raw) as List<dynamic>) {
          final o = OrderModel.fromJson(e as Map<String, dynamic>);
          if (o != null) _orders.add(o);
        }
      } catch (_) {}
    }
    notifyListeners();
  }

  void _save() {
    _prefs?.setString(
        'ecokart_orders', jsonEncode(_orders.map((o) => o.toJson()).toList()));
  }

  List<OrderModel> ordersFor(String? email) => email == null
      ? <OrderModel>[]
      : _orders.where((o) => o.userEmail == email).toList();

  /// Creates ONE order per cart line. Returns how many orders were created.
  int placeFromCart(CartProvider cart, CustomerDetails details, String payment,
      String email) {
    final sub = cart.itemsSubtotal;
    final fee = cart.deliveryFee;
    final now = DateTime.now();
    final stamp = now.millisecondsSinceEpoch.toString();
    final tail = stamp.substring(stamp.length - 6);
    final created = <OrderModel>[];
    int i = 0;
    for (final item in cart.items.values) {
      i++;
      created.add(OrderModel(
        id: 'ECO-$tail-$i',
        userEmail: email,
        placedAt: now,
        product: item.product,
        quantity: item.quantity,
        deliveryShare: sub == 0 ? 0.0 : fee * (item.subtotal / sub),
        paymentMethod: payment,
        details: details,
      ));
    }
    _orders.insertAll(0, created);
    _save();
    notifyListeners();
    return created.length;
  }
}

// ============================================================================
// APP ENTRY & SHELL
// ============================================================================
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
            create: (_) => AuthProvider()..init()),
        ChangeNotifierProvider<AddressProvider>(
            create: (_) => AddressProvider()..init()),
        ChangeNotifierProvider<UnsplashProvider>(
            create: (_) => UnsplashProvider()..init()),
        ChangeNotifierProvider<WishlistProvider>(
            create: (_) => WishlistProvider()),
        ChangeNotifierProvider<CartProvider>(create: (_) => CartProvider()),
        ChangeNotifierProvider<OrdersProvider>(
            create: (_) => OrdersProvider()..init()),
      ],
      child: const EcoKartApp(),
    ),
  );
}

class EcoKartApp extends StatelessWidget {
  const EcoKartApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoKart',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: kBg,
        textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),
        primaryColor: kGreen,
        colorScheme: ColorScheme.fromSeed(seedColor: kGreen, primary: kGreen),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: kDark,
          elevation: 0,
        ),
      ),
      home: const MainNavigationShell(),
    );
  }
}

class MainNavigationShell extends StatelessWidget {
  const MainNavigationShell({Key? key}) : super(key: key);

  Widget _navBadge(Widget icon, int count, Color color) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        icon,
        if (count > 0)
          Positioned(
            top: -4,
            right: -8,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
              child: Text('$count',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold)),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: kTab,
      builder: (context, currentTab, _) {
        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  color: kDark,
                  child: const Text(
                    '🌿 Monsoon Sale: up to 40% OFF · Free delivery over ₹499',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Color(0xFFE8F3EB),
                        fontSize: 11,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                        bottom: BorderSide(color: kBorder.withAlpha(153))),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => kTab.value = kHomeTab,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                  color: kLightGreen,
                                  borderRadius: BorderRadius.circular(8)),
                              child: const Icon(Icons.eco,
                                  color: kGreen, size: 20),
                            ),
                            const SizedBox(width: 8),
                            const Text('EcoKart',
                                style: TextStyle(
                                    color: kGreen,
                                    fontSize: 19,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.5)),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Consumer<CartProvider>(
                        builder: (context, cart, _) => InkWell(
                          onTap: () => kTab.value = kCartTab,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                                color: kGreen,
                                borderRadius: BorderRadius.circular(20)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.shopping_bag_outlined,
                                    color: Colors.white, size: 16),
                                const SizedBox(width: 5),
                                Text(fmt(cart.totalAmount),
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold)),
                                if (cart.itemCount > 0) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 1),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Text('${cart.itemCount}',
                                        style: const TextStyle(
                                            color: kGreen,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: IndexedStack(
                    index: currentTab,
                    children: const [
                      HomeCatalogTab(),
                      WishlistTab(),
                      OrdersTab(),
                      CartTab(),
                      AccountTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: kBorder.withAlpha(204))),
            ),
            child: BottomNavigationBar(
              currentIndex: currentTab,
              onTap: (i) => kTab.value = i,
              backgroundColor: Colors.white,
              selectedItemColor: kGreen,
              unselectedItemColor: kMuted,
              selectedFontSize: 11,
              unselectedFontSize: 11,
              type: BottomNavigationBarType.fixed,
              elevation: 0,
              items: [
                const BottomNavigationBarItem(
                  icon: Icon(Icons.storefront_outlined),
                  activeIcon: Icon(Icons.storefront),
                  label: 'Shop',
                ),
                BottomNavigationBarItem(
                  icon: Consumer<WishlistProvider>(
                    builder: (_, w, __) => _navBadge(
                        const Icon(Icons.favorite_outline), w.count, kRed),
                  ),
                  label: 'Wishlist',
                ),
                BottomNavigationBarItem(
                  icon: Consumer2<OrdersProvider, AuthProvider>(
                    builder: (_, o, a, __) => _navBadge(
                        const Icon(Icons.local_shipping_outlined),
                        o.ordersFor(a.currentUser?.email).length,
                        kMidGreen),
                  ),
                  label: 'Orders',
                ),
                BottomNavigationBarItem(
                  icon: Consumer<CartProvider>(
                    builder: (_, c, __) => _navBadge(
                        const Icon(Icons.shopping_bag_outlined),
                        c.itemCount,
                        kGreen),
                  ),
                  label: 'Cart',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person),
                  label: 'Account',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ============================================================================
// 100 CURATED ECO-FRIENDLY PRODUCTS DATASET
// ============================================================================
final List<Product> kProducts = [
  // ---------------- KITCHEN ----------------
  Product(
      'p1',
      'Beeswax Food Wraps (3-Pack)',
      'HiveHome',
      249.0,
      399.0,
      '🐝',
      'Kitchen',
      'Organic cotton & beeswax',
      4.4,
      2150,
      'BESTSELLER',
      'VERDANT CERTIFIED • BIODEGRADABLE',
      'Reusable food wraps that replace cling film & foil',
      'Infused with organic beeswax, jojoba oil, and natural tree resin. Washable in cold water and fully compostable at home.'),
  Product(
      'p2',
      'Stainless Steel Straws (Set of 6)',
      'HydroGreen',
      149.0,
      249.0,
      '🥤',
      'Kitchen',
      'Food-grade 304 steel',
      4.8,
      3120,
      'BESTSELLER',
      'VERDANT CERTIFIED • REUSABLE',
      'Rust-proof straws with linen pouch & cleaning brush',
      'Set of 6 food-grade stainless steel straws (3 straight, 3 curved) with sisal cleaning brush and travel pouch.'),
  Product(
      'p3',
      'Kitchen Compost Bin (5L)',
      'GreenLoop',
      899.0,
      1299.0,
      '♻️',
      'Kitchen',
      'Recycled carbon steel',
      4.8,
      754,
      'DEAL OF THE DAY',
      'VERDANT CERTIFIED • RECYCLED STEEL',
      'Countertop compost caddy with activated charcoal filter',
      'Airtight lid with dual activated charcoal filters to trap smells and keep food scraps ready for garden soil.'),
  Product(
      'p4',
      'Recycled Glass Storage Jars (Set of 3)',
      'ClearCycle',
      499.0,
      699.0,
      '🍯',
      'Kitchen',
      'Recycled glass & bamboo',
      4.7,
      960,
      null,
      'VERDANT CERTIFIED • ZERO PLASTIC',
      'Airtight pantry containers with natural bamboo lids',
      'Made from post-consumer recycled borosilicate glass with airtight silicone seals to keep grains fresh.'),
  Product(
      'p5',
      'Bamboo Cutlery Set with Pouch',
      'BambooBliss',
      199.0,
      299.0,
      '🍴',
      'Kitchen',
      'Moso bamboo',
      4.5,
      1650,
      null,
      'VERDANT CERTIFIED • ZERO WASTE',
      'Portable fork, knife, spoon & chopsticks in cotton case',
      'Lightweight, splinter-free bamboo dining set for office lunches and travel. Replaces hundreds of single-use forks.'),
  Product(
      'p6',
      'Cast Iron Skillet 10-inch',
      'EarthCook',
      1199.0,
      1699.0,
      '🍳',
      'Kitchen',
      'Pure seasoned cast iron',
      4.9,
      1820,
      'BESTSELLER',
      'VERDANT CERTIFIED • LIFETIME DURABLE',
      'Pre-seasoned toxin-free cookware replacing Teflon pans',
      'Naturally non-stick cooking surface without chemical PTFE coatings. Retains heat evenly and lasts generations.'),
  Product(
      'p7',
      'Coconut Shell Bowls (Set of 2)',
      'CoirCraft',
      299.0,
      449.0,
      '🥥',
      'Kitchen',
      'Reclaimed coconut shell',
      4.6,
      940,
      null,
      'VERDANT CERTIFIED • UPCYCLED',
      'Handcrafted smoothie bowls made from reclaimed shells',
      'Reclaimed from agricultural waste, sanded smooth and polished with virgin coconut oil. 100% natural and food-safe.'),
  Product(
      'p8',
      'Copper Water Jug 1.5L',
      'PureVeda',
      999.0,
      1399.0,
      '🍶',
      'Kitchen',
      'Pure hammered copper',
      4.7,
      830,
      'DEAL OF THE DAY',
      'VERDANT CERTIFIED • AYURVEDIC',
      'Ayurvedic copper pitcher naturally alkalizing drinking water',
      'Handcrafted by traditional artisans. Copper ions naturally purify water and provide essential trace minerals.'),
  Product(
      'p9',
      'Terracotta Clay Cooking Pot',
      'MittiGhar',
      549.0,
      799.0,
      '🍲',
      'Kitchen',
      'Natural unglazed clay',
      4.5,
      620,
      null,
      'VERDANT CERTIFIED • TRADITIONAL',
      'Earthen cookware preserving food nutrients and natural flavor',
      'Clay balances acidity in food and retains moisture through slow even cooking. Free of synthetic lead or glazes.'),
  Product(
      'p10',
      'Brass Spice Box (Masala Dabba)',
      'HeritageVeda',
      1299.0,
      1799.0,
      '✨',
      'Kitchen',
      'Solid brass',
      4.8,
      410,
      'NEW',
      'VERDANT CERTIFIED • HANDCRAFTED',
      '7-compartment traditional brass container with glass lid',
      'Keeps whole and ground spices fresh and fragrant. Brass naturally resists bacterial growth and looks timeless.'),
  Product(
      'p11',
      'Silicone Stretch Food Lids (6-Pack)',
      'ZeroWrap',
      299.0,
      449.0,
      '🥣',
      'Kitchen',
      'Food-grade platinum silicone',
      4.4,
      1120,
      null,
      'VERDANT CERTIFIED • REUSABLE',
      'Stretchable leak-proof bowl covers replacing plastic wrap',
      'Fits snugly over bowls, melons, and jars. Dishwasher and microwave safe from -40C to 230C.'),
  Product(
      'p12',
      'Neem Wood Cooking Spatulas (Set of 4)',
      'BareNest',
      249.0,
      399.0,
      '🥄',
      'Kitchen',
      'Natural neem wood',
      4.6,
      1430,
      'BESTSELLER',
      'VERDANT CERTIFIED • ANTIBACTERIAL',
      'Non-scratch kitchen ladles with natural antibacterial oil',
      'Carved from aged medicinal neem wood. Safe for non-stick surfaces, will not leach toxins into hot soups.'),
  Product(
      'p13',
      'Compostable Trash Bags (30 bags)',
      'GreenLoop',
      199.0,
      299.0,
      '🗑️',
      'Kitchen',
      'Corn starch PLA film',
      4.3,
      1890,
      null,
      'VERDANT CERTIFIED • COMPOSTABLE',
      'Strong plant-based garbage bags certified 100% compostable',
      'Break down within 180 days in soil without microplastics. Leak-proof star-sealed bottom handles wet kitchen waste.'),
  Product(
      'p14',
      'Linen Bread Bag Reusable',
      'SoftEarth',
      249.0,
      349.0,
      '🥖',
      'Kitchen',
      'Unbleached organic linen',
      4.5,
      380,
      null,
      'VERDANT CERTIFIED • ORGANIC',
      'Breathable natural fabric keeping crusty breads fresh',
      'Natural flax linen allows air circulation so artisanal loaves stay crisp outside and soft inside without mold.'),
  Product(
      'p15',
      'Bamboo Chopping Board',
      'BambooBliss',
      449.0,
      649.0,
      '🪵',
      'Kitchen',
      'Organic moso bamboo',
      4.7,
      2190,
      'BESTSELLER',
      'VERDANT CERTIFIED • SUSTAINABLE',
      'Durable reversible cutting board with juice drip groove',
      'Gentle on knife edges and naturally non-porous to resist odor and moisture absorption.'),
  Product(
      'p16',
      'Ceramic Water Filter Dispenser',
      'ClearCycle',
      1499.0,
      2199.0,
      '🚰',
      'Kitchen',
      'Glazed ceramic & terracotta',
      4.8,
      310,
      'NEW',
      'VERDANT CERTIFIED • ECO FILTER',
      'Gravity-fed water filter cooler using natural candle technology',
      'Slow terracotta micro-filtration cools water naturally by evaporation while removing suspended impurities.'),

  // ---------------- BATH & BODY ----------------
  Product(
      'p17',
      'Organic Cold-Pressed Soap Set (3 Bars)',
      'BareNest',
      249.0,
      399.0,
      '🧼',
      'Bath & Body',
      'Plant oils & botanical extracts',
      4.7,
      1842,
      'DEAL OF THE DAY',
      'VERDANT CERTIFIED • ORGANIC',
      'Three cold-pressed bars, wrapped in seed paper',
      'Artisan cold-processed botanical soaps with olive oil and shea butter. Wrapped in wildflower seed paper.'),
  Product(
      'p18',
      'Safety Razor Kit with 10 Blades',
      'EcoShave',
      499.0,
      799.0,
      '🪒',
      'Bath & Body',
      'Brass & chrome alloy',
      4.6,
      1420,
      'DEAL OF THE DAY',
      'VERDANT CERTIFIED • ZERO WASTE',
      'Double-edge metal razor that replaces plastic cartridges',
      'Weighted brass handle with precision comb for the smoothest close shave. Includes 10 recyclable steel blades.'),
  Product(
      'p19',
      'Konjac Facial Exfoliating Sponge',
      'BareNest',
      149.0,
      220.0,
      '🧽',
      'Bath & Body',
      '100% Konjac root fibre',
      4.1,
      310,
      null,
      'VERDANT CERTIFIED • COMPOSTABLE',
      'Pure vegetable fibre sponge for gentle pore cleansing',
      'Harvested from Asian konjac root fibre. Cleanses pores and exfoliates gently without needing soap.'),
  Product(
      'p20',
      'Natural Sun-Dried Loofah (3-Pack)',
      'EarthRoot',
      199.0,
      299.0,
      '🪵',
      'Bath & Body',
      'Sun-dried gourd loofah',
      4.4,
      580,
      null,
      'VERDANT CERTIFIED • 100% NATURAL',
      'Set of 3 unbleached, plant-based bath sponges',
      'Natural fibrous plant sponge grown without synthetic pesticides. Stimulates circulation and softens skin.'),
  Product(
      'p21',
      'Biodegradable Bamboo Toothbrush (Pack of 4)',
      'BambooBliss',
      129.0,
      199.0,
      '🪥',
      'Bath & Body',
      'Moso bamboo & castor bristles',
      4.6,
      4210,
      'BESTSELLER',
      'VERDANT CERTIFIED • PLASTIC FREE',
      'Biodegradable bamboo handles that replace plastic brushes',
      'Smooth organically-grown moso bamboo handles with castor-oil-based soft bristles in recycled packaging.'),
  Product(
      'p22',
      'Neem Wood Hair Detangling Comb',
      'PureVeda',
      149.0,
      249.0,
      '🌿',
      'Bath & Body',
      'Medicinal neem wood',
      4.6,
      2890,
      'BESTSELLER',
      'VERDANT CERTIFIED • AYURVEDIC',
      'Static-free wooden comb preventing hair fall and dandruff',
      'Seamless hand-carved teeth glide through tangled hair without snapping strands or creating frizz.'),
  Product(
      'p23',
      'Solid Shampoo & Conditioner Bar',
      'PureLeaf',
      299.0,
      449.0,
      '🌸',
      'Bath & Body',
      'Coconut oil & argan butter',
      4.4,
      1540,
      null,
      'VERDANT CERTIFIED • ZERO BOTTLE',
      'Concentrated hair cleanse bar replacing 3 plastic bottles',
      'Packed with nourishing argan and rosemary oil. Creates rich lather and lasts over 70 washes.'),
  Product(
      'p24',
      'Organic Cotton Reusable Makeup Pads (Set of 10)',
      'SoftEarth',
      199.0,
      299.0,
      '☁️',
      'Bath & Body',
      'Organic velvet cotton',
      4.5,
      870,
      null,
      'VERDANT CERTIFIED • WASHABLE',
      'Washable organic face pads with mesh laundry pouch',
      'Velvety double-layered organic cotton rounds that replace single-use disposable cotton wipes.'),
  Product(
      'p25',
      'Natural Deodorant Cream with Shea Butter',
      'PureLeaf',
      249.0,
      349.0,
      '🥥',
      'Bath & Body',
      'Arrowroot & shea butter',
      4.3,
      710,
      null,
      'VERDANT CERTIFIED • ALUMINUM FREE',
      'All-day odor control in a reusable aluminum tin',
      'Baking soda and arrowroot absorb wetness while tea tree and lavender provide clean natural freshness.'),
  Product(
      'p26',
      'Sisal Bath Exfoliating Strap',
      'EarthRoot',
      179.0,
      249.0,
      '🧼',
      'Bath & Body',
      'Natural agave sisal fibre',
      4.4,
      460,
      null,
      'VERDANT CERTIFIED • PLANT FIBRE',
      'Double-handled back scrubber for deep invigorating clean',
      'Woven from durable natural agave cactus fibres. Sloughs away dead skin cells effortlessly.'),
  Product(
      'p27',
      'Bamboo Charcoal Teeth Whitening Powder',
      'BambooBliss',
      229.0,
      349.0,
      '🖤',
      'Bath & Body',
      'Activated bamboo charcoal',
      4.5,
      1310,
      null,
      'VERDANT CERTIFIED • FLUORIDE FREE',
      'Natural stain-lifting powder with bentonite clay & mint',
      'Gently polishes away coffee and tea stains without harsh peroxides or synthetic micro-beads.'),
  Product(
      'p28',
      'Ayurvedic Herbal Toothpaste (Plastic-Free Jar)',
      'PureVeda',
      199.0,
      299.0,
      '🌱',
      'Bath & Body',
      'Clove, babool & calcium',
      4.6,
      920,
      null,
      'VERDANT CERTIFIED • TOXIN FREE',
      'Remineralizing tooth paste in recyclable glass jar',
      'Traditional formula with clove oil and camphor strengthens gums and freshens breath naturally.'),
  Product(
      'p29',
      'Stainless Steel Tongue Cleaner (Set of 2)',
      'EcoShave',
      99.0,
      149.0,
      '✨',
      'Bath & Body',
      'Surgical stainless steel',
      4.8,
      3490,
      'BESTSELLER',
      'VERDANT CERTIFIED • LIFETIME',
      'Flexible ergonomic scraper removing morning bacteria',
      'Smooth rounded edges clean the tongue effectively in seconds without gagging. Rust-resistant for life.'),
  Product(
      'p30',
      'Natural Clay Face Mask Powder',
      'BareNest',
      299.0,
      420.0,
      '💆',
      'Bath & Body',
      'Multani mitti & rose petals',
      4.6,
      680,
      null,
      'VERDANT CERTIFIED • RAW BOTANICAL',
      "Detoxifying Indian fuller's earth clay for glowing skin",
      'Mix with rosewater or yogurt for a spa treatment at home. Draws out deep impurities naturally.'),
  Product(
      'p31',
      'Handmade Wooden Shaving Brush',
      'EcoShave',
      349.0,
      499.0,
      '🪒',
      'Bath & Body',
      'Sheesham wood & synthetic vegan hair',
      4.7,
      510,
      'NEW',
      'VERDANT CERTIFIED • CRUELTY FREE',
      'Dense soft lathering brush with polished wooden handle',
      'Generates rich foam from shave soaps while exfoliating facial hair for a smooth, nick-free razor glide.'),
  Product(
      'p32',
      'Organic Lip Balm in Paper Tube',
      'HiveHome',
      149.0,
      220.0,
      '💄',
      'Bath & Body',
      'Beeswax & almond oil',
      4.7,
      1140,
      null,
      'VERDANT CERTIFIED • ZERO PLASTIC',
      'Hydrating lip butter in push-up biodegradable paper tube',
      'Glides smoothly with organic almond oil and cocoa butter to heal chapped lips in zero-plastic packaging.'),

  // ---------------- ON THE GO ----------------
  Product(
      'p33',
      'Insulated Stainless Steel Bottle (750ml)',
      'HydroGreen',
      699.0,
      999.0,
      '🍶',
      'On the go',
      'Double-wall food steel',
      4.9,
      5120,
      'BESTSELLER',
      'VERDANT CERTIFIED • LIFETIME DURABLE',
      '750ml vacuum flask keeping drinks cold 24h & hot 12h',
      'Insulated bottle crafted from 90% recycled steel. Leak-proof bamboo cap prevents single-use plastic bottles.'),
  Product(
      'p34',
      'Natural Cork Yoga Mat',
      'PranaEarth',
      1299.0,
      1899.0,
      '🧘',
      'On the go',
      'Natural cork & tree rubber',
      4.7,
      890,
      'BESTSELLER',
      'VERDANT CERTIFIED • NON-TOXIC',
      'Naturally antimicrobial yoga mat with supreme grip',
      'Harvested without chopping down cork oak trees. Non-slip sweat grip with natural rubber base.'),
  Product(
      'p35',
      'Collapsible Silicone Coffee Cup (350ml)',
      'HydroGreen',
      349.0,
      499.0,
      '☕',
      'On the go',
      'Silicone & bamboo collar',
      4.5,
      1100,
      null,
      'VERDANT CERTIFIED • PORTABLE',
      'Pocket-sized folding travel mug with leak-proof lid',
      'Folds down to just 2 inches when finished. Heat-resistant sleeve and leak-proof stopper save takeaway cups.'),
  Product(
      'p36',
      'Copper Water Bottle 1L',
      'PureVeda',
      799.0,
      1199.0,
      '✨',
      'On the go',
      'Hand-hammered pure copper',
      4.7,
      2340,
      'DEAL OF THE DAY',
      'VERDANT CERTIFIED • AYURVEDIC',
      'Seamless leak-proof copper flask for healthy hydration',
      'Jointless design with silicone ring seal. Storing water overnight charges it with natural antioxidants.'),
  Product(
      'p37',
      'Canvas Laptop Backpack (Organic Cotton)',
      'EcoStep',
      1499.0,
      2299.0,
      '🎒',
      'On the go',
      'Organic canvas & metal brass',
      4.8,
      620,
      'NEW',
      'VERDANT CERTIFIED • GOTS ORGANIC',
      'Padded 15.6-inch laptop bag made from heavyweight canvas',
      'Water-resistant organic cotton canvas with vegetable-tanned straps and multiple functional pockets.'),
  Product(
      'p38',
      'Stainless Steel Lunch Box (3-Tier Tiffin)',
      'HydroGreen',
      699.0,
      999.0,
      '🍱',
      'On the go',
      '304 Food-grade steel',
      4.6,
      1780,
      null,
      'VERDANT CERTIFIED • PLASTIC FREE',
      'Traditional multi-tier lunch carrier with locking clips',
      'Keeps rotis, rice, and curries separated without plastic containers. Easy to carry and dishwasher safe.'),
  Product(
      'p39',
      'Jute Travel Duffle Bag',
      'Jutewala',
      899.0,
      1299.0,
      '👜',
      'On the go',
      'Golden jute & cotton webbing',
      4.6,
      490,
      null,
      'VERDANT CERTIFIED • BIODEGRADABLE',
      'Spacious weekend travel bag handwoven from Bengal jute',
      'Sturdy reinforced stitching with cotton handles and brass zippers. Biodegradable and incredibly strong.'),
  Product(
      'p40',
      'Bamboo Fibre Travel Mug with Silicone Lid',
      'GreenLoop',
      279.0,
      399.0,
      '🍵',
      'On the go',
      'Bamboo powder & cornstarch',
      4.3,
      850,
      null,
      'VERDANT CERTIFIED • ECO COMPOSITE',
      'Lightweight insulated tumbler with splash-proof lid',
      'Made with fast-growing bamboo fibres. Safe for hot chai and iced drinks, biodegradable at end of life.'),
  Product(
      'p41',
      'Solar Power Bank 10,000mAh (Bamboo Casing)',
      'Solaria',
      1399.0,
      1999.0,
      '🔋',
      'On the go',
      'Bamboo shell & lithium polymer',
      4.4,
      530,
      'DEAL OF THE DAY',
      'VERDANT CERTIFIED • RENEWABLE',
      'Dual USB portable charger recharged by direct sunlight',
      'Encased in organic bamboo with high-efficiency monocrystalline solar panel for emergency off-grid charging.'),
  Product(
      'p42',
      'Insulated Thermal Flask with Tea Infuser',
      'HydroGreen',
      649.0,
      899.0,
      '🫖',
      'On the go',
      'Stainless steel & bamboo',
      4.7,
      980,
      null,
      'VERDANT CERTIFIED • ZERO LEAK',
      'Double-walled tumbler with removable loose-leaf filter',
      'Brew hot green tea or infused fruit water on the move. Keeps drinks steaming hot for over 8 hours.'),
  Product(
      'p43',
      'Pocket Cutlery Multi-Tool in Wooden Case',
      'BambooBliss',
      399.0,
      599.0,
      '🛠️',
      'On the go',
      'Stainless steel & beechwood',
      4.5,
      410,
      null,
      'VERDANT CERTIFIED • COMPACT',
      'Detachable fork, spoon, knife and bottle opener for trekking',
      'Folds into a sleek pocket tool with wooden scales. Easily separates into two halves for comfortable dining.'),
  Product(
      'p44',
      'Organic Cotton Drawstring Backpack',
      'SoftEarth',
      349.0,
      499.0,
      '🎒',
      'On the go',
      'Unbleached organic cotton',
      4.6,
      680,
      null,
      'VERDANT CERTIFIED • GOTS',
      'Lightweight gym & beach pack with thick braided cords',
      'Heavyweight 280 GSM cotton fabric holding gym clothes or groceries without tearing.'),
  Product(
      'p45',
      'Reusable Silicone Snack Pouches (3-Pack)',
      'ZeroWrap',
      299.0,
      420.0,
      '🥪',
      'On the go',
      'Food-grade silicone',
      4.5,
      870,
      null,
      'VERDANT CERTIFIED • AIRTIGHT',
      'Stand-up pinch-press ziplock bags replacing sandwich bags',
      'Microwave, freezer and boiling water safe. Airtight seal locks in freshness for dry fruits and sandwiches.'),
  Product(
      'p46',
      'Handwoven Straw Sun Hat',
      'Jutewala',
      499.0,
      699.0,
      '👒',
      'On the go',
      'Natural wheat straw & cotton ribbon',
      4.4,
      320,
      null,
      'VERDANT CERTIFIED • SUN PROTECTION',
      'Wide-brim breathable sun hat woven from natural straw',
      'Provides UPF 50+ sun protection with a soft interior sweatband and adjustable chin cord.'),

  // ---------------- HOME & CLEANING ----------------
  Product(
      'p47',
      'Plant-Based Liquid Dish Soap (500ml)',
      'PureLeaf',
      179.0,
      249.0,
      '🧴',
      'Home & Cleaning',
      'Coconut saponins & lime',
      4.5,
      920,
      null,
      'VERDANT CERTIFIED • BIODEGRADABLE',
      'Tough on grease, gentle on streams & septic systems',
      'Formulated with coconut, aloe vera, and citrus extracts. 100% biodegradable formula in aluminum bottles.'),
  Product(
      'p48',
      'Reusable Swedish Dishcloths (Set of 5)',
      'SoftEarth',
      299.0,
      449.0,
      '🧻',
      'Home & Cleaning',
      '70% cellulose, 30% cotton',
      4.6,
      740,
      'BESTSELLER',
      'VERDANT CERTIFIED • WASHABLE',
      'Absorbent sponge towels replacing 15 paper towel rolls',
      'Absorbs 20x its weight in liquid. Washable in dishwasher or washing machine up to 200 times.'),
  Product(
      'p49',
      'Coconut Coir Scrub Pads (Set of 4)',
      'CoirCraft',
      129.0,
      199.0,
      '🥥',
      'Home & Cleaning',
      'Coconut fibre & natural rubber',
      4.3,
      1980,
      'BESTSELLER',
      'VERDANT CERTIFIED • COMPOSTABLE',
      'Natural scouring pads that shed zero synthetic microplastics',
      'Tough on burnt pans yet non-scratch on glassware. Binds with natural latex, composts in garden soil.'),
  Product(
      'p50',
      'Natural Soy Wax Scented Candle',
      'HiveHome',
      349.0,
      499.0,
      '🕯️',
      'Home & Cleaning',
      '100% Soy wax & cotton wick',
      4.5,
      1105,
      null,
      'VERDANT CERTIFIED • CLEAN BURN',
      'Hand-poured candle in upcycled amber glass jar',
      'Infused with pure lavender and sandalwood essential oils. Burns soot-free for over 45 hours.'),
  Product(
      'p51',
      'Wool Dryer Balls (Pack of 6)',
      'WoolWise',
      399.0,
      599.0,
      '🧶',
      'Home & Cleaning',
      '100% New Zealand wool',
      4.8,
      1260,
      null,
      'VERDANT CERTIFIED • ENERGY SAVER',
      'Cuts laundry drying time by 25% and softens naturally',
      'Replaces chemical fabric softener sheets. Reusable for over 1,000 laundry loads.'),
  Product(
      'p52',
      'Concentrated Floor Cleaner Bar (Dissolvable)',
      'PureLeaf',
      199.0,
      299.0,
      '🧼',
      'Home & Cleaning',
      'Citronella, pine & neem',
      4.4,
      490,
      null,
      'VERDANT CERTIFIED • ZERO WASTE',
      'Dissolvable herbal floor wash bar making 10 litres',
      'Natural insect-repellent mop wash with lemongrass and pine. Ships without single-use water plastic jugs.'),
  Product(
      'p53',
      'Brass Akhand Diya for Home Temple',
      'HeritageVeda',
      499.0,
      699.0,
      '🪔',
      'Home & Cleaning',
      'Solid brass with borosilicate glass',
      4.8,
      890,
      'DEAL OF THE DAY',
      'VERDANT CERTIFIED • TIMELESS',
      'Windproof devotional oil lamp for peaceful home atmosphere',
      'Thick brass base with heat-resistant glass chimney. Burns steadily for hours using natural sesame or ghee oil.'),
  Product(
      'p54',
      'Natural Sisal Bottle Brush with Wooden Handle',
      'CoirCraft',
      149.0,
      220.0,
      '🧹',
      'Home & Cleaning',
      'Sisal agave fibre & beechwood',
      4.5,
      620,
      null,
      'VERDANT CERTIFIED • SCRATCH FREE',
      'Long-reach curved brush for bottles and thermoses',
      'Flexible brush cleans narrow glass necks and bottle bases easily without scratching steel or glass.'),
  Product(
      'p55',
      'Bamboo Desktop Organizer',
      'BambooBliss',
      599.0,
      849.0,
      '🗄️',
      'Home & Cleaning',
      'Solid carbonized bamboo',
      4.6,
      380,
      null,
      'VERDANT CERTIFIED • FSC CERTIFIED',
      'Multi-slot desk caddy for pens, books, and electronics',
      'Clears desk clutter naturally. Polished water-resistant bamboo with durable mortise joints.'),
  Product(
      'p56',
      'Jute Floor Rug (Handwoven 3x2 ft)',
      'Jutewala',
      799.0,
      1199.0,
      '🧶',
      'Home & Cleaning',
      'Natural golden jute fibre',
      4.7,
      720,
      'BESTSELLER',
      'VERDANT CERTIFIED • ARTISAN',
      'Reversible braided floor mat for living rooms & entryways',
      'Handcrafted by rural artisans. Durable, static-free, and brings warm earthy texture to any living room.'),
  Product(
      'p57',
      'Essential Oil Diffuser (Ceramic & Bamboo)',
      'Solaria',
      899.0,
      1299.0,
      '💨',
      'Home & Cleaning',
      'Ceramic & real bamboo base',
      4.6,
      940,
      'NEW',
      'VERDANT CERTIFIED • NON-TOXIC',
      'Ultrasonic cool mist aromatherapy humidifier',
      'Quiet ultrasonic operation with warm ambient light. Humidifies dry air while diffusing pure plant botanicals.'),
  Product(
      'p58',
      'Organic Cotton Bath Towel (GOTS Certified)',
      'SoftEarth',
      599.0,
      899.0,
      '🧖',
      'Home & Cleaning',
      '100% Organic Turkish cotton',
      4.7,
      1420,
      'BESTSELLER',
      'VERDANT CERTIFIED • GOTS ORGANIC',
      'Extra plush 600 GSM bath sheet woven with low-impact dyes',
      'Super absorbent and gentle on sensitive skin. Zero harsh chlorine bleaching or toxic chemical softeners.'),
  Product(
      'p59',
      'Natural Clay Incense Stick Holder',
      'MittiGhar',
      149.0,
      220.0,
      '🌸',
      'Home & Cleaning',
      'Kiln-fired terracotta clay',
      4.5,
      410,
      null,
      'VERDANT CERTIFIED • HANDCRAFTED',
      'Handmade ceramic tray catching falling ash cleanly',
      'Artisan clay design with lotus petal engraving. Keeps temple and living room surfaces spotless and calm.'),
  Product(
      'p60',
      'Herbal Mosquito Repellent Spray (Deet-Free)',
      'PureLeaf',
      229.0,
      320.0,
      '🦟',
      'Home & Cleaning',
      'Lemongrass & eucalyptus oils',
      4.3,
      830,
      null,
      'VERDANT CERTIFIED • CHEMICAL FREE',
      'Non-greasy plant-based mosquito shield safe for kids',
      'Protects against bites for up to 6 hours using natural botanical oils. Safe for indoor and outdoor use.'),

  // ---------------- GARDEN & PAPER ----------------
  Product(
      'p61',
      'Solar Outdoor Fairy String Lights (33ft)',
      'Solaria',
      549.0,
      799.0,
      '💡',
      'Garden & Paper',
      'Solar cell & recycled copper',
      4.5,
      630,
      'DEAL OF THE DAY',
      'VERDANT CERTIFIED • ZERO EMISSIONS',
      'Warm outdoor LED fairy lights powered by solar panel',
      'Weatherproof 33ft outdoor wire with 100 warm LED bulbs. Solar stake illuminates patios 10 hours nightly.'),
  Product(
      'p62',
      'Plantable Seed Paper Journal Notebook',
      'LeafLoop',
      249.0,
      349.0,
      '📓',
      'Garden & Paper',
      'Post-consumer seed paper',
      4.6,
      630,
      null,
      'VERDANT CERTIFIED • ZERO TREE',
      'Tree-free journal embedded with wildflower seeds',
      'Made from recycled cotton garment cuttings. Plant the cover in a pot when full to grow daisies.'),
  Product(
      'p63',
      'Biodegradable Seedling Nursery Pots (24-Pack)',
      'GreenLoop',
      199.0,
      299.0,
      '🌱',
      'Garden & Paper',
      'Compressed peat & wood pulp',
      4.4,
      933,
      null,
      'VERDANT CERTIFIED • COMPOSTABLE',
      'Plantable nursery pots protecting roots from shock',
      'Roots grow straight through the pot walls. Plant directly into the garden soil where the pot decomposes.'),
  Product(
      'p64',
      'Heirloom Vegetable Seeds Starter Kit (10 Varieties)',
      'TinySprout',
      299.0,
      449.0,
      '🍅',
      'Garden & Paper',
      'Non-GMO heirloom seeds',
      4.8,
      710,
      'BESTSELLER',
      'VERDANT CERTIFIED • NON-GMO',
      'Open-pollinated vegetable seeds with planting calendar',
      'Includes spinach, cherry tomato, coriander, bell pepper and brinjal seeds with high germination rate.'),
  Product(
      'p65',
      'Plantable Seed Pencils (Pack of 10)',
      'LeafLoop',
      149.0,
      220.0,
      '✏️',
      'Garden & Paper',
      'Recycled newspaper & seed capsule',
      4.6,
      1540,
      'BESTSELLER',
      'VERDANT CERTIFIED • UPCYCLED',
      'Graphite pencils with herb seeds in biodegradable tip',
      'Sharpen and use like normal pencils. When too short, plant upside down in soil to sprout basil and tomato.'),
  Product(
      'p66',
      'Terracotta Self-Watering Planter',
      'MittiGhar',
      399.0,
      599.0,
      '🪴',
      'Garden & Paper',
      'Porous unglazed terracotta',
      4.7,
      480,
      null,
      'VERDANT CERTIFIED • NATURAL CLAY',
      'Double-chamber pot regulating soil moisture automatically',
      'Water reservoir seeps moisture through terracotta walls directly to plant roots preventing overwatering.'),
  Product(
      'p67',
      'Coco Coir Garden Potting Soil Bricks (Set of 3)',
      'CoirCraft',
      249.0,
      349.0,
      '🥥',
      'Garden & Paper',
      'Compressed coconut coir husk',
      4.7,
      1180,
      null,
      'VERDANT CERTIFIED • PEAT FREE',
      'Expanding potting medium holding 8x water for plants',
      'Each compressed brick expands to 10 litres with water. Aerates garden beds and promotes root health.'),
  Product(
      'p68',
      'Recycled Kraft Paper Gift Wrap Roll (5m)',
      'LeafLoop',
      199.0,
      280.0,
      '🎁',
      'Garden & Paper',
      'Post-consumer recycled paper',
      4.5,
      430,
      null,
      'VERDANT CERTIFIED • RECYCLED',
      'FSC certified brown wrapping paper with jute twine',
      'Durable tear-resistant kraft paper printed with non-toxic water inks. Includes 10m natural jute ribbon.'),
  Product(
      'p69',
      'Macrame Cotton Plant Hanger (Handmade)',
      'SoftEarth',
      299.0,
      420.0,
      '🌿',
      'Garden & Paper',
      '100% Natural cotton rope',
      4.6,
      610,
      null,
      'VERDANT CERTIFIED • HANDCRAFTED',
      'Boho hanging basket for indoor trailing plants',
      'Hand-knotted from unbleached cotton cord with wooden ring. Holds plant pots from 5 to 9 inches wide.'),
  Product(
      'p70',
      'Organic Neem Oil Garden Pest Spray',
      'EarthRoot',
      229.0,
      320.0,
      '🌱',
      'Garden & Paper',
      'Cold-pressed pure neem oil',
      4.6,
      890,
      null,
      'VERDANT CERTIFIED • ORGANIC FARMING',
      'Broad-spectrum pest repellent safe for bees and earthworms',
      'Natural organic solution controlling mealybugs, aphids, and fungus without chemical pesticides.'),
  Product(
      'p71',
      'Brass Mist Sprayer for Indoor Plants',
      'HeritageVeda',
      499.0,
      699.0,
      '🚿',
      'Garden & Paper',
      'Vintage solid brass',
      4.7,
      340,
      'NEW',
      'VERDANT CERTIFIED • ARTISAN',
      'Fine mister providing gentle humidity for orchids & ferns',
      'Pump action mister delivers ultra-fine water particles to delicate leaves without soaking soil.'),
  Product(
      'p72',
      'Upcycled Newspaper Seed Ball Pack (20 Balls)',
      'LeafLoop',
      149.0,
      220.0,
      '🌍',
      'Garden & Paper',
      'Clay, compost & native seeds',
      4.5,
      520,
      null,
      'VERDANT CERTIFIED • RE-WILDING',
      'Wildflower seed bombs for urban guerilla gardening',
      'Just toss onto barren soil or pots. Rain dissolves the clay capsule and native flowers bloom.'),
  Product(
      'p73',
      'Handwoven Cane Garden Basket',
      'Jutewala',
      549.0,
      799.0,
      '🧺',
      'Garden & Paper',
      'Natural wild cane & willow',
      4.6,
      290,
      null,
      'VERDANT CERTIFIED • HANDMADE',
      'Sturdy harvest basket for gathering fresh fruits and herbs',
      'Lightweight handwoven cane with a solid arched handle. Perfect for farm trips and kitchen displays.'),
  Product(
      'p74',
      'Organic Vermicompost Fertilizer (5kg Bag)',
      'GreenLoop',
      299.0,
      420.0,
      '🪱',
      'Garden & Paper',
      'Pure earthworm castings',
      4.8,
      1640,
      'BESTSELLER',
      'VERDANT CERTIFIED • 100% ORGANIC',
      'Nutrient-dense black gold organic manure for potted plants',
      'Enriches soil microbial activity and provides slow-release nitrogen, phosphorus, and potassium naturally.'),

  // ---------------- APPAREL & ACCESSORIES ----------------
  Product(
      'p75',
      'Recycled Fabric Scrunchie Set (3-Pack)',
      'GreenWeave',
      199.0,
      299.0,
      '🎀',
      'Apparel & Accessories',
      'Upcycled textile offcuts',
      4.2,
      483,
      null,
      'VERDANT CERTIFIED • UPCYCLED',
      'Made from fabric offcuts that would go to landfill',
      'Handmade from soft textile remnants collected from ethical apparel mills. Gentle on all hair types.'),
  Product(
      'p76',
      'GOTS Certified Organic Cotton T-Shirt',
      'SoftEarth',
      599.0,
      899.0,
      '👕',
      'Apparel & Accessories',
      '100% GOTS Organic cotton',
      4.5,
      2210,
      'BESTSELLER',
      'VERDANT CERTIFIED • GOTS ORGANIC',
      'Breathable unisex crewneck tee dyed with non-toxic dyes',
      'Soft combed organic cotton farmed without synthetic fertilizers. Pre-shrunk for an all-day comfortable fit.'),
  Product(
      'p77',
      'EcoStep Organic Canvas Sneakers',
      'EcoStep',
      1499.0,
      2199.0,
      '👟',
      'Apparel & Accessories',
      'Organic canvas & wild rubber',
      4.3,
      412,
      'DEAL OF THE DAY',
      'VERDANT CERTIFIED • ETHICAL',
      'Breathable sneakers crafted with GOTS organic canvas',
      'Classic low-top lace sneakers made with 100% organic cotton canvas and wild Amazonian rubber soles.'),
  Product(
      'p78',
      'Pure Linen Button-Down Summer Shirt',
      'GreenWeave',
      1299.0,
      1799.0,
      '👔',
      'Apparel & Accessories',
      '100% European flax linen',
      4.7,
      390,
      'NEW',
      'VERDANT CERTIFIED • SUSTAINABLE',
      'Naturally cooling breathable linen shirt for hot climates',
      'Flax uses 80% less water than conventional cotton. Becomes noticeably softer with every wash.'),
  Product(
      'p79',
      'Handloom Khadi Cotton Kurta',
      'HeritageVeda',
      899.0,
      1299.0,
      '🥻',
      'Apparel & Accessories',
      'Handspun organic khadi',
      4.8,
      640,
      'BESTSELLER',
      'VERDANT CERTIFIED • HANDSPUN',
      'Handcrafted indigenous cotton supporting weaver families',
      'Handspun and woven on traditional charkhas. Breathable in summer and insulating in mild winters.'),
  Product(
      'p80',
      'Handwoven Jute Market Tote Bag',
      'Jutewala',
      349.0,
      499.0,
      '👜',
      'Apparel & Accessories',
      'Natural golden jute fibre',
      4.6,
      4210,
      'BESTSELLER',
      'VERDANT CERTIFIED • 100% BIODEGRADABLE',
      'Heavyweight grocery tote replacing hundreds of plastic bags',
      'Reinforced cotton handles comfortably hold up to 15kg. Biodegradable and built for daily grocery runs.'),
  Product(
      'p81',
      'Hemp Canvas Baseball Cap',
      'Jutewala',
      399.0,
      599.0,
      '🧢',
      'Apparel & Accessories',
      '100% Industrial hemp canvas',
      4.3,
      410,
      null,
      'VERDANT CERTIFIED • ECO FIBRE',
      'UV-protective adjustable cap made from durable hemp',
      'Hemp is naturally antimicrobial and UV-resistant. Brass buckle clasp adjusts to fit all head sizes.'),
  Product(
      'p82',
      'Recycled Wool Winter Scarf',
      'WoolWise',
      699.0,
      999.0,
      '🧣',
      'Apparel & Accessories',
      'Recycled wool blend',
      4.6,
      305,
      null,
      'VERDANT CERTIFIED • RECYCLED WOOL',
      'Cozy fringed scarf woven from recycled woolen garments',
      'Soft non-itchy weave keeps neck warm in chilly weather while diverting textile waste from landfills.'),
  Product(
      'p83',
      'Bamboo Fibre Ankle Socks (Pack of 3)',
      'BambooBliss',
      299.0,
      420.0,
      '🧦',
      'Apparel & Accessories',
      '80% Bamboo fibre, 20% spandex',
      4.7,
      1820,
      'BESTSELLER',
      'VERDANT CERTIFIED • THERMAL',
      'Super soft moisture-wicking anti-odor daily socks',
      'Bamboo fibres naturally inhibit odor-causing bacteria and keep feet cool, dry, and blister-free.'),
  Product(
      'p84',
      'Organic Cotton Tote Bag with Zipper',
      'SoftEarth',
      249.0,
      349.0,
      '🛍️',
      'Apparel & Accessories',
      'Organic unbleached canvas',
      4.5,
      930,
      null,
      'VERDANT CERTIFIED • ETHICAL',
      'Secure zippered shoulder tote with inner phone pocket',
      'Top zipper keeps belongings secure. Durable cross-stitched handles make it ideal for college and market trips.'),
  Product(
      'p85',
      'Upcycled Denim Sling Bag',
      'GreenWeave',
      449.0,
      649.0,
      '👝',
      'Apparel & Accessories',
      'Reclaimed cotton denim',
      4.4,
      380,
      null,
      'VERDANT CERTIFIED • ZERO WASTE',
      'Compact crossbody bag made from discarded blue jeans',
      'Features real denim pockets and vintage brass zippers. Each handcrafted bag has unique shading.'),
  Product(
      'p86',
      'Handcrafted Wood & Cork Sunglass Case',
      'PranaEarth',
      399.0,
      549.0,
      '🕶️',
      'Apparel & Accessories',
      'Natural cork & velvet lining',
      4.6,
      270,
      null,
      'VERDANT CERTIFIED • CRUSH PROOF',
      'Collapsible triangular sunglass holder with magnetic clasp',
      'Protects shades from scratches. Folds completely flat when empty to slide into any small pocket.'),
  Product(
      'p87',
      'Hand-carved Sheesham Wood Hair Stick',
      'PureVeda',
      149.0,
      220.0,
      '🥢',
      'Apparel & Accessories',
      'Sustainably harvested sheesham',
      4.7,
      490,
      null,
      'VERDANT CERTIFIED • HANDMADE',
      'Smooth traditional hair pin for secure updo buns',
      'Polished with organic oils. Holds thick buns effortlessly all day without hair ties or plastic claws.'),

  // ---------------- KIDS & BABY ----------------
  Product(
      'p88',
      'Organic Cotton Baby Onesie (Set of 2)',
      'TinySprout',
      499.0,
      699.0,
      '👶',
      'Kids & Baby',
      '100% GOTS Organic Cotton',
      4.8,
      520,
      null,
      'VERDANT CERTIFIED • GOTS ORGANIC',
      'Hypoallergenic infant bodysuit dyed with natural minerals',
      'Ultra-soft organic cotton free of pesticides, bleach, or synthetic finishes. Nickel-free snaps for easy diapering.'),
  Product(
      'p89',
      'Natural Wooden Teething Ring with Muslin Ears',
      'TinySprout',
      249.0,
      349.0,
      '🧸',
      'Kids & Baby',
      'Beechwood & organic muslin',
      4.7,
      340,
      null,
      'VERDANT CERTIFIED • TOXIN FREE',
      'Chemical-free beechwood ring with organic crinkle ears',
      'Solid European beechwood sanded smooth with natural coconut oil. Safe soothing relief for tender gums.'),
  Product(
      'p90',
      'Eco-Friendly Non-Toxic Beeswax Crayons (12 Colors)',
      'HiveHome',
      299.0,
      420.0,
      '🖍️',
      'Kids & Baby',
      'Pure beeswax & food grade pigments',
      4.8,
      890,
      'BESTSELLER',
      'VERDANT CERTIFIED • 100% NATURAL',
      'Triangular smudge-proof crayons safe for toddler hands',
      'Free of paraffin wax and heavy metals. Chunky triangular shape helps develop proper tripod pencil grip.'),
  Product(
      'p91',
      'Wooden Montessori Stacking Rainbow Toy',
      'TinySprout',
      599.0,
      849.0,
      '🌈',
      'Kids & Baby',
      'Natural pine wood & water colors',
      4.9,
      1140,
      'DEAL OF THE DAY',
      'VERDANT CERTIFIED • MONTESSORI',
      '7-piece open-ended stacking arches sparking creativity',
      'Hand-finished wooden arches encourage spatial awareness and motor skills with zero plastic packaging.'),
  Product(
      'p92',
      'Bamboo Baby Feeding Plate & Spoon Set',
      'BambooBliss',
      449.0,
      649.0,
      '🍽️',
      'Kids & Baby',
      'Natural bamboo & food silicone',
      4.7,
      760,
      null,
      'VERDANT CERTIFIED • BPA FREE',
      'Suction-base sectional plate preventing toddler spills',
      'Sticks firmly to high chair trays so meals stay off the floor. Soft silicone spoon tip is gentle on gums.'),
  Product(
      'p93',
      'Organic Bamboo Cotton Baby Swaddle Blanket',
      'SoftEarth',
      399.0,
      599.0,
      '🍼',
      'Kids & Baby',
      '70% Bamboo, 30% organic cotton',
      4.8,
      1310,
      'BESTSELLER',
      'VERDANT CERTIFIED • ULTRA SOFT',
      'Silky lightweight blanket keeping newborn comfortably snug',
      "Breathable open muslin weave regulates baby's body temperature and prevents overheating during sleep."),
  Product(
      'p94',
      'Reusable Washable Cloth Diaper with Bamboo Insert',
      'TinySprout',
      349.0,
      499.0,
      '🩲',
      'Kids & Baby',
      'Breathable PUL & bamboo fleece',
      4.6,
      980,
      null,
      'VERDANT CERTIFIED • ZERO WASTE',
      'Adjustable snap cloth nappy growing from newborn to toddler',
      'Replaces up to 6,000 single-use plastic disposable diapers. Leak-proof leg gussets prevent blowouts.'),
  Product(
      'p95',
      'Plant-Based Hypoallergenic Baby Wash Bar',
      'PureLeaf',
      199.0,
      280.0,
      '🫧',
      'Kids & Baby',
      'Oat milk & chamomile extract',
      4.7,
      430,
      null,
      'VERDANT CERTIFIED • TEAR FREE',
      'Tear-free soothing soap bar for sensitive infant skin',
      "Enriched with colloidal oatmeal and calendula flower. Cleanses baby's hair and skin without stinging eyes."),
  Product(
      'p96',
      'Hand-Knitted Organic Cotton Rattle Toy',
      'GreenWeave',
      299.0,
      399.0,
      '🦁',
      'Kids & Baby',
      'Organic cotton yarn & wood ring',
      4.8,
      380,
      null,
      'VERDANT CERTIFIED • FAIR TRADE',
      'Soft crochet lion rattle filled with organic corn fiber',
      'Hand-crocheted by women artisans. Gentle chiming bell inside stimulates auditory perception.'),
  Product(
      'p97',
      'Biodegradable Bamboo Baby Wipes (80 Wipes)',
      'BambooBliss',
      199.0,
      299.0,
      '👶',
      'Kids & Baby',
      '100% Bamboo cloth & 99% pure water',
      4.6,
      1720,
      'BESTSELLER',
      'VERDANT CERTIFIED • 100% COMPOSTABLE',
      'Plastic-free water wipes compostable in 60 days',
      'Thick textured bamboo cloths moistened with aloe vera and purified water. Fragrance and alcohol free.'),
  Product(
      'p98',
      'Wooden Alphabet Puzzle Blocks',
      'TinySprout',
      499.0,
      699.0,
      '🔤',
      'Kids & Baby',
      'FSC certified birchwood',
      4.8,
      640,
      null,
      'VERDANT CERTIFIED • PLASTIC FREE',
      '26 hand-printed letter blocks with non-toxic water ink',
      'Smooth rounded edges for little hands. Teaches letter sounds, spelling, and motor building without plastics.'),
  Product(
      'p99',
      'Organic Cotton Kids Sun Hat',
      'SoftEarth',
      299.0,
      399.0,
      '👒',
      'Kids & Baby',
      '100% Organic poplin cotton',
      4.6,
      310,
      null,
      'VERDANT CERTIFIED • UV PROTECTION',
      'Wide-brim bucket hat with chin tie keeping toddlers cool',
      'Breathable organic cotton shielding delicate scalp and neck from harsh sun during park and beach play.'),
  Product(
      'p100',
      'Stainless Steel Toddler Sippy Cup with Silicone Straw',
      'HydroGreen',
      449.0,
      649.0,
      '🥤',
      'Kids & Baby',
      '304 Steel & soft food silicone',
      4.7,
      850,
      'NEW',
      'VERDANT CERTIFIED • DROP PROOF',
      'Spill-proof toddler flask with easy-grip dual handles',
      'Double-walled steel keeps milk or fruit water chilled for 10 hours. Soft weighted silicone straw prevents colic.'),
];

// ============================================================================
// NAVIGATION HELPERS
// ============================================================================
void openProductList(
  BuildContext context, {
  String title = 'All Eco Products',
  List<Product>? source,
  String category = 'All',
  String query = '',
  double minPrice = 0,
  double maxPrice = kMaxPrice,
  double minRating = 0,
  String sort = 'Popular',
}) {
  Navigator.of(context).push(MaterialPageRoute(
    builder: (_) => ProductListPage(
      title: title,
      source: source ?? kProducts,
      initialCategory: category,
      initialQuery: query,
      initialMinPrice: minPrice,
      initialMaxPrice: maxPrice,
      initialMinRating: minRating,
      initialSort: sort,
    ),
  ));
}

// ============================================================================
// 1. HOME TAB
// ============================================================================
class HomeCatalogTab extends StatefulWidget {
  const HomeCatalogTab({Key? key}) : super(key: key);

  @override
  State<HomeCatalogTab> createState() => _HomeCatalogTabState();
}

class _HomeCatalogTabState extends State<HomeCatalogTab> {
  final TextEditingController _searchCtrl = TextEditingController();
  Timer? _timer;
  Duration _timeLeft = const Duration(hours: 8, minutes: 24, seconds: 15);

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _timeLeft = _timeLeft.inSeconds > 0
            ? _timeLeft - const Duration(seconds: 1)
            : const Duration(hours: 24);
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '${h}h : ${m}m : ${s}s';
  }

  void _search() {
    final q = _searchCtrl.text.trim();
    if (q.isEmpty) return;
    openProductList(context, title: 'Results for "$q"', query: q);
    _searchCtrl.clear();
  }

  Widget _rail(List<Product> products) {
    return SizedBox(
      height: 262,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: products.length,
        itemBuilder: (context, i) => Container(
          width: 160,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          child: ProductCard(product: products[i]),
        ),
      ),
    );
  }

  Widget _sectionHeader(IconData icon, Color color, String title,
      {VoidCallback? onSeeAll, Widget? extra}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 26, 16, 12),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 4),
          Expanded(
            child: Text(title,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold, color: kDark)),
          ),
          if (extra != null) ...[extra, const SizedBox(width: 8)],
          if (onSeeAll != null)
            InkWell(
              onTap: onSeeAll,
              child: const Text('See all →',
                  style: TextStyle(
                      color: kGreen,
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }

  Widget _pageTile(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kBorder),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                      color: kLightGreen, shape: BoxShape.circle),
                  child: Icon(icon, color: kGreen, size: 18),
                ),
                const SizedBox(height: 6),
                Text(label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 10, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _prefChip(String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(label),
        labelStyle: const TextStyle(
            fontSize: 11, fontWeight: FontWeight.w600, color: kGreen),
        backgroundColor: Colors.white,
        side: const BorderSide(color: kBorder),
        onPressed: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final deals = kProducts.where((p) => p.badge == 'DEAL OF THE DAY').toList();
    final best = kProducts.where((p) => p.badge == 'BESTSELLER').toList();
    final fresh = kProducts.where((p) => p.badge == 'NEW').toList();

    return ListView(
      padding: const EdgeInsets.only(bottom: 28),
      children: [
        // Search
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: TextField(
            controller: _searchCtrl,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _search(),
            decoration: InputDecoration(
              hintText: 'Search 100 eco-friendly products...',
              hintStyle: const TextStyle(color: kMuted, fontSize: 13),
              prefixIcon: const Icon(Icons.search, color: kGreen, size: 20),
              suffixIcon: IconButton(
                icon: const Icon(Icons.arrow_forward, color: kGreen, size: 18),
                onPressed: _search,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: kBorder)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: kGreen, width: 1.5)),
            ),
          ),
        ),

        // Hero
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E4D38), Color(0xFF112E21)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                      color: kRed, borderRadius: BorderRadius.circular(12)),
                  child: const Text('MONSOON SALE · UP TO 40% OFF',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 12),
                const Text('Sustainable Living\nMade Affordable',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        height: 1.2)),
                const SizedBox(height: 8),
                const Text(
                    '100 plastic-free items. Reusable, compostable and delivered with care.',
                    style: TextStyle(
                        color: Color(0xFFD4E6DC), fontSize: 12, height: 1.35)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => openProductList(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: kGreen,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  child: const Text('Shop Now →',
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),

        // SDG 12 (compact)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
          child: InkWell(
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const SdgPage())),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: kLightGreen,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Text('🌍', style: TextStyle(fontSize: 18)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text('Supports UN SDG 12 · Responsible Consumption',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: kGreen)),
                  ),
                  Text('Learn more →',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: kGreen)),
                ],
              ),
            ),
          ),
        ),

        // Quick pages
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: Row(
            children: [
              _pageTile(Icons.grid_view_rounded, 'All\nProducts',
                  () => openProductList(context)),
              _pageTile(
                  Icons.flash_on,
                  'Deals of\nthe Day',
                  () => openProductList(context,
                      title: 'Deals of the Day', source: deals)),
              _pageTile(
                  Icons.star_rounded,
                  'Best\nSellers',
                  () => openProductList(context,
                      title: 'Bestsellers', source: best)),
              _pageTile(
                  Icons.fiber_new_rounded,
                  'New\nArrivals',
                  () => openProductList(context,
                      title: 'New Arrivals', source: fresh)),
            ],
          ),
        ),

        // Preference shortcuts
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
          child: Text('Shop by preference',
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.bold, color: kDark)),
        ),
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _prefChip(
                  'Under ₹199',
                  () => openProductList(context,
                      title: 'Under ₹199', maxPrice: 199)),
              _prefChip(
                  '₹200 – ₹499',
                  () => openProductList(context,
                      title: '₹200 – ₹499', minPrice: 200, maxPrice: 499)),
              _prefChip(
                  '₹500 – ₹999',
                  () => openProductList(context,
                      title: '₹500 – ₹999', minPrice: 500, maxPrice: 999)),
              _prefChip(
                  '₹1000 & above',
                  () => openProductList(context,
                      title: '₹1000 & above', minPrice: 1000)),
              _prefChip(
                  '4.5★ & above',
                  () => openProductList(context,
                      title: '4.5★ & above',
                      minRating: 4.5,
                      sort: 'Rating: High to Low')),
              _prefChip(
                  '4★ & above',
                  () => openProductList(context,
                      title: '4★ & above',
                      minRating: 4,
                      sort: 'Rating: High to Low')),
              _prefChip(
                  'Price: Low to High',
                  () => openProductList(context,
                      title: 'Lowest price first', sort: 'Price: Low to High')),
            ],
          ),
        ),

        // Categories
        _sectionHeader(Icons.category_outlined, kGreen, 'Shop by Category'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: kCategories.length - 1,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 2.4,
            ),
            itemBuilder: (context, idx) {
              final cat = kCategories[idx + 1];
              final count =
                  kProducts.where((p) => p.category == cat.name).length;
              return InkWell(
                onTap: () => openProductList(context,
                    title: cat.name, category: cat.name),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: kBorder),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                            color: kLightGreen,
                            borderRadius: BorderRadius.circular(8)),
                        child: Center(
                            child: Text(cat.emoji,
                                style: const TextStyle(fontSize: 17))),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(cat.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: kDark)),
                            Text('$count products',
                                style: const TextStyle(
                                    fontSize: 10, color: kMuted)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Deals
        _sectionHeader(
          Icons.flash_on,
          const Color(0xFFE65100),
          'Deals of the Day',
          onSeeAll: () => openProductList(context,
              title: 'Deals of the Day', source: deals),
          extra: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFFFB74D)),
            ),
            child: Text(_formatDuration(_timeLeft),
                style: const TextStyle(
                    color: Color(0xFFE65100),
                    fontSize: 10,
                    fontWeight: FontWeight.bold)),
          ),
        ),
        _rail(deals),

        // Bestsellers
        _sectionHeader(Icons.star, kGold, 'Community Bestsellers',
            onSeeAll: () =>
                openProductList(context, title: 'Bestsellers', source: best)),
        _rail(best),

        // New arrivals
        _sectionHeader(Icons.fiber_new_rounded, kMidGreen, 'New Arrivals',
            onSeeAll: () =>
                openProductList(context, title: 'New Arrivals', source: fresh)),
        _rail(fresh),

        Padding(
          padding: const EdgeInsets.fromLTRB(16, 28, 16, 0),
          child: OutlinedButton(
            onPressed: () => openProductList(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: kGreen,
              side: const BorderSide(color: kGreen),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Browse all 100 products →',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// 2. PRODUCT LIST PAGE (search, category, rating, price, sort filters)
// ============================================================================
class ProductListPage extends StatefulWidget {
  final String title;
  final List<Product> source;
  final String initialCategory;
  final String initialQuery;
  final double initialMinPrice;
  final double initialMaxPrice;
  final double initialMinRating;
  final String initialSort;

  const ProductListPage({
    Key? key,
    required this.title,
    required this.source,
    this.initialCategory = 'All',
    this.initialQuery = '',
    this.initialMinPrice = 0,
    this.initialMaxPrice = kMaxPrice,
    this.initialMinRating = 0,
    this.initialSort = 'Popular',
  }) : super(key: key);

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  static const List<String> _sorts = [
    'Popular',
    'Price: Low to High',
    'Price: High to Low',
    'Rating: High to Low',
  ];

  late final TextEditingController _search;
  late String _category;
  late String _sort;
  late double _minRating;
  late RangeValues _range;

  @override
  void initState() {
    super.initState();
    _search = TextEditingController(text: widget.initialQuery);
    _category = widget.initialCategory;
    _sort = widget.initialSort;
    _minRating = widget.initialMinRating;
    _range = RangeValues(widget.initialMinPrice, widget.initialMaxPrice);
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<Product> _results() {
    final q = _search.text.toLowerCase().trim();
    final list = widget.source.where((p) {
      if (_category != 'All' && p.category != _category) return false;
      if (p.rating < _minRating) return false;
      if (p.price < _range.start || p.price > _range.end) return false;
      if (q.isNotEmpty) {
        final hay =
            '${p.name} ${p.brand} ${p.category} ${p.material} ${p.description}'
                .toLowerCase();
        if (!hay.contains(q)) return false;
      }
      return true;
    }).toList();

    switch (_sort) {
      case 'Price: Low to High':
        list.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Price: High to Low':
        list.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'Rating: High to Low':
        list.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      default:
        list.sort((a, b) {
          if (a.badge == 'BESTSELLER' && b.badge != 'BESTSELLER') return -1;
          if (a.badge != 'BESTSELLER' && b.badge == 'BESTSELLER') return 1;
          return b.reviews.compareTo(a.reviews);
        });
    }
    return list;
  }

  int get _activeFilters {
    int n = 0;
    if (_minRating > 0) n++;
    if (_range.start > 0 || _range.end < kMaxPrice) n++;
    if (_sort != 'Popular') n++;
    return n;
  }

  void _resetFilters() {
    setState(() {
      _minRating = 0;
      _range = const RangeValues(0, kMaxPrice);
      _sort = 'Popular';
      _category = 'All';
      _search.clear();
    });
  }

  Widget _filterChip(String label, bool selected, VoidCallback onTap) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      onSelected: (_) => onTap(),
      selectedColor: kGreen,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
          color: selected ? Colors.white : kDark,
          fontSize: 12,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal),
      side: BorderSide(color: selected ? kGreen : kBorder),
    );
  }

  void _openFilters() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) {
          void update(VoidCallback fn) {
            setState(fn);
            setSheet(() {});
          }

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('Filters',
                          style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      TextButton(
                        onPressed: () => update(() {
                          _minRating = 0;
                          _range = const RangeValues(0, kMaxPrice);
                          _sort = 'Popular';
                        }),
                        child:
                            const Text('Reset', style: TextStyle(color: kRed)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('Minimum rating',
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final r in [0.0, 3.5, 4.0, 4.5])
                        _filterChip(
                            r == 0 ? 'Any' : '$r★ & up',
                            _minRating == r,
                            () => update(() => _minRating = r)),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      const Text('Price range',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      Text('${fmt(_range.start)} – ${fmt(_range.end)}',
                          style: const TextStyle(
                              color: kGreen, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  RangeSlider(
                    values: _range,
                    min: 0,
                    max: kMaxPrice,
                    divisions: 50,
                    activeColor: kGreen,
                    labels: RangeLabels(fmt(_range.start), fmt(_range.end)),
                    onChanged: (v) => update(() => _range = v),
                  ),
                  const SizedBox(height: 10),
                  const Text('Sort by',
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      for (final s in _sorts)
                        _filterChip(
                            s, _sort == s, () => update(() => _sort = s)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text('Show ${_results().length} items',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final results = _results();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        actions: [
          Consumer<CartProvider>(
            builder: (context, cart, _) => Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_bag_outlined),
                  onPressed: () => goToTab(context, kCartTab),
                ),
                if (cart.itemCount > 0)
                  Positioned(
                    top: 8,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                          color: kGreen, shape: BoxShape.circle),
                      child: Text('${cart.itemCount}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _search,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Search by item name, brand, material...',
                      hintStyle: const TextStyle(color: kMuted, fontSize: 12),
                      prefixIcon:
                          const Icon(Icons.search, color: kGreen, size: 20),
                      suffixIcon: _search.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () => setState(() => _search.clear()),
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: kBorder)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: kGreen, width: 1.5)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                InkWell(
                  onTap: _openFilters,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _activeFilters > 0 ? kGreen : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: kGreen),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.tune,
                            size: 20,
                            color: _activeFilters > 0 ? Colors.white : kGreen),
                        if (_activeFilters > 0) ...[
                          const SizedBox(width: 4),
                          Text('$_activeFilters',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12)),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: kCategories.length,
              itemBuilder: (context, idx) {
                final cat = kCategories[idx];
                final sel = _category == cat.name;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    avatar:
                        Text(cat.emoji, style: const TextStyle(fontSize: 14)),
                    label: Text(cat.name),
                    showCheckmark: false,
                    selected: sel,
                    onSelected: (_) => setState(() => _category = cat.name),
                    selectedColor: kGreen,
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                        color: sel ? Colors.white : kDark,
                        fontSize: 12,
                        fontWeight: sel ? FontWeight.bold : FontWeight.normal),
                    side: BorderSide(color: sel ? kGreen : kBorder),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18)),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(
              children: [
                Text('${results.length} items',
                    style: const TextStyle(
                        color: kMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
                const Spacer(),
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _sort,
                    isDense: true,
                    icon: const Icon(Icons.arrow_drop_down, color: kGreen),
                    style: const TextStyle(
                        color: kDark,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                    onChanged: (v) => setState(() => _sort = v ?? _sort),
                    items: [
                      for (final s in _sorts)
                        DropdownMenuItem(value: s, child: Text(s)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: results.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🔍', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 10),
                        const Text('No eco products found',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        const Text('Try changing your search or filters',
                            style: TextStyle(color: kMuted, fontSize: 12)),
                        const SizedBox(height: 14),
                        OutlinedButton(
                          onPressed: _resetFilters,
                          style:
                              OutlinedButton.styleFrom(foregroundColor: kGreen),
                          child: const Text('Reset all filters'),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: results.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.6,
                    ),
                    itemBuilder: (context, i) =>
                        ProductCard(product: results[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 3. PRODUCT CARD
// ============================================================================
class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final wishlist = Provider.of<WishlistProvider>(context);
    final inCart = cart.isInCart(product.id);
    final qty = cart.getProductQuantity(product.id);
    final isWishlisted = wishlist.isWishlisted(product.id);

    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
            builder: (_) => ProductDetailScreen(product: product)),
      ),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ProductImageWidget(
                  product: product,
                  height: 120,
                  width: double.infinity,
                  borderRadius: 12,
                ),
                if (product.badge != null)
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: product.badge == 'DEAL OF THE DAY'
                            ? kRed
                            : (product.badge == 'BESTSELLER'
                                ? const Color(0xFFD97706)
                                : kMidGreen),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(product.badge!,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: InkWell(
                    onTap: () => wishlist.toggle(product.id),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(
                          color: Color(0xE6FFFFFF), shape: BoxShape.circle),
                      child: Icon(
                        isWishlisted ? Icons.favorite : Icons.favorite_border,
                        color: isWishlisted ? kRed : kMuted,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.brand.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 9,
                            color: kMuted,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3)),
                    const SizedBox(height: 2),
                    Text(product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: kDark,
                            height: 1.15)),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.star, color: kGold, size: 12),
                        const SizedBox(width: 2),
                        Text('${product.rating}',
                            style: const TextStyle(
                                fontSize: 10, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 2),
                        Text('(${product.reviews})',
                            style: const TextStyle(fontSize: 9, color: kMuted)),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(fmt(product.price),
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: kGreen)),
                        const SizedBox(width: 4),
                        Text(fmt(product.mrp),
                            style: const TextStyle(
                                fontSize: 10,
                                color: kMuted,
                                decoration: TextDecoration.lineThrough)),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                              color: kLightGreen,
                              borderRadius: BorderRadius.circular(3)),
                          child: Text('${product.discountPercent}%',
                              style: const TextStyle(
                                  color: kGreen,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      width: double.infinity,
                      height: 28,
                      child: inCart
                          ? Container(
                              decoration: BoxDecoration(
                                color: kLightGreen,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: kGreen.withAlpha(76)),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  InkWell(
                                    onTap: () => cart.removeItem(product.id),
                                    child: const Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 8),
                                      child: Icon(Icons.remove,
                                          size: 14, color: kGreen),
                                    ),
                                  ),
                                  Text('$qty',
                                      style: const TextStyle(
                                          color: kGreen,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12)),
                                  InkWell(
                                    onTap: () => cart.addItem(product),
                                    child: const Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 8),
                                      child: Icon(Icons.add,
                                          size: 14, color: kGreen),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ElevatedButton(
                              onPressed: () {
                                cart.addItem(product);
                                ScaffoldMessenger.of(context)
                                  ..hideCurrentSnackBar()
                                  ..showSnackBar(SnackBar(
                                    content: Text(
                                        '${product.name} added to cart 🌱'),
                                    duration: const Duration(seconds: 1),
                                    behavior: SnackBarBehavior.floating,
                                    backgroundColor: kGreen,
                                  ));
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kGreen,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6)),
                              ),
                              child: const Text('+ Add',
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold)),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 4. PRODUCT DETAIL (5-image gallery)
// ============================================================================
class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({Key? key, required this.product})
      : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final PageController _pager = PageController();
  int _page = 0;

  @override
  void dispose() {
    _pager.dispose();
    super.dispose();
  }

  Widget _gallery(Product product, int n, List<UnsplashPhoto>? photos) {
    final credit = (photos != null && photos.isNotEmpty)
        ? photos[_page % photos.length].credit
        : null;
    return Column(
      children: [
        SizedBox(
          height: 300,
          child: Stack(
            children: [
              PageView.builder(
                controller: _pager,
                itemCount: n,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, i) => GestureDetector(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => ImageViewerPage(
                          product: product, startIndex: i, count: n))),
                  child: ProductImageWidget(
                    product: product,
                    index: i,
                    width: double.infinity,
                    height: 300,
                    borderRadius: 0,
                  ),
                ),
              ),
              Positioned(
                right: 12,
                bottom: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(12)),
                  child: Text('${_page + 1}/$n',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 62,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: n,
            itemBuilder: (context, i) => GestureDetector(
              onTap: () => _pager.animateToPage(i,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut),
              child: Container(
                width: 62,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: i == _page ? kGreen : kBorder,
                      width: i == _page ? 2 : 1),
                ),
                child: ProductImageWidget(
                    product: product,
                    index: i,
                    width: 62,
                    height: 62,
                    borderRadius: 6),
              ),
            ),
          ),
        ),
        if (credit != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text('Photo by $credit on Unsplash',
                style: const TextStyle(fontSize: 10, color: kMuted)),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final photos = context.watch<UnsplashProvider>().photosFor(product);
    final int n = (photos != null && photos.isNotEmpty)
        ? (photos.length < Product.imageCount
            ? photos.length
            : Product.imageCount)
        : Product.imageCount;
    final cart = Provider.of<CartProvider>(context);
    final wishlist = Provider.of<WishlistProvider>(context);
    final inCart = cart.isInCart(product.id);
    final isWishlisted = wishlist.isWishlisted(product.id);
    final similar = kProducts
        .where((p) => p.category == product.category && p.id != product.id)
        .take(6)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(product.name,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: Icon(isWishlisted ? Icons.favorite : Icons.favorite_border,
                color: isWishlisted ? kRed : kDark),
            onPressed: () => wishlist.toggle(product.id),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 100),
        children: [
          _gallery(product, n, photos),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                      color: kLightGreen,
                      borderRadius: BorderRadius.circular(4)),
                  child: Text(product.certTag,
                      style: const TextStyle(
                          color: kGreen,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3)),
                ),
                const SizedBox(height: 10),
                Text(product.brand.toUpperCase(),
                    style: const TextStyle(
                        fontSize: 11,
                        color: kMuted,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5)),
                const SizedBox(height: 4),
                Text(product.name,
                    style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: kDark)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                          color: kGreen,
                          borderRadius: BorderRadius.circular(4)),
                      child: Row(
                        children: [
                          Text('${product.rating}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(width: 2),
                          const Icon(Icons.star, color: Colors.white, size: 10),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('${product.reviews} ratings',
                        style: const TextStyle(color: kMuted, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(fmt(product.price),
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: kGreen)),
                    const SizedBox(width: 8),
                    Text(fmt(product.mrp),
                        style: const TextStyle(
                            fontSize: 14,
                            color: kMuted,
                            decoration: TextDecoration.lineThrough)),
                    const SizedBox(width: 8),
                    Text('${product.discountPercent}% OFF',
                        style: const TextStyle(
                            color: kRed,
                            fontSize: 14,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                    'Inclusive of all taxes · You save ${fmt(product.mrp - product.price)}',
                    style: const TextStyle(color: kMuted, fontSize: 11)),
                const SizedBox(height: 18),
                const Divider(color: kBorder),
                const SizedBox(height: 10),
                const Text('Eco-Friendly Specifications',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: kDark)),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FBF9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: kBorder),
                  ),
                  child: Column(
                    children: [
                      _specRow('Category', product.category),
                      const Divider(height: 16, color: kBorder),
                      _specRow('Primary Material', product.material),
                      const Divider(height: 16, color: kBorder),
                      _specRow('Packaging', '100% recycled, plastic-free'),
                      const Divider(height: 16, color: kBorder),
                      _specRow('SDG link', 'Goal 12 · Responsible Consumption'),
                      const Divider(height: 16, color: kBorder),
                      _specRow('Delivery',
                          'Free above ₹499, else ₹40 · Arrives in 3 days'),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                const Text('About this Product',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: kDark)),
                const SizedBox(height: 6),
                Text(product.shortDesc,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: kDark)),
                const SizedBox(height: 6),
                Text(product.description,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF374151), height: 1.4)),
                const SizedBox(height: 22),
                const Text('Customer Reviews',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: kDark)),
                const SizedBox(height: 8),
                _reviewTile('Priya Sharma', '3 days ago', 5,
                    'Outstanding quality and genuinely plastic-free. Delivered in recycled cardboard!'),
                _reviewTile('Rahul Nair', '1 week ago', 4,
                    'Loved the product. Looks natural and feels durable.'),
                const SizedBox(height: 22),
                const Text('Similar Eco Picks',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: kDark)),
                const SizedBox(height: 12),
                SizedBox(
                  height: 262,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: similar.length,
                    itemBuilder: (context, i) => Container(
                      width: 160,
                      margin: const EdgeInsets.only(right: 10),
                      child: ProductCard(product: similar[i]),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: kBorder))),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Price:',
                      style: TextStyle(color: kMuted, fontSize: 10)),
                  Text(fmt(product.price),
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: kGreen)),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (inCart) {
                      goToTab(context, kCartTab);
                    } else {
                      cart.addItem(product);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('${product.name} added to cart 🌱'),
                        duration: const Duration(seconds: 1),
                        backgroundColor: kGreen,
                      ));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: Icon(
                      inCart ? Icons.shopping_bag : Icons.add_shopping_cart,
                      size: 18),
                  label: Text(inCart ? 'View in Cart' : 'Add to Cart',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _specRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(label,
              style: const TextStyle(
                  color: kMuted, fontSize: 11, fontWeight: FontWeight.w500)),
        ),
        Expanded(
          child: Text(value,
              style: const TextStyle(
                  color: kDark, fontSize: 11, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _reviewTile(String name, String date, int rating, String comment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(width: 6),
              ...List.generate(
                  5,
                  (i) => Icon(i < rating ? Icons.star : Icons.star_border,
                      color: kGold, size: 12)),
              const Spacer(),
              Text(date, style: const TextStyle(color: kMuted, fontSize: 10)),
            ],
          ),
          const SizedBox(height: 6),
          Text(comment,
              style: const TextStyle(
                  fontSize: 11, color: Color(0xFF4B5563), height: 1.35)),
        ],
      ),
    );
  }
}

class ImageViewerPage extends StatelessWidget {
  final Product product;
  final int startIndex;
  final int count;
  const ImageViewerPage(
      {Key? key,
      required this.product,
      required this.startIndex,
      this.count = Product.imageCount})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(product.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14)),
      ),
      body: PageView.builder(
        controller: PageController(initialPage: startIndex),
        itemCount: count,
        itemBuilder: (context, i) => InteractiveViewer(
          minScale: 1,
          maxScale: 4,
          child: Center(
            child: ProductImageWidget(
              product: product,
              index: i,
              width: double.infinity,
              fit: BoxFit.contain,
              borderRadius: 0,
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// 5. WISHLIST TAB
// ============================================================================
class WishlistTab extends StatelessWidget {
  const WishlistTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final wishlist = Provider.of<WishlistProvider>(context);
    final cart = Provider.of<CartProvider>(context);
    final saved = wishlist.getProducts(kProducts);

    if (saved.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                  color: kLightGreen, shape: BoxShape.circle),
              child: const Icon(Icons.favorite_border, color: kGreen, size: 48),
            ),
            const SizedBox(height: 16),
            const Text('Your Wishlist is Empty',
                style: TextStyle(
                    fontSize: 17, fontWeight: FontWeight.bold, color: kDark)),
            const SizedBox(height: 6),
            const Text('Tap the heart on any product to save it here.',
                style: TextStyle(color: kMuted, fontSize: 12)),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: () => openProductList(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: kGreen,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Explore products'),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            const Text('Saved Items',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: kDark)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                  color: kLightGreen, borderRadius: BorderRadius.circular(10)),
              child: Text('${saved.length}',
                  style: const TextStyle(
                      color: kGreen,
                      fontSize: 11,
                      fontWeight: FontWeight.bold)),
            ),
            const Spacer(),
            OutlinedButton.icon(
              onPressed: () {
                for (final p in saved) {
                  cart.addItem(p);
                }
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('All saved items added to cart 🌱'),
                  backgroundColor: kGreen,
                  duration: Duration(seconds: 1),
                ));
              },
              style: OutlinedButton.styleFrom(
                  foregroundColor: kGreen,
                  side: const BorderSide(color: kGreen),
                  visualDensity: VisualDensity.compact),
              icon: const Icon(Icons.shopping_bag_outlined, size: 15),
              label:
                  const Text('Add all to cart', style: TextStyle(fontSize: 11)),
            ),
          ],
        ),
        const SizedBox(height: 14),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: saved.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 14,
            crossAxisSpacing: 12,
            childAspectRatio: 0.6,
          ),
          itemBuilder: (context, i) => ProductCard(product: saved[i]),
        ),
      ],
    );
  }
}

// ============================================================================
// 6. CART TAB (no coupons)
// ============================================================================
class CartTab extends StatelessWidget {
  const CartTab({Key? key}) : super(key: key);

  void _checkout(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (!auth.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please sign in to place your order'),
        backgroundColor: kRed,
      ));
      kTab.value = kAccountTab;
      return;
    }
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const CheckoutPage()));
  }

  Widget _priceRow(String label, String value,
      {bool bold = false, double size = 12, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: size,
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                color: kDark)),
        Text(value,
            style: TextStyle(
                fontSize: size,
                fontWeight: bold ? FontWeight.bold : FontWeight.w600,
                color: color ?? kDark)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final items = cart.items.values.toList();
    final free = cart.itemsSubtotal >= kFreeDeliveryAbove;

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: const BoxDecoration(
                  color: kLightGreen, shape: BoxShape.circle),
              child: const Icon(Icons.shopping_bag_outlined,
                  color: kGreen, size: 52),
            ),
            const SizedBox(height: 16),
            const Text('Your Cart is Empty',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: kDark)),
            const SizedBox(height: 6),
            const Text('Explore 100 plastic-free items.',
                style: TextStyle(color: kMuted, fontSize: 12)),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: () => openProductList(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: kGreen,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Start Shopping'),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: kBg,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 110),
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: free ? const Color(0xFFE8F5E9) : const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color:
                      free ? const Color(0xFF81C784) : const Color(0xFFFDE68A)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                        free
                            ? Icons.check_circle
                            : Icons.local_shipping_outlined,
                        size: 16,
                        color: free
                            ? const Color(0xFF2E7D32)
                            : const Color(0xFFD97706)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        free
                            ? '🎉 You unlocked FREE delivery!'
                            : 'Add ${fmt(cart.amountNeededForFreeDelivery)} more to unlock FREE delivery',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: free
                                ? const Color(0xFF1B5E20)
                                : const Color(0xFF92400E)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: cart.freeDeliveryProgress,
                    minHeight: 6,
                    backgroundColor: Colors.white,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        free ? kGreen : const Color(0xFFF59E0B)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text('Cart Items (${cart.itemCount})',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold, color: kDark)),
              const Spacer(),
              TextButton.icon(
                onPressed: cart.clearCart,
                icon: const Icon(Icons.delete_outline, size: 16, color: kRed),
                label: const Text('Clear',
                    style: TextStyle(color: kRed, fontSize: 12)),
              ),
            ],
          ),
          ...items.map((item) => Dismissible(
                key: Key(item.product.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  decoration: BoxDecoration(
                      color: kRed, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) => cart.deleteItem(item.product.id),
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kBorder),
                  ),
                  child: Row(
                    children: [
                      ProductImageWidget(
                          product: item.product,
                          width: 64,
                          height: 64,
                          borderRadius: 8),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.product.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: kDark)),
                            const SizedBox(height: 2),
                            Text(item.product.material,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 10, color: kMuted)),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Text(fmt(item.product.price),
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: kGreen)),
                                const SizedBox(width: 6),
                                Text(fmt(item.product.mrp),
                                    style: const TextStyle(
                                        fontSize: 10,
                                        color: kMuted,
                                        decoration:
                                            TextDecoration.lineThrough)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                            color: kLightGreen,
                            borderRadius: BorderRadius.circular(6)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove,
                                  size: 14, color: kGreen),
                              padding: const EdgeInsets.all(6),
                              constraints: const BoxConstraints(),
                              onPressed: () => cart.removeItem(item.product.id),
                            ),
                            Text('${item.quantity}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: kGreen)),
                            IconButton(
                              icon: const Icon(Icons.add,
                                  size: 14, color: kGreen),
                              padding: const EdgeInsets.all(6),
                              constraints: const BoxConstraints(),
                              onPressed: () => cart.addItem(item.product),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Price Details',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: kDark)),
                const SizedBox(height: 12),
                _priceRow('Total MRP', fmt(cart.mrpTotal)),
                const SizedBox(height: 8),
                _priceRow('Discount on MRP',
                    '- ${fmt(cart.mrpTotal - cart.itemsSubtotal)}',
                    color: const Color(0xFF2E7D32)),
                const SizedBox(height: 8),
                _priceRow('Delivery',
                    cart.deliveryFee == 0 ? 'FREE' : fmt(cart.deliveryFee),
                    color: cart.deliveryFee == 0
                        ? const Color(0xFF2E7D32)
                        : kDark),
                const Divider(height: 20, color: kBorder),
                _priceRow('Total Amount', fmt(cart.totalAmount),
                    bold: true, size: 16, color: kGreen),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                      color: kLightGreen,
                      borderRadius: BorderRadius.circular(6)),
                  child: Center(
                    child: Text(
                        '🌱 You save ${fmt(cart.totalSavings)} on this order!',
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: kGreen)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: kBorder))),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Total to Pay:',
                    style: TextStyle(color: kMuted, fontSize: 10)),
                Text(fmt(cart.totalAmount),
                    style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: kGreen)),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _checkout(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.lock_outline, size: 16),
                label: Text('Checkout (${cart.itemCount})',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 7. CUSTOMER DETAILS FORM (shared by Checkout and Account > Address)
// ============================================================================
class AddressFormController {
  final name = TextEditingController();
  final phone = TextEditingController();
  final email = TextEditingController();
  final line1 = TextEditingController();
  final line2 = TextEditingController();
  final landmark = TextEditingController();
  final city = TextEditingController();
  final pincode = TextEditingController();
  String? state;

  void fill(CustomerDetails? d, {String? fallbackEmail, String? fallbackName}) {
    if (d != null) {
      name.text = d.fullName;
      phone.text = d.phone;
      email.text = d.email;
      line1.text = d.line1;
      line2.text = d.line2;
      landmark.text = d.landmark;
      city.text = d.city;
      pincode.text = d.pincode;
      state = kIndianStates.contains(d.state) ? d.state : null;
    } else {
      email.text = fallbackEmail ?? '';
      name.text = fallbackName ?? '';
    }
  }

  CustomerDetails toDetails() => CustomerDetails(
        fullName: name.text.trim(),
        phone: phone.text.trim(),
        email: email.text.trim(),
        line1: line1.text.trim(),
        line2: line2.text.trim(),
        landmark: landmark.text.trim(),
        city: city.text.trim(),
        state: state ?? '',
        pincode: pincode.text.trim(),
      );

  void dispose() {
    name.dispose();
    phone.dispose();
    email.dispose();
    line1.dispose();
    line2.dispose();
    landmark.dispose();
    city.dispose();
    pincode.dispose();
  }
}

InputDecoration _formDec(String label, {IconData? icon, String? hint}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    labelStyle: const TextStyle(fontSize: 13),
    hintStyle: const TextStyle(fontSize: 12, color: kMuted),
    prefixIcon: icon == null ? null : Icon(icon, color: kGreen, size: 18),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
    enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: kBorder)),
    focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: kGreen, width: 1.5)),
    errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: kRed)),
    focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: kRed, width: 1.5)),
  );
}

class AddressFormFields extends StatefulWidget {
  final AddressFormController c;
  const AddressFormFields({Key? key, required this.c}) : super(key: key);

  @override
  State<AddressFormFields> createState() => _AddressFormFieldsState();
}

class _AddressFormFieldsState extends State<AddressFormFields> {
  String? _req(String? v, String label, {int min = 1}) =>
      (v == null || v.trim().length < min) ? 'Please enter $label' : null;

  @override
  Widget build(BuildContext context) {
    final c = widget.c;
    const gap = SizedBox(height: 14);
    return Column(
      children: [
        TextFormField(
          controller: c.name,
          textCapitalization: TextCapitalization.words,
          decoration: _formDec('Full name *', icon: Icons.person_outline),
          validator: (v) => _req(v, 'your full name', min: 2),
        ),
        gap,
        TextFormField(
          controller: c.phone,
          keyboardType: TextInputType.phone,
          maxLength: 10,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: _formDec('Mobile number *',
                  icon: Icons.phone_outlined, hint: '10-digit number')
              .copyWith(counterText: ''),
          validator: (v) => RegExp(r'^[6-9]\d{9}$').hasMatch((v ?? '').trim())
              ? null
              : 'Enter a valid 10-digit mobile number',
        ),
        gap,
        TextFormField(
          controller: c.email,
          keyboardType: TextInputType.emailAddress,
          decoration: _formDec('Email address *', icon: Icons.email_outlined),
          validator: (v) =>
              RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch((v ?? '').trim())
                  ? null
                  : 'Enter a valid email address',
        ),
        gap,
        TextFormField(
          controller: c.line1,
          textCapitalization: TextCapitalization.words,
          decoration:
              _formDec('House / Flat / Building *', icon: Icons.home_outlined),
          validator: (v) => _req(v, 'your house / flat / building', min: 3),
        ),
        gap,
        TextFormField(
          controller: c.line2,
          textCapitalization: TextCapitalization.words,
          decoration:
              _formDec('Street / Area / Colony', icon: Icons.signpost_outlined),
        ),
        gap,
        TextFormField(
          controller: c.landmark,
          textCapitalization: TextCapitalization.words,
          decoration:
              _formDec('Landmark (optional)', icon: Icons.flag_outlined),
        ),
        gap,
        TextFormField(
          controller: c.city,
          textCapitalization: TextCapitalization.words,
          decoration:
              _formDec('City / Town *', icon: Icons.location_city_outlined),
          validator: (v) => _req(v, 'your city', min: 2),
        ),
        gap,
        DropdownButtonFormField<String>(
          value: c.state,
          isExpanded: true,
          decoration: _formDec('State *', icon: Icons.map_outlined),
          items: [
            for (final s in kIndianStates)
              DropdownMenuItem(value: s, child: Text(s)),
          ],
          onChanged: (v) => setState(() => c.state = v),
          validator: (v) => v == null ? 'Please select your state' : null,
        ),
        gap,
        TextFormField(
          controller: c.pincode,
          keyboardType: TextInputType.number,
          maxLength: 6,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: _formDec('Pincode *',
                  icon: Icons.pin_drop_outlined, hint: '6-digit pincode')
              .copyWith(counterText: ''),
          validator: (v) => RegExp(r'^[1-9]\d{5}$').hasMatch((v ?? '').trim())
              ? null
              : 'Enter a valid 6-digit pincode',
        ),
      ],
    );
  }
}

/// Edit / save the delivery details from the Account tab.
class AddressPage extends StatefulWidget {
  const AddressPage({Key? key}) : super(key: key);

  @override
  State<AddressPage> createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
  final _formKey = GlobalKey<FormState>();
  final _c = AddressFormController();

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    final saved = Provider.of<AddressProvider>(context, listen: false)
        .forUser(user?.email ?? '');
    _c.fill(saved, fallbackEmail: user?.email, fallbackName: user?.name);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser!;
    Provider.of<AddressProvider>(context, listen: false)
        .save(user.email, _c.toDetails());
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Delivery details saved ✅'), backgroundColor: kGreen));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Delivery Details',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
      body: Form(
        key: _formKey,
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(16),
          children: [
            AddressFormFields(c: _c),
            const SizedBox(height: 20),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Save Details',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 8. CHECKOUT PAGE
// ============================================================================
class CheckoutPage extends StatefulWidget {
  const CheckoutPage({Key? key}) : super(key: key);

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _c = AddressFormController();
  String _payment = 'UPI (GPay / PhonePe / Paytm)';
  bool _saveAddress = true;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    final saved = Provider.of<AddressProvider>(context, listen: false)
        .forUser(user?.email ?? '');
    _c.fill(saved, fallbackEmail: user?.email, fallbackName: user?.name);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _place() {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please fill all required details'),
          backgroundColor: kRed));
      return;
    }
    final cart = Provider.of<CartProvider>(context, listen: false);
    final orders = Provider.of<OrdersProvider>(context, listen: false);
    final addr = Provider.of<AddressProvider>(context, listen: false);
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser!;
    final messenger = ScaffoldMessenger.of(context);
    final details = _c.toDetails();

    final count = orders.placeFromCart(cart, details, _payment, user.email);
    if (_saveAddress) addr.save(user.email, details);
    cart.clearCart();

    goToTab(context, kOrdersTab);
    messenger.showSnackBar(SnackBar(
      content: Text(count == 1
          ? '🎉 Order placed! Track it in Orders.'
          : '🎉 $count orders placed (one per product)! Track them in Orders.'),
      backgroundColor: kGreen,
      duration: const Duration(seconds: 4),
    ));
  }

  Widget _section(String title, Widget child) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.bold, color: kDark)),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _pay(String value) {
    return RadioListTile<String>(
      value: value,
      groupValue: _payment,
      dense: true,
      activeColor: kGreen,
      contentPadding: EdgeInsets.zero,
      title: Text(value, style: const TextStyle(fontSize: 12)),
      onChanged: (v) => setState(() => _payment = v!),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final items = cart.items.values.toList();

    return Scaffold(
      appBar: AppBar(
          title: const Text('Checkout',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
      body: Form(
        key: _formKey,
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
          children: [
            _section(
              'Delivery details',
              Column(
                children: [
                  AddressFormFields(c: _c),
                  const SizedBox(height: 6),
                  CheckboxListTile(
                    value: _saveAddress,
                    onChanged: (v) => setState(() => _saveAddress = v ?? true),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    activeColor: kGreen,
                    controlAffinity: ListTileControlAffinity.leading,
                    title: const Text('Save these details for next time',
                        style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
            _section(
              'Payment method',
              Column(
                children: [
                  _pay('UPI (GPay / PhonePe / Paytm)'),
                  _pay('Cash on Delivery'),
                  _pay('Card on Delivery'),
                ],
              ),
            ),
            _section(
              'Order summary (${items.length} ${items.length == 1 ? 'order' : 'separate orders'})',
              Column(
                children: [
                  for (final it in items)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        children: [
                          ProductImageWidget(
                              product: it.product,
                              width: 44,
                              height: 44,
                              borderRadius: 6),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(it.product.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w600)),
                          ),
                          const SizedBox(width: 8),
                          Text('×${it.quantity}  ${fmt(it.subtotal)}',
                              style:
                                  const TextStyle(fontSize: 11, color: kMuted)),
                        ],
                      ),
                    ),
                  const Divider(height: 22, color: kBorder),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Delivery', style: TextStyle(fontSize: 12)),
                      Text(
                          cart.deliveryFee == 0
                              ? 'FREE'
                              : fmt(cart.deliveryFee),
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                      Text(fmt(cart.totalAmount),
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: kGreen)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: kBorder))),
        child: SafeArea(
          top: false,
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: items.isEmpty ? null : _place,
              style: ElevatedButton.styleFrom(
                backgroundColor: kGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: Text('Place Order · ${fmt(cart.totalAmount)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14)),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// 9. ORDERS TAB (one card per product order)
// ============================================================================
Widget _statusPill(OrderModel o) {
  final done = o.step == 5;
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: done ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(o.status,
        style: TextStyle(
            color: done ? const Color(0xFF2E7D32) : const Color(0xFFE65100),
            fontSize: 10,
            fontWeight: FontWeight.bold)),
  );
}

class OrdersTab extends StatefulWidget {
  const OrdersTab({Key? key}) : super(key: key);

  @override
  State<OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<OrdersTab> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Widget _tracker(OrderModel o) {
    final children = <Widget>[];
    for (int s = 1; s <= 5; s++) {
      final done = o.step >= s;
      children.add(Column(
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: done ? kGreen : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: done ? kGreen : kBorder, width: 2),
            ),
            child: done
                ? const Icon(Icons.check, size: 10, color: Colors.white)
                : null,
          ),
          const SizedBox(height: 4),
          Text(OrderModel.stepShort[s - 1],
              style: TextStyle(
                  fontSize: 8.5,
                  fontWeight: o.step == s ? FontWeight.bold : FontWeight.normal,
                  color: done ? kGreen : kMuted)),
        ],
      ));
      if (s < 5) {
        children.add(Expanded(
          child: Container(
            height: 2,
            color: o.step > s ? kGreen : kBorder,
            margin: const EdgeInsets.only(bottom: 14),
          ),
        ));
      }
    }
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, children: children);
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final ordersProv = Provider.of<OrdersProvider>(context);

    if (!auth.isLoggedIn) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline, color: kGreen, size: 48),
            const SizedBox(height: 14),
            const Text('Sign in to see your orders',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: () => kTab.value = kAccountTab,
              style: ElevatedButton.styleFrom(
                backgroundColor: kGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Go to Account'),
            ),
          ],
        ),
      );
    }

    final orders = ordersProv.ordersFor(auth.currentUser!.email);

    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.local_shipping_outlined, color: kGreen, size: 52),
            const SizedBox(height: 16),
            const Text('No Orders Yet',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text('Your orders will appear here with live tracking.',
                style: TextStyle(color: kMuted, fontSize: 12)),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: () => openProductList(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: kGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Start Shopping'),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            const Text('My Orders',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: kDark)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                  color: kLightGreen, borderRadius: BorderRadius.circular(10)),
              child: Text('${orders.length}',
                  style: const TextStyle(
                      color: kGreen,
                      fontSize: 11,
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 14),
        for (final o in orders)
          InkWell(
            onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => OrderDetailPage(order: o))),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: kBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Order ${o.id}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: kDark)),
                            Text(formatDateTime(o.placedAt),
                                style: const TextStyle(
                                    fontSize: 10, color: kMuted)),
                          ],
                        ),
                      ),
                      _statusPill(o),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ProductImageWidget(
                          product: o.product,
                          width: 60,
                          height: 60,
                          borderRadius: 8),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(o.product.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 3),
                            Text('Qty ${o.quantity} × ${fmt(o.product.price)}',
                                style: const TextStyle(
                                    fontSize: 11, color: kMuted)),
                            const SizedBox(height: 3),
                            Text('Total ${fmt(o.total)}',
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: kGreen)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _tracker(o),
                  const SizedBox(height: 10),
                  const Divider(height: 1, color: kBorder),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                            'Deliver to ${o.details.fullName}, ${o.details.city} - ${o.details.pincode}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style:
                                const TextStyle(fontSize: 10, color: kMuted)),
                      ),
                      const Text('View details →',
                          style: TextStyle(
                              fontSize: 11,
                              color: kGreen,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

// ============================================================================
// 10. ORDER DETAIL PAGE (full order history of one product)
// ============================================================================
class OrderDetailPage extends StatefulWidget {
  final OrderModel order;
  const OrderDetailPage({Key? key, required this.order}) : super(key: key);

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Widget _card(String title, Widget child) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.bold, color: kDark)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _kv(String k, String v, {Color? color, bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 110,
              child:
                  Text(k, style: const TextStyle(fontSize: 11, color: kMuted))),
          Expanded(
            child: Text(v,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: bold ? FontWeight.bold : FontWeight.w600,
                    color: color ?? kDark)),
          ),
        ],
      ),
    );
  }

  Widget _timeline(OrderModel o) {
    final rows = <Widget>[];
    for (int s = 1; s <= 5; s++) {
      final done = o.step >= s;
      final current = o.step == s;
      rows.add(IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: done ? kGreen : Colors.white,
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: done ? kGreen : kBorder, width: 2),
                  ),
                  child: done
                      ? const Icon(Icons.check, size: 12, color: Colors.white)
                      : null,
                ),
                if (s < 5)
                  Expanded(
                    child: Container(
                        width: 2, color: o.step > s ? kGreen : kBorder),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(OrderModel.stepNames[s - 1],
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight:
                                current ? FontWeight.bold : FontWeight.w600,
                            color: done ? kDark : kMuted)),
                    const SizedBox(height: 2),
                    Text(done ? formatDateTime(o.stepTime(s)) : 'Pending',
                        style: const TextStyle(fontSize: 10, color: kMuted)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ));
    }
    return Column(children: rows);
  }

  @override
  Widget build(BuildContext context) {
    final o = widget.order;
    final d = o.details;

    return Scaffold(
      appBar: AppBar(
          title: Text('Order ${o.id}',
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.bold))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _card(
            'Product',
            Row(
              children: [
                ProductImageWidget(
                    product: o.product, width: 72, height: 72, borderRadius: 8),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(o.product.brand.toUpperCase(),
                          style: const TextStyle(
                              fontSize: 9,
                              color: kMuted,
                              fontWeight: FontWeight.w600)),
                      Text(o.product.name,
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 3),
                      Text('${o.product.category} · ${o.product.material}',
                          style: const TextStyle(fontSize: 10, color: kMuted)),
                      const SizedBox(height: 3),
                      Text('Qty ${o.quantity} × ${fmt(o.product.price)}',
                          style: const TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _card(
            'Order status',
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _statusPill(o),
                    const Spacer(),
                    Text(
                        o.step == 5
                            ? 'Delivered'
                            : 'Expected ${formatDate(o.expectedDelivery)}',
                        style: const TextStyle(fontSize: 11, color: kMuted)),
                  ],
                ),
                const SizedBox(height: 14),
                _timeline(o),
                const Text(
                    'Tracking updates automatically every minute for demo purposes.',
                    style: TextStyle(fontSize: 9, color: kMuted)),
              ],
            ),
          ),
          _card(
            'Price details',
            Column(
              children: [
                _kv('MRP total', fmt(o.mrpTotal)),
                _kv('Discount', '- ${fmt(o.savings)}',
                    color: const Color(0xFF2E7D32)),
                _kv('Item total', fmt(o.itemsTotal)),
                _kv('Delivery',
                    o.deliveryShare == 0 ? 'FREE' : fmt(o.deliveryShare)),
                const Divider(height: 16, color: kBorder),
                _kv('Order total', fmt(o.total), color: kGreen, bold: true),
              ],
            ),
          ),
          _card(
            'Delivery address',
            Column(
              children: [
                _kv('Name', d.fullName),
                _kv('Mobile', '+91 ${d.phone}'),
                _kv('Email', d.email),
                _kv('Address', d.addressLine),
                _kv('Pincode', d.pincode),
              ],
            ),
          ),
          _card(
            'Order information',
            Column(
              children: [
                _kv('Order ID', o.id),
                _kv('Placed on', formatDateTime(o.placedAt)),
                _kv('Payment', o.paymentMethod),
                _kv(
                    'Delivery date',
                    o.step == 5
                        ? formatDateTime(o.stepTime(5))
                        : formatDate(o.expectedDelivery)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// SDG 12 PAGE (project relevance + estimated impact from the user's orders)
// ============================================================================
class SdgPage extends StatelessWidget {
  const SdgPage({Key? key}) : super(key: key);

  Widget _stat(String value, String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(51)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 8),
            FittedBox(
              child: Text(value,
                  style: TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 16, color: color)),
            ),
            const SizedBox(height: 3),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 10, color: kDark)),
          ],
        ),
      ),
    );
  }

  Widget _pillar(String title, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 1),
            child: Icon(Icons.check_circle, color: kGreen, size: 15),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style:
                    const TextStyle(fontSize: 12, color: kDark, height: 1.35),
                children: [
                  TextSpan(
                      text: '$title: ',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: text),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(String title, Widget child) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.bold, color: kDark)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).currentUser;
    final orders = Provider.of<OrdersProvider>(context).ordersFor(user?.email);
    final items = orders.fold<int>(0, (sum, o) => sum + o.quantity);
    final plastic = items * 0.12; // kg of single-use plastic avoided (estimate)
    final co2 = items * 0.35; // kg CO2 avoided (estimate)
    final trees = co2 / 21; // one tree absorbs roughly 21 kg CO2 a year

    return Scaffold(
      appBar: AppBar(
        title: const Text('SDG 12 · Our Impact',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E4D38), Color(0xFF112E21)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Text('🌍', style: TextStyle(fontSize: 38)),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('UN Sustainable Development Goal 12',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text('Responsible Consumption and Production',
                          style: TextStyle(
                              color: Color(0xFFD4E6DC), fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _card(
            'The problem',
            const Text(
              'Single-use plastic products are used for minutes but last for '
              'centuries, filling landfills and oceans. EcoKart makes the '
              'reusable, compostable and plastic-free choice easy to find and '
              'affordable.',
              style: TextStyle(fontSize: 12, height: 1.4, color: kDark),
            ),
          ),
          _card(
            'How EcoKart helps',
            Column(
              children: [
                _pillar('Plastic-free products',
                    '100 reusable, compostable or natural items replace throwaway ones.'),
                _pillar('Plastic-free packaging',
                    'Orders ship in recycled, plastic-free packaging.'),
                _pillar('Awareness',
                    'Every product shows its material and eco details.'),
                _pillar('Local artisans',
                    'Many items are made from natural materials such as bamboo, jute, clay and cotton.'),
              ],
            ),
          ),
          _card(
            user == null
                ? 'Your impact (sign in to track)'
                : 'Your impact so far',
            Column(
              children: [
                Row(
                  children: [
                    _stat('$items', 'Eco items bought', Icons.shopping_bag,
                        kGreen),
                    const SizedBox(width: 10),
                    _stat('${plastic.toStringAsFixed(2)} kg', 'Plastic avoided',
                        Icons.recycling, const Color(0xFF2E7D32)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _stat('${co2.toStringAsFixed(1)} kg', 'CO₂ avoided',
                        Icons.air, const Color(0xFF0D9488)),
                    const SizedBox(width: 10),
                    _stat(trees.toStringAsFixed(2), 'Tree-years of CO₂',
                        Icons.forest, const Color(0xFF15803D)),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'These are rough estimates (about 0.12 kg plastic and 0.35 kg '
                  'CO₂ avoided per item) shown to illustrate the benefit.',
                  style: TextStyle(fontSize: 10, color: kMuted),
                ),
              ],
            ),
          ),
          _card(
            'UN targets we support',
            Column(
              children: [
                _pillar('12.2',
                    'Sustainable management and efficient use of natural resources.'),
                _pillar('12.5',
                    'Reduce waste through prevention, reduction, recycling and reuse.'),
                _pillar('12.8',
                    'People have information and awareness for sustainable lifestyles.'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 11. ACCOUNT TAB
// ============================================================================
class AccountTab extends StatefulWidget {
  const AccountTab({Key? key}) : super(key: key);

  @override
  State<AccountTab> createState() => _AccountTabState();
}

class _AccountTabState extends State<AccountTab> {
  bool _isSignIn = true;

  final _loginEmailCtrl = TextEditingController();
  final _loginPassCtrl = TextEditingController();
  final _regEmailCtrl = TextEditingController();
  final _regPassCtrl = TextEditingController();

  bool _obscureLogin = true;
  bool _obscureReg = true;

  @override
  void dispose() {
    _loginEmailCtrl.dispose();
    _loginPassCtrl.dispose();
    _regEmailCtrl.dispose();
    _regPassCtrl.dispose();
    super.dispose();
  }

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(msg),
        backgroundColor: error ? kRed : kGreen,
        behavior: SnackBarBehavior.floating,
      ));
  }

  void _doLogin(AuthProvider auth) {
    FocusScope.of(context).unfocus();
    final err = auth.login(_loginEmailCtrl.text, _loginPassCtrl.text);
    if (err != null) {
      _snack(err, error: true);
    } else {
      _loginPassCtrl.clear();
      _snack('Welcome back! 🌱');
    }
  }

  void _doRegister(AuthProvider auth) {
    FocusScope.of(context).unfocus();
    final err = auth.register(_regEmailCtrl.text, _regPassCtrl.text);
    if (err != null) {
      _snack(err, error: true);
    } else {
      _regPassCtrl.clear();
      _snack('Account created & signed in! 🌱');
    }
  }

  InputDecoration _dec(String label, IconData icon, {Widget? suffix}) =>
      _formDec(label, icon: icon).copyWith(suffixIcon: suffix);

  Widget _eye(bool obscured, VoidCallback onTap) => IconButton(
        icon: Icon(obscured ? Icons.visibility_off : Icons.visibility,
            size: 18, color: kMuted),
        onPressed: onTap,
      );

  Widget _primaryButton(String text, VoidCallback onTap) => SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: kGreen,
            foregroundColor: Colors.white,
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Text(text,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ),
      );

  Widget _toggleButton(String text, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: active ? kGreen : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(text,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: active ? Colors.white : kMuted)),
          ),
        ),
      ),
    );
  }

  Widget _signInForm(AuthProvider auth) {
    return Column(
      children: [
        TextField(
          controller: _loginEmailCtrl,
          keyboardType: TextInputType.emailAddress,
          decoration: _dec('Email address', Icons.email_outlined),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _loginPassCtrl,
          obscureText: _obscureLogin,
          onSubmitted: (_) => _doLogin(auth),
          decoration: _dec('Password', Icons.lock_outline,
              suffix: _eye(_obscureLogin,
                  () => setState(() => _obscureLogin = !_obscureLogin))),
        ),
        const SizedBox(height: 18),
        _primaryButton('Sign In', () => _doLogin(auth)),
      ],
    );
  }

  Widget _registerForm(AuthProvider auth) {
    return Column(
      children: [
        TextField(
          controller: _regEmailCtrl,
          keyboardType: TextInputType.emailAddress,
          decoration: _dec('Email address', Icons.email_outlined),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _regPassCtrl,
          obscureText: _obscureReg,
          onSubmitted: (_) => _doRegister(auth),
          decoration: _dec('Password (min 6 characters)', Icons.lock_outline,
              suffix: _eye(_obscureReg,
                  () => setState(() => _obscureReg = !_obscureReg))),
        ),
        const SizedBox(height: 18),
        _primaryButton('Create Account', () => _doRegister(auth)),
      ],
    );
  }

  void _showAbout() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('About EcoKart', style: TextStyle(fontSize: 16)),
        content: const Text(
          'EcoKart is a student project: a marketplace of 100 plastic-free, '
          'eco-friendly products.',
          style: TextStyle(fontSize: 12, height: 1.4),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Close')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    if (!auth.isLoggedIn) {
      return ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                  color: kLightGreen, shape: BoxShape.circle),
              child: const Icon(Icons.eco, color: kGreen, size: 36),
            ),
          ),
          const SizedBox(height: 14),
          const Center(
            child: Text('Welcome to EcoKart',
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold, color: kDark)),
          ),
          const SizedBox(height: 4),
          const Center(
            child: Text('Sign in to place and track your orders',
                style: TextStyle(fontSize: 12, color: kMuted)),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
                color: kLightGreen, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                _toggleButton('Sign In', _isSignIn,
                    () => setState(() => _isSignIn = true)),
                _toggleButton('Create Account', !_isSignIn,
                    () => setState(() => _isSignIn = false)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _isSignIn ? _signInForm(auth) : _registerForm(auth),
        ],
      );
    }

    final user = auth.currentUser!;
    final saved = Provider.of<AddressProvider>(context).forUser(user.email);
    final orderCount =
        Provider.of<OrdersProvider>(context).ordersFor(user.email).length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: kBorder),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: kGreen,
                child: Text(user.avatarInitials,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: kDark)),
                    const SizedBox(height: 2),
                    Text(user.email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, color: kMuted)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _menuTile(
          Icons.location_on_outlined,
          'Delivery Details',
          saved == null
              ? 'Add your address, phone & pincode'
              : '${saved.fullName} · ${saved.city} - ${saved.pincode}',
          onTap: () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const AddressPage())),
        ),
        _menuTile(
          Icons.local_shipping_outlined,
          'My Orders',
          orderCount == 0 ? 'No orders yet' : '$orderCount orders',
          onTap: () => kTab.value = kOrdersTab,
        ),
        _menuTile(Icons.public, 'SDG 12 · Our Impact',
            'Responsible Consumption & Production',
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const SdgPage()))),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              auth.logout();
              _snack('Signed out');
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: kRed,
              side: const BorderSide(color: kRed),
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.logout, size: 16),
            label: const Text('Sign Out',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _menuTile(IconData icon, String title, String subtitle,
      {VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorder),
      ),
      child: ListTile(
        leading: Icon(icon, color: kGreen),
        title: Text(title,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: kMuted)),
        trailing: const Icon(Icons.chevron_right, size: 18, color: kMuted),
        onTap: onTap,
      ),
    );
  }
}
