namespace SharedKernel.Events;

public record PostCommentedEvent(string PostId, string PostOwnerId, string CommentedUserUsername, string CommentContent);
