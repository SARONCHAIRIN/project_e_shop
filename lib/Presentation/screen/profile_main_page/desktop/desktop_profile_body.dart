// import 'package:flutter/material.dart';
//
// import '../widgets/profile_avatar.dart';
// import '../widgets/profile_card.dart';
// import '../widgets/profile_info.dart';
// import '../widgets/profile_menu.dart';
// import '../widgets/profile_top_bar.dart';
//
// class DesktopProfileBody extends StatelessWidget {
//   final dynamic authRepository;
//
//   const DesktopProfileBody({super.key, required this.authRepository});
//
//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(30),
//
//       child: Column(
//         children: [
//           ProfileTopBar(title: "Profile", onSettingPressed: () {}),
//
//           const SizedBox(height: 30),
//
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//
//             children: [
//               // LEFT PROFILE CARD
//               Expanded(
//                 flex: 2,
//
//                 child: ProfileCard(
//                   child: Column(
//                     children: [
//                       const ProfileAvatar(size: 120),
//
//                       const SizedBox(height: 20),
//
//                       const ProfileInfo(
//                         username: "User",
//
//                         email: "user@email.com",
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//
//               const SizedBox(width: 30),
//
//               // RIGHT MENU
//               Expanded(
//                 flex: 3,
//
//                 child: ProfileMenu(
//                   onOrders: () {},
//
//                   onWishlist: () {},
//
//                   onAddress: () {},
//
//                   onSetting: () {},
//
//                   onLogout: () {},
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
