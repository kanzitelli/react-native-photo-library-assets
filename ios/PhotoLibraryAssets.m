#import "PhotoLibraryAssets.h"

#import <Photos/Photos.h>

@implementation PhotoLibraryAssets

RCT_EXPORT_MODULE(RNPhotoLibraryAssets)

RCT_REMAP_METHOD(getImagesForAssets,
                 withAssets:(nonnull NSArray<NSString *> *)assetsIds
                 withIsThumbnail:(nonnull BOOL*)isThumbnail
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
                CGSize imageSize = CGSizeMake(750, 750);
                NSString *imagePrefix = @"image";
                
                if (isThumbnail) {
                    imageSize = CGSizeMake(250, 250);
                    imagePrefix = @"thumbnail";
                }
                        
                // Getting thumbnail for asset
                UIImage *thumbnail = [PhotoLibraryAssets _getImageForAsset:asset withSize:imageSize];

                // Generating file path
                NSString *localIdWithoutPh = [asset.localIdentifier stringByReplacingOccurrencesOfString:@"ph://" withString:@""];
                NSLog(@"%@ -- %@", localIdWithoutPh, asset.localIdentifier);
                NSString *assetLocalId = [[localIdWithoutPh componentsSeparatedByString:@"/"] firstObject]; // removes characters /L0/001
                NSString *thumbnailFilename = [NSString stringWithFormat:@"%@_%@.JPG", imagePrefix, assetLocalId];
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
