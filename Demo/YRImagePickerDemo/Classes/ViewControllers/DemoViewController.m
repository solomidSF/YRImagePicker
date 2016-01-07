//
//  ViewController.m
//  YRImagePickerDemo
//
//  Created by Yuriy Romanchenko on 1/7/16.
//  Copyright © 2016 solomidSF. All rights reserved.
//

// Controllers
#import "DemoViewController.h"

// Components
#import "YRImagePicker.h"

@interface DemoViewController ()

@end

@implementation DemoViewController {
    __weak IBOutlet UIImageView *_pickedImageImageView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)pickImageClicked:(id)sender {
    [YRImagePicker startPickingFromViewController:self
                                      sourceTypes:kYRImagePickerSourceTypeAll
                                       completion:^(UIImage *pickedImage) {
                                           _pickedImageImageView.image = pickedImage;
                                       }];
}

@end
