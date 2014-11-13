//
//  CreateListViewController.m
//  Stockd
//
//  Created by Adam Duflo on 11/5/14.
//  Copyright (c) 2014 Amaeya Kalke. All rights reserved.
//

#import "CreateItemViewController.h"
#import "Item.h"
#import "Photo.h"

@interface CreateItemViewController ()
@property (weak, nonatomic) IBOutlet UITextField *itemDescriptionTextField;
@property (weak, nonatomic) IBOutlet UILabel *quickListLabel;
@property (weak, nonatomic) IBOutlet UISwitch *quickListSwitch;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation CreateItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.fromListDetails == YES) {
        self.quickListLabel.hidden = YES;
        self.quickListSwitch.hidden = YES;
        self.quickListSwitch.userInteractionEnabled = NO;
    } else if (self.fromInventory == YES) {
        [self.quickListSwitch setOn:NO];
        self.quickListLabel.hidden = NO;
        self.quickListSwitch.hidden = NO;
        self.quickListSwitch.userInteractionEnabled = YES;
    }
}

#pragma mark - IBActions

- (IBAction)addItemOnButtonPress:(id)sender {
    Item *item = [[Item alloc] init];
    PFUser *user = [PFUser currentUser];
    if ([self.itemDescriptionTextField.text isEqualToString:@""]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Missing Information" message:@"Please fill item description" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okay = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        }];
        
        [alert addAction:okay];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        if (self.fromInventory == YES) {
            [item createNewItemWithType:self.itemDescriptionTextField.text forUser:user inList:nil inInventory:YES isInQuickList:self.quickListSwitch.isOn];
        } else if (self.fromListDetails == YES) {
            [item createNewItemWithType:self.itemDescriptionTextField.text forUser:user inList:self.listID inInventory:NO isInQuickList:NO];
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)cancelItemCreationOnButtonPress:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)uploadPhotoOnButtonPress:(id)sender {
//    NSData *data = UIImagePNGRepresentation(self.imageView.image);
//    PFFile *imageFile = [PFFile fileWithData:data];
//    PFUser *currentUser = [PFUser currentUser];
//
//    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//        if(!error){
//            Photo *newPhotoObject = [Photo objectWithClassName: @"Photo"];
//            [newPhotoObject setObject:imageFile forKey:@"image"];
//
//            [newPhotoObject createPhotoObject: nil :currentUser];
//
//            [newPhotoObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//                if(error){
//                    NSLog(@"%@", error);
//                }
//                else{
//                    NSLog(@"Image Saved");
//                }
//            }];
//        }
//        else{
//            NSLog(@"%@", error);
//        }
//    }];
}

- (IBAction)setQuickListOnSwitch:(id)sender {

    if ([self.quickListSwitch isOn]) {
        [self.quickListSwitch setOn:YES animated:YES];
    } else {
        [self.quickListSwitch setOn:NO animated:YES];
    }
}

@end
