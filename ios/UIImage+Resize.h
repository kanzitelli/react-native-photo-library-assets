//
//  UIImage+Resize.h
//  PhotoLibraryAssets
//
//  Created by Batyr Kanzitdinov on 09.06.2020.
//  Taken from here -- http://vocaro.com/trevor/blog/wp-content/uploads/2009/10/UIImage+Resize.h
//  Copyright © 2020 Facebook. All rights reserved.
//

@interface UIImage (Resize)
- (UIImage *)resizedImage:(CGSize)newSize
     interpolationQuality:(CGInterpolationQuality)quality;
@end
