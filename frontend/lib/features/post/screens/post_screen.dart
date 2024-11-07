import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frontend/common/widgets/custom_container.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/post/widgets/post_form.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class PostScreen extends StatefulWidget {
  static const String routeName = '/post';
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final ImagePicker _picker = ImagePicker();
  List<XFile>? _imageFiles = [];

  Future<void> _pickImages() async {
    final List<XFile>? selectedImages = await _picker.pickMultiImage();
    if (selectedImages != null) {
      setState(() {
        // Calculate remaining slots available
        int remainingSlots = 10 - _imageFiles!.length;

        // Add only the remaining number of images if exceeding limit
        if (remainingSlots > 0) {
          _imageFiles?.addAll(selectedImages.take(remainingSlots));
        }
      });
    }
  }

  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          backgroundColor: GlobalVariables.green,
          title: Row(
            children: [
              Expanded(
                child: Text(
                  'POST',
                  style: GoogleFonts.alfaSlabOne(
                    fontSize: 24,
                    fontWeight: FontWeight.w400,
                    decoration: TextDecoration.none,
                    color: GlobalVariables.white,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {},
                iconSize: 24,
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: GlobalVariables.white,
                ),
              ),
              IconButton(
                onPressed: () {},
                iconSize: 24,
                icon: const Icon(
                  Icons.message_outlined,
                  color: GlobalVariables.white,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Container(
        color: GlobalVariables.defaultColor,
        child: SingleChildScrollView(
          child: Column(
            children: [
              CustomContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                              'https://plus.unsplash.com/premium_photo-1683121366070-5ceb7e007a97?q=80&w=1770&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                            ),
                            radius: 25,
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _textController,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: GlobalVariables.blackGrey,
                            ),
                            maxLines: null,
                            minLines: 1,
                            decoration: InputDecoration(
                              hintText: 'Ask a question or start a post',
                              hintStyle: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: GlobalVariables.darkGrey,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: GlobalVariables
                                      .green, // Green border when unfocused
                                  width: 1.5,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: GlobalVariables
                                      .green, // Green border when focused
                                  width: 2.0,
                                ),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_imageFiles!.isNotEmpty) SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _imageFiles!.asMap().entries.map((entry) {
                          int index = entry.key;
                          XFile image = entry.value;

                          return Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    File(image.path),
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _imageFiles?.removeAt(index);
                                      });
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: GlobalVariables.darkGrey,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        size: 20,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _pickImages,
                          icon: Icon(
                            Icons.add_photo_alternate,
                            size: 20,
                          ),
                          label: _customText(
                            'Add media',
                            14,
                            FontWeight.w500,
                            Colors
                                .green, // Replace with GlobalVariables.green if defined
                          ),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            // Post action logic here
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: GlobalVariables.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _customText(
                                'Post',
                                14,
                                FontWeight.w500,
                                GlobalVariables.white,
                              ),
                              SizedBox(
                                  width: 8), // Spacing between text and icon
                              Icon(
                                Icons.send,
                                size: 20,
                                color: GlobalVariables.white,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              CustomContainer(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _customText('Lastest', 16, FontWeight.w700,
                        GlobalVariables.blackGrey),
                    Icon(
                      Icons.expand_more,
                      color: GlobalVariables.blackGrey,
                    ),
                  ],
                ),
              ),
              PostFormWidget(),
              PostFormWidget(),
              PostFormWidget(),
              PostFormWidget(),
            ],
          ),
        ),
      ),
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
