class Vehicle {
  final String name;
  final String iconPath; // Đường dẫn đến icon (hoặc tên icon nếu dùng IconData)
  final double basePrice;
  final double pricePerKm; // Giá cước cơ bản

  Vehicle({
    required this.name,
    required this.iconPath,
    required this.basePrice,
    required this.pricePerKm,
  });
   double calculateFare(double distanceInMeters) {
    double distanceInKm = distanceInMeters / 1000; // Chuyển đổi từ mét sang km
    return basePrice + (pricePerKm * distanceInKm);
  }
}