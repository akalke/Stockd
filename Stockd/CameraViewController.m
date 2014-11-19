//
//  CameraViewController.m
//  Stockd
//
//  Created by Amaeya Kalke on 11/13/14.
//  Copyright (c) 2014 Amaeya Kalke. All rights reserved.
//

#define peachBackground [UIColor colorWithRed:255.0/255.0 green:223.0/255.0 blue:181.0/255.0 alpha:1.0]
#define navBarColor [UIColor colorWithRed:231.0/255.0 green:95.0/255.0 blue:73.0/255.0 alpha:1.0]
#define turqouise [UIColor colorWithRed:0.0/255.0 green:191.0/255.0 blue:255.0/255.0 alpha:0.80]

#import "CameraViewController.h"

@interface CameraViewController ()
@end

@implementation CameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Conditional to check if device has a camera
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"No Camera Detected!" message:@"Skip step 1." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            return;
        }];
        
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // Making sure navbar properties are set when screen is selected
    self.navigationController.navigationBar.barTintColor = navBarColor;
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName:[UIFont fontWithName:@"Avenir" size:18.0f],NSForegroundColorAttributeName:[UIColor blackColor]};
    [self.navigationController.navigationBar setBarStyle:UIBarStyleDefault];
}

#pragma mark - ImagePicker Methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.imageView.image = chosenImage;
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

#pragma mark - IBActions

- (IBAction)takePhoto:(id)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;

    [self presentViewController:picker animated:YES completion:NULL];
}

- (IBAction)selectPhoto:(id)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;

    [self presentViewController:picker animated:YES completion:NULL];
}

@end
