class AladhanModelday {
  final String day;

  AladhanModelday({required this.day});

  factory AladhanModelday.fromJson(Map<String, dynamic> data) {
    return AladhanModelday(day: data['day'] ?? "N/A");
  }
}
