enum TutorialStep {
  notifications(
    0,
    'movimientos_inicio',
    'Notificaciones',
    'Consulta tus avisos. El indicador muestra cuántos quedan sin leer.',
  ),
  search(
    0,
    'movimientos_inicio',
    'Buscar movimientos',
    'Busca movimientos sin tener que recorrer la lista del mes.',
  ),
  movementMonth(
    0,
    'movimientos_inicio',
    'Mes de movimientos',
    'Selecciona el mes cuyos ingresos y gastos quieres consultar.',
  ),
  addMovement(
    0,
    'movimientos_inicio',
    'Agregar movimiento',
    'Registra un ingreso o un gasto para el mes seleccionado.',
  ),
  navigation(
    0,
    'movimientos_inicio',
    'Secciones de la aplicación',
    'Desde aquí puedes entrar a Movimientos, Presupuestos, Historial y Más acciones. Cada sección tiene su propio tutorial.',
  ),
  movementSummary(
    0,
    'movimientos_datos',
    'Balance mensual',
    'Aquí se resumen tus ingresos, gastos, balance y variación del ahorro del mes seleccionado.',
  ),
  movementFilters(
    0,
    'movimientos_datos',
    'Filtrar movimientos',
    'Filtra por ingresos, gastos o categoría. Toca de nuevo la categoría seleccionada para quitar ese filtro.',
  ),
  movementMenu(
    0,
    'movimientos_datos',
    'Acciones del movimiento',
    'Este menú permite copiar o mover el movimiento a otra fecha. Toca el card para consultar o editar sus datos.',
  ),
  movementCopy(
    0,
    'movimientos_menu',
    'Copiar movimiento',
    'Crea una copia en la fecha que elijas y conserva el movimiento original.',
  ),
  movementMove(
    0,
    'movimientos_menu',
    'Mover movimiento',
    'Cambia la fecha del movimiento original, sin crear una copia.',
  ),
  budgetMonth(
    1,
    'presupuestos_inicio',
    'Mes de presupuestos',
    'Selecciona el mes para consultar o definir sus presupuestos.',
  ),
  budgetIncome(
    1,
    'presupuestos_inicio',
    'Ingreso presupuestado',
    'Establece o cambia el ingreso presupuestado del mes seleccionado. Debe ser mayor que cero para poder agregar presupuestos.',
  ),
  addBudget(
    1,
    'presupuestos_agregar',
    'Agregar presupuesto',
    'Asigna parte del ingreso presupuestado a una categoría. Este botón aparece cuando el mes tiene un ingreso presupuestado mayor que cero.',
  ),
  budgetSummary(
    1,
    'presupuestos_resumen',
    'Resumen de presupuesto',
    'Compara el ingreso presupuestado del mes con sus gastos y el importe disponible.',
  ),
  budgetCard(
    1,
    'presupuestos_datos',
    'Presupuesto por categoría',
    'Consulta el monto asignado, los gastos, el porcentaje utilizado y el saldo restante. Toca la tarjeta para editar el presupuesto.',
  ),
  budgetMenu(
    1,
    'presupuestos_datos',
    'Acciones del presupuesto',
    'Copia o mueve el presupuesto a otro mes. El destino necesita ingreso disponible; reemplazar uno de la misma categoría requiere confirmación.',
  ),
  budgetCopy(
    1,
    'presupuestos_menu',
    'Copiar presupuesto',
    'Crea el presupuesto en otro mes y conserva el original. Se comprueba el ingreso disponible del destino.',
  ),
  budgetMove(
    1,
    'presupuestos_menu',
    'Mover presupuesto',
    'Traslada el presupuesto a otro mes. Si ya existe uno de la misma categoría, tendrás que confirmar su reemplazo.',
  ),
  historyYear(
    2,
    'historial_inicio',
    'Año del historial',
    'Selecciona el año a visualizar. Solo aparecen años con movimientos registrados.',
  ),
  historyMonth(
    2,
    'historial_datos',
    'Detalle mensual',
    'Despliega un mes para consultar sus ingresos y gastos. El botón de su detalle permite ir a sus movimientos cuando corresponde.',
  ),
  historyBalance(
    2,
    'historial_balance',
    'Balance anual',
    'Muestra el balance acumulado de los meses registrados en el año seleccionado.',
  ),
  excel(
    3,
    'mas_acciones',
    'Exportar movimientos a Excel',
    'Genera un archivo .xlsx con tus movimientos. Esta opción temporal permite consultarlos fuera de la aplicación.',
  ),
  backup(
    3,
    'mas_acciones',
    'Respaldar datos',
    'Crea una copia de seguridad protegida con contraseña. Guarda el archivo y su contraseña para poder restaurarla.',
  ),
  restore(
    3,
    'mas_acciones',
    'Restaurar datos',
    'Importa una copia de seguridad usando su contraseña. La restauración reemplaza los datos actuales y solicita confirmación.',
  ),
  categories(
    3,
    'mas_acciones',
    'Categorías',
    'Administra las categorías que organizan tus ingresos, gastos y presupuestos.',
  ),
  reminders(
    3,
    'mas_acciones',
    'Recordatorios',
    'Administra recordatorios para tus movimientos y sus fechas de aviso.',
  ),
  darkMode(
    3,
    'mas_acciones',
    'Modo oscuro',
    'Cambia entre la apariencia clara y oscura de la aplicación.',
  ),
  notificationSettings(
    3,
    'mas_acciones',
    'Configuración de notificaciones',
    'Configura los avisos de la aplicación y sus umbrales disponibles.',
  ),
  about(
    3,
    'mas_acciones',
    'Sobre la aplicación',
    'Consulta la información de la aplicación y su versión.',
  );

  const TutorialStep(this.tab, this.group, this.title, this.description);
  final int tab;
  final String group;
  final String title;
  final String description;

  bool get isMenuOption => group.endsWith('_menu');
}
