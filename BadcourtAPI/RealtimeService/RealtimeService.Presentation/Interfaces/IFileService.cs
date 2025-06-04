using CloudinaryDotNet.Actions;

namespace RealtimeService.Presentation.Interfaces;

public interface IFileService
{
    Task<DeletionResult> DeleteFileAsync(string publicId, ResourceType resourceType);
    Task<ImageUploadResult> UploadPhotoAsync(string folderPath, IFormFile file);
    Task<VideoUploadResult> UploadVideoAsync(string folderPath, IFormFile file);
}
