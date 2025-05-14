using CloudinaryDotNet.Actions;
using Microsoft.AspNetCore.Http;

namespace PostService.Application.Interfaces;

public interface IFileService
{
    Task<DeletionResult> DeleteFileAsync(string publicId, ResourceType resourceType);
    Task<ImageUploadResult> UploadPhotoAsync(string folderPath, IFormFile file);
    Task<VideoUploadResult> UploadVideoAsync(string folderPath, IFormFile file);
}
