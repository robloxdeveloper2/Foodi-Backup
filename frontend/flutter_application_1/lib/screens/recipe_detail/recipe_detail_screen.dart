import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/recipe_detail_provider.dart';
import '../../providers/user_recipe_provider.dart';
import '../../screens/widgets/user_recipes/favorite_button.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_message.dart';
import '../../widgets/recipe_detail/recipe_header_section.dart';
import '../../widgets/recipe_detail/ingredients_list.dart';
import '../../widgets/recipe_detail/cooking_instructions.dart';
import '../../widgets/recipe_detail/nutrition_card.dart';
import '../../widgets/recipe_detail/recipe_scaling_control.dart';
import '../../utils/app_constants.dart';
import '../../providers/auth_provider.dart';

class RecipeDetailScreen extends StatefulWidget {
  final String recipeId;
  
  const RecipeDetailScreen({
    super.key,
    required this.recipeId,
  });

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Defer loading until after build phase to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRecipeDetails();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRecipeDetails() async {
    // Get real token from auth provider
    final authProvider = context.read<AuthProvider>();
    final token = authProvider.token ?? 'dummy_token'; // Fallback to dummy if no token
    
    await context.read<RecipeDetailProvider>().loadRecipeDetails(
      widget.recipeId,
      token,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<RecipeDetailProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Scaffold(
              body: Center(child: LoadingIndicator()),
            );
          }

          if (provider.hasError) {
            return Scaffold(
              appBar: AppBar(title: const Text('Recipe Details')),
              body: Center(
                child: ErrorMessage(
                  message: provider.error ?? 'Unknown error occurred',
                  onRetry: _loadRecipeDetails,
                ),
              ),
            );
          }

          if (provider.recipe == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Recipe Details')),
              body: const Center(
                child: Text('Recipe not found'),
              ),
            );
          }

