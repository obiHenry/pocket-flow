class ExchangeRateModel {
  final String base;
  final String quote;

  final DateTime date;
  final Map<String, double> rates;
  double rate;

  ExchangeRateModel({
    required this.base,
    required this.quote,
    required this.date,
    required this.rates,
    required this.rate,
  });

  factory ExchangeRateModel.fromJson(Map<String, dynamic> json) {
    return ExchangeRateModel(
      base: json['base'] ?? '',
      quote: json['quote'] ?? '',
      date: DateTime.parse(json['date']),
      // Frankfurter returns rates as Map<String, dynamic>, we cast to double
      rates: Map<String, double>.from(
        json['rates'].map((key, value) => MapEntry(key, value.toDouble())),
      ),
      rate: json['rate']?.toDouble() ?? 0.0,
    );
  }
}
