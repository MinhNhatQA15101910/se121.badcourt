using FacilityService.Core.Application.Commands;
using FluentValidation;

namespace FacilityService.Core.Application.Validators;

public class RegisterFacilityValidator : AbstractValidator<RegisterFacilityCommand>
{
    public RegisterFacilityValidator()
    {
        RuleFor(x => x.RegisterFacilityDto.FacilityName)
            .NotEmpty()
            .WithMessage("Facility name is required.")
            .MaximumLength(100)
            .WithMessage("Facility name must not exceed 100 characters.");

        RuleFor(x => x.RegisterFacilityDto.Lat)
            .NotEmpty()
            .WithMessage("Latitude is required.")
            .InclusiveBetween(-90, 90)
            .WithMessage("Latitude must be between -90 and 90.");

        RuleFor(x => x.RegisterFacilityDto.Lon)
            .NotEmpty()
            .WithMessage("Longitude is required.")
            .InclusiveBetween(-180, 180)
            .WithMessage("Longitude must be between -180 and 180.");

        RuleFor(x => x.RegisterFacilityDto.Description)
            .NotEmpty()
            .WithMessage("Description is required.")
            .MaximumLength(500)
            .WithMessage("Description must not exceed 500 characters.");

        RuleFor(x => x.RegisterFacilityDto.Policy)
            .NotEmpty()
            .WithMessage("Policy is required.")
            .MaximumLength(500)
            .WithMessage("Policy must not exceed 500 characters.");

        RuleFor(x => x.RegisterFacilityDto.DetailAddress)
            .NotEmpty()
            .WithMessage("Detail address is required.")
            .MaximumLength(200)
            .WithMessage("Detail address must not exceed 200 characters.");

        RuleFor(x => x.RegisterFacilityDto.Province)
            .NotEmpty()
            .WithMessage("Province is required.")
            .MaximumLength(100)
            .WithMessage("Province must not exceed 100 characters.");

        RuleFor(x => x.RegisterFacilityDto.FullName)
            .NotEmpty()
            .WithMessage("Full name is required.")
            .MaximumLength(100)
            .WithMessage("Full name must not exceed 100 characters.");

        RuleFor(x => x.RegisterFacilityDto.Email)
            .NotEmpty()
            .WithMessage("Email is required.")
            .EmailAddress()
            .WithMessage("Invalid email format.")
            .MaximumLength(100)
            .WithMessage("Email must not exceed 100 characters.");

        RuleFor(x => x.RegisterFacilityDto.PhoneNumber)
            .NotEmpty()
            .WithMessage("Phone number is required.")
            .Matches(@"^\+?[0-9]{10,15}$")
            .WithMessage("Invalid phone number format. Must be between 10 and 15 digits.")
            .MaximumLength(15)
            .WithMessage("Phone number must not exceed 15 characters.");

        RuleFor(x => x.RegisterFacilityDto.CitizenId)
            .NotEmpty()
            .WithMessage("Citizen ID is required.")
            .Matches(@"^\d{9,12}$")
            .WithMessage("Invalid citizen ID format. Must be between 9 and 12 digits.")
            .MaximumLength(12)
            .WithMessage("Citizen ID must not exceed 12 characters.");

        RuleFor(x => x.RegisterFacilityDto.CitizenImageFront)
            .NotNull()
            .WithMessage("Citizen image front is required.")
            .Must(file => file.Length > 0)
            .WithMessage("Citizen image front must not be empty.");

        RuleFor(x => x.RegisterFacilityDto.CitizenImageBack)
            .NotNull()
            .WithMessage("Citizen image back is required.")
            .Must(file => file.Length > 0)
            .WithMessage("Citizen image back must not be empty.");

        RuleFor(x => x.RegisterFacilityDto.BankCardFront)
            .NotNull()
            .WithMessage("Bank card front is required.")
            .Must(file => file.Length > 0)
            .WithMessage("Bank card front must not be empty.");

        RuleFor(x => x.RegisterFacilityDto.BankCardBack)
            .NotNull()
            .WithMessage("Bank card back is required.")
            .Must(file => file.Length > 0)
            .WithMessage("Bank card back must not be empty.");

        RuleFor(x => x.RegisterFacilityDto.BusinessLicenseImages)
            .NotEmpty()
            .WithMessage("At least one business license image is required.")
            .Must(files => files.All(file => file.Length > 0))
            .WithMessage("All business license images must not be empty.");
    }
}
