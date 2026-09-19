class BillCalculator {
  BillCalculator._();

  static const double quintalsPerTon = 10;

  // Same rule as add_edit_sauda_screen.dart: 1 ton = 1000 kg, 1 quintal = 100 kg.
  static double kgPerUnit(String? unitName) {
    final name = unitName?.toLowerCase().trim() ?? '';
    if (name.contains('ton')) return 1000;
    if (name.contains('quintal')) return 100;
    return 1;
  }

  static double toQuintals(double quantity, String? unitName) =>
      quantity * kgPerUnit(unitName) / 100;

  static double toTons(double quintals) => quintals / quintalsPerTon;

  static double round2(double value) => (value * 100).round() / 100;

  static double amount(double quintals, double ratePerQuintal) =>
      round2(quintals * ratePerQuintal);

  static double ratePerTon(double ratePerQuintal) =>
      ratePerQuintal * quintalsPerTon;
}
