import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/social_models.dart';
import '../services/social_service.dart';
import '../utils/app_constants.dart';

class SocialProvider with ChangeNotifier {
  final SocialService _socialService = SocialService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // State variables
  UserSocialProfile? _currentUserProfile;
  List<UserSocialProfile> _searchResults = [];
  List<ConnectionRequest> _receivedRequests = [];
  List<ConnectionRequest> _sentRequests = [];
  List<UserSocialProfile> _connections = [];
  List<ActivityItem> _activityFeed = [];
  
  // Loading states
  bool _isLoadingProfile = false;
  bool _isLoadingSearch = false;
  bool _isLoadingRequests = false;
  bool _isLoadingConnections = false;
  bool _isLoadingActivityFeed = false;
  bool _isUpdatingProfile = false;
  
  // Pagination states
  int _searchPage = 1;
  int _connectionsPage = 1;
  int _activityFeedPage = 1;
  bool _hasMoreSearch = true;
  bool _hasMoreConnections = true;
  bool _hasMoreActivityFeed = true;
  
  String? _error;

  // Getters
  UserSocialProfile? get currentUserProfile => _currentUserProfile;
  List<UserSocialProfile> get searchResults => _searchResults;
  List<ConnectionRequest> get receivedRequests => _receivedRequests;
  List<ConnectionRequest> get sentRequests => _sentRequests;
  List<UserSocialProfile> get connections => _connections;
  List<ActivityItem> get activityFeed => _activityFeed;
  
  bool get isLoadingProfile => _isLoadingProfile;
  bool get isLoadingSearch => _isLoadingSearch;
  bool get isLoadingRequests => _isLoadingRequests;
  bool get isLoadingConnections => _isLoadingConnections;
  bool get isLoadingActivityFeed => _isLoadingActivityFeed;
  bool get isUpdatingProfile => _isUpdatingProfile;
  
  bool get hasMoreSearch => _hasMoreSearch;
  bool get hasMoreConnections => _hasMoreConnections;
  bool get hasMoreActivityFeed => _hasMoreActivityFeed;
  
  String? get error => _error;

  // Initialize with auth token
  Future<void> initialize() async {
    try {
      final token = await _storage.read(key: AppConstants.tokenKey);
      if (token != null) {
        _socialService.setAuthToken(token);
        await loadCurrentUserProfile();
      }
    } catch (e) {
      debugPrint('Failed to initialize social provider: $e');
    }
  }

  // Set auth token
  void setAuthToken(String token) {
    _socialService.setAuthToken(token);
  }

  // Clear auth token and reset state
  void clearAuth() {
    _socialService.clearAuthToken();
    _currentUserProfile = null;
    _searchResults.clear();
    _receivedRequests.clear();
    _sentRequests.clear();
    _connections.clear();
    _activityFeed.clear();
    _resetPagination();
    notifyListeners();
  }

  // Load current user's profile
  Future<bool> loadCurrentUserProfile() async {
    _isLoadingProfile = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _socialService.getCurrentUserProfile();
      if (result['success']) {
        _currentUserProfile = UserSocialProfile.fromJson(result['data']);
        _isLoadingProfile = false;
        notifyListeners();
        return true;
      } else {
        _error = result['error']['message'];
        _isLoadingProfile = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Failed to load profile: $e';
      _isLoadingProfile = false;
      notifyListeners();
      return false;
    }
  }

  // Update current user's profile
  Future<bool> updateUserProfile(UserSocialProfile profile) async {
    _isUpdatingProfile = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _socialService.updateUserProfile(profile);
      if (result['success']) {
        _currentUserProfile = UserSocialProfile.fromJson(result['data']);
        _isUpdatingProfile = false;
        notifyListeners();
        return true;
      } else {
        _error = result['error']['message'];
        _isUpdatingProfile = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Failed to update profile: $e';
      _isUpdatingProfile = false;
      notifyListeners();
      return false;
    }
  }

  // Search for users
  Future<bool> searchUsers(String query, {bool isNewSearch = true}) async {
    if (isNewSearch) {
      _searchPage = 1;
      _hasMoreSearch = true;
      _searchResults.clear();
    }

    if (!_hasMoreSearch) return true;

    _isLoadingSearch = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _socialService.searchUsers(query, page: _searchPage, limit: AppConstants.defaultPageSize);
      if (result['success']) {
        final searchResult = SearchUsersResult.fromJson(result['data']);
        
        if (isNewSearch) {
          _searchResults = searchResult.users;
        } else {
          _searchResults.addAll(searchResult.users);
        }
        
        _searchPage++;
        _hasMoreSearch = _searchPage <= searchResult.totalPages;
        _isLoadingSearch = false;
        notifyListeners();
        return true;
      } else {
        _error = result['error']['message'];
        _isLoadingSearch = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Failed to search users: $e';
      _isLoadingSearch = false;
      notifyListeners();
      return false;
    }
  }

