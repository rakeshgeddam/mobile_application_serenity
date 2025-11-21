import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  final String initials;
  const ProfileAvatar({super.key, required this.initials});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(child: Text(initials));
  }
}
