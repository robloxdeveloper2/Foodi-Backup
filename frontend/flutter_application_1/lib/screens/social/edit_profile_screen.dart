import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/social_provider.dart';
import '../../models/social_models.dart';
import '../../utils/app_constants.dart';

class EditProfileScreen extends StatefulWidget {
  final UserSocialProfile profile;
  
  const EditProfileScreen({Key? key, required this.profile}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _bioController = TextEditingController();
  final _locationController = TextEditingController();
  final _websiteController = TextEditingController();
  final _profilePictureController = TextEditingController();
  final _coverPhotoController = TextEditingController();
  
  String? _selectedCookingLevel;
  List<String> _favoriteCuisines = [];
  List<String> _cookingGoals = [];
  List<String> _dietaryPreferences = [];
  bool _isPublic = true;
  bool _allowFriendRequests = true;
  
  // Predefined options
  final List<String> _cookingLevels = ['beginner', 'intermediate', 'advanced', 'expert'];
  final List<String> _availableCuisines = [
    'Italian', 'Chinese', 'Japanese', 'Mexican', 'Indian', 'French', 'Thai', 
    'Mediterranean', 'American', 'Korean', 'Vietnamese', 'Greek', 'Spanish',
    'Middle Eastern', 'African', 'Caribbean', 'German', 'British'
  ];
  final List<String> _availableGoals = [
    'Learn basic cooking', 'Master knife skills', 'Bake bread', 'Make pasta from scratch',
    'Meal prep', 'Cook for family', 'Reduce food waste', 'Eat healthier', 
    'Try new cuisines', 'Improve presentation', 'Cook vegetarian', 'Cook vegan'
  ];
  final List<String> _availableDietaryPreferences = [
    'Vegetarian', 'Vegan', 'Gluten-free', 'Dairy-free', 'Keto', 'Paleo',
    'Low-carb', 'High-protein', 'Mediterranean', 'Whole30', 'Pescatarian', 'Halal', 'Kosher'
  ];

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    _displayNameController.text = widget.profile.displayName ?? '';
    _bioController.text = widget.profile.bio ?? '';
    _locationController.text = widget.profile.location ?? '';
    _websiteController.text = widget.profile.websiteUrl ?? '';
    _profilePictureController.text = widget.profile.profilePictureUrl ?? '';
    _coverPhotoController.text = widget.profile.coverPhotoUrl ?? '';
    
    _selectedCookingLevel = widget.profile.cookingLevel;
    _favoriteCuisines = List.from(widget.profile.favoriteCuisines);
    _cookingGoals = List.from(widget.profile.cookingGoals);
    _dietaryPreferences = List.from(widget.profile.dietaryPreferences);
    _isPublic = widget.profile.isPublic;
    _allowFriendRequests = widget.profile.allowFriendRequests;
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    _websiteController.dispose();
    _profilePictureController.dispose();
    _coverPhotoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          Consumer<SocialProvider>(
            builder: (context, socialProvider, child) {
              return TextButton(
                onPressed: socialProvider.isUpdatingProfile ? null : _saveProfile,
                child: socialProvider.isUpdatingProfile
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              );
            },
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          children: [
            _buildBasicInfoSection(),
            const SizedBox(height: 24),
            _buildCookingInfoSection(),
            const SizedBox(height: 24),
            _buildPreferencesSection(),
            const SizedBox(height: 24),
            _buildPrivacySection(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Information',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _displayNameController,
              decoration: const InputDecoration(
                labelText: 'Display Name',
                hintText: 'How others will see your name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a display name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _bioController,
              decoration: const InputDecoration(
                labelText: 'Bio',
                hintText: 'Tell us about yourself and your cooking journey',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              maxLength: 500,
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location',
                hintText: 'City, Country',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _websiteController,
              decoration: const InputDecoration(
                labelText: 'Website/Blog',
                hintText: 'https://yourwebsite.com',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link),
              ),
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final urlPattern = RegExp(r'^https?://');
                  if (!urlPattern.hasMatch(value)) {
                    return 'Please enter a valid URL starting with http:// or https://';
                  }
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCookingInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cooking Information',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            DropdownButtonFormField<String>(
              value: _selectedCookingLevel,
              decoration: const InputDecoration(
                labelText: 'Cooking Level',
                border: OutlineInputBorder(),
              ),
              items: _cookingLevels.map((level) => DropdownMenuItem(
                value: level,
                child: Text(level.toUpperCase()),
              )).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCookingLevel = value;
                });
              },
            ),
            const SizedBox(height: 16),
            
            _buildMultiSelectSection(
              'Favorite Cuisines',
              _availableCuisines,
              _favoriteCuisines,
              (selected) => setState(() => _favoriteCuisines = selected),
            ),
            const SizedBox(height: 16),
            
            _buildMultiSelectSection(
              'Cooking Goals',
              _availableGoals,
              _cookingGoals,
              (selected) => setState(() => _cookingGoals = selected),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferencesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dietary Preferences',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            _buildMultiSelectSection(
              'Dietary Preferences',
              _availableDietaryPreferences,
              _dietaryPreferences,
              (selected) => setState(() => _dietaryPreferences = selected),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Settings',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            SwitchListTile(
              title: const Text('Public Profile'),
              subtitle: const Text('Allow others to find and view your profile'),
              value: _isPublic,
              onChanged: (value) {
                setState(() {
                  _isPublic = value;
                });
              },
            ),
            
            SwitchListTile(
              title: const Text('Allow Friend Requests'),
              subtitle: const Text('Let others send you connection requests'),
              value: _allowFriendRequests,
              onChanged: (value) {
                setState(() {
                  _allowFriendRequests = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMultiSelectSection(
    String title,
    List<String> available,
    List<String> selected,
    Function(List<String>) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: available.map((item) {
            final isSelected = selected.contains(item);
            return FilterChip(
              label: Text(item),
              selected: isSelected,
              onSelected: (isSelectedNew) {
                if (isSelectedNew) {
                  onChanged([...selected, item]);
                } else {
                  onChanged(selected.where((s) => s != item).toList());
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final updatedProfile = widget.profile.copyWith(
      displayName: _displayNameController.text.trim(),
      bio: _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
      location: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
      websiteUrl: _websiteController.text.trim().isEmpty ? null : _websiteController.text.trim(),
      profilePictureUrl: _profilePictureController.text.trim().isEmpty ? null : _profilePictureController.text.trim(),
      coverPhotoUrl: _coverPhotoController.text.trim().isEmpty ? null : _coverPhotoController.text.trim(),
      cookingLevel: _selectedCookingLevel,
      favoriteCuisines: _favoriteCuisines,
      cookingGoals: _cookingGoals,
      dietaryPreferences: _dietaryPreferences,
      isPublic: _isPublic,
      allowFriendRequests: _allowFriendRequests,
    );

    final socialProvider = Provider.of<SocialProvider>(context, listen: false);
    final success = await socialProvider.updateUserProfile(updatedProfile);

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(socialProvider.error ?? 'Failed to update profile')),
      );
    }
  }
} 