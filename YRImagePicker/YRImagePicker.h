//
//  YRImagePicker.h
//  MyKitTestProject
//
//  Created by Yuriy Romanchenko on 10/6/14.
//  Copyright (c) 2014 solomidSF. All rights reserved.
//

@import UIKit;

typedef void (^YRImagePickerCompletionBlock) (UIImage *pickedImage);

typedef enum {
    kYRImagePickerSourceTypeNone = 0,
    kYRImagePickerSourceTypeCamera = 1 << 0,
    kYRImagePickerSourceTypePhotoLibrary = 1 << 1,
    kYRImagePickerSourceTypeSavedPhotosAlbum = 1 << 2,
	
	kYRImagePickerSourceTypeAll = 0x7,
	kYRImagePickerSourceTypeTypesMask = kYRImagePickerSourceTypeAll
} YRImagePickerSourceType;

/**
 *  Simple image picker that encapsulates image picking from camera/photo library.
 */
@interface YRImagePicker : NSObject

+ (void)startPickingFromViewController:(UIViewController *)controller
                           sourceTypes:(YRImagePickerSourceType)type
                            completion:(YRImagePickerCompletionBlock)completion;

- (void)startPickingFromViewController:(UIViewController *)controller
                           sourceTypes:(YRImagePickerSourceType)type
                            completion:(YRImagePickerCompletionBlock)completion;

@end
