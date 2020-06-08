import { NativeModules, Platform } from 'react-native';

// "ph://.../L0/001": "/var/.../Documents/....jpg"
interface GetImagesForAssetsResponse {
  [key: string]: string;
}

type PhotoLibraryAssetsType = {
  getImagesForAssets(
    assetsIds: string[],
    isThumbnail: boolean
  ): Promise<GetImagesForAssetsResponse>;
};

let RNPhotoLibraryAssets = {};

if (Platform.OS === 'ios') {
  RNPhotoLibraryAssets = NativeModules.RNPhotoLibraryAssets;
}

export default RNPhotoLibraryAssets as PhotoLibraryAssetsType;
