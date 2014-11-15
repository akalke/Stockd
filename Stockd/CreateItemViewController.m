//
//  CreateListViewController.m
//  Stockd
//
//  Created by Adam Duflo on 11/5/14.
//  Copyright (c) 2014 Amaeya Kalke. All rights reserved.
//

#import "CreateItemViewController.h"
#import "CameraViewController.h"

@interface CreateItemViewController ()
@property (weak, nonatomic) IBOutlet UITextField *itemDescriptionTextField;
@property (weak, nonatomic) IBOutlet UILabel *quickListLabel;
@property (weak, nonatomic) IBOutlet UISwitch *quickListSwitch;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation CreateItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    PFFile *image = [self.item objectForKey:@"image"];
    [image getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
        } else {
            self.imageView.image = [UIImage imageWithData:data];
        }
    }];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.fromListDetails == YES) {
        [self hideQuickListObjects];
    } else if (self.fromInventory == YES) {
        [self.quickListSwitch setOn:NO];
        [self showQuickListObjects];
    } else if (self.editingFromInventory == YES) {
        if (self.item.isInQuickList == YES) {
            [self.quickListSwitch setOn:YES];
        } else {
            [self.quickListSwitch setOn:NO];
        }
        [self showQuickListObjects];
        self.quickListLabel.text = @"In Quick List";
        self.itemDescriptionTextField.text = self.item.type;
    } else if (self.editingFromListDetails == YES) {
        [self hideQuickListObjects];
        self.itemDescriptionTextField.text = self.item.type;
    }
}

#pragma mark - Helper Methods

- (void)hideQuickListObjects {
    self.quickListLabel.hidden = YES;
    self.quickListSwitch.hidden = YES;
    self.quickListSwitch.userInteractionEnabled = NO;
}

- (void)showQuickListObjects {
    self.quickListLabel.hidden = NO;
    self.quickListSwitch.hidden = NO;
    self.quickListSwitch.userInteractionEnabled = YES;
}

- (void)noDescriptionAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Missing Information" message:@"Please fill item description" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okay = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
    }];
    
    [alert addAction:okay];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)dismissViewControllerAndResetBOOLs {
    [self dismissViewControllerAnimated:YES completion:^{
        self.fromInventory = NO;
        self.fromListDetails = NO;
        self.editingFromInventory = NO;
        self.editingFromListDetails = NO;
    }];
}

#pragma mark - IBActions

- (IBAction)addItemOnButtonPress:(id)sender {
    PFUser *user = [PFUser currentUser];
    if (self.fromInventory || self.fromListDetails) {
        Item *item = [[Item alloc] init];
        if ([self.itemDescriptionTextField.text isEqualToString:@""]) {
            [self noDescriptionAlert];
        } else {
            if (self.fromInventory == YES) {
                [item createNewItem:self.itemDescriptionTextField.text forUser:user inList:nil inInventory:YES isInQuickList:self.quickListSwitch.isOn withImage:self.imageView.image withBlock:^{
                    [self dismissViewControllerAndResetBOOLs];
                }];
            } else if (self.fromListDetails == YES) {
                [item createNewItem:self.itemDescriptionTextField.text forUser:user inList:self.listID inInventory:NO isInQuickList:NO withImage:self.imageView.image withBlock:^{
                    [self dismissViewControllerAndResetBOOLs];
                }];
            }
        }
    } else if (self.editingFromInventory || self.editingFromListDetails) {
        if ([self.itemDescriptionTextField.text isEqualToString:@""]) {
            [self noDescriptionAlert];
        } else {
            if (self.imageView.image) {
                if (self.editingFromInventory) {
                    [self.item setObject:[NSNumber numberWithBool:self.quickListSwitch.isOn] forKey:@"isInQuickList"];
                }
                [self.item setObject:self.itemDescriptionTextField.text forKey:@"type"];
                
                NSData *data = UIImagePNGRepresentation(self.imageView.image);
                PFFile *imageFile = [PFFile fileWithData:data];
                [self.item setObject:imageFile forKey:@"image"];
                
                [self.item saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (error) {
                        NSLog(@"%@", error);
                    } else if (succeeded) {
                        [self dismissViewControllerAndResetBOOLs];
                    }
                }];
            } else {
                if (self.editingFromInventory) {
                    [self.item setObject:[NSNumber numberWithBool:self.quickListSwitch.isOn] forKey:@"isInQuickList"];
                }
                [self.item setObject:self.itemDescriptionTextField.text forKey:@"type"];
                
                [self.item saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (error) {
                        NSLog(@"%@", error);
                    } else if (succeeded) {
                        [self dismissViewControllerAndResetBOOLs];
                    }
                }];
            }
        }
    }
}

- (IBAction)cancelItemCreationOnButtonPress:(id)sender {
    self.quickListLabel.text = @"Add to Quick List?";
    [self dismissViewControllerAndResetBOOLs];
}

- (IBAction)uploadPhotoOnButtonPress:(id)sender {
    
}

- (IBAction)setQuickListOnSwitch:(id)sender {
    
    if ([self.quickListSwitch isOn]) {
        [self.quickListSwitch setOn:YES animated:YES];
    } else {
        [self.quickListSwitch setOn:NO animated:YES];
    }
}

-(IBAction)unwindFromCameraSegue:(UIStoryboardSegue *)segue{
    CameraViewController *cameraVC = segue.sourceViewController;
    self.imageView.image = cameraVC.imageView.image;
}

@end
