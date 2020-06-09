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
const thumbnails = await RNPhotoLibraryAssets.getThumbnailsForAssets(assetsIds);
/*
all images are around 300x300 and compressed

response: { [key: string]: string }
{
    '6065FBB8-AD2C-4EDE-B80B-E2193BC229F9/L0/001': '/var/.../Documents/thumbnail_6065FBB8-AD2C-4EDE-B80B-E2193BC229F9.JPG,
    'ph://83489525-944D-42A8-9896-E9753EA03633/L0/001': '/var/.../Documents/thumbnail_83489525-944D-42A8-9896-E9753EA03633/L0/001.JPG,
}
*/

const imageUri = await RNPhotoLibraryAssets.getImageForAsset(assetsIds[0]);
/*
generated image is going to be around 100kb and image is resized with
interpolation quality so it should be good enough to be uploaded
to a server (e.g. chat photos)

response: string
'/var/.../Documents/thumbnail_6065FBB8-AD2C-4EDE-B80B-E2193BC229F9.JPG'
*/
```

## Todos
🔳 Rewrite logic of image generation for uploading to a server

⬜️ index.d.ts

⬜️ Move all logic of gathering photo library assets to this library, so there would be only one request to native side instead of getting assets first and then send request to this library

⬜️ Examples using Image and FastImage

⬜️ Show benchmarks

⬜️ Put more details of how the library works

⬜️ 1.0 version must be a full replacement of react-native-community/react-native-image-picker library. It should be fully React Native Photos Library implementation with full customization and multiple select


## License

MIT
