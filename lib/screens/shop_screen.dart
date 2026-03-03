import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        final isGujarati = languageProvider.isGujarati;

        return Scaffold(
          appBar: AppBar(
            title: Text(isGujarati ? 'દુકાન લોકેટર' : 'Shop Locator'),
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.store, size: 100, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  isGujarati
                      ? 'દુકાન લોકેટર ટૂંક સમયમાં આવશે'
                      : 'Shop Locator Coming Soon',
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.grey,
                    fontFamily: 'NotoSansGujarati',
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
