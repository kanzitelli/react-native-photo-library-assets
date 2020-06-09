import { NativeModules, Platform } from 'react-native';

// "ph://.../L0/001": "/var/.../Documents/....jpg"
interface GetThumbnailsForAssetsResponse {
  [key: string]: string;
}

type GetImagesForAssetsResponse = string;

type PhotoLibraryAssetsType = {
  getThumbnailsForAssets(
    assetsIds: string[]
  ): Promise<GetThumbnailsForAssetsResponse>;
  getImagesForAssets(assetId: string): Promise<GetImagesForAssetsResponse>;
};

let RNPhotoLibraryAssets = {};

if (Platform.OS === 'ios') {
  RNPhotoLibraryAssets = NativeModules.RNPhotoLibraryAssets;
}

export default RNPhotoLibraryAssets as PhotoLibraryAssetsType;
