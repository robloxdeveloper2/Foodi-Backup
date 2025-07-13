Story 4.4 - Edit and Delete Pantry Items
Status: Draft
Story

    As a Foodi user I want to edit the details of a pantry item (e.g., quantity, expiry date) or remove it entirely
    So that I can keep my inventory accurate and reflect what I've used or discarded.

Acceptance Criteria (ACs)
    AC-1: The user can select an existing pantry item from the list to initiate an edit.
    AC-2: The system presents an editable form pre-populated with the item's current details (name, quantity, expiry date).
    AC-3: The user can modify the Item Name, Quantity, and Expiration Date.
    AC-4: Upon saving changes, the item's details are updated in the inventory list.
    AC-5: The user can select an existing pantry item and confirm its deletion.
    AC-6: Upon confirmation, the item is removed from the inventory list and the backend.
    AC-7: The system provides appropriate success/error feedback for edit and delete operations.

Tasks / Subtasks
    [ ] Design the UI for editing and deleting pantry items.
    [ ] Implement frontend functionality to select an item for editing.
    [ ] Implement frontend form for editing item details.
    [ ] Implement backend API endpoint for updating a pantry item.
    [ ] Implement backend API endpoint for deleting a pantry item.
    [ ] Integrate frontend edit/delete actions with backend APIs.

Dev Technical Guidance
    Implement proper authentication and authorization checks for edit and delete operations.
    Consider soft deletes for auditing purposes if future requirements might necessitate tracking deleted items.

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