class User {
  final String id;
  final String name;
  final String initials;
  final String avatarColor;
  final bool isOnline;

  User({
    required this.id,
    required this.name,
    required this.initials,
    required this.avatarColor,
    this.isOnline = false,
  });
}


