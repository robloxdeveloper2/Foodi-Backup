# Story 5.2: Recipe Sharing & Community Discovery

**Status: NotStarted**

## User Story

**As a user, I want to share my favorite recipes with the community and discover highly-rated recipes from other users, so that I can expand my cooking repertoire through community recommendations.**

## Acceptance Criteria

- [ ] User can share recipes to the community with personal notes and photos
- [ ] User can rate and review community-shared recipes
- [ ] Community recipe feed shows trending and highly-rated recipes
- [ ] User can follow other users to see their shared recipes
- [ ] Recipe sharing includes cooking experience and modifications
- [ ] Community recipes can be filtered by cuisine, difficulty, and ratings
- [ ] User can save community recipes to their personal collection
- [ ] Comment system for recipe discussions and tips

## Technical Implementation

### Backend (Flask)


#### Database Schema

```sql
-- Community recipe shares
CREATE TABLE community_recipe_shares (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL REFERENCES users(id),
    original_recipe_id VARCHAR(36) REFERENCES recipes(id),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    personal_notes TEXT,
    modifications TEXT,
    cooking_experience JSONB,
    images JSONB, -- Array of image URLs
    tags TEXT[],
    privacy_level VARCHAR(20) DEFAULT 'public' CHECK (privacy_level IN ('public', 'friends', 'private')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Recipe reviews and ratings
CREATE TABLE community_recipe_reviews (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL REFERENCES users(id),
    recipe_share_id VARCHAR(36) NOT NULL REFERENCES community_recipe_shares(id),
    rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    review_text TEXT,
    cooking_experience JSONB, -- Difficulty, time taken, modifications made
    helpful_votes INT DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, recipe_share_id)
);

-- Recipe comments
CREATE TABLE community_recipe_comments (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL REFERENCES users(id),
    recipe_share_id VARCHAR(36) NOT NULL REFERENCES community_recipe_shares(id),
    parent_comment_id VARCHAR(36) REFERENCES community_recipe_comments(id),
    comment_text TEXT NOT NULL,
    is_deleted BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- User follows
CREATE TABLE user_follows (
    id VARCHAR(36) PRIMARY KEY,
    follower_id VARCHAR(36) NOT NULL REFERENCES users(id),
    following_id VARCHAR(36) NOT NULL REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(follower_id, following_id),
    CHECK (follower_id != following_id)
);

-- Community recipe saves
CREATE TABLE community_recipe_saves (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL REFERENCES users(id),
    recipe_share_id VARCHAR(36) NOT NULL REFERENCES community_recipe_shares(id),
    personal_notes TEXT,
    category VARCHAR(100),
    saved_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, recipe_share_id)
);

-- Recipe share likes/reactions
CREATE TABLE community_recipe_reactions (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL REFERENCES users(id),
    recipe_share_id VARCHAR(36) NOT NULL REFERENCES community_recipe_shares(id),
    reaction_type VARCHAR(20) NOT NULL DEFAULT 'like' CHECK (reaction_type IN ('like', 'love', 'wow', 'yum')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, recipe_share_id)
);

-- Add indexes for performance
CREATE INDEX idx_community_recipe_shares_user ON community_recipe_shares(user_id, created_at DESC);
CREATE INDEX idx_community_recipe_shares_privacy ON community_recipe_shares(privacy_level, created_at DESC);
CREATE INDEX idx_community_recipe_reviews_share ON community_recipe_reviews(recipe_share_id, rating DESC);
CREATE INDEX idx_community_recipe_comments_share ON community_recipe_comments(recipe_share_id, created_at);
CREATE INDEX idx_user_follows_follower ON user_follows(follower_id);
CREATE INDEX idx_user_follows_following ON user_follows(following_id);
CREATE INDEX idx_community_recipe_saves_user ON community_recipe_saves(user_id, saved_at DESC);
CREATE INDEX idx_community_recipe_reactions_share ON community_recipe_reactions(recipe_share_id, reaction_type);

-- Full-text search for community recipes
CREATE INDEX idx_community_recipes_search ON community_recipe_shares USING GIN(
    to_tsvector('english', title || ' ' || description || ' ' || COALESCE(personal_notes, '') || ' ' || array_to_string(tags, ' '))
);
```


#### Models

```dart
// lib/core/models/community_recipe.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'recipe.dart';
import 'social_profile.dart';

part 'community_recipe.freezed.dart';
part 'community_recipe.g.dart';

@freezed
class CommunityRecipeShare with _$CommunityRecipeShare {
  const factory CommunityRecipeShare({
    required String id,
    required String userId,
    String? originalRecipeId,
    required String title,
    required String description,
    String? personalNotes,
    String? modifications,
    Map<String, dynamic>? cookingExperience,
    @Default([]) List<String> images,
    @Default([]) List<String> tags,
    @Default('public') String privacyLevel,
    required DateTime createdAt,
    required DateTime updatedAt,
    
    // Additional data from joins
    UserSocialProfile? author,
    Recipe? originalRecipe,
    @Default(0.0) double averageRating,
    @Default(0) int totalReviews,
    @Default(0) int totalReactions,
    @Default(0) int totalComments,
    @Default(false) bool isLikedByUser,
    @Default(false) bool isSavedByUser,
    int? userRating,
  }) = _CommunityRecipeShare;

  factory CommunityRecipeShare.fromJson(Map<String, dynamic> json) => 
      _$CommunityRecipeShareFromJson(json);
}

@freezed
class RecipeReview with _$RecipeReview {
  const factory RecipeReview({
    required String id,
    required String userId,
    required String recipeShareId,
    required int rating,
    String? reviewText,
    Map<String, dynamic>? cookingExperience,
    @Default(0) int helpfulVotes,
    required DateTime createdAt,
    
    // Additional data
    UserSocialProfile? reviewer,
    @Default(false) bool isHelpful,
  }) = _RecipeReview;

  factory RecipeReview.fromJson(Map<String, dynamic> json) => 
      _$RecipeReviewFromJson(json);
}

@freezed
class RecipeComment with _$RecipeComment {
  const factory RecipeComment({
    required String id,
    required String userId,
    required String recipeShareId,
    String? parentCommentId,
    required String commentText,
    @Default(false) bool isDeleted,
    required DateTime createdAt,
    
    // Additional data
    UserSocialProfile? commenter,
    @Default([]) List<RecipeComment> replies,
  }) = _RecipeComment;

  factory RecipeComment.fromJson(Map<String, dynamic> json) => 
      _$RecipeCommentFromJson(json);
}
```

## Performance Considerations

- **Feed Pagination**: Implement efficient pagination with cursor-based loading
- **Image Optimization**: Compress and cache community recipe images
- **Real-time Updates**: Use WebSocket for real-time reactions and comments
- **Content Caching**: Cache community feed data for offline viewing
- **Search Optimization**: Implement full-text search with proper indexing

## Accessibility Features

- **Screen Reader**: Full support for community content and interactions
- **High Contrast**: Ensure recipe cards and ratings are clearly visible
- **Large Text**: Support dynamic text scaling for all community content
- **Keyboard Navigation**: Complete keyboard support for all community features
- **Focus Management**: Proper focus handling for comments and reactions

## Success Metrics

- **Recipe Sharing**: Number of recipes shared per user
- **Community Engagement**: Likes, comments, and shares on community recipes
- **Discovery Rate**: Recipes discovered through community vs search
- **Follow Growth**: User following relationships and network growth
- **Rating Quality**: Average ratings and review engagement on shared recipes 