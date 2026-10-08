import 'dart:async';

import 'package:control_financiero/app/app_state.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';

import 'tutorial_progress.dart';
import 'tutorial_step.dart';

final tutorialRouteObserver = RouteObserver<ModalRoute<dynamic>>();

class TutorialAnchor {
  TutorialAnchor(this.showcaseKey, this.targetKey);
  final GlobalKey showcaseKey;
  final GlobalKey targetKey;
}

class TutorialCoordinator {
  TutorialCoordinator(this.changed, this.openMenu);
  final VoidCallback changed;
  final Future<void> Function(VoidCallback) openMenu;
  final targets = <TutorialStep, TutorialAnchor>{};
  Future<void> Function()? reset;

  void register(TutorialStep step, GlobalKey key, GlobalKey targetKey) {
    targets[step] = TutorialAnchor(key, targetKey);
    changed();
  }

  void unregister(TutorialStep step, GlobalKey key) {
    if (targets[step]?.showcaseKey == key) targets.remove(step);
    changed();
  }
}

/// Owns one showcase registration across all four main tabs.
class TutorialHost extends StatefulWidget {
  const TutorialHost({super.key, required this.child, this.progress});
  final Widget child;
  final TutorialProgress? progress;

  @override
  State<TutorialHost> createState() => _TutorialHostState();
}

class _TutorialHostState extends State<TutorialHost>
    with WidgetsBindingObserver, RouteAware {
  late final TutorialCoordinator _coordinator;
  late final ShowcaseView _showcase;
  TutorialProgress? _progress;
  AppState? _appState;
  ModalRoute<dynamic>? _route;
  Timer? _timer;
  String? _activeGroup;
  List<TutorialAnchor> _activeTargets = [];
  int? _activeTab;
  bool _interrupted = false;
  bool _saving = false;
  bool _foreground = true;
  bool _disposed = false;
  final _sessionFinished = <String>{};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _coordinator = TutorialCoordinator(_schedule, _openMenu);
    _coordinator.reset = _reset;
    _showcase = ShowcaseView.register(
      scope: 'tutoriales',
      enableAutoScroll: true,
      disableBarrierInteraction: true,
      disableMovingAnimation: true,
      onFinish: () => unawaited(_finish(skipped: false)),
      onDismiss: (_) {
        if (!_interrupted) unawaited(_finish(skipped: true));
      },
    );
    unawaited(_load());
  }

  Future<void> _load() async {
    if (widget.progress != null) {
      _progress = widget.progress;
      _schedule();
      return;
    }
    try {
      final box = Hive.isBoxOpen('settings')
          ? Hive.box<dynamic>('settings')
          : await Hive.openBox<dynamic>('settings');
      if (_disposed) return;
      _progress = TutorialProgress(box);
      _schedule();
    } catch (error) {
      // Financial features stay usable if local preferences cannot be read.
      debugPrint('No se pudieron cargar los tutoriales: $error');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = context.read<AppState>();
    if (_appState != state) {
      _appState?.removeListener(_changed);
      _appState = state;
      state.addListener(_changed);
    }
    final route = ModalRoute.of(context);
    if (_route != route) {
      tutorialRouteObserver.unsubscribe(this);
      _route = route;
      if (route != null) tutorialRouteObserver.subscribe(this, route);
    }
    _schedule();
  }

  void _changed() {
    final state = _appState!;
    if (_activeGroup != null &&
        (_activeTab != state.currentTab || _loading(state))) {
      _pause();
    }
    _schedule();
  }

  bool _loading(AppState state) =>
      state.loadingInitialData ||
      switch (state.currentTab) {
        0 => state.isLoadingMonth,
        1 => state.isLoadingBudget,
        2 => state.isLoadingHistory,
        _ => false,
      };

  void _schedule() {
    if (_disposed) return;
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 500), _startPending);
  }

  void _startPending() {
    final state = _appState;
    final progress = _progress;
    if (_activeGroup != null &&
        _activeTargets.any(
          (target) => target.targetKey.currentContext == null,
        )) {
      _pause();
    }
    if (!mounted ||
        !_foreground ||
        _saving ||
        _activeGroup != null ||
        state == null ||
        progress == null ||
        _loading(state)) {
      return;
    }

    final steps = TutorialStep.values.where(
      (step) => step.tab == state.currentTab,
    );
    final groups = steps.map((step) => step.group).toSet();
    for (final group in groups) {
      if (!progress.isPending(group) || _sessionFinished.contains(group)) {
        continue;
      }
      final required = steps.where((step) => step.group == group).toList();
      if (!required.first.isMenuOption && !(_route?.isCurrent ?? false)) {
        continue;
      }
      final anchors = <TutorialAnchor>[];
      for (final step in required) {
        final anchor = _coordinator.targets[step];
        final targetContext = anchor?.targetKey.currentContext;
        if (anchor == null ||
            targetContext == null ||
            !(ModalRoute.of(targetContext)?.isCurrent ?? false)) {
          break;
        }
        final render = targetContext.findRenderObject();
        if (render is! RenderBox ||
            !render.attached ||
            !render.hasSize ||
            render.size.isEmpty) {
          break;
        }
        anchors.add(anchor);
      }
      // Never finish a group while one of its conditional targets is absent.
      if (anchors.length != required.length) continue;
      _activeGroup = group;
      _activeTargets = anchors;
      _activeTab = state.currentTab;
      _showcase.startShowCase(
        anchors.map((anchor) => anchor.showcaseKey).toList(),
      );
      return;
    }
  }

  Future<void> _finish({required bool skipped}) async {
    final group = _activeGroup;
    if (group == null || _saving || _disposed) return;
    _saving = true;
    _sessionFinished.add(group);
    _activeGroup = null;
    _activeTargets = [];
    try {
      await _progress?.finish(group, skipped: skipped);
    } catch (error) {
      debugPrint('No se pudo guardar el progreso del tutorial: $error');
    } finally {
      _saving = false;
      _schedule();
    }
  }

  void _pause() {
    if (_activeGroup == null) return;
    _interrupted = true;
    _showcase.dismiss();
    _interrupted = false;
    _activeGroup = null;
    _activeTargets = [];
  }

  Future<void> _openMenu(VoidCallback open) async {
    _interrupted = true;
    _showcase.dismiss();
    _interrupted = false;
    await _finish(skipped: false);
    if (!_disposed) open();
  }

  Future<void> _reset() async {
    _pause();
    await _progress?.reset();
    if (_disposed) return;
    _sessionFinished.clear();
    _appState?.changeTab(0);
    _schedule();
  }

  @override
  void didPushNext() => _pause();

  @override
  void didPopNext() {
    if (_activeGroup?.endsWith('_menu') ?? false) _pause();
    _schedule();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    if (!_foreground) _pause();
    if (_foreground) _schedule();
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    _appState?.removeListener(_changed);
    tutorialRouteObserver.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);
    _pause();
    _showcase.unregister();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Provider<TutorialCoordinator>.value(
    value: _coordinator,
    child: widget.child,
  );
}

