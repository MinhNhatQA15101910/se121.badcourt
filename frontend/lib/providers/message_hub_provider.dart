import 'package:flutter/material.dart';
import 'package:frontend/common/services/message_hub_service.dart';
import 'package:frontend/models/group_dto.dart';
import 'package:frontend/models/message_dto.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/user_provider.dart';

class MessageHubProvider with ChangeNotifier {
  final MessageHubService _messageHubService = MessageHubService();
  
  List<MessageDto> _messages = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  GroupDto? _currentGroup;
  
  // Pagination info
  int _currentPage = 1;
  int _totalPages = 1;
  int _pageSize = 20;
  int _totalCount = 0;

  List<MessageDto> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  GroupDto? get currentGroup => _currentGroup;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get pageSize => _pageSize;
  int get totalCount => _totalCount;
  bool get hasMorePages => _currentPage < _totalPages;

  MessageHubProvider() {
    _setupCallbacks();
  }

  void _setupCallbacks() {
    _messageHubService.onUpdatedGroup = (group) {
      _currentGroup = group;
      notifyListeners();
    };

    _messageHubService.onReceiveMessageThread = (paginatedMessages) {
      print('[MessageHubProvider] Received paginated messages: ${paginatedMessages.items.length} messages on page ${paginatedMessages.currentPage}');
      
      // Update pagination info
      _currentPage = paginatedMessages.currentPage;
      _totalPages = paginatedMessages.totalPages;
      _pageSize = paginatedMessages.pageSize;
      _totalCount = paginatedMessages.totalCount;
      
      // If loading more pages, append to existing messages
      if (_isLoadingMore) {
        // Add only new messages that don't already exist
        final existingIds = _messages.map((m) => m.id).toSet();
        final newMessages = paginatedMessages.items.where((m) => !existingIds.contains(m.id)).toList();
        _messages.addAll(newMessages);
        _isLoadingMore = false;
      } else {
        // Otherwise replace all messages
        _messages = paginatedMessages.items;
      }
      
      _isLoading = false;
      notifyListeners();
      
      print('[MessageHubProvider] Updated with ${_messages.length} messages, total: $_totalCount, page: $_currentPage/$_totalPages');
    };

    _messageHubService.onNewMessage = (message) {
      _messages.insert(0, message);
      notifyListeners();
    };

    _messageHubService.onNewMessageReceived = (group) {
      _currentGroup = group;
      notifyListeners();
    };
  }

  Future<bool> connectToUser(BuildContext context, String otherUserId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final accessToken = userProvider.user.token;

      print('[MessageHubProvider] Connecting to user: $otherUserId');
      print('[MessageHubProvider] Using token: ${accessToken.substring(0, 20)}...');

      // Kiểm tra xem đã connected chưa
      if (_messageHubService.isConnectionReady(otherUserId)) {
        print('[MessageHubProvider] Already connected to user: $otherUserId');
        _isLoading = false;
        notifyListeners();
        return true;
      }

      await _messageHubService.startConnection(accessToken, otherUserId);
      
      // Đợi một chút để connection ổn định
      await Future.delayed(Duration(milliseconds: 500));
      
      final isReady = _messageHubService.isConnectionReady(otherUserId);
      print('[MessageHubProvider] Connection ready: $isReady');
      
      _isLoading = false;
      notifyListeners();
      
      return isReady;
    } catch (e) {
      print('[MessageHubProvider] Error connecting to user $otherUserId: $e');
      _error = 'Failed to connect: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> loadMoreMessages(BuildContext context, String otherUserId) async {
    if (!hasMorePages || _isLoadingMore) {
      return false;
    }
    
    try {
      _isLoadingMore = true;
      notifyListeners();
      
      final nextPage = _currentPage + 1;
      print('[MessageHubProvider] Loading message page $nextPage for user $otherUserId');
      
      final success = await _messageHubService.requestMessagePage(otherUserId, nextPage, _pageSize);
      
      if (!success) {
        _isLoadingMore = false;
        notifyListeners();
      }
      
      return success;
    } catch (e) {
      print('[MessageHubProvider] Error loading more messages: $e');
      _isLoadingMore = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> sendMessage(BuildContext context, String otherUserId, String content) async {
    try {
      Provider.of<UserProvider>(context, listen: false);

      // Đảm bảo connection sẵn sàng trước khi gửi
      if (!_messageHubService.isConnectionReady(otherUserId)) {
        print('[MessageHubProvider] Connection not ready, attempting to connect...');
        final connected = await connectToUser(context, otherUserId);
        if (!connected) {
          _error = 'Cannot establish connection to send message';
          notifyListeners();
          return false;
        }
        
        // Đợi thêm một chút sau khi kết nối
        await Future.delayed(Duration(milliseconds: 1000));
      }

      // Kiểm tra lại connection state
      final connectionState = _messageHubService.getConnectionState(otherUserId);
      print('[MessageHubProvider] Connection state before sending: $connectionState');

      if (!_messageHubService.isConnectionReady(otherUserId)) {
        _error = 'Connection not ready to send message';
        notifyListeners();
        return false;
      }

      final success = await _messageHubService.sendMessage(otherUserId, content);
      
      if (!success) {
        _error = 'Failed to send message';
        notifyListeners();
      }
      
      return success;
    } catch (e) {
      print('[MessageHubProvider] Error sending message: $e');
      _error = 'Error sending message: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> disconnectFromUser(String otherUserId) async {
    await _messageHubService.stopConnection(otherUserId);
    _clearMessages();
    notifyListeners();
  }

  Future<void> disconnectAll() async {
    await _messageHubService.stopAllConnections();
    _clearAllData();
    notifyListeners();
  }

  bool isConnectedToUser(String otherUserId) {
    return _messageHubService.isConnectionReady(otherUserId);
  }

  String getConnectionState(String otherUserId) {
    return _messageHubService.getConnectionStateString(otherUserId);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _clearMessages() {
    _messages.clear();
    _currentPage = 1;
    _totalPages = 1;
    _pageSize = 20;
    _totalCount = 0;
  }

  void _clearAllData() {
    _messages.clear();
    _currentGroup = null;
    _currentPage = 1;
    _totalPages = 1;
    _pageSize = 20;
    _totalCount = 0;
    _error = null;
    _isLoading = false;
    _isLoadingMore = false;
  }
}
