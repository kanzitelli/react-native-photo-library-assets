import { NativeModules } from 'react-native';

type PhotoLibraryAssetsType = {
  multiply(a: number, b: number): Promise<number>;
};

const { PhotoLibraryAssets } = NativeModules;

export default PhotoLibraryAssets as PhotoLibraryAssetsType;
