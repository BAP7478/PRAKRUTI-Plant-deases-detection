# App Icon Instructions

To complete the app icon setup with the leaf design:

1. Create a 1024x1024 PNG image named `app_icon.png` in this directory
2. The image should feature a green leaf design similar to the `Icons.eco_rounded` used in the app
3. Use a clean, modern design with a green color scheme matching your app's theme
4. Save it as `app_icon.png` in this assets/icons/ directory

Recommended colors:
- Primary green: #4CAF50 (Colors.green)
- Dark green: #388E3C (Colors.green[600])
- Light green background: #E8F5E8

Once you have the image file, run:
```bash
flutter pub get
flutter pub run flutter_launcher_icons
```

This will automatically generate all the required icon sizes for all platforms.
