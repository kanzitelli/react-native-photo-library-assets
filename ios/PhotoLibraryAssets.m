#import "PhotoLibraryAssets.h"

#import <Photos/Photos.h>
#import "UIImage+Resize.h"

@implementation PhotoLibraryAssets

RCT_EXPORT_MODULE(RNPhotoLibraryAssets)

RCT_REMAP_METHOD(getThumbnailsForAssets,
                 withAssets:(nonnull NSArray<NSString *> *)assetsIds
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)
{
    __block NSMutableArray<NSString *> *_assetsIds = [NSMutableArray arrayWithArray:assetsIds];
    // removing ph:// from assets ids
    [assetsIds enumerateObjectsUsingBlock:^(NSString *str, NSUInteger index, BOOL *stop) {
        _assetsIds[index] = [str stringByReplacingOccurrencesOfString:@"ph://" withString:@""];
    }];

    PHFetchResult *assets = [PhotoLibraryAssets _getAssetsByIds:_assetsIds];
    
    if (assets) {
        __block NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithCapacity:[assetsIds count]];
        
        [assets enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL *stop) {
            if (asset.mediaType == PHAssetMediaTypeImage) {
                CGSize imageSize = CGSizeMake(300, 300);
                NSString *prefix = @"thumbnail";
                        
                // Getting thumbnail for asset
                UIImage *thumbnail = [PhotoLibraryAssets _getImageForAsset:asset withSize:imageSize];

                // Generating file path
                NSString *thumbnailFilename = [PhotoLibraryAssets _filePathForAsset:asset withPrefix:prefix];
                
                // Saving file
                [PhotoLibraryAssets _saveImage:thumbnail toFileName:thumbnailFilename];
                
                // Saving to data dictionary
                NSString *phAssetId = [NSString stringWithFormat:@"ph://%@", asset.localIdentifier];
                data[phAssetId] = [PhotoLibraryAssets _fullDocumentsDirPath:thumbnailFilename];
            }
        }];
        
        resolve(data);
    } else {
        reject(@"no assets", @"no assets", nil);
    }
}

RCT_REMAP_METHOD(getImageForAsset,
                 withAsset:(nonnull NSString *)assetId
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)
{
    NSString *_assetId = [assetId stringByReplacingOccurrencesOfString:@"ph://" withString:@""];
    PHAsset *asset = [PhotoLibraryAssets _getAssetById:_assetId];
    
    if (asset) {
        if (asset.mediaType == PHAssetMediaTypeImage) {
            NSString *prefix = @"image";

            // Generating file path
            NSString *imageFilename = [PhotoLibraryAssets _filePathForAsset:asset withPrefix:prefix];
            
            // Getting image for resizing
            PHContentEditingInputRequestOptions *options = [PHContentEditingInputRequestOptions new];
            options.networkAccessAllowed = YES;

            [asset requestContentEditingInputWithOptions:options
                                   completionHandler:^(PHContentEditingInput * _Nullable contentEditingInput, NSDictionary * _Nonnull info) {
                UIImage *image = contentEditingInput.displaySizeImage;

                CGFloat RNPLAImageQuality = 1.0 / sqrt(2.0);
                CGFloat RNPLAImageSize = 1024 * 512; // ~0.5MB

                NSData  *imageData    = UIImageJPEGRepresentation(image, RNPLAImageQuality);
                double   factor       = 1.0;
                double   adjustment   = RNPLAImageQuality;
                CGSize   size         = image.size;
                CGSize   currentSize  = size;
                UIImage *currentImage = image;
            
                while (imageData.length >= RNPLAImageSize)
                {
                    factor      *= adjustment;
                    currentSize  = CGSizeMake(roundf(size.width * factor), roundf(size.height * factor));
                    currentImage = [image resizedImage:currentSize interpolationQuality:RNPLAImageQuality];
                    imageData    = UIImageJPEGRepresentation(currentImage, RNPLAImageQuality);
                }
                
                // Saving image
                [PhotoLibraryAssets _saveImage:currentImage toFileName:imageFilename];
                
                resolve([PhotoLibraryAssets _fullDocumentsDirPath:imageFilename]);
            }];
        } else {
            reject(@"asset is not an image", @"asset is not an image", nil);
        }
    } else {
        reject(@"no assets", @"no assets", nil);
    }
}

+ (NSString *)_filePathForAsset:(PHAsset *)asset withPrefix:(NSString *)prefix
{
    NSString *localIdWithoutPh = [asset.localIdentifier stringByReplacingOccurrencesOfString:@"ph://" withString:@""];
    NSString *assetLocalId = [[localIdWithoutPh componentsSeparatedByString:@"/"] firstObject]; // removes characters /L0/001
    return [NSString stringWithFormat:@"%@_%@.JPG", prefix, assetLocalId];
}

+ (NSString *)_fullDocumentsDirPath:(NSString *)forFilename
{
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    return [NSString stringWithFormat:@"%@/%@", documentsDirectory, forFilename];
}

+ (UIImage *)_getImageForAsset:(PHAsset *)asset withSize:(CGSize)size
{
    PHImageManager *phManager = [PHImageManager defaultManager];
    __block UIImage *img;
    
    // Requesting image for asset
    PHImageRequestOptions *requestOptions = [PHImageRequestOptions new];
    requestOptions.synchronous = YES;

    [phManager requestImageForAsset:asset
                         targetSize:size
                        contentMode:PHImageContentModeAspectFill
                            options:requestOptions
                      resultHandler:^void(UIImage *image, NSDictionary *info) {
        img = image;
    }];
    
    return img;
}

+ (BOOL)_saveImage:(UIImage *)image toFileName:(NSString *)fileName
{
    NSError *error;
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSArray<NSString *> *directoryFiles = [fileMgr contentsOfDirectoryAtPath:documentsDirectory error:&error];
    
    if (error == nil && ![directoryFiles containsObject:fileName]) {
        NSString *imageUri = [documentsDirectory stringByAppendingPathComponent:fileName];
        NSData *imageData = UIImageJPEGRepresentation(image, 1.0 / sqrt(2.0));
    
        [imageData writeToFile:imageUri atomically:YES];
        
        return YES;
    }
    
    return NO;
}

+ (PHFetchResult *)_getAssetsByIds:(NSArray<NSString *> *)assetIds
{
    PHFetchOptions *options = [PHFetchOptions new];
    options.includeHiddenAssets = YES;
    options.includeAllBurstAssets = YES;
    options.includeAssetSourceTypes = PHAssetMediaTypeImage;
    options.fetchLimit = assetIds.count;
    return [PHAsset fetchAssetsWithLocalIdentifiers:assetIds options:options];
}

+ (PHAsset *)_getAssetById:(NSString *)assetId
{
    if (assetId) {
        return [PhotoLibraryAssets _getAssetsByIds:@[assetId]].firstObject;
        
    }
    
    return nil;
}

@end
