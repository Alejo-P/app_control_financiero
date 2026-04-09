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

DateTime get currentDateTime => DateTime.now();

// Función para obtener el nombre del mes a partir de un DateTime
String getMonthName(DateTime date) {
  return monthNames[date.month - 1];
}

// Función para formatear una fecha como "dia mes"
String formatDayMonth(DateTime date) {
  final monthName = getMonthName(date);
  final day = date.day.toString().padLeft(2, '0');
  return '$day $monthName';
}

// Función para formatear una fecha como "Mes de Año"
String formatMonthYear(DateTime date) {
  final monthName = getMonthName(date);
  return '$monthName de ${date.year}';
}

// Funcion para obtener la fecha actual sin hora
DateTime getCurrentDateWithoutTime() {
  final now = currentDateTime;
  return DateTime(now.year, now.month, now.day);
}

DateTime normalizeDate(DateTime date) {
  return DateTime(date.year, date.month);
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

bool isSameMonth(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month;
}

bool isCurrentMonth(DateTime date) {
  final now = currentDateTime;
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

/// Funcion que genere una lista de años desde una fecha inicial hasta el limite especificado
/// @param startYear Año de inicio (ej; 2020)
/// @param nuumberOfYears Cantidad de numeros a agregar a la lista. Por defecto y como limite es 10
/// @ return Lista de numeros generada [2020, 2021, 2022, ...]
List<int> generateYearList(int startYear, [int numberOfYears = 10]) {
  // Verificar que la lista no exceda los 10 elementos
  if (numberOfYears > 10) {
    numberOfYears = 10;
  }

  return List<int>.generate(numberOfYears, (i) => startYear + i);
}

// Obtener etiqueta de una fecha especifica ('Hoy', 'Esta semana', etc)
String getDateGroupLabel(DateTime date) {
  final now = DateTime.now();
  final diff = now.difference(date);
  // Si corresponde al mes pasado, mostrar el nombre del mes
  if (!isSameMonth(now, date) && now.year == date.year) {
    return getMonthName(date);
  }

  if (diff.inDays == 0) return 'Hoy';
  if (diff.inDays == 1) return 'Ayer';
  if (diff.inDays < 7) return 'Esta semana';
  if (diff.inDays < 30) return 'Este mes';

  if (now.year == date.year) {
    final monthName = getMonthName(date);
    return monthName;
  }

  return '${date.year}';
}
