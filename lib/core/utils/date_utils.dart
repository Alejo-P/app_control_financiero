// Lista de meses en español
const List<String> monthNames = [
  'Enero',
  'Febrero',
  'Marzo',
  'Abril',
  'Mayo',
  'Junio',
  'Julio',
  'Agosto',
  'Septiembre',
  'Octubre',
  'Noviembre',
  'Diciembre',
];

// Función para obtener el nombre del mes a partir de un DateTime
String getMonthName(DateTime date) {
  return monthNames[date.month - 1];
}

// Función para formatear una fecha como "Mes de Año"
String formatMonthYear(DateTime date) {
  final monthName = getMonthName(date);
  return '$monthName de ${date.year}';
}

// Funcion para obtener la fecha actual sin hora
DateTime getCurrentDateWithoutTime() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

// Función para formatear una fecha como "dd/MM/yyyy"
String formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final year = date.year.toString();
  return '$day/$month/$year';
}

// Función para formatear una fecha reladiva (Hoy, 29 de Junio, etc.)
String formatRelativeDateWithMonth(DateTime date) {
  final currentDate = getCurrentDateWithoutTime();
  final targetDate = DateTime(date.year, date.month, date.day);
  final difference = currentDate.difference(targetDate).inDays;
  final monthName = getMonthName(date);
  String resultado = '';

  if (difference == 0) {
    resultado = 'Hoy, ';
  } else if (difference == 1) {
    resultado = 'Ayer, ';
  } else {
    resultado = '';
  }

  resultado += '${date.day} de $monthName';

  // Agregar el año solo si no es el año actual
  if (date.year != currentDate.year) {
    resultado += ', ${date.year}';
  }

  return resultado;
}

bool isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

bool isCurrentMonth(DateTime date) {
  final now = DateTime.now();
  return date.year == now.year && date.month == now.month;
}

DateTime getFirstDayOfMonth(DateTime date) {
  return DateTime(date.year, date.month, 1);
}

DateTime getLastDayOfMonth(DateTime date) {
  final beginningNextMonth = (date.month < 12)
      ? DateTime(date.year, date.month + 1, 1)
      : DateTime(date.year + 1, 1, 1);
  return beginningNextMonth.subtract(const Duration(days: 1));
}