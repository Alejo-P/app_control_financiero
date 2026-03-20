import 'package:intl/intl.dart';

class MonthData {
  final DateTime month;
  final double spent;
  final double income;

  MonthData({required this.month, required this.spent, required this.income});

  MonthData copyWith({DateTime? month, double? spent, double? income}) {
    return MonthData(
      month: month ?? this.month,
      spent: spent ?? this.spent,
      income: income ?? this.income,
    );
  }

  factory MonthData.fromMap(Map<String, dynamic> map) {
    return MonthData(
      month: DateTime.parse('${map['month']}-01'),
      spent: (map['spent'] as num).toDouble(),
      income: (map['income'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'month': DateFormat('yyyy-MM-dd').format(month),
      'spent': spent,
      'income': income,
    };
  }

  @override
  String toString() {
    return 'MonthData(month: $month, spent: $spent, income: $income)';
  }

  double get balance => (income - spent);
}
