using AuthService.Core.Application.DTOs;

namespace AuthService.Core.Application.Commands;

public record VerifyPincodeCommand(VerifyPincodeDto VerifyPincodeDto) : ICommand<object>;
