import 'package:frontend/common/services/presence_service_hub.dart';
import 'package:frontend/common/services/group_hub_service.dart';
import 'package:frontend/common/services/message_hub_service.dart';
import 'package:frontend/models/group_dto.dart';

class SignalRManagerService {
  static final SignalRManagerService _instance = SignalRManagerService._internal();
  factory SignalRManagerService() => _instance;
  SignalRManagerService._internal();

  final PresenceService _presenceService = PresenceService();
  final GroupHubService _groupHubService = GroupHubService();
  final MessageHubService _messageHubService = MessageHubService();

  // Start all SignalR connections
  Future<void> startAllConnections(String accessToken) async {
    try {
      print('[SignalRManager] Starting all SignalR connections...');
      
      // Start presence connection
      await _presenceService.startConnection(accessToken);
      
      // Start group hub connection
      await _groupHubService.startConnection(accessToken);
      
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

  // Send message to a user
  Future<bool> sendMessage(String otherUserId, String content, {String? attachmentUrl}) async {
    return await _messageHubService.sendMessage(otherUserId, content, attachmentUrl: attachmentUrl);
  }

  // Send message to group
  Future<bool> sendMessageToGroup(String groupId, String content, {String? attachmentUrl}) async {
    return await _groupHubService.sendMessage(groupId, content, attachmentUrl: attachmentUrl);
  }

  // Mark group as read
  Future<bool> markGroupAsRead(String groupId) async {
    return await _groupHubService.markGroupAsRead(groupId);
  }

  // Getters for individual services
  PresenceService get presenceService => _presenceService;
  GroupHubService get groupHubService => _groupHubService;
  MessageHubService get messageHubService => _messageHubService;

  // Connection status
  bool get isPresenceConnected => _presenceService.isConnected;
  bool get isGroupHubConnected => _groupHubService.isConnected;
  bool isConnectedToUser(String userId) => _messageHubService.isConnectedToUser(userId);
  
  List<String> get connectedUsers => _messageHubService.connectedUsers;

  // Initialize all services with callbacks
  void initializeCallbacks({
    Function(String userId)? onUserOnline,
    Function(String userId)? onUserOffline,
    Function(List<String> users)? onOnlineUsersReceived,
    Function(List<GroupDto> groups)? onReceiveGroups,
    Function(MessageDto message)? onNewMessage,
    Function(GroupDto group)? onGroupUpdated,
  }) {
    // Set presence callbacks
    _presenceService.onUserOnline = onUserOnline;
    _presenceService.onUserOffline = onUserOffline;
    _presenceService.onOnlineUsersReceived = onOnlineUsersReceived;

    // Set group hub callbacks
    _groupHubService.onReceiveGroups = onReceiveGroups;
    _groupHubService.onNewMessage = onNewMessage;
    _groupHubService.onGroupUpdated = onGroupUpdated;
  }
}
