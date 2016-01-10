//
// YRImagePicker.m
//
// The MIT License (MIT)
//
// Copyright (c) 2015 Yuri R.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

// Components
#import "YRImagePicker.h"

// Other
#import <objc/runtime.h>

static const void *kYRImagePickerDummyKey = &kYRImagePickerDummyKey;

@interface YRImagePicker ()
<
UIActionSheetDelegate,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate
>
@end

@interface YRImagePicker ()
@property (nonatomic, weak) IBOutlet UIViewController *owner;
@property (nonatomic, weak) IBOutlet UIImageView *destinationImageView;
@end

@implementation YRImagePicker {
    UIViewController __weak *_presenterController;
    YRImagePickerCompletionBlock _completionBlock;
    YRImagePickerSourceType _currentSourceTypes;
    
    BOOL _isPicking;
}

#pragma mark - Public

+ (void)startPickingFromViewController:(UIViewController *)controller
                           sourceTypes:(YRImagePickerSourceType)types
                            completion:(YRImagePickerCompletionBlock)completion {
    types = [self filterSourceTypesByAvailability:types];
    
    if (types == kYRImagePickerSourceTypeNone) {
        return;
    }
    
    YRImagePicker *picker = objc_getAssociatedObject(controller,
                                                     kYRImagePickerDummyKey);
    
    if (!picker) {
        picker = [self new];
    }
    
    [picker startPickingFromViewController:controller sourceTypes:types completion:completion];
}

- (void)startPickingFromViewController:(UIViewController *)controller
                           sourceTypes:(YRImagePickerSourceType)types
                            completion:(YRImagePickerCompletionBlock)completion {
    if (!_isPicking) {
        NSAssert(controller, @"[YRImagePicker]: Can't pick from nil controller.");
        
        // Retain current instance while picking stuff.
        objc_setAssociatedObject(controller, kYRImagePickerDummyKey, self, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        _presenterController = controller;
        _completionBlock = completion;
        _currentSourceTypes = types;
        _isPicking = YES;
        
        UIAlertController *sheetController = [self sheetForSourceTypes:types];
        
        if (sheetController) {
            [controller presentViewController:sheetController animated:YES completion:NULL];
        } else {
            [self presentImagePickerWithSourceType:[[self class] pickerSourceTypeFromYRSourceType:types]];
        }
    } else {
        NSLog(@"[YRImagePicker]: Can't start picking, because already picking from %@ controller", controller);
    }
}

#pragma mark - IBActions

- (IBAction)pickImageClicked:(id)sender {
    NSAssert(self.owner, @"[YRImagePicker]: Couldn't find YRImagePicker owner (kindof UIViewController), probably you forgot to set it in storyboard/xib?");
    NSAssert(self.destinationImageView, @"[YRImagePicker]: Couldn't find destination image view.");
    
    YRImagePickerSourceType resultingTypes = kYRImagePickerSourceTypeNone;
    
    if (_currentSourceTypes == kYRImagePickerSourceTypeNone) {
        resultingTypes = [[self class] filterSourceTypesByAvailability:kYRImagePickerSourceTypeAll];
    } else {
        resultingTypes = [[self class] filterSourceTypesByAvailability:_currentSourceTypes];
    }
    
    if (resultingTypes != kYRImagePickerSourceTypeNone) {
        [self startPickingFromViewController:self.owner
                                 sourceTypes:resultingTypes
                                  completion:^(UIImage *pickedImage) {
                                      _destinationImageView.image = pickedImage;
                                  }];
    }
}

#pragma mark - Private

+ (YRImagePickerSourceType)filterSourceTypesByAvailability:(YRImagePickerSourceType)types {
    // First of all check if we have at least one type.
    NSAssert(types & kYRImagePickerSourceTypeTypesMask, @"[YRImagePicker]: You must specify source type for picking.");

    if (types & kYRImagePickerSourceTypeCamera) {
        if (![UIImagePickerController isSourceTypeAvailable:[self pickerSourceTypeFromYRSourceType:kYRImagePickerSourceTypeCamera]]) {
            types &= ~kYRImagePickerSourceTypeCamera;
        }
    }
    
    if (types & kYRImagePickerSourceTypePhotoLibrary) {
        if (![UIImagePickerController isSourceTypeAvailable:[self pickerSourceTypeFromYRSourceType:kYRImagePickerSourceTypePhotoLibrary]]) {
            types &= ~kYRImagePickerSourceTypePhotoLibrary;
        }
    }
    
    if (types & kYRImagePickerSourceTypeSavedPhotosAlbum) {
        if (![UIImagePickerController isSourceTypeAvailable:[self pickerSourceTypeFromYRSourceType:kYRImagePickerSourceTypeSavedPhotosAlbum]]) {
            types &= ~kYRImagePickerSourceTypeSavedPhotosAlbum;
        }
    }
    
    return types;
}

- (UIAlertController *)sheetForSourceTypes:(YRImagePickerSourceType)types {
    NSArray *readableTypes = [self readableSourceTypesFromSourceTypesEnumeration:types];
    NSArray *sourceTypes = [self separatedSourceTypesFromType:types];
    
    if (readableTypes.count > 1) {
		UIAlertController *resultingController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Pick from where?", @"")
																					 message:nil
																			  preferredStyle:UIAlertControllerStyleActionSheet];
		
		[resultingController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"")
																style:UIAlertActionStyleCancel
															  handler:^(UIAlertAction *action) {
																  _isPicking = NO;
																  _completionBlock = NULL;
																  _currentSourceTypes = 0;
																  
																  objc_setAssociatedObject(_presenterController,
																						   kYRImagePickerDummyKey,
																						   nil,
																						   OBJC_ASSOCIATION_RETAIN_NONATOMIC);
															  }]];
		
		[readableTypes enumerateObjectsUsingBlock:^(NSString *readableType, NSUInteger idx, BOOL *stop) {
			void (^sheetAction)(UIAlertAction *action) = ^(UIAlertAction *action) {
				YRImagePickerSourceType pickedType = (YRImagePickerSourceType)[sourceTypes[idx] intValue];
				
				[self presentImagePickerWithSourceType:[[self class] pickerSourceTypeFromYRSourceType:pickedType]];
			};
			
			UIAlertAction *action = [UIAlertAction actionWithTitle:readableType
															 style:UIAlertActionStyleDefault
														   handler:sheetAction];
			
			[resultingController addAction:action];
		}];
		
        return resultingController;
    } else {
        // There is no need to create action sheet - only one source type specified.
        return nil;
    }
}

