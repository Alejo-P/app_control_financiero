import 'package:control_financiero/core/constants/movimiento_constants.dart';
import 'package:control_financiero/features/categorias/models/categoria.dart';
import 'package:control_financiero/features/tipo_categorias/models/tipo_categoria.dart';

final tipoCategoriasList = <TipoCategoria>[
  TipoCategoria(
    id: 1,
    name: 'Gastos escenciales',
    description: 'Gastos relacionados con alimentos y necesidades básicas',
  ),
  TipoCategoria(
    id: 2,
    name: 'Estilo de vida',
    description: 'Gastos relacionados con actividades recreativas y ocio',
  ),
  TipoCategoria(
    id: 3,
    name: 'Ahorro e inversión',
    description: 'Gastos relacionados con ahorro e inversiones',
  ),
];

final categoriasList = <Categoria>[
  Categoria(
    id: 1,
    name: 'Vivienda',
    description: 'Gastos relacionados con el hogar y la vivienda',
    movementType: TipoMovimiento.gasto,
    categoryTypeID: 1,
    iconName: 'home',
    iconColorValue: 0xFF42A5F5,
    isDefault: true,
  ),
  Categoria(
    id: 2,
    name: 'Alimentos',
    description: 'Gastos en comida y supermercado',
    movementType: TipoMovimiento.gasto,
    categoryTypeID: 1,
    iconName: 'restaurant',
    iconColorValue: 0xFFEF5350,
    isDefault: true,
  ),
  Categoria(
    id: 2,
    name: 'Transporte',
    description: 'Gastos en transporte público y gasolina',
    movementType: TipoMovimiento.gasto,
    categoryTypeID: 1,
    iconName: 'directions_bus',
    iconColorValue: 0xFFFF9800,
    isDefault: true,
  ),
  Categoria(
    id: 3,
    name: 'Trabajo',
    description: 'Ingresos relacionados con el trabajo',
    movementType: TipoMovimiento.ingreso,
    categoryTypeID: 3,
    iconName: 'attach_money',
    iconColorValue: 0xFF4CAF50,
    isDefault: true,
  ),
  Categoria(
    id: 4,
    name: 'Salud',
    description: 'Gastos en salud y bienestar',
    movementType: TipoMovimiento.gasto,
    categoryTypeID: 2,
    iconName: 'movie',
    iconColorValue: 0xFFAB47BC,
    isDefault: true,
  ),
  Categoria(
    id: 5,
    name: 'Ocio',
    description: 'Gastos en actividades recreativas y entretenimiento',
    movementType: TipoMovimiento.gasto,
    categoryTypeID: 2,
    iconName: 'fitness_center',
    iconColorValue: 0xFFFF7043,
    isDefault: true,
  ),
];
