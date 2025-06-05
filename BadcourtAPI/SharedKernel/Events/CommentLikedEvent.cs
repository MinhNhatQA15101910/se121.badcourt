namespace SharedKernel.Events;

public record CommentLikedEvent(string CommentId, string CommentOwnerId, string LikedUserUsername);
