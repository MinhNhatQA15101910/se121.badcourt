import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frontend/common/widgets/custom_button.dart';
import 'package:frontend/common/widgets/loader.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/post/services/post_service.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class CreatePostScreen extends StatefulWidget {
  static const String routeName = '/createPostScreen';
  const CreatePostScreen({Key? key}) : super(key: key);

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();

  final _postService = PostService();
  final ImagePicker _picker = ImagePicker();
  List<File>? _imageFiles = [];
  bool _isLoading = false;

  Future<void> _createPost() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _postService.createPost(
        context,
        _imageFiles!,
        _descriptionController.text,
        _titleController.text,
      );

      // Navigate back to the previous screen
      Navigator.pop(context, true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImages() async {
    final List<XFile>? selectedImages = await _picker.pickMultiImage();
    if (selectedImages != null) {
      setState(() {
        // Calculate remaining slots available
        int remainingSlots = 10 - _imageFiles!.length;

        // Convert XFile to File and add only the remaining number of images if exceeding limit
        if (remainingSlots > 0) {
          _imageFiles?.addAll(
            selectedImages
                .take(remainingSlots)
                .map((xfile) => File(xfile.path))
                .toList(),
          );
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _descriptionController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();

    return Stack(
      children: [
        SafeArea(
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: GlobalVariables.green,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Create post',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.none,
                      color: GlobalVariables.white,
                    ),
                  ),
                  Container(
                    width: 80,
                    child: CustomButton(
                      onTap: _createPost,
                      buttonText: 'Post',
                      borderColor: GlobalVariables.white,
                      fillColor: GlobalVariables.white,
                      textColor: GlobalVariables.green,
                    ),
                  ),
                ],
              ),
            ),
            body: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Avatar
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.green,
                              width: 2.0,
                            ),
                          ),
                          child: CircleAvatar(
                            backgroundImage: NetworkImage(
                              userProvider.user.imageUrl,
                            ),
                            radius: 25,
                          ),
                        ),
                        const SizedBox(width: 12),
                        _customText(
                          userProvider.user.username,
                          16,
                          FontWeight.w700,
                          GlobalVariables.black,
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: _titleController,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: GlobalVariables.blackGrey,
                      ),
                      maxLines: null,
                      minLines: 1,
                      decoration: InputDecoration(
                        hintText: 'Post title',
                        hintStyle: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: GlobalVariables.darkGrey,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: GlobalVariables.green,
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: GlobalVariables.green,
                            width: 2.0,
                          ),
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                    ),
                    SizedBox(height: 12),
                    Container(
                      child: TextFormField(
                        controller: _descriptionController,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: GlobalVariables.blackGrey,
                        ),
                        maxLines: null,
                        minLines: 8,
                        decoration: InputDecoration(
                          hintText: 'Post description',
                          hintStyle: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: GlobalVariables.darkGrey,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: GlobalVariables.grey,
                              width: 1.5,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: GlobalVariables.grey,
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: GlobalVariables.darkGrey,
                              width: 2.0,
                            ),
                          ),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 1,
                      ),
                      itemCount: (_imageFiles?.length ?? 0) + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return GestureDetector(
                            onTap: _pickImages,
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFF2F4F5),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  double iconSize = constraints.maxWidth * 0.6;
                                  return Center(
                                    child: Icon(
                                      Icons.add_photo_alternate_outlined,
                                      size: iconSize,
                                      color: Colors.grey[700],
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        } else {
                          final image = _imageFiles![index - 1];
                          return Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Image.file(
                                  image,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _imageFiles?.removeAt(index - 1);
                                    });
                                  },
                                  child: Container(
                                    child: const Icon(
                                      Icons.close,
                                      shadows: <Shadow>[
                                        Shadow(
                                            color: Colors.black,
                                            blurRadius: 15.0)
                                      ],
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Loader overlay when _isLoading is true
        if (_isLoading)
          Stack(
            children: [
              Container(
                color:
                    Colors.black..withOpacity(0.3), // Semi-transparent barrier
              ),
              const Center(
                child: Loader(),
              ),
            ],
          ),
      ],
    );
  }

  Widget _customText(String text, double size, FontWeight weight, Color color) {
    return Text(
      text,
      textAlign: TextAlign.start,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.inter(
        color: color,
        fontSize: size,
        fontWeight: weight,
      ),
    );
  }
}
