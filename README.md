# YRImagePicker
`YRImagePicker` is a simple wrapper around default UIKit image picker.

## Description

`YRImagePicker` encapsulates image picking using default `UIImagePickerController` saving your time to write default picking behaviour. 

## Installation

Simply drag&drop source into your project.

## Usage

To start picking image you need to write... 0 lines of code!
This requires a bit of setup in Interface Builder, but it's worth it.

![Usage example](/DemoImages/demo.gif)

1. Drag 'object' element into your view controller.
2. Set 'object' class to YRImagePicker
3. Navigate to connections tab of YRImagePicker and connect corresponding outlets.
4. Drag 'pickImageClicked:' action to button by which you want to instantiate image picking.

Or you can use following code snipper:

    [YRImagePicker startPickingFromViewController:self
                                      sourceTypes:kYRImagePickerSourceTypeAll
                                       completion:^(UIImage *pickedImage) {
                                           <#Your image view#>.image = pickedImage;
                                       }];


## Customization

You can prompt user to pick image from specific place as defined by `YRImagePickerSourceType`

    typedef enum {
        kYRImagePickerSourceTypeNone = 0,
        kYRImagePickerSourceTypeCamera = 1 << 0,
        kYRImagePickerSourceTypePhotoLibrary = 1 << 1,
        kYRImagePickerSourceTypeSavedPhotosAlbum = 1 << 2,
	
	    kYRImagePickerSourceTypeAll = 0x7,
	    kYRImagePickerSourceTypeTypesMask = kYRImagePickerSourceTypeAll
    } YRImagePickerSourceType;

## Version

v1.0.0