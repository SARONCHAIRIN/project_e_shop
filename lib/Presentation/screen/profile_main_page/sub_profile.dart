import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_shop/Presentation/screen/address/list_my_address.dart';
import 'package:e_shop/Presentation/screen/auth/login/login_screen.dart';
import 'package:e_shop/Presentation/screen/profile_main_page/setting_page.dart';
import 'package:e_shop/Presentation/screen/sub_category_screen/subcategory_with_product.dart';
import 'package:e_shop/core/storage/token_storage.dart';
import 'package:e_shop/data/datasources/adress/adress_service.dart';
import 'package:e_shop/data/models/user/get_user_model.dart';
import 'package:e_shop/data/repositories/address/address_repository.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../../../data/datasources/user/get_user_Id_service.dart';

class Profilepage extends StatefulWidget {
  final authRepository;

  const Profilepage({super.key, required this.authRepository});

  @override
  State<Profilepage> createState() => _ProfilepageState();
}

class _ProfilepageState extends State<Profilepage> {
  String? username;
  String? email;
  bool _isLoading = true;
  bool _isloadinged = false;
  GetUserModel? user;

  File? _image;
  String? _uploadedImageUrl;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  int _addressCount = 0;
  int _couponCount = 0;
  int _followingCount = 0;
  int _wishlistCount = 0;

  int _coinBalance = 0;
  String _tierName = "bronze".tr();
  int _tierPoints = 0;

  final serviceaddress = AddressService();
  final getAddressid = GetUserIdService();
  late final repoaddress = AddressRepository(serviceaddress);
  final storage = TokenStorage();

  @override
  void initState() {
    super.initState();
    fetchUser();
    _loadUser();
    _loadSavedImage();
    _loadAddressCount();
  }

