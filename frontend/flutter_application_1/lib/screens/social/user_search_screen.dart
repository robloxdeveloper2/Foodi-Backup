import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/social_provider.dart';
import '../../models/social_models.dart';
import '../../utils/app_constants.dart';
import '../../widgets/loading_widget.dart';
import 'profile_screen.dart';

class UserSearchScreen extends StatefulWidget {
  const UserSearchScreen({Key? key}) : super(key: key);

  @override
  State<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _currentQuery = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.9) {
      final socialProvider = Provider.of<SocialProvider>(context, listen: false);
      if (socialProvider.hasMoreSearch && !socialProvider.isLoadingSearch && _currentQuery.isNotEmpty) {
        socialProvider.searchUsers(_currentQuery, isNewSearch: false);
      }
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _currentQuery = query.trim();
    });

    if (_currentQuery.length >= 2) {
      final socialProvider = Provider.of<SocialProvider>(context, listen: false);
      socialProvider.searchUsers(_currentQuery, isNewSearch: true);
    } else {
      final socialProvider = Provider.of<SocialProvider>(context, listen: false);
      socialProvider.clearSearchResults();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Friends'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name or username...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).scaffoldBackgroundColor,
              ),
              onChanged: _onSearchChanged,
            ),
          ),
        ),
      ),
      body: Consumer<SocialProvider>(
        builder: (context, socialProvider, child) {
          if (_currentQuery.isEmpty) {
            return _buildInitialState();
          }

          if (_currentQuery.length < 2) {
            return _buildMinQueryLengthMessage();
          }

          if (socialProvider.isLoadingSearch && socialProvider.searchResults.isEmpty) {
            return const LoadingWidget(message: 'Searching users...');
          }

          if (socialProvider.searchResults.isEmpty && !socialProvider.isLoadingSearch) {
            return _buildNoResultsState();
          }

          return ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            itemCount: socialProvider.searchResults.length + (socialProvider.hasMoreSearch ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= socialProvider.searchResults.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final user = socialProvider.searchResults[index];
              return _buildUserCard(user, socialProvider);
            },
          );
        },
      ),
    );
  }

  Widget _buildInitialState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Find Food Enthusiasts',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Search for other users to connect with and share your cooking journey!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.search, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'Type at least 2 characters to search',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMinQueryLengthMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Keep typing...',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Type at least 2 characters to start searching',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No Users Found',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No users match your search for "$_currentQuery". Try a different search term.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(UserSocialProfile user, SocialProvider socialProvider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 30,
          backgroundImage: user.profilePictureUrl != null
              ? CachedNetworkImageProvider(user.profilePictureUrl!)
              : null,
          child: user.profilePictureUrl == null
              ? Text(
                  (user.displayName ?? 'U')[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
        title: Text(
          user.displayName ?? 'Anonymous User',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (user.bio != null && user.bio!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                user.bio!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
            if (user.location != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.location_on, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    user.location!,
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
            if (user.cookingLevel != null) ...[
              const SizedBox(height: 8),
              Chip(
                label: Text(
                  user.cookingLevel!.toUpperCase(),
                  style: const TextStyle(fontSize: 12),
                ),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
                backgroundColor: _getCookingLevelColor(user.cookingLevel!),
              ),
            ],
          ],
        ),
        trailing: _buildActionButton(user, socialProvider),
        onTap: () => _navigateToProfile(user),
      ),
    );
  }

  Widget _buildActionButton(UserSocialProfile user, SocialProvider socialProvider) {
    if (user.isCurrentUser) {
      return const Chip(
        label: Text('You'),
        backgroundColor: Colors.grey,
      );
    }

    if (user.isConnected) {
      return ElevatedButton.icon(
        onPressed: null,
        icon: const Icon(Icons.check, size: 16),
        label: const Text('Connected'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
      );
    }

    if (user.hasRequestPending) {
      return OutlinedButton.icon(
        onPressed: null,
        icon: const Icon(Icons.hourglass_empty, size: 16),
        label: const Text('Pending'),
      );
    }

    if (!user.allowFriendRequests) {
      return const Chip(
        label: Text('Private'),
        backgroundColor: Colors.grey,
      );
    }

    return ElevatedButton.icon(
      onPressed: () => _sendConnectionRequest(user, socialProvider),
      icon: const Icon(Icons.person_add, size: 16),
      label: const Text('Connect'),
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

  void _navigateToProfile(UserSocialProfile user) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProfileScreen(userId: user.userId),
      ),
    );
  }

  Future<void> _sendConnectionRequest(UserSocialProfile user, SocialProvider socialProvider) async {
    final success = await socialProvider.sendConnectionRequest(user.userId);
    
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connection request sent to ${user.displayName}!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(socialProvider.error ?? 'Failed to send request')),
      );
    }
  }
} 