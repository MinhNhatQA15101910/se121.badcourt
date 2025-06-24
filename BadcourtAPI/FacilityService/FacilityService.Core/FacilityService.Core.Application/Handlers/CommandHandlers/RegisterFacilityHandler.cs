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

        // Upload facility images
        var facilityPhotos = await UploadMultiplePhotosAsync(
            $"facilities/{facility.Id}",
            request.RegisterFacilityDto.FacilityImages,
            withMain: true
        );
        facility.Photos = [.. facilityPhotos.Select(p => new FacilityPhoto
        {
            Id = ObjectId.GenerateNewId().ToString(),
            Url = p.Url,
            PublicId = p.PublicId,
            IsMain = p.IsMain
        })];

        // Upload manager info documents
        facility.ManagerInfo.CitizenImageFront = await UploadSinglePhotoAsync(
            $"facilities/{facility.Id}/citizen_images",
            request.RegisterFacilityDto.CitizenImageFront
        );

        facility.ManagerInfo.CitizenImageBack = await UploadSinglePhotoAsync(
            $"facilities/{facility.Id}/citizen_images",
            request.RegisterFacilityDto.CitizenImageBack
        );

        facility.ManagerInfo.BankCardFront = await UploadSinglePhotoAsync(
            $"facilities/{facility.Id}/bank_cards",
            request.RegisterFacilityDto.BankCardFront
        );

        facility.ManagerInfo.BankCardBack = await UploadSinglePhotoAsync(
            $"facilities/{facility.Id}/bank_cards",
            request.RegisterFacilityDto.BankCardBack
        );

        facility.ManagerInfo.BusinessLicenseImages = await UploadMultiplePhotosAsync(
            $"facilities/{facility.Id}/business_licenses",
            request.RegisterFacilityDto.BusinessLicenseImages,
            withMain: true
        );

        // Persist full data
        await facilityRepository.UpdateFacilityAsync(facility, cancellationToken);

        return mapper.Map<FacilityDto>(facility);
    }

    private async Task<Photo> UploadSinglePhotoAsync(string folder, IFormFile file)
    {
        var result = await fileService.UploadPhotoAsync(folder, file);
        if (result.Error != null)
            throw new BadRequestException(result.Error.Message);

        return new Photo
        {
            Url = result.SecureUrl.ToString(),
            PublicId = result.PublicId,
            IsMain = false
        };
    }

    private async Task<List<Photo>> UploadMultiplePhotosAsync(string folder, IEnumerable<IFormFile> files, bool withMain = false)
    {
        var photos = new List<Photo>();
        bool isMain = withMain;
        foreach (var file in files)
        {
            var result = await fileService.UploadPhotoAsync(folder, file);
            if (result.Error != null)
                throw new BadRequestException(result.Error.Message);

            photos.Add(new Photo
            {
                Url = result.SecureUrl.ToString(),
                PublicId = result.PublicId,
                IsMain = isMain
            });

            isMain = false;
        }

        return photos;
    }
}
