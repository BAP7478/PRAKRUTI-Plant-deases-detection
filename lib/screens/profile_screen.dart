import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:prakruti/localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../models/user_profile.dart';
import '../providers/language_provider.dart';
import 'dart:convert';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _farmSizeController = TextEditingController();
  List<String> _selectedCrops = [];
  bool _isEditing = false;
  UserProfile? _userProfile;
  bool _isAdmin = false;

  final List<String> _availableCrops = [
    'Cotton',
    'Wheat',
    'Rice',
    'Groundnut',
    'Sugarcane',
    'Maize',
    'Pulses',
    'Others'
  ];

  // Help section data
  final List<Map<String, dynamic>> _helpSections = [
    {
      'title': 'AI Assistant',
      'titleGu': 'AI સહાયક',
      'icon': Icons.smart_toy_rounded,
      'isClickable': true,
      'route': '/chatbot',
      'items': [
        {
          'text': 'Ask questions about farming',
          'textGu': 'ખેતી વિશે પ્રશ્નો પૂછો'
        },
        {'text': 'Get instant advice', 'textGu': 'તાત્કાલિક સલાહ મેળવો'},
        {'text': 'Plant disease help', 'textGu': 'પાક રોગ સહાય'},
        {'text': 'Crop management tips', 'textGu': 'પાક સંચાલન ટિપ્સ'},
      ]
    },
    {
      'title': 'Getting Started',
      'titleGu': 'શરૂઆત કરવી',
      'icon': Icons.play_circle_outline,
      'items': [
        {
          'text': 'How to detect plant diseases',
          'textGu': 'પાક રોગ કેવી રીતે શોધવા'
        },
        {
          'text': 'Using the camera scanner',
          'textGu': 'કેમેરા સ્કેનર કેવી રીતે વાપરવું'
        },
        {'text': 'Understanding results', 'textGu': 'પરિણામો કેવી રીતે સમજવા'},
        {'text': 'Saving scan history', 'textGu': 'સ્કેન ઇતિહાસ સાચવવો'},
      ]
    },
    {
      'title': 'Disease Management',
      'titleGu': 'રોગ સંચાલન',
      'icon': Icons.healing,
      'items': [
        {'text': 'Reading remedy suggestions', 'textGu': 'ઉપચાર સૂચનો વાંચવા'},
        {'text': 'Preventive measures', 'textGu': 'નિવારક પગલાં'},
        {'text': 'When to apply treatments', 'textGu': 'સારવાર ક્યારે કરવી'},
        {
          'text': 'Organic vs chemical solutions',
          'textGu': 'કુદરતી વિ. રાસાયણિક ઉકેલ'
        },
      ]
    },
    {
      'title': 'Weather & Farming',
      'titleGu': 'હવામાન અને ખેતી',
      'icon': Icons.wb_sunny,
      'items': [
        {'text': 'Using weather forecasts', 'textGu': 'હવામાન આગાહી વાપરવી'},
        {'text': 'Best planting times', 'textGu': 'વાવેતરનો શ્રેષ્ઠ સમય'},
        {'text': 'Seasonal crop care', 'textGu': 'મોસમી પાક સંભાળ'},
        {'text': 'Climate-based decisions', 'textGu': 'આબોહવા આધારિત નિર્ણયો'},
      ]
    },
    {
      'title': 'Community Features',
      'titleGu': 'સમુદાયિક સુવિધાઓ',
      'icon': Icons.people,
      'items': [
        {'text': 'Posting questions', 'textGu': 'પ્રશ્નો પોસ્ટ કરવા'},
        {'text': 'Sharing experiences', 'textGu': 'અનુભવો શેર કરવા'},
        {'text': 'Learning from others', 'textGu': 'અન્યોથી શીખવું'},
        {'text': 'Building farming network', 'textGu': 'ખેતી નેટવર્ક બનાવવું'},
      ]
    },
  ];

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
    _loadUserProfile();
  }

  Future<void> _checkAdminStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isAdmin = prefs.getBool('is_admin') ?? false;
    setState(() {
      _isAdmin = isAdmin;
      _tabController = TabController(length: isAdmin ? 4 : 3, vsync: this);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _farmSizeController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final profileJson = prefs.getString('user_profile');

    if (profileJson != null) {
      final profileMap = json.decode(profileJson);
      setState(() {
        _userProfile = UserProfile.fromMap(profileMap);
        _nameController.text = _userProfile!.name;
        _phoneController.text = _userProfile!.phoneNumber;
        _locationController.text = _userProfile!.location;
        _farmSizeController.text = _userProfile!.farmSize;
        _selectedCrops = _userProfile!.cropTypes;
      });
    } else {
      setState(() {
        _userProfile = UserProfile(
          uid: 'user1',
          name: '',
          email: 'demo@prakruti.com',
          phoneNumber: '',
          location: '',
          farmSize: '',
          cropTypes: [],
          profileImageUrl: null,
        );
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final profile = UserProfile(
        uid: _userProfile!.uid,
        name: _nameController.text,
        email: _userProfile!.email,
        phoneNumber: _phoneController.text,
        location: _locationController.text,
        farmSize: _farmSizeController.text,
        cropTypes: _selectedCrops,
        profileImageUrl: _userProfile?.profileImageUrl,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_profile', json.encode(profile.toMap()));

      setState(() {
        _userProfile = profile;
        _isEditing = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              AppLocalizations.of(context)?.translate('profile_updated') ??
                  'Profile updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final profile = UserProfile(
        uid: _userProfile!.uid,
        name: _userProfile!.name,
        email: _userProfile!.email,
        phoneNumber: _userProfile!.phoneNumber,
        location: _userProfile!.location,
        farmSize: _userProfile!.farmSize,
        cropTypes: _userProfile!.cropTypes,
        profileImageUrl: image.path,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_profile', json.encode(profile.toMap()));

      setState(() {
        _userProfile = profile;
      });
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      _showErrorSnackBar('Could not launch phone dialer');
    }
  }

  Future<void> _sendEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@prakruti.com',
      query: 'subject=PRAKRUTI App Support Request',
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      _showErrorSnackBar('Could not launch email client');
    }
  }

  Future<void> _openWhatsApp() async {
    const phoneNumber = '+919876543210'; // Replace with actual number
    final Uri whatsappUri = Uri.parse(
        'https://wa.me/$phoneNumber?text=Hi, I need help with PRAKRUTI app');

    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri);
    } else {
      _showErrorSnackBar('WhatsApp is not installed');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
              AppLocalizations.of(context)?.translate('select_language') ??
                  'Select Language'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(
                    AppLocalizations.of(context)?.translate('english') ??
                        'English'),
                leading: const Icon(Icons.language),
                onTap: () {
                  Navigator.of(context).pop();
                  _changeLanguage('en');
                },
              ),
              ListTile(
                title: Text(
                    AppLocalizations.of(context)?.translate('gujarati') ??
                        'ગુજરાતી'),
                leading: const Icon(Icons.language),
                onTap: () {
                  Navigator.of(context).pop();
                  _changeLanguage('gu');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _changeLanguage(String languageCode) async {
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    await languageProvider.setLanguage(languageCode);

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Language changed to ${languageCode == 'en' ? 'English' : 'ગુજરાતી'} successfully!'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_userProfile == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
            AppLocalizations.of(context)?.translate('profile') ?? 'Profile'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: const Icon(Icons.person),
              text: AppLocalizations.of(context)?.translate('profile') ??
                  'Profile',
            ),
            Tab(
              icon: const Icon(Icons.help_outline),
              text: AppLocalizations.of(context)?.translate('help') ?? 'Help',
            ),
            Tab(
              icon: const Icon(Icons.support_agent),
              text: AppLocalizations.of(context)?.translate('support') ??
                  'Support',
            ),
            if (_isAdmin)
              const Tab(
                icon: Icon(Icons.admin_panel_settings, color: Colors.red),
                text: 'Admin',
              ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Profile Tab
          _buildProfileTab(),
          // Help Tab
          _buildHelpTab(),
          // Support Tab
          _buildSupportTab(),
          // Admin Tab (only if admin)
          if (_isAdmin) _buildAdminTab(),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Picture Section
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: _userProfile?.profileImageUrl != null
                        ? FileImage(File(_userProfile!.profileImageUrl!))
                        : null,
                    backgroundColor:
                        Theme.of(context).primaryColor.withOpacity(0.1),
                    child: _userProfile?.profileImageUrl == null
                        ? Icon(Icons.person,
                            size: 50, color: Theme.of(context).primaryColor)
                        : null,
                  ),
                  if (_isEditing)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        backgroundColor: Theme.of(context).primaryColor,
                        radius: 18,
                        child: IconButton(
                          icon: const Icon(Icons.camera_alt,
                              size: 18, color: Colors.white),
                          onPressed: _pickImage,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Edit Button
            if (!_isEditing)
              Center(
                child: ElevatedButton.icon(
                  onPressed: () => setState(() => _isEditing = true),
                  icon: const Icon(Icons.edit),
                  label: Text(
                      AppLocalizations.of(context)?.translate('edit_profile') ??
                          'Edit Profile'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Profile Form Fields
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)?.translate('name') ??
                    'Full Name',
                prefixIcon: const Icon(Icons.person_outline),
                enabled: _isEditing,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (value) =>
                  value?.isEmpty == true ? 'Name is required' : null,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)?.translate('phone') ??
                    'Phone Number',
                prefixIcon: const Icon(Icons.phone_outlined),
                enabled: _isEditing,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) =>
                  value?.isEmpty == true ? 'Phone number is required' : null,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText:
                    AppLocalizations.of(context)?.translate('location') ??
                        'Location',
                prefixIcon: const Icon(Icons.location_on_outlined),
                enabled: _isEditing,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (value) =>
                  value?.isEmpty == true ? 'Location is required' : null,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _farmSizeController,
              decoration: InputDecoration(
                labelText:
                    AppLocalizations.of(context)?.translate('farm_size') ??
                        'Farm Size',
                prefixIcon: const Icon(Icons.landscape_outlined),
                suffixText: 'acres',
                enabled: _isEditing,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              keyboardType: TextInputType.number,
              validator: (value) =>
                  value?.isEmpty == true ? 'Farm size is required' : null,
            ),
            const SizedBox(height: 24),

            // Crop Types Section
            Text(
              AppLocalizations.of(context)?.translate('crop_types') ??
                  'Crop Types',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            if (_isEditing)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableCrops.map((crop) {
                  return FilterChip(
                    label: Text(crop),
                    selected: _selectedCrops.contains(crop),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedCrops.add(crop);
                        } else {
                          _selectedCrops.remove(crop);
                        }
                      });
                    },
                    selectedColor:
                        Theme.of(context).primaryColor.withOpacity(0.2),
                    checkmarkColor: Theme.of(context).primaryColor,
                  );
                }).toList(),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _selectedCrops.isEmpty
                    ? [
                        Chip(
                            label: Text(AppLocalizations.of(context)
                                    ?.translate('no_crops_selected') ??
                                'No crops selected'))
                      ]
                    : _selectedCrops
                        .map((crop) => Chip(
                              label: Text(crop),
                              backgroundColor: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.1),
                            ))
                        .toList(),
              ),

            const SizedBox(height: 32),

            // Settings Section
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.language),
                    title: Text(
                        AppLocalizations.of(context)?.translate('language') ??
                            'Language'),
                    subtitle: Text(AppLocalizations.of(context)
                            ?.translate('change_app_language') ??
                        'Change app language'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: _showLanguageDialog,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.notifications_outlined),
                    title: Text(AppLocalizations.of(context)
                            ?.translate('notifications') ??
                        'Notifications'),
                    subtitle: Text(AppLocalizations.of(context)
                            ?.translate('manage_notifications') ??
                        'Manage notification settings'),
                    trailing: Switch(
                      value: true,
                      onChanged: (value) {
                        // Handle notification toggle
                      },
                    ),
                  ),
                ],
              ),
            ),

            if (_isEditing) ...[
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveProfile,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                      child: Text(
                        AppLocalizations.of(context)?.translate('save') ??
                            'Save Changes',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() => _isEditing = false);
                        _loadUserProfile(); // Reset form
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                          AppLocalizations.of(context)?.translate('cancel') ??
                              'Cancel'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHelpTab() {
    final isGujarati = Localizations.localeOf(context).languageCode == 'gu';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Help Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withOpacity(0.7)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.help_center, color: Colors.white, size: 32),
                const SizedBox(height: 12),
                Text(
                  isGujarati ? 'PRAKRUTI સહાય કેન્દ્ર' : 'PRAKRUTI Help Center',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isGujarati
                      ? 'અમારી એપ્લિકેશનનો મહત્તમ લાભ લેવા માટે આ માર્ગદર્શિકા અનુસરો'
                      : 'Follow this guide to get the most out of our farming app',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Help Sections
          ..._helpSections
              .map((section) => Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: section['isClickable'] == true
                        ? ListTile(
                            leading: Icon(section['icon'],
                                color: Theme.of(context).primaryColor),
                            title: Text(
                              isGujarati
                                  ? section['titleGu']
                                  : section['title'],
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              isGujarati
                                  ? 'AI સાથે વાત કરો અને તાત્કાલિક સહાય મેળવો'
                                  : 'Chat with AI and get instant help',
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              Navigator.of(context).pushNamed(section['route']);
                            },
                          )
                        : ExpansionTile(
                            leading: Icon(section['icon'],
                                color: Theme.of(context).primaryColor),
                            title: Text(
                              isGujarati
                                  ? section['titleGu']
                                  : section['title'],
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            children: (section['items'] as List)
                                .map<Widget>((item) => ListTile(
                                      leading: const Icon(
                                          Icons.article_outlined,
                                          size: 20),
                                      title: Text(isGujarati
                                          ? item['textGu']
                                          : item['text']),
                                      onTap: () {
                                        // Handle help item tap - could open detailed help screen
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(isGujarati
                                                ? '${item['textGu']} વિશે વધુ માહિતી આવી રહી છે...'
                                                : 'More information about ${item['text']} coming soon...'),
                                          ),
                                        );
                                      },
                                    ))
                                .toList(),
                          ),
                  ))
              .toList(),

          // FAQ Section
          Card(
            child: ExpansionTile(
              leading: Icon(Icons.quiz_outlined,
                  color: Theme.of(context).primaryColor),
              title: Text(
                isGujarati
                    ? 'વારંવાર પૂછાતા પ્રશ્નો'
                    : 'Frequently Asked Questions',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              children: [
                ListTile(
                  title: Text(isGujarati
                      ? 'એપ ઓફલાઇન કામ કરે છે?'
                      : 'Does the app work offline?'),
                  subtitle: Text(isGujarati
                      ? 'હા, મોટાભાગની સુવિધાઓ ઇન્ટરનેટ વગર કામ કરે છે.'
                      : 'Yes, most features work without internet connection.'),
                ),
                ListTile(
                  title: Text(isGujarati
                      ? 'કેટલા રોગ ઓળખી શકાય છે?'
                      : 'How many diseases can be detected?'),
                  subtitle: Text(isGujarati
                      ? '223+ વિવિધ પાક રોગોની ઓળખ કરી શકાય છે.'
                      : '223+ different crop diseases can be identified.'),
                ),
                ListTile(
                  title: Text(isGujarati
                      ? 'રિપોર્ટ કેવી રીતે સાચવવો?'
                      : 'How to save reports?'),
                  subtitle: Text(isGujarati
                      ? 'બધી સ્કેન રિપોર્ટ આપોઆપ History માં સાચવાય છે.'
                      : 'All scan reports are automatically saved in History.'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportTab() {
    final isGujarati = Localizations.localeOf(context).languageCode == 'gu';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Support Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.blue.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.support_agent, color: Colors.white, size: 32),
                const SizedBox(height: 12),
                Text(
                  isGujarati ? '24/7 ગ્રાહક સેવા' : '24/7 Customer Support',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isGujarati
                      ? 'અમે તમારી મદદ માટે હંમેશા તૈયાર છીએ'
                      : 'We are always ready to help you',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Contact Options
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.phone, color: Colors.green),
                  ),
                  title: Text(
                      isGujarati ? 'હેલ્પલાઇન પર કૉલ કરો' : 'Call Helpline'),
                  subtitle: const Text('1800-XXX-XXXX (Toll Free)'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => _makePhoneCall('1800XXXXXXX'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.email, color: Colors.blue),
                  ),
                  title: Text(isGujarati ? 'ઇમેઇલ મોકલો' : 'Send Email'),
                  subtitle: const Text('support@prakruti.com'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: _sendEmail,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.chat, color: Colors.green),
                  ),
                  title: Text(
                      isGujarati ? 'WhatsApp પર ચેટ કરો' : 'Chat on WhatsApp'),
                  subtitle: const Text('+91 98765-43210'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: _openWhatsApp,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Emergency Support
          Card(
            color: Colors.red.withOpacity(0.05),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.emergency, color: Colors.red),
                      const SizedBox(width: 8),
                      Text(
                        isGujarati ? 'તાકીદની સહાય' : 'Emergency Support',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isGujarati
                        ? 'પાકમાં ગંભીર રોગ અથવા તાત્કાલિક સહાયની જરૂર હોય તો:'
                        : 'For severe crop diseases or immediate assistance:',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () =>
                        _makePhoneCall('1909'), // Agriculture helpline
                    icon: const Icon(Icons.phone, color: Colors.white),
                    label: Text(isGujarati
                        ? 'કૃષિ હેલ્પલાઇન - 1909'
                        : 'Agriculture Helpline - 1909'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Additional Resources
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    isGujarati ? 'વધારાની સંસાધનો' : 'Additional Resources',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.video_library),
                  title: Text(
                      isGujarati ? 'ટ્યુટોરિયલ વિડિઓઝ' : 'Tutorial Videos'),
                  subtitle: Text(isGujarati
                      ? 'એપ વાપરવાની રીત શીખો'
                      : 'Learn how to use the app'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(isGujarati
                              ? 'ટ્યુટોરિયલ આવી રહ્યા છે...'
                              : 'Tutorials coming soon...')),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.book),
                  title: Text(
                      isGujarati ? 'વપરાશકર્તા માર્ગદર્શિકા' : 'User Manual'),
                  subtitle: Text(
                      isGujarati ? 'વિગતવાર માર્ગદર્શિકા' : 'Detailed guide'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(isGujarati
                              ? 'માર્ગદર્શિકા આવી રહી છે...'
                              : 'Manual coming soon...')),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.feedback),
                  title: Text(isGujarati ? 'પ્રતિસાદ આપો' : 'Send Feedback'),
                  subtitle: Text(isGujarati
                      ? 'એપ સુધારવામાં મદદ કરો'
                      : 'Help us improve the app'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => _sendEmail(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminTab() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.red[50]!,
            Colors.white,
          ],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Admin Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red[300]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.admin_panel_settings,
                      color: Colors.red[700], size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Administrator Panel',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.red[700],
                          ),
                        ),
                        Text(
                          'Access admin tools and testing features',
                          style: TextStyle(
                            color: Colors.red[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // API Testing Section
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.api, color: Colors.green[600]),
                        const SizedBox(width: 12),
                        const Text(
                          'API Testing',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Test all backend API endpoints and functionality',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pushNamed('/admin-api-test');
                        },
                        icon: const Icon(Icons.bug_report),
                        label: const Text('Open API Test Console'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // System Information Section
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue[600]),
                        const SizedBox(width: 12),
                        const Text(
                          'System Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow('App Version', '2.0.0'),
                    _buildInfoRow(
                        'Backend URL', 'http://localhost:8000'), // UPDATED
                    _buildInfoRow('Build Mode', 'Debug'),
                    _buildInfoRow('Admin Status', 'Active'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Database Management Section
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.storage, color: Colors.orange[600]),
                        const SizedBox(width: 12),
                        const Text(
                          'Database Management',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Manage disease remedies and model data',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Database backup feature coming soon'),
                                ),
                              );
                            },
                            icon: const Icon(Icons.backup),
                            label: const Text('Backup'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Database refresh feature coming soon'),
                                ),
                              );
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Refresh'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Danger Zone
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning, color: Colors.red[600]),
                        const SizedBox(width: 12),
                        const Text(
                          'Danger Zone',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Dangerous operations that can affect system functionality',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Clear All Data'),
                              content: const Text(
                                'This will clear all app data including profiles, history, and settings. This action cannot be undone.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: const Text('Clear Data',
                                      style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );

                          if (confirmed == true) {
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.clear();
                            if (mounted) {
                              Navigator.of(context).pushReplacementNamed('/');
                            }
                          }
                        },
                        icon:
                            const Icon(Icons.delete_forever, color: Colors.red),
                        label: const Text('Clear All Data',
                            style: TextStyle(color: Colors.red)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
