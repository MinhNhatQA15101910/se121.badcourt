import 'package:frontend/common/services/presence_service_hub.dart';
import 'package:frontend/common/services/group_hub_service.dart';
import 'package:frontend/common/services/message_hub_service.dart';
import 'package:frontend/models/group_dto.dart';
import 'package:frontend/models/message_dto.dart';
import 'package:frontend/common/services/notification_hub_service.dart';
import 'package:frontend/common/services/court_hub_service.dart';
import 'package:frontend/models/paginated_groups_dto.dart';

class SignalRManagerService {
  static final SignalRManagerService _instance =
      SignalRManagerService._internal();
  factory SignalRManagerService() => _instance;
  SignalRManagerService._internal();

  final PresenceService _presenceService = PresenceService();
  final GroupHubService _groupHubService = GroupHubService();
  final MessageHubService _messageHubService = MessageHubService();
  final NotificationHubService _notificationHubService =
      NotificationHubService();
  final CourtHubService _courtHubService = CourtHubService();

  // Start all SignalR connections
  Future<void> startAllConnections(String accessToken) async {
    try {
      print('[SignalRManager] Starting all SignalR connections...');

      // Start presence connection
      await _presenceService.startConnection(accessToken);

      // Start group hub connection
      await _groupHubService.startConnection(accessToken);

      // Start notification hub connection
      await _notificationHubService.startConnection(accessToken);

      print('✅ [SignalRManager] All connections started successfully');
    } catch (e) {
      print('❌ [SignalRManager] Error starting connections: $e');
      rethrow;
    }
  }

  // Stop all SignalR connections
  Future<void> stopAllConnections() async {
    try {
      print('[SignalRManager] Stopping all SignalR connections...');

      await _presenceService.stopConnection();
      await _groupHubService.stopConnection();
      await _messageHubService.stopAllConnections();
      await _notificationHubService.stopConnection();
      await _courtHubService.disconnectFromAllCourts(); // Add this line

      print('✅ [SignalRManager] All connections stopped');
    } catch (e) {
      print('❌ [SignalRManager] Error stopping connections: $e');
    }
  }

  // Connect to a specific user for messaging
  Future<void> connectToUser(String accessToken, String otherUserId) async {
    try {
      await _messageHubService.startConnection(accessToken, otherUserId);
    } catch (e) {
      print('[SignalRManager] Error connecting to user $otherUserId: $e');
      rethrow;
    }
  }

  // Disconnect from a specific user
  Future<void> disconnectFromUser(String otherUserId) async {
    await _messageHubService.stopConnection(otherUserId);
  }

  // Mark group as read
  Future<bool> markGroupAsRead(String groupId) async {
    return await _groupHubService.markGroupAsRead(groupId);
  }

  // Connect to a specific court for real-time updates
  Future<void> connectToCourt(String accessToken, String courtId) async {
    try {
      await _courtHubService.connectToCourt(accessToken, courtId);
    } catch (e) {
      print('[SignalRManager] Error connecting to court $courtId: $e');
      rethrow;
    }
  }

  // Disconnect from a specific court
  Future<void> disconnectFromCourt(String courtId) async {
    await _courtHubService.disconnectFromCourt(courtId);
  }

  // Disconnect from all courts
  Future<void> disconnectFromAllCourts() async {
    await _courtHubService.disconnectFromAllCourts();
  }

  // Getters for individual services
  PresenceService get presenceService => _presenceService;
  GroupHubService get groupHubService => _groupHubService;
  MessageHubService get messageHubService => _messageHubService;
  NotificationHubService get notificationHubService => _notificationHubService;
  CourtHubService get courtHubService => _courtHubService;

  // Connection status
  bool get isPresenceConnected => _presenceService.isConnected;
  bool get isGroupHubConnected => _groupHubService.isConnected;
  bool isConnectedToUser(String userId) =>
      _messageHubService.isConnectedToUser(userId);
  bool get isNotificationHubConnected => _notificationHubService.isConnected;

  List<String> get connectedUsers => _messageHubService.connectedUsers;

  bool isConnectedToCourt(String courtId) =>
      _courtHubService.isConnectedToCourt(courtId);
  List<String> get connectedCourts => _courtHubService.connectedCourts;

  // Initialize all services with callbacks - Updated to use PaginatedGroupsDto
  void initializeCallbacks({
    Function(String userId)? onUserOnline,
    Function(String userId)? onUserOffline,
    Function(List<String> users)? onOnlineUsersReceived,
    Function(PaginatedGroupsDto paginatedGroups)? onReceiveGroups,
    Function(MessageDto message)? onNewMessage,
    Function(GroupDto group)? onGroupUpdated,
    Function(GroupDto group)? onNewMessageReceived, // Thêm callback mới
  }) {
    // Set presence callbacks
    _presenceService.onUserOnline = onUserOnline;
    _presenceService.onUserOffline = onUserOffline;
    _presenceService.onOnlineUsersReceived = onOnlineUsersReceived;

    // Set group hub callbacks
    _groupHubService.onReceiveGroups = onReceiveGroups;
    _groupHubService.onNewMessage = onNewMessage;
    _groupHubService.onGroupUpdated = onGroupUpdated;
    _groupHubService.onNewMessageReceived =
        onNewMessageReceived; // Thêm callback mới
  }

  // Helper method to convert List<GroupDto> to PaginatedGroupsDto for backward compatibility
  PaginatedGroupsDto createPaginatedGroups(
    List<GroupDto> groups, {
    int currentPage = 1,
    int totalPages = 1,
    int pageSize = 20,
  }) {
    return PaginatedGroupsDto(
      currentPage: currentPage,
      totalPages: totalPages,
      pageSize: pageSize,
      totalCount: groups.length,
      items: groups,
    );
  }
}