  // Send connection request
  Future<bool> sendConnectionRequest(String userId, {String? message}) async {
    try {
      final result = await _socialService.sendConnectionRequest(userId, message: message);
      if (result['success']) {
        // Update the user in search results to show pending request
        final userIndex = _searchResults.indexWhere((user) => user.userId == userId);
        if (userIndex >= 0) {
          _searchResults[userIndex] = _searchResults[userIndex].copyWith(hasRequestPending: true);
        }
        
        // Refresh sent requests
        await loadConnectionRequests('sent');
        notifyListeners();
        return true;
      } else {
        _error = result['error']['message'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Failed to send connection request: $e';
      notifyListeners();
      return false;
    }
  }

  // Load connection requests
  Future<bool> loadConnectionRequests(String type) async {
    _isLoadingRequests = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _socialService.getConnectionRequests(type);
      if (result['success']) {
        final requests = (result['data']['requests'] as List<dynamic>)
            .map((request) => ConnectionRequest.fromJson(request))
            .toList();
        
        if (type == 'received') {
          _receivedRequests = requests;
        } else {
          _sentRequests = requests;
        }
        
        _isLoadingRequests = false;
        notifyListeners();
        return true;
      } else {
        _error = result['error']['message'];
        _isLoadingRequests = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Failed to load connection requests: $e';
      _isLoadingRequests = false;
      notifyListeners();
      return false;
    }
  }

  // Respond to connection request
  Future<bool> respondToConnectionRequest(String requestId, String action) async {
    try {
      final result = await _socialService.respondToConnectionRequest(requestId, action);
      if (result['success']) {
        // Remove the request from received requests
        _receivedRequests.removeWhere((request) => request.id == requestId);
        
        // If accepted, refresh connections
        if (action == 'accept') {
          await loadConnections(isNewLoad: true);
        }
        
        notifyListeners();
        return true;
      } else {
        _error = result['error']['message'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Failed to respond to connection request: $e';
      notifyListeners();
      return false;
    }
  }

  // Load user connections
  Future<bool> loadConnections({bool isNewLoad = true}) async {
    if (isNewLoad) {
      _connectionsPage = 1;
      _hasMoreConnections = true;
      _connections.clear();
    }

    if (!_hasMoreConnections) return true;

    _isLoadingConnections = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _socialService.getUserConnections(page: _connectionsPage, limit: AppConstants.defaultPageSize);
      if (result['success']) {
        final connectionsResult = ConnectionsResult.fromJson(result['data']);
        
        if (isNewLoad) {
          _connections = connectionsResult.connections;
        } else {
          _connections.addAll(connectionsResult.connections);
        }
        
        _connectionsPage++;
        _hasMoreConnections = _connectionsPage <= connectionsResult.totalPages;
        _isLoadingConnections = false;
        notifyListeners();
        return true;
      } else {
        _error = result['error']['message'];
        _isLoadingConnections = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Failed to load connections: $e';
      _isLoadingConnections = false;
      notifyListeners();
      return false;
    }
  }

  // Load activity feed
  Future<bool> loadActivityFeed({bool isNewLoad = true}) async {
    if (isNewLoad) {
      _activityFeedPage = 1;
      _hasMoreActivityFeed = true;
      _activityFeed.clear();
    }

    if (!_hasMoreActivityFeed) return true;

    _isLoadingActivityFeed = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _socialService.getActivityFeed(page: _activityFeedPage, limit: AppConstants.defaultPageSize);
      if (result['success']) {
        final activityResult = ActivityFeedResult.fromJson(result['data']);
        
        if (isNewLoad) {
          _activityFeed = activityResult.activities;
        } else {
          _activityFeed.addAll(activityResult.activities);
        }
        
        _activityFeedPage++;
        _hasMoreActivityFeed = _activityFeedPage <= activityResult.totalPages;
        _isLoadingActivityFeed = false;
        notifyListeners();
        return true;
      } else {
        _error = result['error']['message'];
        _isLoadingActivityFeed = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Failed to load activity feed: $e';
      _isLoadingActivityFeed = false;
      notifyListeners();
      return false;
    }
  }

  // Get another user's profile
  Future<UserSocialProfile?> getUserProfile(String userId) async {
    try {
      final result = await _socialService.getUserProfile(userId);
      if (result['success']) {
        return UserSocialProfile.fromJson(result['data']);
      } else {
        _error = result['error']['message'];
        notifyListeners();
        return null;
      }
    } catch (e) {
      _error = 'Failed to load user profile: $e';
      notifyListeners();
      return null;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Reset pagination
  void _resetPagination() {
    _searchPage = 1;
    _connectionsPage = 1;
    _activityFeedPage = 1;
    _hasMoreSearch = true;
    _hasMoreConnections = true;
    _hasMoreActivityFeed = true;
  }

  // Clear search results
  void clearSearchResults() {
    _searchResults.clear();
    _searchPage = 1;
    _hasMoreSearch = true;
    notifyListeners();
  }
} 