import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/post/screens/create_post_screen.dart';
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
  late Animation<double> _animation;

  List<Post> _postList = [];
  int _currentPage = 1;
  int _totalPages = 1;
  bool _isLoading = false;
  bool _isRefreshing = false;
  bool _isSearching = false;
  String _currentFilter = 'Latest';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _fetchAllPost();
      }
      
      // Show/hide FAB based on scroll direction
      if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
        _animationController.reverse();
      } else if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
        _animationController.forward();
      }
    });

    _fetchAllPost();
    _animationController.forward();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchAllPost() async {
    if (_isLoading || _currentPage > _totalPages) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _postService.fetchAllPosts(
        context: context,
        pageNumber: _currentPage,
        searchQuery: _searchQuery,
      );

      final List<Post> newPosts = result['posts'];
      final int totalPages = result['totalPages'];

      setState(() {
        _postList.addAll(newPosts);
        _totalPages = totalPages;
        _currentPage++;
      });
    } catch (error) {
      IconSnackBar.show(
        context,
        label: error.toString(),
        snackBarType: SnackBarType.fail,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshPosts() async {
    if (_isRefreshing) return;
    
    setState(() {
      _isRefreshing = true;
      _postList.clear();
      _currentPage = 1;
    });
    
    await _fetchAllPost();
    
    setState(() {
      _isRefreshing = false;
    });
  }

  Future<void> _navigateToCreatePostScreen() async {
    final result = await Navigator.of(context).pushNamed(CreatePostScreen.routeName);

    if (result == true) {
      await _refreshPosts();
    }
  }

  void _performSearch(String query) {
    setState(() {
      _searchQuery = query;
      _postList.clear();
      _currentPage = 1;
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
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _isSearching = false;
                        _searchQuery = '';
                      });
                      _refreshPosts();
                    },
                  ),
                ),
                onSubmitted: (value) {
                  _performSearch(value);
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
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _refreshPosts,
          ),
        ],
      ),
      body: RefreshIndicator(
        color: GlobalVariables.green,
        onRefresh: _refreshPosts,
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
            
            SliverPadding(
              padding: const EdgeInsets.only(top: 8),
              sliver: _postList.isEmpty && !_isLoading
                ? SliverFillRemaining(
                    child: _buildEmptyState(),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(
                            left: 16, 
                            right: 16, 
                            bottom: 16
                          ),
                          child: PostFormWidget(currentPost: _postList[index]),
                        );
                      },
                      childCount: _postList.length,
                    ),
                  ),
            ),
            
            if (_isLoading && _postList.isNotEmpty)
              SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(GlobalVariables.green),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: ScaleTransition(
        scale: _animation,
        child: FloatingActionButton(
          onPressed: _navigateToCreatePostScreen,
          backgroundColor: GlobalVariables.green,
          child: const Icon(Icons.add, color: Colors.white),
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
                // User avatar
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
                      userProvider.user.imageUrl,
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
                
                // Post input field
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
          
          // Action buttons
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
            Icons.forum_outlined,
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
                ? 'Try different keywords or filters'
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
            ),
        ],
      ),
    );
  }
}
