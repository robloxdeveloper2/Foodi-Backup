# Story 5.4: Community Challenges & Groups

**Status: NotStarted**

## User Story

**As a user, I want to participate in cooking challenges and join interest-based groups, so that I can stay motivated in my cooking journey and learn from like-minded community members.**

## Acceptance Criteria

- [ ] User can browse and join cooking challenges (monthly themes, skill challenges, seasonal cooking)
- [ ] User can create and manage interest-based cooking groups
- [ ] Challenge participation tracking with progress updates and achievements
- [ ] Group discussions and recipe sharing within communities
- [ ] Leaderboards and social recognition for challenge participants
- [ ] User can earn badges and achievements for challenge completion
- [ ] Notification system for challenge updates and group activities
- [ ] Community moderation tools for group administrators

## Technical Implementation

### Backend (Flask)

#### Database Schema

```sql
-- Cooking challenges
CREATE TABLE cooking_challenges (
    id VARCHAR(36) PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    category VARCHAR(50) NOT NULL, -- skill, seasonal, themed, diet
    difficulty_level VARCHAR(20) NOT NULL CHECK (difficulty_level IN ('beginner', 'intermediate', 'advanced')),
    start_date TIMESTAMP WITH TIME ZONE NOT NULL,
    end_date TIMESTAMP WITH TIME ZONE NOT NULL,
    max_participants INT,
    rules JSONB NOT NULL,
    prizes JSONB,
    created_by VARCHAR(36) NOT NULL REFERENCES users(id),
    is_active BOOLEAN DEFAULT TRUE,
    featured BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Challenge participation
CREATE TABLE challenge_participations (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL REFERENCES users(id),
    challenge_id VARCHAR(36) NOT NULL REFERENCES cooking_challenges(id),
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'completed', 'abandoned')),
    progress_data JSONB DEFAULT '{}',
    final_score INT DEFAULT 0,
    final_rank INT,
    completed_at TIMESTAMP WITH TIME ZONE,
    UNIQUE(user_id, challenge_id)
);

-- Challenge submissions
CREATE TABLE challenge_submissions (
    id VARCHAR(36) PRIMARY KEY,
    participation_id VARCHAR(36) NOT NULL REFERENCES challenge_participations(id),
    recipe_id VARCHAR(36) NOT NULL REFERENCES recipes(id),
    submission_notes TEXT,
    images JSONB,
    submitted_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    score INT DEFAULT 0,
    judge_feedback TEXT,
    is_featured BOOLEAN DEFAULT FALSE
);

-- Community groups
CREATE TABLE community_groups (
    id VARCHAR(36) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    category VARCHAR(50) NOT NULL, -- cuisine, diet, skill, location, general
    tags TEXT[],
    is_private BOOLEAN DEFAULT FALSE,
    created_by VARCHAR(36) NOT NULL REFERENCES users(id),
    member_count INT DEFAULT 1,
    discussion_count INT DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Community group memberships
CREATE TABLE community_group_members (
    id VARCHAR(36) PRIMARY KEY,
    group_id VARCHAR(36) NOT NULL REFERENCES community_groups(id),
    user_id VARCHAR(36) NOT NULL REFERENCES users(id),
    role VARCHAR(20) NOT NULL DEFAULT 'member' CHECK (role IN ('admin', 'moderator', 'member')),
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(group_id, user_id)
);

-- Group discussions
CREATE TABLE group_discussions (
    id VARCHAR(36) PRIMARY KEY,
    group_id VARCHAR(36) NOT NULL REFERENCES community_groups(id),
    user_id VARCHAR(36) NOT NULL REFERENCES users(id),
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    discussion_type VARCHAR(30) DEFAULT 'general' CHECK (discussion_type IN ('general', 'recipe', 'question', 'announcement')),
    is_pinned BOOLEAN DEFAULT FALSE,
    reply_count INT DEFAULT 0,
    last_reply_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Discussion replies
CREATE TABLE discussion_replies (
    id VARCHAR(36) PRIMARY KEY,
    discussion_id VARCHAR(36) NOT NULL REFERENCES group_discussions(id),
    user_id VARCHAR(36) NOT NULL REFERENCES users(id),
    content TEXT NOT NULL,
    parent_reply_id VARCHAR(36) REFERENCES discussion_replies(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- User achievements
CREATE TABLE user_achievements (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL REFERENCES users(id),
    achievement_type VARCHAR(50) NOT NULL,
    achievement_data JSONB NOT NULL,
    points_earned INT DEFAULT 0,
    earned_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Achievement badges
CREATE TABLE achievement_badges (
    id VARCHAR(36) PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    icon VARCHAR(100),
    criteria JSONB NOT NULL,
    points_required INT DEFAULT 0,
    rarity VARCHAR(20) DEFAULT 'common' CHECK (rarity IN ('common', 'uncommon', 'rare', 'epic', 'legendary'))
);

-- User badges
CREATE TABLE user_badges (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL REFERENCES users(id),
    badge_id VARCHAR(36) NOT NULL REFERENCES achievement_badges(id),
    earned_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, badge_id)
);

-- Community moderation
CREATE TABLE community_moderation_actions (
    id VARCHAR(36) PRIMARY KEY,
    moderator_id VARCHAR(36) NOT NULL REFERENCES users(id),
    target_type VARCHAR(20) NOT NULL, -- discussion, reply, user
    target_id VARCHAR(36) NOT NULL,
    action_type VARCHAR(20) NOT NULL, -- warn, mute, ban, delete, pin
    reason TEXT,
    duration_hours INT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Add indexes for performance
CREATE INDEX idx_cooking_challenges_active ON cooking_challenges(is_active, start_date, end_date);
CREATE INDEX idx_cooking_challenges_category ON cooking_challenges(category, difficulty_level);
CREATE INDEX idx_challenge_participations_user ON challenge_participations(user_id, status);
CREATE INDEX idx_challenge_participations_challenge ON challenge_participations(challenge_id, final_rank);
CREATE INDEX idx_challenge_submissions_participation ON challenge_submissions(participation_id, submitted_at);
CREATE INDEX idx_community_groups_category ON community_groups(category, is_private);
CREATE INDEX idx_community_group_members_user ON community_group_members(user_id);
CREATE INDEX idx_community_group_members_group ON community_group_members(group_id, role);
CREATE INDEX idx_group_discussions_group ON group_discussions(group_id, created_at DESC);
CREATE INDEX idx_discussion_replies_discussion ON discussion_replies(discussion_id, created_at);
CREATE INDEX idx_user_achievements_user ON user_achievements(user_id, earned_at DESC);
CREATE INDEX idx_user_badges_user ON user_badges(user_id);

-- Full-text search indexes
CREATE INDEX idx_cooking_challenges_search ON cooking_challenges USING GIN(
    to_tsvector('english', title || ' ' || description)
);

CREATE INDEX idx_community_groups_search ON community_groups USING GIN(
    to_tsvector('english', name || ' ' || description || ' ' || array_to_string(tags, ' '))
);
```

## Performance Considerations

- **Challenge Leaderboards**: Implement efficient ranking calculations with caching
- **Group Discussions**: Use pagination and lazy loading for discussion threads
- **Achievement Calculation**: Background processing for achievement and badge computation
- **Real-time Updates**: WebSocket for live challenge updates and group activity
- **Image Optimization**: Compress and cache challenge submission images

## Accessibility Features

- **Screen Reader**: Full support for challenge content and group discussions
- **High Contrast**: Ensure leaderboards and achievement badges are clearly visible
- **Large Text**: Support dynamic text scaling for all challenge content
- **Keyboard Navigation**: Complete keyboard support for all community features
- **Focus Management**: Proper focus handling for modals and discussion threads

## Success Metrics

- **Challenge Participation**: Number of users joining and completing challenges
- **Group Engagement**: Active members and discussion activity in community groups
- **Achievement Unlock**: Badge and achievement earning rates
- **Community Retention**: Long-term engagement through challenges and groups
- **User-Generated Content**: Quality and quantity of challenge submissions and discussions
</rewritten_file> 