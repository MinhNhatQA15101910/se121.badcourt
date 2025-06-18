import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:google_fonts/google_fonts.dart';

class MessageInputWidget extends StatefulWidget {
  final TextEditingController messageController;
  final List<File> mediaFiles;
  final bool isConnected;
  final bool isSendingMessage;
  final VoidCallback onPickMedia;
  final Function(int) onRemoveMedia;
  final VoidCallback onSendMessage;

  const MessageInputWidget({
    Key? key,
    required this.messageController,
    required this.mediaFiles,
    required this.isConnected,
    required this.isSendingMessage,
    required this.onPickMedia,
    required this.onRemoveMedia,
    required this.onSendMessage,
  }) : super(key: key);

  @override
  State<MessageInputWidget> createState() => _MessageInputWidgetState();
}

class _MessageInputWidgetState extends State<MessageInputWidget>
    with SingleTickerProviderStateMixin {
  bool _hasText = false;
  bool _isFocused = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _borderColorAnimation;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _hasText = widget.messageController.text.trim().isNotEmpty;
    widget.messageController.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
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

    if (_canSend) {
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    widget.messageController.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _animationController.dispose();
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
    if (_isFocused != _focusNode.hasFocus) {
      setState(() {
        _isFocused = _focusNode.hasFocus;
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
      widget.isConnected && (_hasText || widget.mediaFiles.isNotEmpty);

  @override
  Widget build(BuildContext context) {
    return Container(
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
              _buildInputRow(),
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
        color: widget.isConnected
            ? GlobalVariables.green.withOpacity(0.1)
            : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: widget.isConnected ? widget.onPickMedia : null,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(
              Icons.attach_file,
              color: widget.isConnected
                  ? GlobalVariables.green
                  : Colors.grey.shade400,
              size: 24,
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
        focusNode: _focusNode,
        enabled: widget.isConnected,
        maxLines: null,
        textAlignVertical: TextAlignVertical.center,
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
          color: Colors.black87,
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
              color: _canSend ? GlobalVariables.green : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(20),
              boxShadow: _canSend
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
                onTap: _canSend ? widget.onSendMessage : null,
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
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset('assets/video_placeholder.png',
                          fit: BoxFit.cover),
                      Center(
                        child: Icon(Icons.play_circle_fill,
                            size: 32, color: Colors.white),
                      ),
                    ],
                  )
                : Image.file(file, fit: BoxFit.cover),
          ),
        ),
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
