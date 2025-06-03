import 'package:flutter/material.dart';
import 'package:frontend/common/services/message_hub_service.dart';
import 'package:frontend/models/group_dto.dart';

class MessageHubProvider extends ChangeNotifier {
  final MessageHubService _messageHubService = MessageHubService();
  
  Map<String, List<MessageDto>> _messageThreads = {};
  Map<String, GroupDto> _activeGroups = {};
  Set<String> _connectedUsers = {};
  bool _isLoading = false;
  String? _error;

  // Getters
  Map<String, List<MessageDto>> get messageThreads => _messageThreads;
  Map<String, GroupDto> get activeGroups => _activeGroups;
  Set<String> get connectedUsers => _connectedUsers;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasActiveConnections => _messageHubService.hasActiveConnections;
  int get activeConnectionsCount => _messageHubService.activeConnectionsCount;

  // Initialize MessageHub connection for a specific user
  Future<void> connectToUser(String accessToken, String otherUserId) async {
    try {
      _setLoading(true);
      _setError(null);

      // Set up callbacks
      _messageHubService.onUpdatedGroup = _onUpdatedGroup;
      _messageHubService.onReceiveMessageThread = _onReceiveMessageThread;
      _messageHubService.onNewMessage = _onNewMessage;
      _messageHubService.onNewMessageReceived = _onNewMessageReceived;

      // Start connection
      await _messageHubService.startConnection(accessToken, otherUserId);
      _connectedUsers.add(otherUserId);
      
      print('[MessageHubProvider] Connected to user: $otherUserId');
    } catch (e) {
      _setError('Failed to connect to user $otherUserId: $e');
      print('[MessageHubProvider] Error connecting to user $otherUserId: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Disconnect from a specific user
  Future<void> disconnectFromUser(String otherUserId) async {
    try {
      await _messageHubService.stopConnection(otherUserId);
      _connectedUsers.remove(otherUserId);
      _messageThreads.remove(otherUserId);
      _activeGroups.remove(otherUserId);
      notifyListeners();
      print('[MessageHubProvider] Disconnected from user: $otherUserId');
    } catch (e) {
      print('[MessageHubProvider] Error disconnecting from user $otherUserId: $e');
    }
  }

  // Disconnect from all users
  Future<void> disconnectAll() async {
    try {
      await _messageHubService.stopAllConnections();
      _connectedUsers.clear();
      _messageThreads.clear();
      _activeGroups.clear();
      notifyListeners();
      print('[MessageHubProvider] Disconnected from all users');
    } catch (e) {
      print('[MessageHubProvider] Error disconnecting from all users: $e');
    }
  }

  // Send message to a user
  Future<bool> sendMessage(String otherUserId, String content, {String? attachmentUrl}) async {
    try {
      final success = await _messageHubService.sendMessage(
        otherUserId, 
        content, 
        attachmentUrl: attachmentUrl,
      );
      
      if (success) {
        print('[MessageHubProvider] Message sent to user: $otherUserId');
      } else {
        _setError('Failed to send message to user: $otherUserId');
      }
      
      return success;
    } catch (e) {
      _setError('Error sending message: $e');
      return false;
    }
  }

  // Callback methods
  void _onUpdatedGroup(GroupDto group) {
    print('[MessageHubProvider] Group updated: ${group.id}');
    _activeGroups[group.id] = group;
    notifyListeners();
  }

  void _onReceiveMessageThread(List<MessageDto> messages) {
    if (messages.isNotEmpty) {
      // Assume all messages in thread are from same conversation
      final firstMessage = messages.first;
      final otherUserId = firstMessage.senderId; // This might need adjustment based on your logic
      _messageThreads[otherUserId] = messages;
      print('[MessageHubProvider] Received ${messages.length} messages for user: $otherUserId');
      notifyListeners();
    }
  }

  void _onNewMessage(MessageDto message) {
    print('[MessageHubProvider] New message received from: ${message.senderId}');
    
    // Add message to appropriate thread
    final senderId = message.senderId;
    if (_messageThreads.containsKey(senderId)) {
      _messageThreads[senderId]!.add(message);
    } else {
      _messageThreads[senderId] = [message];
    }
    
    notifyListeners();
  }

  void _onNewMessageReceived(GroupDto group) {
    print('[MessageHubProvider] New message received in group: ${group.id}');
    _activeGroups[group.id] = group;
    notifyListeners();
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // Check if connected to specific user
  bool isConnectedToUser(String otherUserId) {
    return _messageHubService.isConnectedToUser(otherUserId);
  }

  // Get connection state for specific user
  String getConnectionState(String otherUserId) {
    return _messageHubService.getConnectionState(otherUserId);
  }

  // Get messages for specific user
  List<MessageDto> getMessagesForUser(String otherUserId) {
    return _messageThreads[otherUserId] ?? [];
  }

  // Get group for specific user (if exists)
  GroupDto? getGroupForUser(String otherUserId) {
    return _activeGroups[otherUserId];
  }
}
