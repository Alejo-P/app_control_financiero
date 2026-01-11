import 'package:control_financiero/app/app_state.dart';
import 'package:control_financiero/core/models/app_bar_action.dart';
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
    final categorias = appState.categorias;
    final bool loadingInitialData = appState.loadingInitialData;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: loadingInitialData
                ? LoadingScreen()
                : categorias.isEmpty
                    ? _EmptyCategorias()
                    : ListView.separated(
                        itemCount: categorias.length,
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) {
                          final categoria = categorias[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: categoria.iconColor,
                              child: Icon(
                                categoria.iconData,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(categoria.name),
                            subtitle: Text(categoria.description),
                            onTap: () {
                              // Acción al tocar una categoría (si es necesario)
                            },
                          );
                        },
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
          Icon(
            Icons.category_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            'No hay categorías para mostrar.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          Text(
            'Agrega nuevas categorías para clasificar tus movimientos.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
}