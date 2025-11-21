class DashboardStats {
  final int carsCount;
  final int clientsCount;
  final int dealsCount;
  final int usersCount;

  DashboardStats({
    required this.carsCount,
    required this.clientsCount,
    required this.dealsCount,
    required this.usersCount,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      carsCount: json['cars'] as int,
      clientsCount: json['clients'] as int,
      dealsCount: json['deals'] as int,
      usersCount: json['users'] as int,
    );
  }
}