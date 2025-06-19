namespace SharedKernel.Exceptions;

public class GroupNotFoundException(string groupName)
    : NotFoundException($"The order with the name {groupName} was not found.")
{
}