- (NSArray *)readableSourceTypesFromSourceTypesEnumeration:(YRImagePickerSourceType)types {
    NSMutableArray *resultingSourceTypes = [NSMutableArray new];
    
    if (types & kYRImagePickerSourceTypeCamera) {
        [resultingSourceTypes addObject:@"Camera"];
    }
    
    if (types & kYRImagePickerSourceTypePhotoLibrary) {
        [resultingSourceTypes addObject:@"Photo Library"];
    }
    
    if (types & kYRImagePickerSourceTypeSavedPhotosAlbum) {
        [resultingSourceTypes addObject:@"Saved Photos Album"];
    }
    
    return [NSArray arrayWithArray:resultingSourceTypes];
}

- (void)presentImagePickerWithSourceType:(UIImagePickerControllerSourceType)type {
    UIImagePickerController *pickerController = [UIImagePickerController new];
    
    pickerController.delegate = self;
    pickerController.sourceType = type;
    
    [_presenterController presentViewController:pickerController
                                       animated:YES
                                     completion:NULL];
}

- (NSArray *)separatedSourceTypesFromType:(YRImagePickerSourceType)types {
    NSMutableArray *resultingSourceTypes = [NSMutableArray new];
    
    if (types & kYRImagePickerSourceTypeCamera) {
        [resultingSourceTypes addObject:@(kYRImagePickerSourceTypeCamera)];
    }
    
    if (types & kYRImagePickerSourceTypePhotoLibrary) {
        [resultingSourceTypes addObject:@(kYRImagePickerSourceTypePhotoLibrary)];
    }
    
    if (types & kYRImagePickerSourceTypeSavedPhotosAlbum) {
        [resultingSourceTypes addObject:@(kYRImagePickerSourceTypeSavedPhotosAlbum)];
    }

    return [NSArray arrayWithArray:resultingSourceTypes];
}

+ (UIImagePickerControllerSourceType)pickerSourceTypeFromYRSourceType:(YRImagePickerSourceType)type {
    if (type & kYRImagePickerSourceTypeCamera) {
        return UIImagePickerControllerSourceTypeCamera;
    } else if (type & kYRImagePickerSourceTypePhotoLibrary) {
        return UIImagePickerControllerSourceTypePhotoLibrary;
    } else if (type & kYRImagePickerSourceTypeSavedPhotosAlbum) {
        return UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    } else {
        NSAssert(NO, @"Couldn't transform YRImagePickerSourceType to UIImagePickerControllerSourceType!");
        return NSNotFound;
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    _isPicking = NO;
    _completionBlock = NULL;
    _currentSourceTypes = kYRImagePickerSourceTypeNone;
    
    [picker dismissViewControllerAnimated:YES
                               completion:^{
                                   // Remove strong reference from controller to current instance.
                                   objc_setAssociatedObject(_presenterController,
                                                            kYRImagePickerDummyKey,
                                                            nil,
                                                            OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                               }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES
                               completion:^{
                                   !_completionBlock ? : _completionBlock(info[UIImagePickerControllerOriginalImage]);
                                   _isPicking = NO;
                                   _completionBlock = NULL;
                                   _currentSourceTypes = kYRImagePickerSourceTypeNone;
                                   
                                   // Remove strong reference from controller to current instance.
                                   objc_setAssociatedObject(_presenterController,
                                                            kYRImagePickerDummyKey,
                                                            nil,
                                                            OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                               }];
}

@end
