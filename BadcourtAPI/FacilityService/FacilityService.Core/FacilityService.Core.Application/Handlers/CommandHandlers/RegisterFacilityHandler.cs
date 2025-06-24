using AutoMapper;
using FacilityService.Core.Application.Commands;
using FacilityService.Core.Application.Extensions;
using FacilityService.Core.Application.ExternalServices.Interfaces;
using FacilityService.Core.Application.Interfaces;
using FacilityService.Core.Domain.Entities;
using FacilityService.Core.Domain.Repositories;
using Microsoft.AspNetCore.Http;
using MongoDB.Bson;
using SharedKernel.DTOs;
using SharedKernel.Exceptions;

namespace FacilityService.Core.Application.Handlers.CommandHandlers;

public class RegisterFacilityHandler(
    IHttpContextAccessor httpContextAccessor,
    IFacilityRepository facilityRepository,
    IFileService fileService,
    IUserServiceClient userServiceClient,
    IMapper mapper
) : ICommandHandler<RegisterFacilityCommand, FacilityDto>
{
    public async Task<FacilityDto> Handle(RegisterFacilityCommand request, CancellationToken cancellationToken)
    {
        var userId = httpContextAccessor.HttpContext.User.GetUserId();
        var user = await userServiceClient.GetUserByIdAsync(userId)
            ?? throw new UserNotFoundException(userId);

        var facility = mapper.Map<Facility>(request.RegisterFacilityDto);
        facility.UserId = user.Id;
        facility.UserName = user.Username;
        facility.UserImageUrl = user.Photos.FirstOrDefault(p => p.IsMain)?.Url;

        await facilityRepository.AddFacilityAsync(facility, cancellationToken);

        // Upload facility images to cloudinary
        List<FacilityPhoto> photos = [];
        bool isMain = true;
        foreach (var image in request.RegisterFacilityDto.FacilityImages)
        {
            var uploadResult = await fileService.UploadPhotoAsync($"facilities/{facility.Id}", image);
            if (uploadResult.Error != null)
            {
                throw new BadRequestException(uploadResult.Error.Message);
            }

            photos.Add(new FacilityPhoto
            {
                Id = ObjectId.GenerateNewId().ToString(),
                Url = uploadResult.SecureUrl.ToString(),
                PublicId = uploadResult.PublicId,
                IsMain = isMain
            });

            isMain = false;
        }

        // Upload citizen image front to cloudinary
        var citizenImageFrontUploadResult = await fileService.UploadPhotoAsync($"facilities/{facility.Id}/citizen_images", request.RegisterFacilityDto.CitizenImageFront);
        if (citizenImageFrontUploadResult.Error != null)
        {
            throw new BadRequestException(citizenImageFrontUploadResult.Error.Message);
        }
        var citizenImageFront = new Photo
        {
            Url = citizenImageFrontUploadResult.SecureUrl.ToString(),
            PublicId = citizenImageFrontUploadResult.PublicId,
            IsMain = false
        };

        // Upload citizen image back to cloudinary
        var citizenImageBackUploadResult = await fileService.UploadPhotoAsync($"facilities/{facility.Id}/citizen_images", request.RegisterFacilityDto.CitizenImageBack);
        if (citizenImageBackUploadResult.Error != null)
        {
            throw new BadRequestException(citizenImageBackUploadResult.Error.Message);
        }
        var citizenImageBack = new Photo
        {
            Url = citizenImageBackUploadResult.SecureUrl.ToString(),
            PublicId = citizenImageBackUploadResult.PublicId,
            IsMain = false
        };

        // Upload bank card front image to cloudinary
        var bankCardFrontUploadResult = await fileService.UploadPhotoAsync($"facilities/{facility.Id}/bank_cards", request.RegisterFacilityDto.BankCardFront);
        if (bankCardFrontUploadResult.Error != null)
        {
            throw new BadRequestException(bankCardFrontUploadResult.Error.Message);
        }
        var bankCardFront = new Photo
        {
            Url = bankCardFrontUploadResult.SecureUrl.ToString(),
            PublicId = bankCardFrontUploadResult.PublicId,
            IsMain = false
        };

        // Upload bank card back image to cloudinary
        var bankCardBackUploadResult = await fileService.UploadPhotoAsync($"facilities/{facility.Id}/bank_cards", request.RegisterFacilityDto.BankCardBack);
        if (bankCardBackUploadResult.Error != null)
        {
            throw new BadRequestException(bankCardBackUploadResult.Error.Message);
        }
        var bankCardBack = new Photo
        {
            Url = bankCardBackUploadResult.SecureUrl.ToString(),
            PublicId = bankCardBackUploadResult.PublicId,
            IsMain = false
        };

        // Upload business license images to cloudinary
        List<Photo> businessLicenseImages = [];
        isMain = true;
        foreach (var image in request.RegisterFacilityDto.BusinessLicenseImages)
        {
            var uploadResult = await fileService.UploadPhotoAsync($"facilities/{facility.Id}/business_licenses", image);
            if (uploadResult.Error != null)
            {
                throw new BadRequestException(uploadResult.Error.Message);
            }

            businessLicenseImages.Add(new Photo
            {
                Url = uploadResult.SecureUrl.ToString(),
                PublicId = uploadResult.PublicId,
                IsMain = isMain
            });

            isMain = false;
        }

        facility.Photos = photos.AsEnumerable();
        facility.ManagerInfo.CitizenImageFront = citizenImageFront;
        facility.ManagerInfo.CitizenImageBack = citizenImageBack;
        facility.ManagerInfo.BankCardFront = bankCardFront;
        facility.ManagerInfo.BankCardBack = bankCardBack;
        facility.ManagerInfo.BusinessLicenseImages = businessLicenseImages.AsEnumerable();

        // Update facility in the repository
        await facilityRepository.UpdateFacilityAsync(facility, cancellationToken);

        return mapper.Map<FacilityDto>(facility);
    }
}
