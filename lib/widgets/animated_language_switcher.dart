import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';

class AnimatedLanguageSwitcher extends StatefulWidget {
  const AnimatedLanguageSwitcher({super.key});

  @override
  State<AnimatedLanguageSwitcher> createState() =>
      _AnimatedLanguageSwitcherState();
}

class _AnimatedLanguageSwitcherState extends State<AnimatedLanguageSwitcher>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _rotateAnimation = Tween<double>(begin: 0.0, end: 0.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onLanguageSelected(String language) {
    _controller.forward().then((_) {
      final languageProvider =
          Provider.of<LanguageProvider>(context, listen: false);
      languageProvider.setLanguage(language);
      _controller.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Transform.rotate(
                angle: _rotateAnimation.value,
                child: PopupMenuButton<String>(
                  onSelected: _onLanguageSelected,
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem(
                      value: 'gu',
                      child: Row(
                        children: [
                          const Text('ગુજરાતી',
                              style: TextStyle(fontFamily: 'NotoSansGujarati')),
                          const SizedBox(width: 8),
                          if (languageProvider.currentLanguageCode == 'gu')
                            const Icon(Icons.check, color: Colors.green),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'en',
                      child: Row(
                        children: [
                          const Text('English'),
                          const SizedBox(width: 8),
                          if (languageProvider.currentLanguageCode == 'en')
                            const Icon(Icons.check, color: Colors.green),
                        ],
                      ),
                    ),
                  ],
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.language, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          languageProvider.currentLanguageName,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
