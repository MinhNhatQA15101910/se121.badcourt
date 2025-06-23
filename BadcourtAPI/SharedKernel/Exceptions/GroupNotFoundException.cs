namespace SharedKernel.Exceptions;

public class GroupNotFoundException(string groupName)
    : NotFoundException($"The group with the name {groupName} was not found.")
{
}
