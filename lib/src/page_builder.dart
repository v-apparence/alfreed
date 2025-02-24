import 'package:alfreed/src/context_wrapper.dart';
import 'package:flutter/material.dart';

import '../alfreed.dart';
import 'content_builder.dart';
import 'models/anim.dart';

/// builds a presenter
typedef PresenterBuilder<P extends Presenter> = P Function(
    BuildContext context);

/// builds the interface that the presenter can call to call the view
typedef AlfreedViewBuilder<I extends AlfreedView> = I Function(
    BuildContext context);

/// functions to handle animation state without refresh page
typedef MvvmAnimationListener<P extends Presenter, M> = void Function(
    AlfreedContext context, P presenter, M model);

/// functions to create animations using a string key to find your animation back
typedef AlfreedAnimationsBuilder = Map<String, AlfreedAnimation> Function(
    TickerProvider tickerProvider);

/// builds a single [AlfreedAnimation]
typedef AlfreedAnimationBuilder = Map<String, AlfreedAnimation> Function(
    TickerProvider tickerProvider);

class AlfreedPageBuilder<P extends Presenter, M, I extends AlfreedView> {
  P? _presenter;
  Key? key;

  final PresenterBuilder<P> presenterBuilder;
  final ContentBuilder<P, M> builder;
  final AlfreedViewBuilder<I> interfaceBuilder;
  MvvmAnimationListener<P, M>? animListener;
  AlfreedAnimationBuilder? singleAnimControllerBuilder;
  AlfreedAnimationsBuilder? multipleAnimControllerBuilder;
  bool forceRebuild;
  bool rebuildIfDisposed;
  Object? args;

  AlfreedPageBuilder._({
    this.key,
    required this.presenterBuilder,
    required this.builder,
    required this.interfaceBuilder,
    this.animListener,
    this.singleAnimControllerBuilder,
    this.multipleAnimControllerBuilder,
    this.forceRebuild = false,
    this.rebuildIfDisposed = false,
  });

  factory AlfreedPageBuilder({
    Key? key,
    required PresenterBuilder<P> presenterBuilder,
    required ContentBuilder<P, M> builder,
    required AlfreedViewBuilder<I> interfaceBuilder,
    bool rebuildIfDisposed = true,
  }) =>
      AlfreedPageBuilder._(
        key: key,
        presenterBuilder: presenterBuilder,
        builder: builder,
        interfaceBuilder: interfaceBuilder,
        rebuildIfDisposed: rebuildIfDisposed,
      );

  factory AlfreedPageBuilder.animated({
    Key? key,
    required PresenterBuilder<P> presenterBuilder,
    required ContentBuilder<P, M> builder,
    required AlfreedViewBuilder<I> interfaceBuilder,
    required MvvmAnimationListener<P, M>? animListener,
    required AlfreedAnimationBuilder? singleAnimControllerBuilder,
    bool rebuildIfDisposed = true,
  }) =>
      AlfreedPageBuilder._(
          key: key,
          presenterBuilder: presenterBuilder,
          builder: builder,
          interfaceBuilder: interfaceBuilder,
          animListener: animListener,
          rebuildIfDisposed: rebuildIfDisposed,
          singleAnimControllerBuilder: singleAnimControllerBuilder);

  factory AlfreedPageBuilder.animatedMulti({
    Key? key,
    required PresenterBuilder<P> presenterBuilder,
    required ContentBuilder<P, M> builder,
    required AlfreedViewBuilder<I> interfaceBuilder,
    required MvvmAnimationListener<P, M>? animListener,
    required AlfreedAnimationsBuilder? multipleAnimControllerBuilder,
    bool rebuildIfDisposed = true,
  }) =>
      AlfreedPageBuilder._(
          key: key,
          presenterBuilder: presenterBuilder,
          builder: builder,
          interfaceBuilder: interfaceBuilder,
          animListener: animListener,
          rebuildIfDisposed: rebuildIfDisposed,
          multipleAnimControllerBuilder: multipleAnimControllerBuilder);

  Widget build(BuildContext context) {
    assert(
        ((singleAnimControllerBuilder != null ||
                    multipleAnimControllerBuilder != null) &&
                animListener != null) ||
            (singleAnimControllerBuilder == null &&
                multipleAnimControllerBuilder == null),
        'An Animated page was requested, but no listener was given.');
    assert(
        !(singleAnimControllerBuilder != null &&
            multipleAnimControllerBuilder != null),
        'Cannot have both a single and a multiple animation controller builder.');
    if (_presenter == null ||
        forceRebuild ||
        (_presenter?.presenterState == PresenterState.DISPOSED &&
            rebuildIfDisposed)) {
      _presenter = presenterBuilder(context);
      _presenter!.view = interfaceBuilder(context);
    }
    _presenter!.args = args;
    // Widget content;
    Widget content = MVVMContent<P, M>(
      singleAnimController: singleAnimControllerBuilder,
      multipleAnimController: multipleAnimControllerBuilder,
      animListener: animListener,
    );
    return PresenterInherited<P, M>(
      key: key,
      presenter: _presenter!,
      builder: builder,
      child: content,
    );
  }

  @visibleForTesting
  P get presenter => _presenter!;
}
