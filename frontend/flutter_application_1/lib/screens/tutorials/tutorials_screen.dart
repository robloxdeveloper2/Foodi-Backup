import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/tutorial_provider.dart';
import '../../models/tutorial_models.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';
import '../widgets/tutorial_card.dart';
import '../widgets/tutorial_search_bar.dart';
import '../widgets/tutorial_filter_sheet.dart';
import '../widgets/tutorial_category_chips.dart';
import 'tutorial_detail_screen.dart';

class TutorialsScreen extends StatefulWidget {
  const TutorialsScreen({super.key});

  @override
  State<TutorialsScreen> createState() => _TutorialsScreenState();
}

class _TutorialsScreenState extends State<TutorialsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _scrollController.addListener(_onScroll);
    
    // Initialize tutorial provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TutorialProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      // Load more tutorials when near bottom
      context.read<TutorialProvider>().loadMoreTutorials();
    }
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const TutorialFilterSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Cooking Tutorials',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: _showFilterSheet,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Featured'),
            Tab(text: 'Beginner'),
            Tab(text: 'My Progress'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            color: Theme.of(context).primaryColor,
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: TutorialSearchBar(),
            ),
          ),
          
          // Category chips
          Container(
            color: Colors.white,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: TutorialCategoryChips(),
            ),
          ),
          
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAllTutorialsTab(),
                _buildFeaturedTutorialsTab(),
                _buildBeginnerTutorialsTab(),
                _buildProgressTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllTutorialsTab() {
    return Consumer<TutorialProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.tutorials.isEmpty) {
          return const LoadingWidget();
        }

        if (provider.error != null && provider.tutorials.isEmpty) {
                   return CustomErrorWidget(
           message: provider.error!,
           onRetry: () => provider.searchTutorials(resetPage: true),
         );
        }

        if (provider.tutorials.isEmpty) {
          return _buildEmptyState('No tutorials found', 'Try adjusting your search or filters');
        }

        return RefreshIndicator(
          onRefresh: () => provider.refresh(),
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: provider.tutorials.length + (provider.isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= provider.tutorials.length) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final tutorial = provider.tutorials[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: TutorialCard(
                  tutorial: tutorial,
                  onTap: () => _navigateToTutorialDetail(tutorial),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildFeaturedTutorialsTab() {
    return Consumer<TutorialProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingFeatured) {
          return const LoadingWidget();
        }

        if (provider.featuredTutorials.isEmpty) {
          return _buildEmptyState('No featured tutorials', 'Check back later for featured content');
        }

        return RefreshIndicator(
          onRefresh: () => provider.loadFeaturedTutorials(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.featuredTutorials.length,
            itemBuilder: (context, index) {
              final tutorial = provider.featuredTutorials[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: TutorialCard(
                  tutorial: tutorial,
                  onTap: () => _navigateToTutorialDetail(tutorial),
                  showFeaturedBadge: true,
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildBeginnerTutorialsTab() {
    return Consumer<TutorialProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingBeginner) {
          return const LoadingWidget();
        }

        if (provider.beginnerTutorials.isEmpty) {
          return _buildEmptyState('No beginner tutorials', 'Check back later for beginner-friendly content');
        }

        return RefreshIndicator(
          onRefresh: () => provider.loadBeginnerTutorials(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.beginnerTutorials.length,
            itemBuilder: (context, index) {
              final tutorial = provider.beginnerTutorials[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: TutorialCard(
                  tutorial: tutorial,
                  onTap: () => _navigateToTutorialDetail(tutorial),
                  showBeginnerBadge: true,
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildProgressTab() {
    return Consumer<TutorialProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingProgress) {
          return const LoadingWidget();
        }

        final progressSummary = provider.progressSummary;
        final inProgressTutorials = provider.tutorialProgress.values
            .where((progress) => !progress.isCompleted)
            .toList();
        final completedTutorials = provider.tutorialProgress.values
            .where((progress) => progress.isCompleted)
            .toList();

        return RefreshIndicator(
          onRefresh: () => provider.loadProgressSummary(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress summary card
                if (progressSummary != null) ...[
                  _buildProgressSummaryCard(progressSummary),
                  const SizedBox(height: 24),
                ],

                // In progress tutorials
                if (inProgressTutorials.isNotEmpty) ...[
                  Text(
                    'Continue Learning',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...inProgressTutorials.map((progress) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildProgressCard(progress, false),
                  )),
                  const SizedBox(height: 24),
                ],

                // Completed tutorials
                if (completedTutorials.isNotEmpty) ...[
                  Text(
                    'Completed',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...completedTutorials.map((progress) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildProgressCard(progress, true),
                  )),
                ],

                // Empty state
                if (inProgressTutorials.isEmpty && completedTutorials.isEmpty)
                  _buildEmptyState(
                    'No tutorials started yet',
                    'Start a tutorial to track your progress',
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressSummaryCard(UserProgressSummary summary) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Progress',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Completed',
                    summary.completedCount.toString(),
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'In Progress',
                    summary.inProgressCount.toString(),
                    Icons.play_circle,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Time Spent',
                    '${summary.totalTimeMinutes}m',
                    Icons.access_time,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Avg Rating',
                    summary.averageRating != null ? summary.averageRating!.toStringAsFixed(1) : 'N/A',
                    Icons.star,
                    Colors.amber,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressCard(TutorialProgress progress, bool isCompleted) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isCompleted ? Colors.green : Colors.orange,
          child: Icon(
            isCompleted ? Icons.check : Icons.play_arrow,
            color: Colors.white,
          ),
        ),
        title: Text('Tutorial ${progress.tutorialId}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(
              value: progress.completionPercentage / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                isCompleted ? Colors.green : Colors.orange,
              ),
            ),
            const SizedBox(height: 4),
            Text('${progress.completionPercentage.toInt()}% complete'),
            if (progress.timeSpentMinutes > 0)
              Text('${progress.timeSpentMinutes} minutes spent'),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          // Navigate to tutorial detail
          // We'll need to fetch the tutorial details first
          context.read<TutorialProvider>().loadTutorialDetails(progress.tutorialId);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TutorialDetailScreen(tutorialId: progress.tutorialId),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToTutorialDetail(Tutorial tutorial) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TutorialDetailScreen(tutorialId: tutorial.id),
      ),
    );
  }
} 