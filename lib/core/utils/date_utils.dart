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