  Future<void> _loadUser() async {
    try {
      final storage = TokenStorage();
      await Future.delayed(const Duration(milliseconds: 100));

      final name = await storage.readUsername();
      final storedEmail = await storage.readUserEmail();
      final emailToShow = (storedEmail?.isNotEmpty == true)
          ? storedEmail
          : name;

      if (mounted) {
        setState(() {
          username = name;
          email = emailToShow;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading user: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> fetchUser() async {
    try {
      final userId = await TokenStorage().getUserId();
      if (userId == null) {
        setState(() => _isloadinged = false);
        return;
      }

      final response = await widget.authRepository.authenticatedGet(
        '/user/id/user?id=$userId',
      );

      if (response == null) {
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => LoginScreen(authRepository: widget.authRepository),
          ),
          (route) => false,
        );
        return;
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final userData = data['data'];

        if (userData['image'] != null &&
            userData['image'].toString().isNotEmpty) {
          await TokenStorage().writeUserImage(userData['image']);
          if (mounted) setState(() => _uploadedImageUrl = userData['image']);
        }

        if (mounted) {
          setState(() {
            user = GetUserModel.fromJson(userData);
            _isloadinged = false;
          });
        }
      } else {
        setState(() => _isloadinged = false);
      }
    } catch (e) {
      debugPrint('fetchUser error: $e');
      setState(() => _isloadinged = false);
    }
  }

  Future<void> _loadSavedImage() async {
    final storage = TokenStorage();
    final savedImage = await storage.readUserImage();
    if (savedImage != null) {
      setState(() => _uploadedImageUrl = savedImage);
    }
  }

  Future<void> _loadAddressCount() async {
    try {
      final userId = await TokenStorage().readUserId();
      final token = await TokenStorage().readToken();
      if (userId == null || token == null) return;
      // TODO: replace with your real address-count fetch
    } catch (e) {
      debugPrint('address count error: $e');
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
          _isUploading = true;
        });

        final imageUrl = await _uploadImage(File(pickedFile.path));

        if (imageUrl != null) {
          await TokenStorage().writeUserImage(imageUrl);
          setState(() {
            _uploadedImageUrl = imageUrl;
            _image = null;
          });
        }
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<String?> _uploadImage(File imageFile) async {
    try {
      final token = await TokenStorage().getToken();
      final userId = await TokenStorage().getUserId();

      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('YOUR_API_URL/user/$userId'),
      );
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );

      var response = await request.send();

      if (response.statusCode == 200) {
        final resBody = await response.stream.bytesToString();
        final data = jsonDecode(resBody);
        return data['data']['image'];
      } else {
        debugPrint("Upload failed: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Upload error: $e");
    }
    return null;
  }

  Future<void> _openEditImageSheet() async {
    try {
      final source = await showModalBottomSheet<ImageSource>(
        context: context,
        builder: (context) => SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text("gallery".tr()),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: Text("camera".tr()),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
            ],
          ),
        ),
      );

      if (source == null) return;

      await _pickImage(source);
      await fetchUser();
      await _loadSavedImage();
    } catch (e) {
      debugPrint("Image update error: $e");
    }
  }

  void _goToOrderHistory({String? statusFilter}) async {
    final storage = TokenStorage();
    final token = await storage.readToken();
    final userId = await storage.readUserId();
    if (token == null || userId == null) return;

    if (!mounted) return;
    Navigator.pushNamed(
      context,
      '/orderHistory',
      arguments: {
        'userId': userId,
        'token': token,
        if (statusFilter != null) 'status': statusFilter,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () async {
                  await fetchUser();
                  await _loadAddressCount();
                },
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    // ── everything that was your old body ──
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeaderRow(),
                            const SizedBox(height: 20),
                            _buildStatsRow(),
                            const SizedBox(height: 24),
                            _buildOrdersCard(),
                          ],
                        ),
                      ),
                    ),

                    // ── Recommended For You section header ──
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 28, 16, 10),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.favorite,
                              size: 18,
                              color: Colors.redAccent,
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Recommended For You',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ── the sliver grid itself ──
                    SubcategoryWithProduct(
                      categoryName: null,
                      repository: widget.authRepository,
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: 100)),
                  ],
                ),
              ),
      ),
    );
  }

  // ── Header: avatar + name/email + points pills + settings gear ──
  Widget _buildHeaderRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueAccent.withOpacity(0.4),
                    blurStyle: BlurStyle.outer,
                    blurRadius: 2,
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 34,
                backgroundColor: Colors.green.shade400,
                child: ClipOval(child: _buildProfileImage(size: 68)),
              ),
            ),
            Positioned(
              bottom: -2,
              right: -2,
              child: GestureDetector(
                onTap: _openEditImageSheet,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: Colors.blue.shade100),
                  ),
                  child: const Icon(Icons.edit, size: 14, color: Colors.blue),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                username?.isNotEmpty == true ? username! : 'User'.tr(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                user?.email ?? email ?? 'user@email.com',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _pill(
                    icon: Icons.monetization_on,
                    iconColor: Colors.amber.shade700,
                    label: '$_coinBalance',
                    background: Colors.amber.shade50,
                  ),
                  const SizedBox(width: 8),
                  _pill(
                    icon: Icons.military_tech,
                    iconColor: Colors.brown.shade400,
                    label: '$_tierName · $_tierPoints pts',
                    background: Colors.orange.shade50,
                  ),
                ],
              ),
            ],
          ),
        ),
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: const Icon(Icons.settings, size: 20, color: Colors.black87),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    SettingPage(authRepository: widget.authRepository),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _pill({
    required IconData icon,
    required Color iconColor,
    required String label,
    required Color background,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  // ── Stats row: Addresses / Coupons / Following / Wishlist ──
  Widget _buildStatsRow() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _statItem(
            icon: Icons.location_on_outlined,
            iconColor: Colors.teal,
            count: _addressCount,
            label: "addresses".tr(),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    AddressListPage(repo: repoaddress, storage: storage),
              ),
            ),
          ),
          _statItem(
            icon: Icons.local_offer_outlined,
            iconColor: Colors.green,
            count: _couponCount,
            label: "coupons".tr(),
            onTap: () {},
          ),
          _statItem(
            icon: Icons.groups_outlined,
            iconColor: Colors.indigo,
            count: _followingCount,
            label: "following".tr(),
            onTap: () {},
          ),
          _statItem(
            icon: Icons.favorite_border,
            iconColor: Colors.redAccent,
            count: _wishlistCount,
            label: "wishlist".tr(),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _statItem({
    required IconData icon,
    required Color iconColor,
    required int count,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(height: 6),
            Text(
              '$count',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  // ── My Orders card ──
  Widget _buildOrdersCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "my_orders".tr(),
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              TextButton(
                onPressed: () => _goToOrderHistory(),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Row(
                  children: [
                    Text(
                      "view_all".tr(),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange,
                      ),
                    ),
                    Icon(Icons.chevron_right, size: 16, color: Colors.orange),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _orderStatusItem(
                icon: Icons.receipt_long_outlined,
                background: Colors.amber.shade50,
                iconColor: Colors.amber.shade700,
                label: "pending".tr(),
                onTap: () => _goToOrderHistory(statusFilter: 'PENDING'),
              ),
              _orderStatusItem(
                icon: Icons.inventory_2_outlined,
                background: Colors.indigo.shade50,
                iconColor: Colors.indigo,
                label: "processing".tr(),
                onTap: () => _goToOrderHistory(statusFilter: 'PROCESSING'),
              ),
              _orderStatusItem(
                icon: Icons.local_shipping_outlined,
                background: Colors.teal.shade50,
                iconColor: Colors.teal,
                label: "shipped".tr(),
                onTap: () => _goToOrderHistory(statusFilter: 'SHIPPED'),
              ),
              _orderStatusItem(
                icon: Icons.check_circle_outline,
                background: Colors.green.shade50,
                iconColor: Colors.green,
                label: "delivered".tr(),
                onTap: () => _goToOrderHistory(statusFilter: 'DELIVERED'),
              ),
              _orderStatusItem(
                icon: Icons.cancel_outlined,
                background: Colors.red.shade50,
                iconColor: Colors.red,
                label: "cancelled".tr(),
                onTap: () => _goToOrderHistory(statusFilter: 'CANCELLED'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _orderStatusItem({
    required IconData icon,
    required Color background,
    required Color iconColor,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage({double size = 68}) {
    if (_image != null) {
      return Image.file(_image!, width: size, height: size, fit: BoxFit.cover);
    } else if (_uploadedImageUrl != null) {
      return CachedNetworkImage(
        imageUrl:
            "${_uploadedImageUrl!}?v=${DateTime.now().millisecondsSinceEpoch}",
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          width: size,
          height: size,
          color: Colors.blue.shade200,
          child: const Center(
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
          ),
        ),
        errorWidget: (context, url, error) => Center(
          child: Text(
            _initial(),
            style: const TextStyle(fontSize: 24, color: Colors.white),
          ),
        ),
      );
    } else {
      return Center(
        child: Text(
          _initial(),
          style: const TextStyle(fontSize: 24, color: Colors.white),
        ),
      );
    }
  }

  String _initial() {
    final name = username?.isNotEmpty == true ? username! : 'U';
    return name.substring(0, 1).toUpperCase();
  }
}
