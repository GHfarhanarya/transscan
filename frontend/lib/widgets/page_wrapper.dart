import 'package:flutter/material.dart';
import 'custom_navbar.dart';

class PageWrapper extends StatefulWidget {
  final int selectedIndex;

  const PageWrapper({
    Key? key,
    required this.selectedIndex,
  }) : super(key: key);

  @override
  State<PageWrapper> createState() => _PageWrapperState();
}

class _PageWrapperState extends State<PageWrapper>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  int _currentIndex = 0;
  Widget? _currentContent;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.selectedIndex;
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
    _updateContent();
  }

  @override
  void didUpdateWidget(PageWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _animateToPage(widget.selectedIndex);
    }
  }

  void _animateToPage(int newIndex) {
    if (_currentIndex == newIndex) return;

    // Tentukan arah slide
    bool isFromRight = newIndex > _currentIndex;

    // Set slide animation
    _slideAnimation = Tween<Offset>(
      begin: Offset(isFromRight ? 1.0 : -1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    // Update index dan content
    setState(() {
      _currentIndex = newIndex;
      _updateContent();
    });

    // Start animation
    _animationController.forward(from: 0.0);
  }

  void _updateContent() {
    switch (_currentIndex) {
      case 0:
        _currentContent = _buildHomeContent();
        break;
      case 2:
        _currentContent = _buildSettingsContent();
        break;
      default:
        _currentContent = _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
    // Import dan gunakan konten dari HomePage
    return Container(
      child: Center(
        child: Text(
          'Home Content',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildSettingsContent() {
    // Import dan gunakan konten dari SettingsPage
    return Container(
      child: Center(
        child: Text(
          'Settings Content',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedBuilder(
        animation: _slideAnimation,
        builder: (context, child) {
          return SlideTransition(
            position: _slideAnimation,
            child: _currentContent ?? Container(),
          );
        },
      ),
      bottomNavigationBar: CustomNavbar(selectedIndex: _currentIndex),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
