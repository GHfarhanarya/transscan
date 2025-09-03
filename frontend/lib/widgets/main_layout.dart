import 'package:flutter/material.dart';
import '../widgets/custom_navbar.dart';
import '../pages/home_page.dart';
import '../pages/settings.dart';

class MainLayout extends StatefulWidget {
  final int initialIndex;

  const MainLayout({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout>
    with TickerProviderStateMixin {
  late int _currentIndex;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }

  void _onNavItemTapped(int index) {
    if (_currentIndex == index) return;

    // Tentukan arah slide
    bool isFromRight = index > _currentIndex;

    // Setup animasi
    _slideAnimation = Tween<Offset>(
      begin: Offset(isFromRight ? 1.0 : -1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.2, 1.0, curve: Curves.easeOut),
    ));

    // Update index
    setState(() {
      _currentIndex = index;
    });

    // Start animation
    _animationController.forward(from: 0.0);
  }

  Widget _getCurrentContent() {
    switch (_currentIndex) {
      case 0:
        return _HomeContent();
      case 2:
        return _SettingsContent();
      default:
        return _HomeContent();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: _getCurrentContent(),
            ),
          );
        },
      ),
      bottomNavigationBar: CustomNavbar(
        selectedIndex: _currentIndex,
        onIndexChanged: _onNavItemTapped,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

// Widget wrapper untuk konten HomePage
class _HomeContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return HomePage();
  }
}

// Widget wrapper untuk konten SettingsPage
class _SettingsContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SettingsPage();
  }
}
