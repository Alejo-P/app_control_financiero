import 'package:control_financiero/app/app_state.dart';
import 'package:control_financiero/core/models/app_bar_action.dart';
import 'package:control_financiero/features/categorias/widgets/category_container.dart';
import 'package:control_financiero/features/shared/widgets/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CategoriasPage extends StatefulWidget {
  const CategoriasPage({super.key});

  @override
  State<CategoriasPage> createState() => _CategoriasPageState();
}

class _CategoriasPageState extends State<CategoriasPage> {
  late AppState _appState;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _appState = context.read<AppState>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _appState.setAppBarActions([
        AppBarAction(
          icon: Icons.add,
          tooltip: 'Nueva categoría',
          onPressed: () {
            Navigator.pushNamed(context, '/agregar_categoria');
          },
        ),
      ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final nombresTiposCategoria = appState.uniqueTipeCategoryNames;
    final bool loadingInitialData = appState.loadingInitialData;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        children: [
          Expanded(
            child: loadingInitialData
                ? LoadingScreen()
                : nombresTiposCategoria.isEmpty
                ? _EmptyCategorias()
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        ...nombresTiposCategoria.map((tipoCategoria) {
                          final categorias = appState
                              .getCategoriasByTipoCategoria(tipoCategoria);
                          return CategoryContainer(
                            categoryName: tipoCategoria,
                            categorias: categorias,
                          );
                        }),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _EmptyCategorias extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.category_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 24),
          Text(
            'No hay categorías para mostrar.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          Text(
            'Agrega nuevas categorías para clasificar tus movimientos.',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
