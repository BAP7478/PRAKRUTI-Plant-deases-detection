import 'dart:io';

void main() async {
  // Create SVG content for the leaf icon
  const size = 1024;
  const center = size / 2;
  
  final svgContent = '''
<svg width="$size" height="$size" xmlns="http://www.w3.org/2000/svg">
  <!-- Gradient background -->
  <defs>
    <radialGradient id="backgroundGradient" cx="50%" cy="50%" r="50%">
      <stop offset="0%" style="stop-color:#66BB6A;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#4CAF50;stop-opacity:1" />
    </radialGradient>
  </defs>
  
  <!-- Background circle -->
  <circle cx="$center" cy="$center" r="$center" fill="url(#backgroundGradient)" />
  
  <!-- Leaf shape -->
  <path d="M${center},${center + 50} 
           Q${center - 100},${center - 83} ${center - 150},${center - 190}
           Q${center - 75},${center - 310} ${center},${center - 350}
           Q${center + 75},${center - 310} ${center + 150},${center - 190}
           Q${center + 100},${center - 83} ${center},${center + 50} Z"
        fill="#2E7D32" />
  
  <!-- Central vein -->
  <line x1="$center" y1="${center + 50}" x2="$center" y2="${center - 350}" 
        stroke="#1B5E20" stroke-width="4" />
  
  <!-- Side veins -->
  <line x1="$center" y1="${center - 280}" x2="${center - 60}" y2="${center - 300}" 
        stroke="#1B5E20" stroke-width="3" />
  <line x1="$center" y1="${center - 280}" x2="${center + 60}" y2="${center - 300}" 
        stroke="#1B5E20" stroke-width="3" />
  
  <line x1="$center" y1="${center - 210}" x2="${center - 80}" y2="${center - 230}" 
        stroke="#1B5E20" stroke-width="3" />
  <line x1="$center" y1="${center - 210}" x2="${center + 80}" y2="${center - 230}" 
        stroke="#1B5E20" stroke-width="3" />
  
  <line x1="$center" y1="${center - 140}" x2="${center - 90}" y2="${center - 160}" 
        stroke="#1B5E20" stroke-width="3" />
  <line x1="$center" y1="${center - 140}" x2="${center + 90}" y2="${center - 160}" 
        stroke="#1B5E20" stroke-width="3" />
  
  <line x1="$center" y1="${center - 70}" x2="${center - 60}" y2="${center - 90}" 
        stroke="#1B5E20" stroke-width="3" />
  <line x1="$center" y1="${center - 70}" x2="${center + 60}" y2="${center - 90}" 
        stroke="#1B5E20" stroke-width="3" />
</svg>
''';

  // Ensure directory exists
  final directory = Directory('assets/icons');
  if (!await directory.exists()) {
    await directory.create(recursive: true);
  }
  
  // Save SVG file
  final svgFile = File('assets/icons/app_icon.svg');
  await svgFile.writeAsString(svgContent);
  print('✅ SVG icon generated successfully at: ${svgFile.path}');
  
  print('\n🔄 To complete the icon setup:');
  print('1. We need to convert SVG to PNG format');
  print('2. Then run flutter_launcher_icons to generate all app icons');
  print('\nLet me check if we can use ImageMagick or another tool...');
}
