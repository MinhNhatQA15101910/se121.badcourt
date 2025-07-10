import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/post/screens/create_post_screen.dart';
import 'package:frontend/features/post/screens/user_profile_screen.dart';
import 'package:frontend/features/post/services/post_service.dart';
import 'package:frontend/features/post/widgets/post_form.dart';
import 'package:frontend/models/post.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class PostScreen extends StatefulWidget {
  static const String routeName = '/post';
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> with SingleTickerProviderStateMixin {
  final _postService = PostService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;

  List<Post> _postList = [];
  int _currentPage = 1;
  int _totalPages = 1;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _isRefreshing = false;
  bool _isSearching = false;
  String _currentFilter = 'Latest';
  String _searchQuery = '';
  final int _pageSize = 20;
  bool _hasMoreData = true;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _scrollController.addListener(_onScroll);
    _fetchAllPost();
    _animationController.forward();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
      _animationController.reverse();
    } else if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
      _animationController.forward();
    }

    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 300) {
      _loadMorePosts();
    }
  }

  Future<void> _fetchAllPost() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _hasMoreData = true;
    });

    try {
      final result = await _postService.fetchAllPosts(
        context: context,
        pageNumber: 1,
        pageSize: _pageSize,
        searchQuery: _searchQuery,
      );

      final List<Post> newPosts = result['posts'] ?? [];
      final int totalPages = result['totalPages'] ?? 1;

      if (mounted) {
        setState(() {
          _postList = newPosts;
          _totalPages = totalPages;
          _currentPage = 1;
          _hasMoreData = _currentPage < _totalPages;
        });
      }
    } catch (error) {
      if (mounted) {
        IconSnackBar.show(
          context,
          label: 'Failed to load posts: $error',
          snackBarType: SnackBarType.fail,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadMorePosts() async {
    if (_isLoadingMore || _isLoading || !_hasMoreData || _currentPage >= _totalPages) {
      return;
    }

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final nextPage = _currentPage + 1;
      
      final result = await _postService.fetchAllPosts(
        context: context,
        pageNumber: nextPage,
        pageSize: _pageSize,
        searchQuery: _searchQuery,
      );

      final List<Post> newPosts = result['posts'] ?? [];
      final int totalPages = result['totalPages'] ?? 1;

      if (mounted) {
        setState(() {
          if (newPosts.isNotEmpty) {
            _postList.addAll(newPosts);
            _currentPage = nextPage;
            _totalPages = totalPages;
            _hasMoreData = _currentPage < _totalPages;
          } else {
            _hasMoreData = false;
          }
        });
      }
    } catch (error) {
      if (mounted) {
        IconSnackBar.show(
          context,
          label: 'Failed to load more posts: $error',
          snackBarType: SnackBarType.fail,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  Future<void> _refreshPosts() async {
    if (_isRefreshing) return;
    
    setState(() {
      _isRefreshing = true;
      _currentPage = 1;
      _hasMoreData = true;
    });
    
    try {
      final result = await _postService.fetchAllPosts(
        context: context,
        pageNumber: 1,
        pageSize: _pageSize,
        searchQuery: _searchQuery,
      );

      final List<Post> newPosts = result['posts'] ?? [];
      final int totalPages = result['totalPages'] ?? 1;

      if (mounted) {
        setState(() {
          _postList = newPosts;
          _totalPages = totalPages;
          _currentPage = 1;
          _hasMoreData = _currentPage < _totalPages;
        });
      }
    } catch (error) {
      if (mounted) {
        IconSnackBar.show(
          context,
          label: 'Failed to refresh posts: $error',
          snackBarType: SnackBarType.fail,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  Future<void> _navigateToCreatePostScreen() async {
    final result = await Navigator.of(context).pushNamed(CreatePostScreen.routeName);

    if (result == true) {
      await _refreshPosts();
    }
  }

  // FIXED: Proper navigation to post detail with result handling
  Future<void> _navigateToPostDetail(String postId, int postIndex) async {
    print('DEBUG: Navigating to post detail for postId: $postId, index: $postIndex');
    
    final result = await Navigator.of(context).pushNamed(
      '/post-detail',
      arguments: postId,
    );

    print('DEBUG: Navigation result: $result');

    // FIXED: Handle the result from post detail screen
    if (result != null && result is Map<String, dynamic>) {
      final action = result['action'];
      print('DEBUG: Action received: $action');
      
      if (action == 'deleted') {
        // Remove the deleted post from the list
        print('DEBUG: Removing post at index $postIndex');
        setState(() {
          if (postIndex >= 0 && postIndex < _postList.length) {
            _postList.removeAt(postIndex);
          }
        });
        
        IconSnackBar.show(
          context,
          label: 'Post deleted successfully',
          snackBarType: SnackBarType.success,
        );
      } else if (action == 'updated') {
        // Update the post with new like/comment counts
        final updatedPost = result['post'] as Post;
        print('DEBUG: Updating post at index $postIndex with new data');
        setState(() {
          if (postIndex >= 0 && postIndex < _postList.length) {
            _postList[postIndex] = updatedPost;
          }
        });
      }
    }
  }

  // FIXED: Handle post deletion from post form
  void _handlePostDeleted(String postId) {
    print('DEBUG: Handling post deletion for postId: $postId');
    setState(() {
      _postList.removeWhere((post) => post.id == postId);
    });
    
    IconSnackBar.show(
      context,
      label: 'Post deleted successfully',
      snackBarType: SnackBarType.success,
    );
  }

  // FIXED: Handle post updates (like/comment count changes)
  void _handlePostUpdated(Post updatedPost) {
    print('DEBUG: Handling post update for postId: ${updatedPost.id}');
    final index = _postList.indexWhere((post) => post.id == updatedPost.id);
    if (index != -1) {
      print('DEBUG: Updating post at index $index');
      setState(() {
        _postList[index] = updatedPost;
      });
    }
  }

  void _navigateToUserProfile(UserProvider userProvider) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => UserProfileScreen(
          userId: userProvider.user.id,
        ),
      ),
    );
  }

  void _performSearch(String query) {
    setState(() {
      _searchQuery = query.trim();
      _postList.clear();
      _currentPage = 1;
      _totalPages = 1;
      _hasMoreData = true;
    });
    _fetchAllPost();
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _isSearching = false;
      _searchQuery = '';
      _postList.clear();
      _currentPage = 1;
      _totalPages = 1;
      _hasMoreData = true;
    });
    _fetchAllPost();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();

    return Scaffold(
      backgroundColor: GlobalVariables.defaultColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: GlobalVariables.green,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                  hintText: 'Search posts...',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.7),
                  ),
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear, color: Colors.white),
                    onPressed: _clearSearch,
                  ),
                ),
                onSubmitted: _performSearch,
                onChanged: (value) {
                  if (value.isEmpty) {
                    _clearSearch();
                  }
                },
              )
            : Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isSearching = true;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.search,
                              color: Colors.white.withOpacity(0.7),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Search posts...',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
        actions: [
          GestureDetector(
            onTap: () => _navigateToUserProfile(userProvider),
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: Image.network(
                  userProvider.user.photoUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 20,
                      color: GlobalVariables.green,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: GlobalVariables.green,
        onRefresh: _refreshPosts,
        child: NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            if (scrollInfo is ScrollEndNotification &&
                scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 100) {
              _loadMorePosts();
            }
            return false;
          },
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildCreatePostCard(userProvider),
                ),
              ),
              
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildFilterBar(),
                ),
              ),

              if (_searchQuery.isNotEmpty)
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: GlobalVariables.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: GlobalVariables.green.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search,
                          size: 16,
                          color: GlobalVariables.green,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Search results for "${_searchQuery}"',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: GlobalVariables.green,
                            ),
                          ),
                        ),
                        if (_postList.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: GlobalVariables.green,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${_postList.length}',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              
              if (_postList.isEmpty && !_isLoading)
                SliverFillRemaining(
                  child: _buildEmptyState(),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.only(top: 8),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(
                            left: 16, 
                            right: 16, 
                            bottom: 16
                          ),
                          child: PostFormWidget(
                            currentPost: _postList[index],
                            // FIXED: Pass proper callbacks
                            onPostDeleted: _handlePostDeleted,
                            onPostUpdated: _handlePostUpdated,
                            onNavigateToDetail: () {
                              print('DEBUG: PostForm navigation callback called for index $index');
                              _navigateToPostDetail(_postList[index].id, index);
                            },
                          ),
                        );
                      },
                      childCount: _postList.length,
                    ),
                  ),
                ),

              if (_isLoadingMore)
                SliverToBoxAdapter(
                  child: _buildLoadingMoreIndicator(),
                ),

              if (_postList.isNotEmpty && !_hasMoreData && !_isLoadingMore)
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 16,
                          color: GlobalVariables.green,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'You\'ve reached the end!',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: GlobalVariables.darkGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingMoreIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(GlobalVariables.green),
                  strokeWidth: 2,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Loading more posts...',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: GlobalVariables.darkGrey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreatePostCard(UserProvider userProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: _navigateToCreatePostScreen,
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: GlobalVariables.green,
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: Image.network(
                      userProvider.user.photoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.person,
                        size: 24,
                        color: GlobalVariables.green,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      'Share your thoughts...',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildPostActionButton(
                  icon: Icons.photo_library_outlined,
                  label: 'Photo',
                  onTap: _navigateToCreatePostScreen,
                ),
              ),
              Expanded(
                child: _buildPostActionButton(
                  icon: Icons.videocam_outlined,
                  label: 'Video',
                  onTap: _navigateToCreatePostScreen,
                ),
              ),
              Expanded(
                child: _buildPostActionButton(
                  icon: Icons.event_outlined,
                  label: 'Event',
                  onTap: _navigateToCreatePostScreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPostActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: GlobalVariables.green,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: GlobalVariables.darkGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                'Sort by:',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: GlobalVariables.darkGrey,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: GlobalVariables.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Text(
                      _currentFilter,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: GlobalVariables.green,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_drop_down,
                      size: 20,
                      color: GlobalVariables.green,
                    ),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            icon: Icon(
              Icons.filter_list,
              color: GlobalVariables.darkGrey,
            ),
            onPressed: () {
              // Show filter options
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _searchQuery.isNotEmpty ? Icons.search_off : Icons.forum_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty ? 'No results found' : 'No posts yet',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: GlobalVariables.darkGrey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'Try different keywords or clear your search'
                : 'Be the first to share something with the community',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (_searchQuery.isEmpty)
            ElevatedButton(
              onPressed: _navigateToCreatePostScreen,
              style: ElevatedButton.styleFrom(
                backgroundColor: GlobalVariables.green,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: Text(
                'Create a post',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            )
          else
            TextButton(
              onPressed: _clearSearch,
              child: Text(
                'Clear search',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: GlobalVariables.green,
                ),
              ),
            ),
        ],
      ),
    );
  }
}