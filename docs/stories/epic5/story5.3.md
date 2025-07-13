# Story 5.3: Social Meal Planning & Collaboration

**Status: NotStarted**

## User Story

**As a user, I want to collaborate with family members or friends on meal planning and shopping lists, so that we can coordinate our cooking activities and share meal preparation responsibilities.**

## Acceptance Criteria

- [ ] User can create shared meal plans with family/friends
- [ ] Multiple users can contribute recipes to a shared meal plan
- [ ] Collaborative shopping lists generated from shared meal plans
- [ ] Real-time updates when collaborators make changes
- [ ] Assignment of cooking responsibilities to different users
- [ ] Notification system for meal plan updates and assignments
- [ ] Permission management for shared meal plans (view/edit/admin)
- [ ] Family group creation and management

## Technical Implementation

### Backend (Flask)


#### Database Schema

```sql
-- Family groups for collaboration
CREATE TABLE family_groups (
    id VARCHAR(36) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    created_by VARCHAR(36) NOT NULL REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Family group memberships
CREATE TABLE family_group_members (
    id VARCHAR(36) PRIMARY KEY,
    family_group_id VARCHAR(36) NOT NULL REFERENCES family_groups(id),
    user_id VARCHAR(36) NOT NULL REFERENCES users(id),
    role VARCHAR(20) NOT NULL DEFAULT 'member' CHECK (role IN ('admin', 'member', 'viewer')),
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(family_group_id, user_id)
);

-- Family group invitations
CREATE TABLE family_group_invitations (
    id VARCHAR(36) PRIMARY KEY,
    family_group_id VARCHAR(36) NOT NULL REFERENCES family_groups(id),
    invited_by VARCHAR(36) NOT NULL REFERENCES users(id),
    email VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'member',
    status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'declined', 'expired')),
    invited_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    responded_at TIMESTAMP WITH TIME ZONE,
    expires_at TIMESTAMP WITH TIME ZONE DEFAULT (CURRENT_TIMESTAMP + INTERVAL '7 days')
);

-- Shared meal plans
CREATE TABLE shared_meal_plans (
    id VARCHAR(36) PRIMARY KEY,
    family_group_id VARCHAR(36) NOT NULL REFERENCES family_groups(id),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    created_by VARCHAR(36) NOT NULL REFERENCES users(id),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Shared meal plan meals
CREATE TABLE shared_meal_plan_meals (
    id VARCHAR(36) PRIMARY KEY,
    shared_meal_plan_id VARCHAR(36) NOT NULL REFERENCES shared_meal_plans(id),
    recipe_id VARCHAR(36) NOT NULL REFERENCES recipes(id),
    meal_date DATE NOT NULL,
    meal_type VARCHAR(20) NOT NULL CHECK (meal_type IN ('breakfast', 'lunch', 'dinner', 'snack')),
    assigned_to VARCHAR(36) REFERENCES users(id),
    notes TEXT,
    added_by VARCHAR(36) NOT NULL REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Shared shopping lists
CREATE TABLE shared_shopping_lists (
    id VARCHAR(36) PRIMARY KEY,
    shared_meal_plan_id VARCHAR(36) NOT NULL REFERENCES shared_meal_plans(id),
    generated_by VARCHAR(36) NOT NULL REFERENCES users(id),
    generated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_updated TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Shared shopping list items
CREATE TABLE shared_shopping_list_items (
    id VARCHAR(36) PRIMARY KEY,
    shared_shopping_list_id VARCHAR(36) NOT NULL REFERENCES shared_shopping_lists(id),
    ingredient_name VARCHAR(255) NOT NULL,
    quantity DECIMAL(10,2),
    unit VARCHAR(50),
    category VARCHAR(100),
    is_checked BOOLEAN DEFAULT FALSE,
    checked_by VARCHAR(36) REFERENCES users(id),
    checked_at TIMESTAMP WITH TIME ZONE,
    recipe_ids JSONB -- Array of recipe IDs that need this ingredient
);

-- Cooking assignments
CREATE TABLE cooking_assignments (
    id VARCHAR(36) PRIMARY KEY,
    shared_meal_plan_id VARCHAR(36) NOT NULL REFERENCES shared_meal_plans(id),
    meal_id VARCHAR(36) NOT NULL REFERENCES shared_meal_plan_meals(id),
    assigned_to VARCHAR(36) NOT NULL REFERENCES users(id),
    assigned_by VARCHAR(36) NOT NULL REFERENCES users(id),
    assignment_notes TEXT,
    is_completed BOOLEAN DEFAULT FALSE,
    completed_at TIMESTAMP WITH TIME ZONE,
    completion_notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Collaboration activity log
CREATE TABLE collaboration_activities (
    id VARCHAR(36) PRIMARY KEY,
    family_group_id VARCHAR(36) NOT NULL REFERENCES family_groups(id),
    user_id VARCHAR(36) NOT NULL REFERENCES users(id),
    activity_type VARCHAR(50) NOT NULL,
    activity_data JSONB NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Add indexes for performance
CREATE INDEX idx_family_group_members_group ON family_group_members(family_group_id);
CREATE INDEX idx_family_group_members_user ON family_group_members(user_id);
CREATE INDEX idx_family_group_invitations_email ON family_group_invitations(email, status);
CREATE INDEX idx_shared_meal_plans_group ON shared_meal_plans(family_group_id, is_active);
CREATE INDEX idx_shared_meal_plan_meals_plan ON shared_meal_plan_meals(shared_meal_plan_id, meal_date);
CREATE INDEX idx_shared_meal_plan_meals_assigned ON shared_meal_plan_meals(assigned_to, meal_date);
CREATE INDEX idx_shared_shopping_list_items_list ON shared_shopping_list_items(shared_shopping_list_id);
CREATE INDEX idx_cooking_assignments_user ON cooking_assignments(assigned_to, is_completed);
CREATE INDEX idx_collaboration_activities_group ON collaboration_activities(family_group_id, created_at DESC);
```


## Performance Considerations

- **Real-time Updates**: Use WebSocket for real-time collaboration updates
- **Offline Sync**: Cache collaboration data for offline meal planning
- **Optimistic Updates**: Update UI immediately for better responsiveness
- **Efficient Notifications**: Batch notifications for group activities
- **Shopping List Sync**: Real-time synchronization of shopping list changes

## Accessibility Features

- **Screen Reader**: Full support for collaboration features and updates
- **High Contrast**: Ensure assignment status and group roles are clearly visible
- **Large Text**: Support dynamic text scaling for all collaboration content
- **Keyboard Navigation**: Complete keyboard support for all collaborative features
- **Focus Management**: Proper focus handling for group invitations and assignments

## Success Metrics

- **Group Creation**: Number of family groups created and active groups
- **Collaboration Engagement**: Active participants in shared meal planning
- **Assignment Completion**: Cooking assignment completion rates
- **Shopping List Usage**: Usage and completion of shared shopping lists
- **User Retention**: Impact of collaboration features on app retention