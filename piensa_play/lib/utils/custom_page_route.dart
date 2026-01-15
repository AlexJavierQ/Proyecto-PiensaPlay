import 'package:flutter/material.dart';

/// Transiciones personalizadas para navegación premium
class CustomPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final RouteTransitionType transitionType;

  CustomPageRoute({
    required this.page,
    this.transitionType = RouteTransitionType.fade,
    RouteSettings? settings,
  }) : super(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 350),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            switch (transitionType) {
              case RouteTransitionType.fade:
                return FadeTransition(opacity: animation, child: child);
              
              case RouteTransitionType.slideRight:
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  )),
                  child: child,
                );
              
              case RouteTransitionType.slideUp:
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.0, 1.0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  )),
                  child: child,
                );
              
              case RouteTransitionType.scale:
                return ScaleTransition(
                  scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutBack,
                    ),
                  ),
                  child: FadeTransition(opacity: animation, child: child),
                );
              
              case RouteTransitionType.fadeScale:
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                    child: child,
                  ),
                );
              
              case RouteTransitionType.slideAndFade:
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.3, 0.0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  )),
                  child: FadeTransition(opacity: animation, child: child),
                );
            }
          },
        );
}

enum RouteTransitionType {
  fade,
  slideRight,
  slideUp,
  scale,
  fadeScale,
  slideAndFade,
}

/// Helper para crear rutas con transiciones específicas
Route<T> createRoute<T>(
  Widget page, {
  RouteTransitionType type = RouteTransitionType.fadeScale,
  RouteSettings? settings,
}) {
  return CustomPageRoute<T>(
    page: page,
    transitionType: type,
    settings: settings,
  );
}
