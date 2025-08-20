import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'login_page.dart';
import 'home_page.dart';
import '../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _blinkController;
  late AnimationController _scanController;
  late AnimationController _moveLogoController;

  bool show1 = true;
  bool show2 = false;
  bool show3 = false;
  bool show4 = false;

  // ukuran masing-masing SVG
  final double size1 = 100;
  final double size2 = 70;
  final double size3 = 40;
  final double size4 = 70;

  @override
  void initState() {
    super.initState();

    _blinkController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    _scanController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    _moveLogoController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 700),
    );

    _startSequence();
  }

  Future<void> _startSequence() async {
    // Munculkan 2.svg dengan kedip 2x
    await Future.delayed(Duration(milliseconds: 800));
    setState(() => show2 = true);
    for (int i = 0; i < 2; i++) {
      await _blinkController.forward();
      await _blinkController.reverse();
    }

    // Setelah kedip, tetap tampilkan 2.svg dan munculkan 3.svg scanning
    setState(() => show3 = true);
    _scanController.forward();
    await Future.delayed(Duration(milliseconds: 800));

    // Hilangkan 3.svg, munculkan 4.svg + geser 1.svg
    setState(() {
      show3 = false;
      show4 = true;
    });
    _moveLogoController.forward();

    await Future.delayed(Duration(milliseconds: 1000));
    _navigateToLogin();
  }

  _navigateToLogin() async {
    bool isLoggedIn = await AuthService.isLoggedIn();
    if (!mounted) return;

    if (isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  @override
  void dispose() {
    _blinkController.dispose();
    _scanController.dispose();
    _moveLogoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scanAnimation = Tween<Offset>(
      begin: Offset(-35.5, 0),
      end: Offset(35.5, 0),
    ).animate(CurvedAnimation(
      parent: _scanController,
      curve: Curves.easeInOut,
    ));

    final moveLogoAnimation = Tween<Offset>(
      begin: Offset(0, 0),
      end: Offset(0.25, 0), // geser dikit pas ke 4.svg
    ).animate(CurvedAnimation(
      parent: _moveLogoController,
      curve: Curves.easeInOut,
    ));

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFD90000), // Warna merah utama di atas
              Color(0xFFFF3333), // Warna merah yang lebih gelap di bawah
            ],
            stops: [0.0, 1.0],
          ),
        ),
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 2.svg selalu di tengah setelah muncul
              if (show2)
                FadeTransition(
                  opacity: _blinkController.isAnimating
                      ? _blinkController
                      : AlwaysStoppedAnimation(1),
                  child: SvgPicture.asset(
                    'assets/splash/2.svg',
                    height: size2,
                    width: size2,
                  ),
                ),

              // 4.svg di atas 2.svg (center)
              if (show4)
                SvgPicture.asset(
                  'assets/splash/4.svg',
                  height: size3,
                  width: size3,
                ),

              // 1.svg (bergser saat 4.svg muncul) → di atas 2.svg
              if (show1)
                SlideTransition(
                  position: show4
                      ? moveLogoAnimation
                      : AlwaysStoppedAnimation(Offset.zero),
                  child: SvgPicture.asset(
                    'assets/splash/1.svg',
                    height: size3,
                    width: size3,
                  ),
                ),

              // 3.svg scanning di atas 2.svg
              if (show3)
                SlideTransition(
                  position: scanAnimation,
                  child: SvgPicture.asset(
                    'assets/splash/3.svg',
                    height: size1,
                    width: size1,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
