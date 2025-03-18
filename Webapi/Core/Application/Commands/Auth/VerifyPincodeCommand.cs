using Application.DTOs.Auth;

namespace Application.Commands.Auth;

public record VerifyPincodeCommand(VerifyPincodeDto VerifyPincodeDto) : ICommand<object>;
