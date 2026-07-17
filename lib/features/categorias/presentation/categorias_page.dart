import 'package:control_financiero/app/app_state.dart';
import 'package:control_financiero/app/app_routes.dart';
import 'package:control_financiero/features/categorias/models/categoria_form_args.dart';
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
  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final nombresTiposCategoria = appState.uniqueTipeCategoryNames;
    final bool loadingInitialData = appState.loadingInitialData;
    final int cantidadCategorias = appState.getTotalCategoriasCount();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorías'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Nueva categoría',
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRoutes.categoriaFormRoute,
                arguments: CategoriaFormArgs(id: -1),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              spacing: 8,
              children: [
                Icon(Icons.lock, color: colorScheme.onSurface.withOpacity(0.6)),
                Expanded(
                  child: Text(
                    'Las categorías con este ícono no se pueden eliminar ni modificar.',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.primary.withOpacity(0.6),
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    softWrap: loadingInitialData ? false : true,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: loadingInitialData
                  ? LoadingScreen(message: 'Cargando categorías...')
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
                          const SizedBox(height: 8),
                          Text(
                            'Total de categorías: $cantidadCategorias',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
            ),
          ],
        ),
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
