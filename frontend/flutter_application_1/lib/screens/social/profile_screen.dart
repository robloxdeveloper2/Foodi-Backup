import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/social_provider.dart';
import '../../models/social_models.dart';
import '../../utils/app_constants.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';
import 'edit_profile_screen.dart';
import 'activity_feed_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String? userId;
  
  const ProfileScreen({Key? key, this.userId}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserSocialProfile? _otherUserProfile;
  bool _isLoadingOtherProfile = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfile();
    });
  }

  Future<void> _loadProfile() async {
    final socialProvider = Provider.of<SocialProvider>(context, listen: false);
    
    if (widget.userId == null) {
      // Load current user profile
      await socialProvider.loadCurrentUserProfile();
    } else {
      // Load other user's profile
      setState(() => _isLoadingOtherProfile = true);
      final profile = await socialProvider.getUserProfile(widget.userId!);
      setState(() {
        _otherUserProfile = profile;
        _isLoadingOtherProfile = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SocialProvider>(
      builder: (context, socialProvider, child) {
        final isCurrentUser = widget.userId == null;
        final profile = isCurrentUser ? socialProvider.currentUserProfile : _otherUserProfile;
        final isLoading = isCurrentUser ? socialProvider.isLoadingProfile : _isLoadingOtherProfile;

        if (isLoading) {
          return Scaffold(
            appBar: AppBar(title: const Text('Profile')),
            body: const LoadingWidget(),
          );
        }

        if (profile == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Profile')),
            body: CustomErrorWidget(
              message: socialProvider.error ?? 'Profile not found',
              onRetry: _loadProfile,
            ),
          );
        }

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              _buildAppBar(context, profile, isCurrentUser),
              SliverToBoxAdapter(
                child: _buildProfileContent(context, profile, isCurrentUser, socialProvider),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context, UserSocialProfile profile, bool isCurrentUser) {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Cover photo
            if (profile.coverPhotoUrl != null)
              CachedNetworkImage(
                imageUrl: profile.coverPhotoUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
            
            // Overlay gradient
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black54,
                  ],
                ),
              ),
            ),

            // Profile picture and name
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  // Profile picture
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 38,
                      backgroundImage: profile.profilePictureUrl != null
                          ? CachedNetworkImageProvider(profile.profilePictureUrl!)
                          : null,
                      child: profile.profilePictureUrl == null
                          ? Text(
                              (profile.displayName ?? 'U')[0].toUpperCase(),
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Name and stats
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          profile.displayName ?? 'Anonymous User',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (profile.location != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_on, color: Colors.white70, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                profile.location!,
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        if (isCurrentUser)
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _navigateToEditProfile(context, profile),
          ),
      ],
    );
  }

  Widget _buildProfileContent(BuildContext context, UserSocialProfile profile, bool isCurrentUser, SocialProvider socialProvider) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats and action buttons
          _buildStatsSection(context, profile, isCurrentUser, socialProvider),
          
          const SizedBox(height: 24),
          
          // Bio section
          if (profile.bio?.isNotEmpty == true) ...[
            _buildSectionTitle('About'),
            const SizedBox(height: 8),
            Text(
              profile.bio!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
          ],
          
          // Cooking level
          if (profile.cookingLevel != null) ...[
            _buildSectionTitle('Cooking Level'),
            const SizedBox(height: 8),
            Chip(
              label: Text(profile.cookingLevel!.toUpperCase()),
              backgroundColor: _getCookingLevelColor(profile.cookingLevel!),
            ),
            const SizedBox(height: 24),
          ],
          
          // Favorite cuisines
          if (profile.favoriteCuisines.isNotEmpty) ...[
            _buildSectionTitle('Favorite Cuisines'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: profile.favoriteCuisines.map((cuisine) => 
                Chip(label: Text(cuisine))
              ).toList(),
            ),
            const SizedBox(height: 24),
          ],
          
          // Cooking goals
          if (profile.cookingGoals.isNotEmpty) ...[
            _buildSectionTitle('Cooking Goals'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: profile.cookingGoals.map((goal) => 
                Chip(
                  label: Text(goal),
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                )
              ).toList(),
            ),
            const SizedBox(height: 24),
          ],
          
          // Dietary preferences
          if (profile.dietaryPreferences.isNotEmpty) ...[
            _buildSectionTitle('Dietary Preferences'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: profile.dietaryPreferences.map((pref) => 
                Chip(
                  label: Text(pref),
                  backgroundColor: Colors.green.withOpacity(0.1),
                )
              ).toList(),
            ),
            const SizedBox(height: 24),
          ],
          
          // Website link
          if (profile.websiteUrl != null) ...[
            _buildSectionTitle('Website'),
            const SizedBox(height: 8),
            InkWell(
              onTap: () {
                // TODO: Launch URL
              },
              child: Row(
                children: [
                  const Icon(Icons.link, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      profile.websiteUrl!,
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context, UserSocialProfile profile, bool isCurrentUser, SocialProvider socialProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Stats row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem('Connections', socialProvider.connections.length.toString()),
                _buildStatItem('Level', profile.cookingLevel?.toUpperCase() ?? 'BEGINNER'),
                _buildStatItem('Posts', '0'), // TODO: Add posts count
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Action buttons
            Row(
              children: [
                if (isCurrentUser) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _navigateToEditProfile(context, profile),
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit Profile'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _navigateToActivityFeed(context),
                      icon: const Icon(Icons.feed),
                      label: const Text('Activity'),
                    ),
                  ),
                ] else ...[
                  if (profile.isConnected) ...[
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Show message option
                        },
                        icon: const Icon(Icons.message),
                        label: const Text('Message'),
                      ),
                    ),
                  ] else if (profile.hasRequestPending) ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: null,
                        icon: const Icon(Icons.hourglass_empty),
                        label: const Text('Request Sent'),
                      ),
                    ),
                  ] else if (profile.allowFriendRequests) ...[
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _sendConnectionRequest(context, socialProvider, profile.userId),
                        icon: const Icon(Icons.person_add),
                        label: const Text('Connect'),
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Color _getCookingLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'beginner':
        return Colors.green.withOpacity(0.2);
      case 'intermediate':
        return Colors.orange.withOpacity(0.2);
      case 'advanced':
        return Colors.red.withOpacity(0.2);
      case 'expert':
        return Colors.purple.withOpacity(0.2);
      default:
        return Colors.grey.withOpacity(0.2);
    }
  }

  void _navigateToEditProfile(BuildContext context, UserSocialProfile profile) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(profile: profile),
      ),
    );
  }

  void _navigateToActivityFeed(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ActivityFeedScreen(),
      ),
    );
  }

  Future<void> _sendConnectionRequest(BuildContext context, SocialProvider socialProvider, String userId) async {
    final success = await socialProvider.sendConnectionRequest(userId);
    
    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Connection request sent!')),
        );
        setState(() {}); // Refresh the profile state
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(socialProvider.error ?? 'Failed to send request')),
        );
      }
    }
  }
} 