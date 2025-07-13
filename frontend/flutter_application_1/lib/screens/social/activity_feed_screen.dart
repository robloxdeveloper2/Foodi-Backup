import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/social_provider.dart';
import '../../models/social_models.dart';
import '../../utils/app_constants.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';

class ActivityFeedScreen extends StatefulWidget {
  const ActivityFeedScreen({Key? key}) : super(key: key);

  @override
  State<ActivityFeedScreen> createState() => _ActivityFeedScreenState();
}

class _ActivityFeedScreenState extends State<ActivityFeedScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadActivityFeed();
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.9) {
      final socialProvider = Provider.of<SocialProvider>(context, listen: false);
      if (socialProvider.hasMoreActivityFeed && !socialProvider.isLoadingActivityFeed) {
        socialProvider.loadActivityFeed(isNewLoad: false);
      }
    }
  }

  Future<void> _loadActivityFeed() async {
    final socialProvider = Provider.of<SocialProvider>(context, listen: false);
    await socialProvider.loadActivityFeed(isNewLoad: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity Feed'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadActivityFeed,
          ),
        ],
      ),
      body: Consumer<SocialProvider>(
        builder: (context, socialProvider, child) {
          if (socialProvider.isLoadingActivityFeed && socialProvider.activityFeed.isEmpty) {
            return const LoadingWidget(message: 'Loading activity feed...');
          }

          if (socialProvider.activityFeed.isEmpty && socialProvider.error != null) {
            return CustomErrorWidget(
              message: socialProvider.error!,
              onRetry: _loadActivityFeed,
            );
          }

          if (socialProvider.activityFeed.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: _loadActivityFeed,
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              itemCount: socialProvider.activityFeed.length + (socialProvider.hasMoreActivityFeed ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= socialProvider.activityFeed.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final activity = socialProvider.activityFeed[index];
                return _buildActivityCard(activity);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.feed_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No Activity Yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Connect with friends to see their cooking activities, or start sharing your own!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pushNamed('/social/search');
              },
              icon: const Icon(Icons.person_add),
              label: const Text('Find Friends'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard(ActivityItem activity) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildActivityHeader(activity),
          _buildActivityContent(activity),
          _buildActivityActions(activity),
        ],
      ),
    );
  }

  Widget _buildActivityHeader(ActivityItem activity) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: activity.userProfile?.profilePictureUrl != null
                ? CachedNetworkImageProvider(activity.userProfile!.profilePictureUrl!)
                : null,
            child: activity.userProfile?.profilePictureUrl == null
                ? Text(
                    (activity.userProfile?.displayName ?? 'U')[0].toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.userProfile?.displayName ?? 'Anonymous User',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  _getActivityDescription(activity),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _formatActivityTime(activity.createdAt),
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityContent(ActivityItem activity) {
    switch (activity.activityType) {
      case 'recipe_shared':
        return _buildRecipeActivityContent(activity);
      case 'meal_completed':
        return _buildMealActivityContent(activity);
      case 'profile_updated':
        return _buildProfileActivityContent(activity);
      case 'connection_made':
        return _buildConnectionActivityContent(activity);
      default:
        return _buildGenericActivityContent(activity);
    }
  }

  Widget _buildRecipeActivityContent(ActivityItem activity) {
    final recipeData = activity.activityData;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (recipeData['recipe_name'] != null) ...[
            Text(
              recipeData['recipe_name'],
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
          ],
          if (recipeData['description'] != null) ...[
            Text(
              recipeData['description'],
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
          ],
          if (recipeData['image_url'] != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: recipeData['image_url'],
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 200,
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 200,
                  color: Colors.grey[200],
                  child: const Center(child: Icon(Icons.error)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMealActivityContent(ActivityItem activity) {
    final mealData = activity.activityData;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Completed: ${mealData['meal_name'] ?? 'a meal'}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileActivityContent(ActivityItem activity) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.person, color: Theme.of(context).primaryColor),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Updated their profile',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionActivityContent(ActivityItem activity) {
    final connectionData = activity.activityData;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.people, color: Colors.blue),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Connected with ${connectionData['friend_name'] ?? 'a new friend'}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenericActivityContent(ActivityItem activity) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        activity.activityData.toString(),
        style: TextStyle(color: Colors.grey[600]),
      ),
    );
  }

  Widget _buildActivityActions(ActivityItem activity) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          TextButton.icon(
            onPressed: () {
              // TODO: Implement like functionality
            },
            icon: const Icon(Icons.favorite_border, size: 20),
            label: const Text('Like'),
          ),
          const SizedBox(width: 16),
          TextButton.icon(
            onPressed: () {
              // TODO: Implement comment functionality
            },
            icon: const Icon(Icons.comment_outlined, size: 20),
            label: const Text('Comment'),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              // TODO: Implement share functionality
            },
            icon: const Icon(Icons.share_outlined, size: 20),
          ),
        ],
      ),
    );
  }

  String _getActivityDescription(ActivityItem activity) {
    switch (activity.activityType) {
      case 'recipe_shared':
        return 'shared a recipe';
      case 'meal_completed':
        return 'completed a meal';
      case 'profile_updated':
        return 'updated their profile';
      case 'connection_made':
        return 'made a new connection';
      default:
        return 'had some activity';
    }
  }

  String _formatActivityTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
} 