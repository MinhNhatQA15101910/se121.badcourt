using Microsoft.AspNetCore.Identity;

namespace AuthService.Core.Domain.Exceptions;

public class IdentityErrorException(IEnumerable<IdentityError> errors) : BadRequestException(string.Join("\n", errors.Select(e => e.Description)))
{
}
