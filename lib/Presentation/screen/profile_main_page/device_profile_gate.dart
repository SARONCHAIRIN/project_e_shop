// import 'package:e_shop/Presentation/screen/profile_main_page/setting_page.dart';
// import 'package:e_shop/Presentation/screen/profile_main_page/sub_profile.dart';
// import 'package:e_shop/features/auth/presentation/screens/login_button_sheet.dart';
// import 'package:e_shop/features/auth/presentation/screens/reset_password_screen.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:e_shop/data/repositories/user_auth_repository.dart';
// import 'package:e_shop/core/storage/token_storage.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
//
// class DeviceProfileGate extends StatefulWidget {
//   final User_AuthRepository repository;
//
//   const DeviceProfileGate({super.key, required this.repository});
//
//   @override
//   State<DeviceProfileGate> createState() => _DeviceProfileGateState();
// }
//
// class _DeviceProfileGateState extends State<DeviceProfileGate> {
//   int? userId;
//   bool isLoading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadUser();
//   }
//
//   Future<void> _loadUser() async {
//     final id = await TokenStorage().readUserId();
//     if (!mounted) return;
//     setState(() {
//       userId = id;
//       isLoading = false;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (isLoading) {
//       return const Scaffold(
//         body: Center(child: SpinKitCircle(color: Colors.grey, size: 20)),
//       );
//     }
//     if (userId == null || userId == 0) {
//       return _GuestProfilePage(repository: widget.repository);
//     }
//     return Profilepage(authRepository: widget.repository);
//     // return Profilepage(authRepository: widget.repository);
//   }
// }
//
// // ─── Guest state ───────────────────────────────────────────────
// class _GuestProfilePage extends StatefulWidget {
//   final User_AuthRepository repository;
//
//   const _GuestProfilePage({required this.repository});
//
//   @override
//   State<_GuestProfilePage> createState() => _GuestProfilePageState();
// }
//
// class _GuestProfilePageState extends State<_GuestProfilePage> {
//   void _showLoginSheet(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       isDismissible: true,
//       enableDrag: true,
//       backgroundColor: Colors.transparent,
//       // builder: (_) =>LoginBottomSheet(authRepository: widget.repository),
//       builder: (_) => LoginBottomSheet1(),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       extendBody: true,
//       // backgroundColor: const Color(0xFFF5F5F5),
//       backgroundColor: Colors.grey.shade100,
//       body: SafeArea(
//         child: Column(
//           children: [
//             _TopBar(),
//             Expanded(
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.only(bottom: 100),
//                 child: Column(
//                   children: [
//                     _GuestHero(context),
//                     const SizedBox(height: 8),
//                     _GuestMenuSection(),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _TopBar() => Padding(
//     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
//     child: Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           'profile'.tr(),
//           style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
//         ),
//         IconButton(
//           onPressed: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (_) => SettingPage(authRepository: widget.repository),
//               ),
//             );
//           },
//           icon: Icon(Icons.settings, color: Colors.grey, size: 20),
//         ),
//       ],
//     ),
//   );
//
//   Widget _GuestHero(BuildContext context) => Container(
//     decoration: BoxDecoration(
//       borderRadius: BorderRadius.circular(20),
//       color: Colors.white,
//     ),
//     margin: EdgeInsets.symmetric(horizontal: 20),
//     padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
//     child: Column(
//       children: [
//         Container(
//           width: 80,
//           height: 80,
//           decoration: BoxDecoration(
//             shape: BoxShape.circle,
//             color: Colors.grey[100],
//             border: Border.all(color: Colors.grey[300]!),
//           ),
//           child: const Icon(
//             Icons.person_outline,
//             size: 38,
//             color: Color(0xFFAAAAAA),
//           ),
//         ),
//         const SizedBox(height: 16),
//         Text(
//           'signInToAccount'.tr(),
//           style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
//         ),
//         const SizedBox(height: 6),
//         Text(
//           'guestHeroSubtitle'.tr(),
//           textAlign: TextAlign.center,
//           style: TextStyle(fontSize: 13, color: Colors.grey[500], height: 1.5),
//         ),
//         SizedBox(height: 28),
//         SizedBox(
//           width: double.infinity,
//           height: 50,
//           child: ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Color(0xFF1A1A2E),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               elevation: 0,
//             ),
//             onPressed: () => _showLoginSheet(context),
//             child: Text(
//               'signIn'.tr(),
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 15,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//         ),
//         const SizedBox(height: 10),
//         SizedBox(
//           width: double.infinity,
//           height: 50,
//           child: OutlinedButton(
//             style: OutlinedButton.styleFrom(
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               side: BorderSide(color: Colors.grey[300]!),
//             ),
//             onPressed: () => Navigator.pushNamed(context, '/register'),
//             child: Text('createAccount'.tr(), style: TextStyle(fontSize: 15)),
//           ),
//         ),
//       ],
//     ),
//   );
//
//   Widget _GuestMenuSection() => Container(
//     decoration: BoxDecoration(
//       color: const Color(0xFFF5F5F5),
//       // color: Colors.red,
//       borderRadius: BorderRadius.circular(20),
//       boxShadow: [
//         BoxShadow(
//           color: Colors.grey.shade400,
//           spreadRadius: 1,
//           blurRadius: 1,
//           blurStyle: BlurStyle.outer,
//         ),
//       ],
//     ),
//
//     margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
//           child: Text(
//             'browseAsGuest'.tr(),
//             style: TextStyle(fontSize: 14, color: Colors.grey[500]),
//           ),
//         ),
//         _MenuTile(
//           icon: Icons.inventory_2_outlined,
//           iconBg: const Color(0xFFE6F1FB),
//           iconColor: const Color(0xFF185FA5),
//           title: 'trackOrder'.tr(),
//           subtitle: 'trackOrderSubtitle'.tr(),
//           onTap: () {
//             showDialog(
//               context: context,
//               builder: (context) => AlertDialog(
//                 title: Text('Track Order'),
//                 content: Text('trackOrderDialogBody'.tr()),
//                 actions: [
//                   TextButton(
//                     onPressed: () => Navigator.pop(context),
//                     child: Text('close'.tr()),
//                   ),
//                 ],
//               ),
//             );
//           },
//         ),
//         _MenuTile(
//           icon: Icons.headset_mic_outlined,
//           iconBg: const Color(0xFFE1F5EE),
//           iconColor: const Color(0xFF0F6E56),
//           title: 'helpAndSupport'.tr(),
//           subtitle: 'helpAndSupportSubtitle'.tr(),
//           onTap: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (_) => ResetPasswordScreen()),
//             );
//           },
//         ),
//       ],
//     ),
//   );
// }
//
// // ─── Shared menu tile ──────────────────────────────────────────
// class _MenuTile extends StatelessWidget {
//   final IconData icon;
//   final Color iconBg;
//   final Color iconColor;
//   final String title;
//   final String? subtitle;
//   final VoidCallback onTap;
//
//   const _MenuTile({
//     required this.icon,
//     required this.iconBg,
//     required this.iconColor,
//     required this.title,
//     this.subtitle,
//     required this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onTap,
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.only(
//             bottomLeft: Radius.circular(15),
//             bottomRight: Radius.circular(15),
//           ),
//         ),
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
//         child: Row(
//           children: [
//             Container(
//               width: 36,
//               height: 36,
//               decoration: BoxDecoration(
//                 color: iconBg,
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Icon(icon, size: 18, color: iconColor),
//             ),
//             const SizedBox(width: 14),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(title, style: const TextStyle(fontSize: 14)),
//                   if (subtitle != null)
//                     Text(
//                       subtitle!,
//                       style: TextStyle(fontSize: 12, color: Colors.grey[500]),
//                     ),
//                 ],
//               ),
//             ),
//             Icon(Icons.chevron_right, size: 18, color: Colors.grey[400]),
//           ],
//         ),
//       ),
//     );
//   }
// }
