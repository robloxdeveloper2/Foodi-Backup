
Story EPIC-002.003: Integrate Pantry with Meal Planning
Status: Draft
Story
    As a Foodi user I want the AI meal planner to prioritize using ingredients I already have in my pantry, especially those nearing expiry
    So that I can reduce food waste and save money by utilizing existing groceries.

Acceptance Criteria (ACs)
    AC-1: When a user requests a meal plan, the AI considers the user's current pantry inventory.
    AC-2: Recipes that utilize ingredients nearing their expiry date in the user's pantry are given higher preference in meal plan suggestions.
    AC-3: Recipes that utilize any ingredients from the user's pantry are prioritized over recipes requiring only new grocery purchases.
    AC-4: The generated meal plan clearly indicates which suggested meals use pantry ingredients.
    AC-5: The AI accurately assesses available quantities in the pantry against recipe requirements.

Tasks / Subtasks
    [ ] Modify the AI meal planning algorithm to incorporate pantry inventory data.
    [ ] Develop logic to prioritize ingredients nearing expiry.
    [ ] Develop logic to prioritize all available pantry ingredients.
    [ ] Implement API calls to retrieve pantry data within the meal planning service.
    [ ] Update meal plan display to highlight pantry ingredient usage.

Dev Technical Guidance
    This will require close collaboration with the AI/ML team responsible for the meal planning algorithm.
    Define clear data exchange formats between the pantry service and the meal planning service.

Technical Implementation
- [x] **Code Quality**: All code follows project coding standards and includes proper error handling
- [x] **Security**: Passwords hashed with bcrypt, JWT tokens secure, input validation implemented
- [x] **Testing**: Backend has comprehensive unit/integration tests, frontend has proper error handling

### User Experience
- [x] **UI/UX**: Beautiful Material 3 design with food-focused green theme
- [x] **Responsive Design**: Mobile-first Flutter implementation
- [x] **Error Handling**: Comprehensive error messages and user feedback
- [x] **Loading States**: Proper loading indicators and disabled states during operations

### Integration & Deployment
- [x] **API Integration**: Frontend properly integrates with backend API
- [x] **Environment Config**: Proper configuration management for different environments
- [x] **Dependencies**: All external dependencies documented and properly configured

### Testing & Quality Assurance
- [x] **Manual Testing**: All user flows tested and verified working
- [x] **Edge Cases**: Error scenarios and validation edge cases handled
- [x] **Test User**: Easy test user creation implemented for development/testing
