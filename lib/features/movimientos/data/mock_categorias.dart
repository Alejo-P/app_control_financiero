import 'package:control_financiero/features/movimientos/models/categoria.dart';
import 'package:control_financiero/features/movimientos/models/category_type.dart';

final mockTipoCategorias = <CategoryType>[
  CategoryType(
    id: 'gastos_escenciales',
    name: 'Gastos escenciales',
    description: 'Gastos relacionados con alimentos y necesidades básicas',
  ),
  CategoryType(
    id: 'estilo_de_vida',
    name: 'Estilo de vida',
    description: 'Gastos relacionados con actividades recreativas y ocio',
  ),
  CategoryType(
    id: 'ahorro_inversion',
    name: 'Ahorro e inversión',
    description: 'Gastos relacionados con ahorro e inversiones',
  ),
];

final mockCategorias = <Categoria>[
  Categoria(
    id: 'alimentos',
    name: 'Alimentos',
    description: 'Gastos en comida y supermercado',
    categoryTypeID: 'gastos_escenciales',
    iconName: 'shopping_cart',
    iconColorValue: 0xFF2196F3,
  ),
  Categoria(
    id: 'transporte',
    name: 'Transporte',
    description: 'Gastos en transporte público y gasolina',
    categoryTypeID: 'gastos_escenciales',
    iconName: 'directions_bus',
    iconColorValue: 0xFFFF9800,
  ),
  Categoria(
    id: 'trabajo',
    name: 'Trabajo',
    description: 'Ingresos relacionados con el trabajo',
    categoryTypeID: 'ahorro_inversion',
    iconName: 'attach_money',
    iconColorValue: 0xFF4CAF50,
  ),
  Categoria(
    id: 'entretenimiento',
    name: 'Entretenimiento',
    description: 'Gastos en actividades recreativas y ocio',
    categoryTypeID: 'estilo_de_vida',
    iconName: 'movie',
    iconColorValue: 0xFFAB47BC,
  ),
];
