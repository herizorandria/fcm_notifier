import 'package:flutter/material.dart';

class CustomScaffold extends StatelessWidget {
  const CustomScaffold({
    super.key,
    required this.child,
    this.showBackButton = false,
    this.backButtonColor = Colors.black,
  });

  final Widget child;
  final bool showBackButton;
  final Color backButtonColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: showBackButton && Navigator.canPop(context)
            ? IconButton(
          icon: Icon(Icons.arrow_back, color: backButtonColor),
          onPressed: () => Navigator.pop(context),
        )
            : null,
        automaticallyImplyLeading: false,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // ✅ Fond dégradé jaune
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFFFAC1), // Jaune très clair
                  Color(0xFFFEB823), // Jaune orangé
                ],
              ),
            ),
          ),
          SafeArea(child: child),
        ],
      ),
    );
  }
}