class TutorialTarget extends StatefulWidget {
  const TutorialTarget({
    super.key,
    required this.step,
    required this.child,
    this.openMenu,
  });
  final TutorialStep step;
  final Widget child;
  final VoidCallback? openMenu;

  @override
  State<TutorialTarget> createState() => _TutorialTargetState();
}

class _TutorialTargetState extends State<TutorialTarget> {
  final _key = GlobalKey();
  // Since showcaseview 5, its key identifies the controller, not an Element.
  final _targetKey = GlobalKey();
  TutorialCoordinator? _coordinator;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final coordinator = context.read<TutorialCoordinator?>();
    if (_coordinator != coordinator) {
      _coordinator?.unregister(widget.step, _key);
      _coordinator = coordinator;
      coordinator?.register(widget.step, _key, _targetKey);
    }
  }

  @override
  void didUpdateWidget(TutorialTarget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.step != widget.step) {
      _coordinator?.unregister(oldWidget.step, _key);
      _coordinator?.register(widget.step, _key, _targetKey);
    }
  }

  @override
  void dispose() {
    _coordinator?.unregister(widget.step, _key);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final coordinator = _coordinator;
    if (coordinator == null) return widget.child;
    final colors = Theme.of(context).colorScheme;
    return KeyedSubtree(
      key: _targetKey,
      child: Showcase(
        key: _key,
        scope: 'tutoriales',
        title: widget.step.title,
        description: widget.step.description,
        tooltipBackgroundColor: colors.surface,
        textColor: colors.onSurface,
        disableBarrierInteraction: true,
        onTargetClick: widget.openMenu == null
            ? null
            : () => unawaited(coordinator.openMenu(widget.openMenu!)),
        disposeOnTap: widget.openMenu == null ? null : false,
        tooltipActions: [
          TooltipActionButton(
            type: TooltipDefaultActionType.skip,
            name: 'Omitir',
            onTap: () => ShowcaseView.getNamed('tutoriales').dismiss(),
          ),
          TooltipActionButton(
            type: TooltipDefaultActionType.next,
            name: widget.openMenu != null ? 'Abrir menú' : 'Siguiente',
            onTap: widget.openMenu == null
                ? null
                : () => unawaited(coordinator.openMenu(widget.openMenu!)),
          ),
        ],
        child: widget.child,
      ),
    );
  }
}
