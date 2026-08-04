import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {

  final String? imageUrl;
  final double size;

  const ProfileAvatar({
    super.key,
    this.imageUrl,
    this.size = 90,
  });


  @override
  Widget build(BuildContext context) {

    return Container(

      width: size,
      height: size,

      decoration: BoxDecoration(

        shape: BoxShape.circle,

        color: Colors.grey.shade100,

        border: Border.all(
          color: Colors.grey.shade300,
        ),

      ),


      child: ClipOval(

        child: imageUrl != null && imageUrl!.isNotEmpty

            ? Image.network(
          imageUrl!,
          fit: BoxFit.cover,

          errorBuilder:
              (context, error, stackTrace) {

            return Icon(
              Icons.person,
              size: size * 0.45,
              color: Colors.grey,
            );
          },
        )


            : Icon(
          Icons.person,
          size: size * 0.45,
          color: Colors.grey,
        ),
      ),
    );
  }
}