class NotificationDataDto {
  final String? orderId;
  final String? roomId;
  final String? postId;
  final String? commentId;

  NotificationDataDto({
    this.orderId,
    this.roomId,
    this.postId,
    this.commentId,
  });

  factory NotificationDataDto.fromJson(Map<String, dynamic> json) {
    try {
      return NotificationDataDto(
        orderId: json['orderId'] as String?,
        roomId: json['roomId'] as String?,
        postId: json['postId'] as String?,
        commentId: json['commentId'] as String?,
      );
    } catch (e) {
      print('[NotificationDataDto] Error parsing JSON: $e');
      print('[NotificationDataDto] JSON data: $json');
      return NotificationDataDto();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'roomId': roomId,
      'postId': postId,
      'commentId': commentId,
    };
  }

  @override
  String toString() {
    return 'NotificationDataDto(orderId: $orderId, roomId: $roomId, postId: $postId, commentId: $commentId)';
  }
}
