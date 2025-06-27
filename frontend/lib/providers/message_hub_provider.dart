import 'package:flutter/material.dart';
import 'package:frontend/common/services/message_hub_service.dart';
import 'package:frontend/features/message/services/message_service.dart';
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
  bool _userScrolling = false; // Track user scrolling
  
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
  bool get userScrolling => _userScrolling;

  MessageHubProvider() {
    _setupCallbacks();
  }

  void setUserScrolling(bool scrolling) {
    _userScrolling = scrolling;
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
      
      // Sort messages by time (oldest first for proper display order)
      final sortedMessages = List<MessageDto>.from(paginatedMessages.items);
      sortedMessages.sort((a, b) => a.messageSent.compareTo(b.messageSent));
      
      if (_isLoadingMore) {
        // When loading more (older messages), add them to the beginning
        final existingIds = _messages.map((m) => m.id).toSet();
        final newMessages = sortedMessages.where((m) => !existingIds.contains(m.id)).toList();
        
        // Insert older messages at the beginning
        _messages.insertAll(0, newMessages);
        _isLoadingMore = false;
      } else {
        // Initial load - replace all messages
        _messages = sortedMessages;
      }
      
      _isLoading = false;
      notifyListeners();
      
      print('[MessageHubProvider] Updated with ${_messages.length} messages, total: $_totalCount, page: $_currentPage/$_totalPages');
    };

    _messageHubService.onNewMessage = (message) {
      print('[MessageHubProvider] Received new message: ${message.content}');
      // Add new messages to the end (they are the newest)
      _messages.add(message);
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

      if (_messageHubService.isConnectionReady(otherUserId)) {
        print('[MessageHubProvider] Already connected to user: $otherUserId');
        _isLoading = false;
        notifyListeners();
        return true;
      }

      await _messageHubService.startConnection(accessToken, otherUserId);
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
      print('[MessageHubProvider] Loading message page $nextPage for user $otherUserId via REST API');
      
      // Use REST API for additional pages
      final messageService = MessageService();
      final paginatedResponse = await messageService.fetchMessagesByOrderUserId(
        context: context,
        userId: otherUserId,
        pageNumber: nextPage,
      );

      if (paginatedResponse.items.isNotEmpty) {
        // Sort messages by time (oldest first)
        final sortedMessages = List<MessageDto>.from(paginatedResponse.items);
        sortedMessages.sort((a, b) => a.messageSent.compareTo(b.messageSent));
        
        // Add older messages to the beginning of the list
        final existingIds = _messages.map((m) => m.id).toSet();
        final newMessages = sortedMessages.where((m) => !existingIds.contains(m.id)).toList();
        _messages.insertAll(0, newMessages);

        // Update pagination info from REST API response
        _currentPage = paginatedResponse.currentPage;
        _totalPages = paginatedResponse.totalPages;
        
        print('[MessageHubProvider] Loaded ${newMessages.length} more messages via REST API, now on page $_currentPage/$_totalPages');
      }
      
      _isLoadingMore = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('[MessageHubProvider] Error loading more messages: $e');
      _isLoadingMore = false;
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
    _userScrolling = false;
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
    _userScrolling = false;
  }
}
