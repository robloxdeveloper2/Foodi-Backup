Story 4.2 View Food Inventory List
Status: Draft
Story

    As a Foodi user I want to view a comprehensive list of all items currently in my pantry/inventory
    So that I know what groceries I possess at a glance.

Acceptance Criteria (ACs)

    AC-1: The system displays a dedicated "Pantry" or "Inventory" screen.
    AC-2: The screen lists all food items added by the user.
    AC-3: For each item, the Item Name, Quantity, and Expiration Date are clearly displayed.
    AC-4: Users can sort the list by Expiration Date (ascending/descending).
    AC-5: Users can sort the list by Item Name (alphabetical).
    AC-6: The list provides a clear visual indication for items whose expiration date has passed (e.g., greyed out, red text).

Tasks / Subtasks

    [ ] Design the UI for the pantry list view.
    [ ] Implement frontend component to display a list of pantry items.
    [ ] Implement backend API endpoint to retrieve all pantry items for a user.
    [ ] Implement sorting logic on the frontend (or backend if preferred for performance).
    [ ] Implement visual cues for expired items.

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
