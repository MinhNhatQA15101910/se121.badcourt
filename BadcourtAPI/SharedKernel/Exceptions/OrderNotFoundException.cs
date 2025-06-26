namespace SharedKernel.Exceptions;

public class OrderNotFoundException : NotFoundException
{
    public OrderNotFoundException(Guid orderId) : base($"Order with ID '{orderId}' not found.")
    {
    }

    public OrderNotFoundException(string paymentIntentId) : base($"Order with Payment Intent ID '{paymentIntentId}' not found.")
    {
    }
}
