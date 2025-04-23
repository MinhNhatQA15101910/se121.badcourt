using CloudinaryDotNet.Actions;
using Microsoft.AspNetCore.Http;

namespace AuthService.Core.Application.Interfaces;

public interface IFileService
{
    Task<DeletionResult> DeleteFileAsync(string publicId, ResourceType resourceType);
    Task<ImageUploadResult> UploadPhotoAsync(string folderPath, IFormFile file);
}