          return _buildRecipeContent(context, provider);
        },
      ),
      floatingActionButton: Consumer<RecipeDetailProvider>(
        builder: (context, provider, child) {
          if (provider.recipe == null) return const SizedBox.shrink();
          
          return _buildFloatingActionButton(context, provider);
        },
      ),
    );
  }

  Widget _buildRecipeContent(BuildContext context, RecipeDetailProvider provider) {
    final recipe = provider.recipe!;
    
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            actions: [
              // Favorite button
              Consumer<UserRecipeProvider>(
                builder: (context, userRecipeProvider, child) {
                  return FutureBuilder<bool>(
                    future: userRecipeProvider.checkRecipeFavorited(recipe.baseRecipe.id),
                    builder: (context, snapshot) {
                      final isFavorited = snapshot.data ?? false;
                      return FavoriteButton(
                        recipeId: recipe.baseRecipe.id,
                        isFavorited: isFavorited,
                        size: 24,
                      );
                    },
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () => _shareRecipe(context, provider),
              ),
              PopupMenuButton<String>(
                onSelected: (value) => _handleMenuAction(context, provider, value),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'save',
                    child: Row(
                      children: [
                        Icon(Icons.bookmark_border),
                        SizedBox(width: 8),
                        Text('Save Recipe'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'report',
                    child: Row(
                      children: [
                        Icon(Icons.flag_outlined),
                        SizedBox(width: 8),
                        Text('Report Issue'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: RecipeHeaderSection(recipe: recipe),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Ingredients'),
                  Tab(text: 'Instructions'),
                  Tab(text: 'Nutrition'),
                ],
              ),
            ),
          ),
        ];
      },
      body: Column(
        children: [
          // Recipe scaling control
          RecipeScalingControl(
            currentScale: provider.currentScaleFactor,
            onScaleChanged: (scale) => _handleScaleChange(context, provider, scale),
            isLoading: provider.isScaling,
          ),
          
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildIngredientsTab(context, provider),
                _buildInstructionsTab(context, provider),
                _buildNutritionTab(context, provider),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsTab(BuildContext context, RecipeDetailProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IngredientsList(
            ingredients: provider.recipe!.getScaledIngredients(),
            originalServings: provider.recipe!.baseRecipe.servings,
            scaledServings: provider.recipe!.scaledServings,
          ),
          
          const SizedBox(height: AppConstants.largePadding),
          
          // Equipment needed
          if (provider.recipe!.equipmentNeeded.isNotEmpty) ...[
            const Text(
              'Equipment Needed',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.smallPadding),
            ...provider.getEquipmentByType().entries.map((entry) => 
              _buildEquipmentSection(entry.key, entry.value)
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInstructionsTab(BuildContext context, RecipeDetailProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CookingInstructions(
            steps: provider.steps,
            onStepCompleted: (index) => provider.completeStep(index),
            onStepUncompleted: (index) => provider.uncompleteStep(index),
            isCookingMode: provider.isCookingSessionActive,
          ),
          
          const SizedBox(height: AppConstants.largePadding),
          
          // Cooking tips
          if (provider.recipe!.cookingTips.isNotEmpty) ...[
            const Text(
              'Cooking Tips',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.smallPadding),
            ...provider.getCookingTipsByCategory().entries.map((entry) =>
              _buildTipsSection(entry.key, entry.value)
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNutritionTab(BuildContext context, RecipeDetailProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        children: [
          NutritionCard(
            nutrition: provider.recipe!.getScaledNutrition(),
            servings: provider.recipe!.scaledServings,
            costPerServing: provider.recipe!.baseRecipe.costPerServingUsd,
          ),
        ],
      ),
    );
  }

  Widget _buildEquipmentSection(String category, List<String> equipment) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            category,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: equipment.map((item) => Chip(
              label: Text(item),
              backgroundColor: Theme.of(context).colorScheme.surface,
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsSection(String category, List<dynamic> tips) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            category.toUpperCase(),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          ...tips.map((tip) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  size: 16,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(tip.tip),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context, RecipeDetailProvider provider) {
    if (provider.isCookingSessionActive) {
      return FloatingActionButton.extended(
        onPressed: () => _showCookingControls(context, provider),
        icon: Icon(provider.currentSession!.isPaused ? Icons.play_arrow : Icons.pause),
        label: Text(provider.currentSession!.isPaused ? 'Resume' : 'Pause'),
      );
    } else {
      return FloatingActionButton.extended(
        onPressed: () => _startCooking(context, provider),
        icon: const Icon(Icons.play_arrow),
        label: const Text('Start Cooking'),
      );
    }
  }

  Future<void> _handleScaleChange(BuildContext context, RecipeDetailProvider provider, double scale) async {
    // TODO: Get token from auth provider/service
    const token = 'dummy_token';
    await provider.scaleRecipe(scale, token);
  }

  void _shareRecipe(BuildContext context, RecipeDetailProvider provider) {
    final shareText = provider.getShareText();
    // TODO: Implement sharing when share_plus is available
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Share text prepared: ${shareText.length} characters'),
        action: SnackBarAction(
          label: 'Copy',
          onPressed: () {
            // TODO: Copy to clipboard
          },
        ),
      ),
    );
  }

  void _handleMenuAction(BuildContext context, RecipeDetailProvider provider, String action) {
    switch (action) {
      case 'save':
        // TODO: Implement recipe saving
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recipe saved!')),
        );
        break;
      case 'report':
        // TODO: Implement recipe reporting
        _showReportDialog(context);
        break;
    }
  }

  void _showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Issue'),
        content: const Text('What seems to be the problem with this recipe?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Thank you for your feedback!')),
              );
            },
            child: const Text('Report'),
          ),
        ],
      ),
    );
  }

  Future<void> _startCooking(BuildContext context, RecipeDetailProvider provider) async {
    // Store context reference before async gap
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    await provider.startCookingSession();
    
    if (mounted) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Cooking session started! Check off steps as you go.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _showCookingControls(BuildContext context, RecipeDetailProvider provider) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Cooking Progress: ${(provider.cookingProgress * 100).round()}%',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            LinearProgressIndicator(value: provider.cookingProgress),
            const SizedBox(height: AppConstants.largePadding),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: provider.currentSession!.isPaused
                      ? () => provider.resumeCookingSession()
                      : () => provider.pauseCookingSession(),
                  icon: Icon(provider.currentSession!.isPaused ? Icons.play_arrow : Icons.pause),
                  label: Text(provider.currentSession!.isPaused ? 'Resume' : 'Pause'),
                ),
                ElevatedButton.icon(
                  onPressed: () => _endCookingSession(context, provider),
                  icon: const Icon(Icons.stop),
                  label: const Text('End Session'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    foregroundColor: Theme.of(context).colorScheme.onError,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _endCookingSession(BuildContext context, RecipeDetailProvider provider) async {
    Navigator.of(context).pop(); // Close bottom sheet
    
    final shouldEnd = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Cooking Session'),
        content: const Text('Are you sure you want to end this cooking session? Your progress will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('End Session'),
          ),
        ],
      ),
    );

    if (shouldEnd == true) {
      await provider.endCookingSession();
    }
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
} 