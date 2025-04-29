class AppUtils {
  static String formatPrice(double price) {
    return '\$${price.toStringAsFixed(2)}';
  }

  static String truncateWithEllipsis(String text, int maxLength) {
    return text.length <= maxLength
        ? text
        : '${text.substring(0, maxLength)}...';
  }
}
