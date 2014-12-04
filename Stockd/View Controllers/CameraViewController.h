//
//  CameraViewController.h
//  Stockd
//
//  Created by Amaeya Kalke on 11/13/14.
//  Copyright (c) 2014 Amaeya Kalke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface CameraViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *imageView;

- (IBAction)takePhoto:(id)sender;
- (IBAction)selectPhoto:(id)sender;

@end
