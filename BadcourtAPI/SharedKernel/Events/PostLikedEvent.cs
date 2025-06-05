namespace SharedKernel.Events;

public record PostLikedEvent(string PostId, string PostOwnerId, string LikedUserUsername);
