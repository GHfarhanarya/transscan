import 'package:flutter/material.dart';

// Untuk transisi konten saja (navbar tetap di tempat)
class ContentSlideRoute extends PageRouteBuilder {
  final Widget content;
  final bool isFromRight;
  final PreferredSizeWidget? appBar;
  final Color? backgroundColor;
  final int selectedIndex;

  ContentSlideRoute({
    required this.content,
    required this.selectedIndex,
    this.isFromRight = true,
    this.appBar,
    this.backgroundColor,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => content,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Slide animation horizontal
            var begin = Offset(isFromRight ? 1.0 : -1.0, 0.0);
            var end = Offset.zero;
            var curve = Curves.easeOutCubic;

            var slideAnimation = Tween<Offset>(
              begin: begin,
              end: end,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: curve,
              ),
            );

            // Fade untuk smoothness
            var fadeAnimation = Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Interval(0.2, 1.0, curve: Curves.easeOut),
              ),
            );

            return SlideTransition(
              position: slideAnimation,
              child: FadeTransition(
                opacity: fadeAnimation,
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 250),
        );
}

// Untuk transisi login yang smooth dan profesional
class SmoothLoginRoute extends PageRouteBuilder {
  final Widget page;

  SmoothLoginRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Kombinasi fade dan slide yang sangat smooth
            var slideAnimation = Tween<Offset>(
              begin: const Offset(0.0, 0.1),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutQuart,
              ),
            );

            var fadeAnimation = Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Interval(0.0, 0.8, curve: Curves.easeOut),
              ),
            );

            var scaleAnimation = Tween<double>(
              begin: 0.98,
              end: 1.0,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutQuart,
              ),
            );

            return SlideTransition(
              position: slideAnimation,
              child: FadeTransition(
                opacity: fadeAnimation,
                child: ScaleTransition(
                  scale: scaleAnimation,
                  child: child,
                ),
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 600),
        );
}



// Untuk halaman detail yang dibuka dari item list (slide dari kanan)
class DetailPageRoute extends PageRouteBuilder {
  final Widget page;

  DetailPageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var begin = const Offset(1.0, 0.0);
            var end = Offset.zero;
            var curve = Curves.easeOutCubic;
            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);

            var fadeAnimation = Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              ),
            );

            return SlideTransition(
              position: offsetAnimation,
              child: FadeTransition(
                opacity: fadeAnimation,
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 350),
        );
}



// Untuk navigasi antar section utama (slide dari bawah) - Lebih smooth
class MainPageRoute extends PageRouteBuilder {
  final Widget page;

  MainPageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var begin = const Offset(0.0, 0.8);
            var end = Offset.zero;
            var curve = Curves.easeOutQuart;
            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);

            var fadeAnimation = Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Interval(0.0, 0.7, curve: Curves.easeOut),
              ),
            );

            var scaleAnimation = Tween<double>(
              begin: 0.96,
              end: 1.0,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: curve,
              ),
            );

            return SlideTransition(
              position: offsetAnimation,
              child: FadeTransition(
                opacity: fadeAnimation,
                child: ScaleTransition(
                  scale: scaleAnimation,
                  child: child,
                ),
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 500),
        );
}

// Untuk keluar/logout (fade out dengan scale sedikit)
class ExitPageRoute extends PageRouteBuilder {
  final Widget page;

  ExitPageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var scaleAnimation = Tween<double>(
              begin: 1.0,
              end: 0.95,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeIn,
              ),
            );

            var fadeAnimation = Tween<double>(
              begin: 1.0,
              end: 0.0,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              ),
            );

            return FadeTransition(
              opacity: fadeAnimation,
              child: ScaleTransition(
                scale: scaleAnimation,
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 200),
          reverseTransitionDuration: const Duration(milliseconds: 200),
        );
}



// Untuk transisi horizontal smooth dari Home ke Settings
class SettingsSlideRoute extends PageRouteBuilder {
  final Widget page;
  final bool isFromRight; // true = slide dari kanan, false = slide dari kiri

  SettingsSlideRoute({required this.page, this.isFromRight = true})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Slide animation - dari kanan untuk settings, dari kiri untuk home
            var begin = Offset(isFromRight ? 1.0 : -1.0, 0.0);
            var end = Offset.zero;
            var slideCurve = Curves.easeOutQuart;

            var slideAnimation = Tween<Offset>(
              begin: begin,
              end: end,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: slideCurve,
              ),
            );

            // Fade animation untuk transisi yang lebih smooth
            var fadeAnimation = Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Interval(0.0, 0.8, curve: Curves.easeOut),
              ),
            );

            // Scale animation untuk memberikan depth
            var scaleAnimation = Tween<double>(
              begin: 0.98,
              end: 1.0,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: slideCurve,
              ),
            );

            // Secondary animation untuk halaman yang ditinggalkan
            var secondarySlideAnimation = Tween<Offset>(
              begin: Offset.zero,
              end: Offset(isFromRight ? -0.3 : 0.3, 0.0),
            ).animate(
              CurvedAnimation(
                parent: secondaryAnimation,
                curve: slideCurve,
              ),
            );

            var secondaryScaleAnimation = Tween<double>(
              begin: 1.0,
              end: 0.95,
            ).animate(
              CurvedAnimation(
                parent: secondaryAnimation,
                curve: slideCurve,
              ),
            );

            return Stack(
              children: [
                // Halaman yang ditinggalkan (dengan efek parallax)
                SlideTransition(
                  position: secondarySlideAnimation,
                  child: ScaleTransition(
                    scale: secondaryScaleAnimation,
                    child: Container(),
                  ),
                ),
                // Halaman baru
                SlideTransition(
                  position: slideAnimation,
                  child: FadeTransition(
                    opacity: fadeAnimation,
                    child: ScaleTransition(
                      scale: scaleAnimation,
                      child: child,
                    ),
                  ),
                ),
              ],
            );
          },
          transitionDuration: const Duration(milliseconds: 400),
          reverseTransitionDuration: const Duration(milliseconds: 350),
        );
}
