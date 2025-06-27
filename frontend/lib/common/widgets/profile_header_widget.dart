import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:frontend/common/services/user_service.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/models/photo.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ProfileHeaderWidget extends StatefulWidget {
  final String username;
  final String photoUrl;
  final String userId;
  final List<Photo> photos;
  final bool showEditButton;
  final VoidCallback? onEditPressed;

  const ProfileHeaderWidget({
    Key? key,
    required this.username,
    required this.photoUrl,
    required this.userId,
    required this.photos,
    this.showEditButton = true,
    this.onEditPressed,
  }) : super(key: key);

  @override
  State<ProfileHeaderWidget> createState() => _ProfileHeaderWidgetState();
}

class _ProfileHeaderWidgetState extends State<ProfileHeaderWidget> {
  final UserService _userService = UserService();
  final ImagePicker _imagePicker = ImagePicker();
  bool _isLoading = false;

  Future<void> _showPhotoManagementBottomSheet() async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final currentPhotos = userProvider.user.photos;

          return Container(
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Header
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Manage Photos',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: GlobalVariables.blackGrey,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),

                // Add photo button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _addPhoto,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.add_a_photo),
                      label:
                          Text(_isLoading ? 'Uploading...' : 'Add New Photo'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: GlobalVariables.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Photos grid - Now using currentPhotos from provider
                Expanded(
                  child: currentPhotos.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.photo_library_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No photos yet',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Add your first photo above',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 1,
                          ),
                          itemCount: currentPhotos.length,
                          itemBuilder: (context, index) {
                            final photo = currentPhotos[index];
                            return _buildPhotoItem(photo, index);
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPhotoItem(Photo photo, int index) {
    return GestureDetector(
      onTap: () => _showPhotoOptionsDialog(photo),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: photo.isMain
              ? Border.all(color: GlobalVariables.green, width: 3)
              : null,
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                photo.url,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.error, color: Colors.grey),
                ),
              ),
            ),

            // Main photo indicator
            if (photo.isMain)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: GlobalVariables.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Main',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

            // Options button
            Positioned(
              bottom: 4,
              right: 4,
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
                child: GestureDetector(
                  onTap: () => _showPhotoOptionsDialog(photo),
                  child: const Icon(
                    Icons.more_vert,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPhotoOptionsDialog(Photo photo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Photo Options',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!photo.isMain)
              ListTile(
                leading: Icon(Icons.star, color: GlobalVariables.green),
                title: Text(
                  'Set as Main Photo',
                  style: GoogleFonts.inter(),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _setMainPhoto(photo.id);
                },
              ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: Text(
                'Delete Photo',
                style: GoogleFonts.inter(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(photo);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: GlobalVariables.darkGrey),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(Photo photo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Photo',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to delete this photo? This action cannot be undone.',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: GlobalVariables.darkGrey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deletePhoto(photo.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Delete',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addPhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _isLoading = true;
        });

        await _userService.addPhoto(context, File(image.path));

        // Refresh user data after adding photo
        if (mounted) {
          await _refreshUser();
        }
      }
    } catch (e) {
      print('Error adding photo: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshUser() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final token = userProvider.user.token;

    try {
      final fetchedUser = await _userService.fetchCurrentUser(context: context);

      if (fetchedUser != null) {
        final updatedUser = fetchedUser.copyWith(token: token);
        userProvider.setUserFromModel(updatedUser);
      } else {
        throw Exception('User data is null');
      }
    } catch (error) {
      IconSnackBar.show(
        context,
        label: 'Failed to load user information: $error',
        snackBarType: SnackBarType.fail,
      );
    }
  }

  Future<void> _setMainPhoto(String photoId) async {
    try {
      await _userService.setMainPhoto(context, photoId);

      // Refresh user data after setting main photo
      if (mounted) {
        await _refreshUser();
      }
    } catch (e) {
      print('Error setting main photo: $e');
    }
  }

  Future<void> _deletePhoto(String photoId) async {
    try {
      await _userService.deletePhoto(context, photoId);

      // Refresh user data after deleting photo
      if (mounted) {
        await _refreshUser();
      }
    } catch (e) {
      print('Error deleting photo: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        return Container(
          height: 240,
          child: Stack(
            children: [
              // Background image with gradient overlay
              Positioned.fill(
                child: ShaderMask(
                  shaderCallback: (rect) {
                    return LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        GlobalVariables.green,
                        GlobalVariables.green.withOpacity(0.8),
                      ],
                      stops: const [0.1, 1.0],
                    ).createShader(rect);
                  },
                  blendMode: BlendMode.srcATop,
                  child: Image.asset(
                    'assets/images/img_account_background.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // Profile content
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                ),
              ),

              // Profile image - Now using userProvider data
              Positioned(
                top: 80,
                left: 0,
                right: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: _showPhotoManagementBottomSheet,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          ClipOval(
                            child: Image.network(
                              userProvider.user.photoUrl.isNotEmpty
                                  ? userProvider.user.photoUrl
                                  : widget.photoUrl,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                color: Colors.white,
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.person,
                                  size: 80,
                                  color: GlobalVariables.green,
                                ),
                              ),
                            ),
                          ),

                          // Camera overlay
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black.withOpacity(0.3),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Username - Now using userProvider data
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    userProvider.user.username.isNotEmpty
                        ? userProvider.user.username
                        : widget.username,
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: GlobalVariables.blackGrey,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
