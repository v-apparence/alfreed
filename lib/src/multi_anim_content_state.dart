import 'package:alfreed/src/context_wrapper.dart';
import 'package:flutter/material.dart';

import '../alfreed.dart';
import 'content_builder.dart';
import 'models/anim.dart';

class MVVMMultipleTickerProviderContentState<P extends Presenter, M>
    extends State<MVVMContent>
    with TickerProviderStateMixin
    implements ContentView {
  Map<String, AlfreedAnimation>? _animations;
  final MvvmAnimationListener<P, M> animListener;
  bool hasInit = false;

  MVVMMultipleTickerProviderContentState(this.animListener);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    presenter.viewRef = this;
    _animations = widget.multipleAnimController!(this);
    if (!hasInit) {
      hasInit = true;
      presenter.onInit();
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        presenter.afterViewInit();
      });
    }
  }

  @override
  void reassemble() {
    super.reassemble();
    presenter.onInit();
    hasInit = false;
  }

  @override
  void deactivate() {
    presenter.onDeactivate();
    this.disposeAnimation();
    super.deactivate();
  }

  @override
  void forceRefreshView() {
    if (mounted) {
      setState(() {});
    }
  }

  AlfreedContext get mvvmContext =>
      AlfreedContext(context, animations: _animations);

  P get presenter => PresenterInherited.of<P, M>(context).presenter;

  ContentBuilder<P, M> get builder =>
      PresenterInherited.of<P, M>(context).builder;

  @override
  Widget build(BuildContext context) =>
      builder(mvvmContext, presenter, presenter.state);

  @override
  Future<void> refreshAnimation() async =>
      animListener(mvvmContext, presenter, presenter.state);

  @override
  Future<void> disposeAnimation() async {
    if (_animations != null && _animations!.length > 0) {
      for (var el in _animations!.values) {
        el.controller.stop();
        el.controller.dispose();
      }
    }
  }

  @override
  Map<String, AlfreedAnimation> get animations => _animations!;
}
