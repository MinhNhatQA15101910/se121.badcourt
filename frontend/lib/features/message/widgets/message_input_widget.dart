import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class MessageInputWidget extends StatefulWidget {
  final TextEditingController messageController;
  final FocusNode messageFocusNode;
  final List<File> mediaFiles;
  final bool isConnected;
  final bool isSendingMessage;
  final Function(List<File>) onPickMedia;
  final Function(int) onRemoveMedia;
  final VoidCallback onSendMessage;
  final VoidCallback onClearMedia;

  const MessageInputWidget({
    Key? key,
    required this.messageController,
    required this.messageFocusNode,
    required this.mediaFiles,
    required this.isConnected,
    required this.isSendingMessage,
    required this.onPickMedia,
    required this.onRemoveMedia,
    required this.onSendMessage,
    required this.onClearMedia,
  }) : super(key: key);

  @override
  State<MessageInputWidget> createState() => _MessageInputWidgetState();
}

class _MessageInputWidgetState extends State<MessageInputWidget>
    with TickerProviderStateMixin {
  bool _hasText = false;
  bool _isFocused = false;
  bool _showMediaMenu = false;
  late AnimationController _animationController;
  late AnimationController _menuAnimationController;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _borderColorAnimation;
  late Animation<double> _menuSlideAnimation;
  late Animation<double> _menuFadeAnimation;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _hasText = widget.messageController.text.trim().isNotEmpty;
    widget.messageController.addListener(_onTextChanged);
    widget.messageFocusNode.addListener(_onFocusChanged);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _menuAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _borderColorAnimation = ColorTween(
      begin: Colors.grey.withOpacity(0.2),
      end: GlobalVariables.green.withOpacity(0.6),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _menuSlideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _menuAnimationController,
      curve: Curves.easeOutBack,
    ));

    _menuFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _menuAnimationController,
      curve: Curves.easeOut,
    ));

    if (_canSend) {
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    widget.messageController.removeListener(_onTextChanged);
    widget.messageFocusNode.removeListener(_onFocusChanged);
    _animationController.dispose();
    _menuAnimationController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = widget.messageController.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
      _updateAnimations();
    }
  }

  void _onFocusChanged() {
    if (_isFocused != widget.messageFocusNode.hasFocus) {
      setState(() {
        _isFocused = widget.messageFocusNode.hasFocus;
      });
      _updateAnimations();
    }
  }

  void _updateAnimations() {
    if (_canSend || _isFocused) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  bool get _canSend =>
    widget.isConnected && 
    !widget.isSendingMessage && 
    (_hasText || widget.mediaFiles.isNotEmpty);

  void _toggleMediaMenu() {
    if (!widget.isConnected || widget.isSendingMessage) return;
    
    setState(() {
      _showMediaMenu = !_showMediaMenu;
    });

    if (_showMediaMenu) {
      _menuAnimationController.forward();
    } else {
      _menuAnimationController.reverse();
    }
  }

  void _hideMediaMenu() {
    if (_showMediaMenu) {
      setState(() {
        _showMediaMenu = false;
      });
      _menuAnimationController.reverse();
    }
  }

  Future<void> _pickImages() async {
    if (widget.isSendingMessage) return;
    
    try {
      final List<XFile>? images = await _picker.pickMultiImage();
      if (images != null && images.isNotEmpty) {
        final List<File> imageFiles = images.map((xfile) => File(xfile.path)).toList();
        widget.onPickMedia(imageFiles);
      }
    } catch (e) {
      print('Error picking images: $e');
    }
    _hideMediaMenu();
    
    // Giữ focus sau khi chọn media
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.messageFocusNode.canRequestFocus) {
        widget.messageFocusNode.requestFocus();
      }
    });
  }

  Future<void> _pickVideo() async {
    if (widget.isSendingMessage) return;
    
    try {
      final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
      if (video != null) {
        widget.onPickMedia([File(video.path)]);
      }
    } catch (e) {
      print('Error picking video: $e');
    }
    _hideMediaMenu();
    
    // Giữ focus sau khi chọn media
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.messageFocusNode.canRequestFocus) {
        widget.messageFocusNode.requestFocus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _hideMediaMenu,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              children: [
                if (widget.mediaFiles.isNotEmpty) _buildMediaPreview(),
                // Media menu buttons
                AnimatedBuilder(
                  animation: _menuAnimationController,
                  builder: (context, child) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      height: _showMediaMenu ? 60 : 0,
                      child: _showMediaMenu ? _buildMediaButtons() : null,
                    );
                  },
                ),
                _buildInputRow(),
                // Hiển thị trạng thái gửi tin nhắn nhẹ nhàng hơn
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMediaButtons() {
    return AnimatedBuilder(
      animation: _menuAnimationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - _menuSlideAnimation.value)),
          child: Opacity(
            opacity: _menuFadeAnimation.value,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  // Image button
                  Expanded(
                    child: _buildMediaButton(
                      icon: Icons.image_rounded,
                      label: 'Image',
                      color: Colors.blue,
                      onTap: _pickImages,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Video button
                  Expanded(
                    child: _buildMediaButton(
                      icon: Icons.videocam_rounded,
                      label: 'Video',
                      color: Colors.red,
                      onTap: _pickVideo,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMediaButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: color,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputRow() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: widget.isConnected
                  ? _borderColorAnimation.value ?? Colors.grey.withOpacity(0.2)
                  : Colors.grey.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildImagePickerButton(),
              const SizedBox(width: 8),
              Expanded(child: _buildTextInput()),
              const SizedBox(width: 8),
              _buildSendButton(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImagePickerButton() {
    return Container(
      margin: const EdgeInsets.only(left: 4, bottom: 4),
      decoration: BoxDecoration(
        color: widget.isConnected && !widget.isSendingMessage
            ? (_showMediaMenu 
                ? GlobalVariables.green.withOpacity(0.2)
                : GlobalVariables.green.withOpacity(0.1))
            : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: (widget.isConnected && !widget.isSendingMessage) ? _toggleMediaMenu : null,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: AnimatedRotation(
              turns: _showMediaMenu ? 0.125 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                _showMediaMenu ? Icons.close : Icons.attach_file,
                color: (widget.isConnected && !widget.isSendingMessage)
                    ? GlobalVariables.green
                    : Colors.grey.shade400,
                size: 24,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextInput() {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 36,
        maxHeight: 120,
      ),
      child: TextFormField(
        controller: widget.messageController,
        focusNode: widget.messageFocusNode,
        enabled: widget.isConnected, // Không disable khi đang gửi
        maxLines: null,
        textAlignVertical: TextAlignVertical.center,
        onTap: _hideMediaMenu,
        decoration: InputDecoration(
          hintText: widget.isConnected ? 'Type a message...' : 'Connecting...',
          hintStyle: GoogleFonts.inter(
            color: Colors.grey.shade500,
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
        style: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: Colors.black87, // Luôn giữ màu đen
        ),
      ),
    );
  }

  Widget _buildSendButton() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            margin: const EdgeInsets.only(right: 4, bottom: 4),
            decoration: BoxDecoration(
              color: _canSend || widget.isSendingMessage ? GlobalVariables.green : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(20),
              boxShadow: (_canSend || widget.isSendingMessage)
                  ? [
                      BoxShadow(
                        color: GlobalVariables.green.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: _canSend ? () {
                  _hideMediaMenu();
                  widget.onSendMessage();
                } : null,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: widget.isSendingMessage
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Icon(
                          Icons.send,
                          color: _canSend ? Colors.white : Colors.grey.shade500,
                          size: 24,
                        ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMediaPreview() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${widget.mediaFiles.length} file${widget.mediaFiles.length > 1 ? 's' : ''} selected',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: widget.mediaFiles.length,
            itemBuilder: (context, index) => _buildMediaPreviewItem(index),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaPreviewItem(int index) {
    final file = widget.mediaFiles[index];
    final isVideo = file.path.toLowerCase().endsWith('.mp4') ||
        file.path.toLowerCase().endsWith('.mov');

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AspectRatio(
            aspectRatio: 1,
            child: isVideo
                ? Container(
                    color: Colors.black,
                    child: const Center(
                      child: Icon(
                        Icons.play_circle_fill,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),
                  )
                : Image.file(file, fit: BoxFit.cover),
          ),
        ),
        if (!widget.isSendingMessage) // Chỉ hiện remove button khi không loading
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => widget.onRemoveMedia(index),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.close, size: 14, color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }
}
