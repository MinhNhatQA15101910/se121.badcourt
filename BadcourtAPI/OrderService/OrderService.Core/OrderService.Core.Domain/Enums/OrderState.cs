namespace OrderService.Core.Domain.Enums;

public enum OrderState
{
    None = 0,
    Pending = 1,
    NotPlay = 2,
    Playing = 3,
    Played = 4,
    Cancelled = 5,
}
