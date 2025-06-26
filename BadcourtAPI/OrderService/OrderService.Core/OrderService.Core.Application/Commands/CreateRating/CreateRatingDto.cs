namespace OrderService.Core.Application.Commands.CreateRating;

public class CreateRatingDto
{
    public int Stars { get; set; }
    public string Feedback { get; set; } = string.Empty;
}
