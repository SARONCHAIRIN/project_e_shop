// import 'package:flutter/material.dart';
//
// import '../widgets/profile_avatar.dart';
// import '../widgets/profile_card.dart';
// import '../widgets/profile_info.dart';
// import '../widgets/profile_menu.dart';
// import '../widgets/profile_top_bar.dart';
//
// class WebProfileBody extends StatelessWidget {
//   final dynamic authRepository;
//
//   const WebProfileBody({super.key, required this.authRepository});
//
//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(40),
//
//       child: Column(
//         children: [
//           ProfileTopBar(title: "Profile", onSettingPressed: () {}),
//
//           const SizedBox(height: 40),
//
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//
//             children: [
//               // Profile information
//               Expanded(
//                 flex: 2,
//
//                 child: ProfileCard(
//                   child: Column(
//                     children: [
//                       const ProfileAvatar(size: 140),
//
//                       const SizedBox(height: 25),
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
//               const SizedBox(width: 40),
//
//               // Menu
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
