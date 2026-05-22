class Validator {
  // Validate username
  static String? username(String? value) {
    if (value == null || value.isEmpty) return "Username is required";
    if (value.length < 3) return "Username must be at least 3 characters";
    return null;
  }

  // Validate email
  static String? email(String? value) {
    if (value == null || value.isEmpty) return "Email is required";
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) return "Enter a valid email";
    return null;
  }

  // Validate full name
  static String? fullName(String? value) {
    if (value == null || value.isEmpty) return "Full Name is required";
    return null;
  }

  // Validate password
  static String? password(String? value) {
    if (value == null || value.isEmpty) return "Password is required";
    if (value.length < 6) return "Password must be at least 6 characters";
    return null;
  }
}
