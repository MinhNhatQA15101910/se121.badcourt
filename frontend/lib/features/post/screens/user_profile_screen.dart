import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/post/services/post_service.dart';
import 'package:frontend/features/post/widgets/post_form.dart';
import 'package:frontend/models/post.dart';
// Change from user_dto to user
import 'package:frontend/models/user_dto.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class UserProfileScreen extends StatefulWidget {
  static const String routeName = '/user-profile';
  final String userId;

  const UserProfileScreen({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen>
    with SingleTickerProviderStateMixin {
  final _postService = PostService();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;

  List<Post> _postList = [];
  int _currentPage = 1;
  int _totalPages = 1;
  bool _isLoading = false;
  bool _isRefreshing = false;
  bool _isLoadingUser = true; // Add loading state for user
  User? _userInfo; // Store fetched user info

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _fetchUserPosts();
      }

      // Show/hide back button based on scroll direction
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        _animationController.reverse();
      } else if (_scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        _animationController.forward();
      }
    });

    // Initialize data fetching
    _initializeData();
    _animationController.forward();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // Initialize both user info and posts
  Future<void> _initializeData() async {
    await Future.wait([
      _fetchUserInfo(),
      _fetchUserPosts(),
    ]);
  }

  // Fetch user information
  Future<void> _fetchUserInfo() async {
    setState(() {
      _isLoadingUser = true;
    });

    try {
      final user = await _postService.fetchUserById(
        context: context,
        userId: widget.userId,
      );

      if (mounted) {
        setState(() {
          _userInfo = user;
          _isLoadingUser = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _isLoadingUser = false;
        });
        
        IconSnackBar.show(
          context,
          label: 'Failed to load user information: $error',
          snackBarType: SnackBarType.fail,
        );
      }
    }
  }

  Future<void> _fetchUserPosts() async {
    if (_isLoading || _currentPage > _totalPages) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _postService.fetchPostsByUserId(
        context: context,
        publisherId: widget.userId,
        pageNumber: _currentPage,
      );

      final List<Post> newPosts = result['posts'];
      final int totalPages = result['totalPages'];

      if (mounted) {
        setState(() {
          _postList.addAll(newPosts);
          _totalPages = totalPages;
          _currentPage++;
        });
      }
    } catch (error) {
      if (mounted) {
        IconSnackBar.show(
          context,
          label: error.toString(),
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

  Future<void> _refreshData() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
      _postList.clear();
      _currentPage = 1;
    });

    await Future.wait([
      _fetchUserInfo(),
      _fetchUserPosts(),
    ]);

    if (mounted) {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<UserProvider>().user;
    final isOwnProfile = currentUser.id == widget.userId;

    return Scaffold(
      backgroundColor: GlobalVariables.defaultColor,
      body: RefreshIndicator(
        color: GlobalVariables.green,
        onRefresh: _refreshData,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Custom App Bar with User Info
            SliverAppBar(
              expandedHeight: 200,
              floating: false,
              pinned: true,
              backgroundColor: GlobalVariables.green,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        GlobalVariables.green,
                        GlobalVariables.green.withOpacity(0.8),
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: _isLoadingUser
                        ? _buildLoadingUserInfo()
                        : _buildUserInfo(isOwnProfile, currentUser),
                  ),
                ),
              ),
            ),

            // Posts Section Header
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(16),
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
                  children: [
                    Icon(
                      Icons.article_outlined,
                      color: GlobalVariables.green,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isOwnProfile ? 'Your Posts' : 'Posts',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: GlobalVariables.darkGrey,
                      ),
                    ),
                    const Spacer(),
                    if (_postList.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: GlobalVariables.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_postList.length}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: GlobalVariables.green,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Posts List
            _postList.isEmpty && !_isLoading
                ? SliverFillRemaining(
                    child: _buildEmptyState(isOwnProfile),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: PostFormWidget(currentPost: _postList[index]),
                          );
                        },
                        childCount: _postList.length,
                      ),
                    ),
                  ),

            // Loading Indicator
            if (_isLoading && _postList.isNotEmpty)
              SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        GlobalVariables.green,
                      ),
                    ),
                  ),
                ),
              ),

            // Bottom padding
            const SliverToBoxAdapter(
              child: SizedBox(height: 20),
            ),
          ],
        ),
      ),
    );
  }

  // Loading state for user info
  Widget _buildLoadingUserInfo() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        // Loading Avatar
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.3),
            border: Border.all(
              color: Colors.white,
              width: 3,
            ),
          ),
          child: Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 2,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Loading Name
        Container(
          width: 120,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(height: 8),
        // Loading Email
        Container(
          width: 160,
          height: 16,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ],
    );
  }

  // User info display
  Widget _buildUserInfo(bool isOwnProfile, currentUser) {
    final displayUser = _userInfo ?? currentUser;
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        // User Avatar
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 3,
            ),
          ),
          child: ClipOval(
            child: Image.network(
              displayUser.photoUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Container(
                color: Colors.white,
                child: Icon(
                  Icons.person,
                  size: 40,
                  color: GlobalVariables.green,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // User Name
        Text(
          displayUser.username,
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        // User Email
        Text(
          displayUser.email,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
        // Error state if user info failed to load
        if (_userInfo == null && !_isLoadingUser) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Text(
              'Failed to load user info',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEmptyState(bool isOwnProfile) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: GlobalVariables.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.article_outlined,
              size: 60,
              color: GlobalVariables.green,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isOwnProfile ? 'No posts yet' : 'No posts found',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: GlobalVariables.darkGrey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isOwnProfile
                ? 'Share your first post with the community'
                : 'This user hasn\'t shared any posts yet',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
