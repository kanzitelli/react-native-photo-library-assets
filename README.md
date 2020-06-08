# react-native-photo-library-assets

RNPhotoLibraryAssets helps to get access to iOS photo library assets (full path to compressed .jpg or .png) and generates thumbnails or images which are ready to be uploaded to your server.

## Installation

```sh
yarn add react-native-photo-library-assets
```

## Usage

```js
import RNPhotoLibraryAssets from "react-native-photo-library-assets";

// ...

// assets ph://... can be gathered from react-native-community/cameraroll
const assetsIds = [
    '6065FBB8-AD2C-4EDE-B80B-E2193BC229F9/L0/001',
    'ph://83489525-944D-42A8-9896-E9753EA03633/L0/001',
];
const isThumbnail = true;
const result = await RNPhotoLibraryAssets.getImagesForAssets(assetsIds, isThumbnail);

/*
result: {
    '6065FBB8-AD2C-4EDE-B80B-E2193BC229F9/L0/001': '/var/.../Documents/thumbnail_6065FBB8-AD2C-4EDE-B80B-E2193BC229F9.JPG,
    'ph://83489525-944D-42A8-9896-E9753EA03633/L0/001': '/var/.../Documents/thumbnail_83489525-944D-42A8-9896-E9753EA03633/L0/001.JPG,
}
*/
```

## Todos
1. Move all logic of gathering photo library assets to this library, so there would be only one request to native side instead of getting assets first and then send request to this library.
2. Examples using Image and FastImage.
3. Show benchmarks
4. Put more details of how the library works
5. 1.0 version must be a full replacement of react-native-community/react-native-image-picker library. It should be fully React Native Photos Library implementation with full customization and multiple select.

## License

MIT
