class AladhanModel {
  final String imsak;
  final String shubuh;
  final String dzuhur;
  final String ashar;
  final String maghrib;
  final String isya;

  AladhanModel({
    required this.imsak,
    required this.shubuh,
    required this.dzuhur,
    required this.ashar,
    required this.maghrib,
    required this.isya,
  });

  factory AladhanModel.fromJson(Map<String, dynamic> data) {
    return AladhanModel(
      imsak: data['Imsak'] ?? "N/A",
      shubuh: data['Fajr'] ?? "N/A",
      dzuhur: data['Dhuhr'] ?? "N/A",
      ashar: data['Asr'] ?? "N/A",
      maghrib: data['Maghrib'] ?? "N/A",
      isya: data['Isha'] ?? "N/A",
    );
  }
}
