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

## License

MIT
