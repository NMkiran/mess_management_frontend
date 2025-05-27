class HistorySummary {
  final double todayIncome;
  final double todayExpenses;
  final double thisMonthIncome;
  final double thisMonthExpenses;
  final double allTimeIncome;
  final double allTimeExpenses;

  HistorySummary({
    required this.todayIncome,
    required this.todayExpenses,
    required this.thisMonthIncome,
    required this.thisMonthExpenses,
    required this.allTimeIncome,
    required this.allTimeExpenses,
  });

  factory HistorySummary.fromJson(Map<String, dynamic> json) {
    return HistorySummary(
      todayIncome: (json['todayIncome'] ?? 0).toDouble(),
      todayExpenses: (json['todayExpenses'] ?? 0).toDouble(),
      thisMonthIncome: (json['thisMonthIncome'] ?? 0).toDouble(),
      thisMonthExpenses: (json['thisMonthExpenses'] ?? 0).toDouble(),
      allTimeIncome: (json['allTimeIncome'] ?? 0).toDouble(),
      allTimeExpenses: (json['allTimeExpenses'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'todayIncome': todayIncome,
      'todayExpenses': todayExpenses,
      'thisMonthIncome': thisMonthIncome,
      'thisMonthExpenses': thisMonthExpenses,
      'allTimeIncome': allTimeIncome,
      'allTimeExpenses': allTimeExpenses,
    };
  }

  double get todayBalance => todayIncome - todayExpenses;
  double get thisMonthBalance => thisMonthIncome - thisMonthExpenses;
  double get allTimeBalance => allTimeIncome - allTimeExpenses;
}
