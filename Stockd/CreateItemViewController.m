//
//  CreateListViewController.m
//  Stockd
//
//  Created by Adam Duflo on 11/5/14.
//  Copyright (c) 2014 Amaeya Kalke. All rights reserved.
//

#define stockdBlueColor [UIColor colorWithRed:32.0/255.0 green:59.0/255.0 blue:115.0/255.0 alpha:1.0]
#define stockdOrangeColor [UIColor colorWithRed:217.0/255.0 green:126.0/255.0 blue:0.0/255.0 alpha:1.0]

#import "CreateItemViewController.h"
#import "CameraViewController.h"

@interface CreateItemViewController () <UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *itemDescriptionTextField;
@property (weak, nonatomic) IBOutlet UILabel *quickListLabel;
@property (weak, nonatomic) IBOutlet UISwitch *quickListSwitch;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation CreateItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignKeyboardOnTap:)];
    [self.view addGestureRecognizer:tapGesture];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.barTintColor = stockdBlueColor;
    self.navigationController.navigationBar.tintColor = stockdOrangeColor;
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName:[UIFont fontWithName:@"Arial-BoldMT" size:18.0f],NSForegroundColorAttributeName:[UIColor whiteColor]};
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlackTranslucent];
    
    PFFile *image = [self.item objectForKey:@"image"];
    [image getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (error) {
            NSLog(@"Error Getting Image: %@", error);
        } else {
            self.imageView.image = [UIImage imageWithData:data];
        }
    }];
    
    if (self.fromListDetails == YES || self.fromMyPantry == YES) {
        self.title = @"Create Item";
        if (self.fromListDetails == YES) {
            [self hideQuickListObjects];
        } else if (self.fromMyPantry == YES) {
            [self.quickListSwitch setOn:NO];
            [self showQuickListObjects];
        }
    } else if (self.editingFromListDetails == YES || self.editingFromMyPantry == YES) {
        self.title = @"Edit Item";
        if (self.editingFromMyPantry == YES) {
            if (self.item.isInQuickList == YES) {
                [self.quickListSwitch setOn:YES];
            } else {
                [self.quickListSwitch setOn:NO];
            }
            [self showQuickListObjects];
            self.itemDescriptionTextField.text = self.item.type;
        } else if (self.editingFromListDetails == YES) {
            [self hideQuickListObjects];
            self.itemDescriptionTextField.text = self.item.type;
        }
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

- (void)resignKeyboardOnTap:(UITapGestureRecognizer *)sender {
    [self.itemDescriptionTextField resignFirstResponder];
}

- (void)noDescriptionAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Missing Information" message:@"Please fill item description" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okay = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
    }];
    
    [alert addAction:okay];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)dismissViewControllerAndResetBOOLs {
    [self.navigationController popViewControllerAnimated:YES];
    self.fromMyPantry = NO;
    self.fromListDetails = NO;
    self.editingFromMyPantry = NO;
    self.editingFromListDetails = NO;
}

#pragma mark - IBActions

- (IBAction)addItemOnButtonPress:(id)sender {
    PFUser *user = [PFUser currentUser];
    if (self.fromMyPantry || self.fromListDetails) {
        Item *item = [[Item alloc] init];
        if ([self.itemDescriptionTextField.text isEqualToString:@""]) {
            [self noDescriptionAlert];
        } else {
            if (self.fromMyPantry == YES) {
                [item createNewItem:self.itemDescriptionTextField.text forUser:user inList:nil inInventory:YES isInQuickList:self.quickListSwitch.isOn withImage:self.imageView.image withBlock:^{
                    [self dismissViewControllerAndResetBOOLs];
                }];
            } else if (self.fromListDetails == YES) {
                [item createNewItem:self.itemDescriptionTextField.text forUser:user inList:self.listID inInventory:NO isInQuickList:NO withImage:self.imageView.image withBlock:^{
                    [self dismissViewControllerAndResetBOOLs];
                }];
            }
        }
    } else if (self.editingFromMyPantry || self.editingFromListDetails) {
        if ([self.itemDescriptionTextField.text isEqualToString:@""]) {
            [self noDescriptionAlert];
        } else {
            if (self.imageView.image) {
                if (self.editingFromMyPantry) {
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
                if (self.editingFromMyPantry) {
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
    [self.itemDescriptionTextField resignFirstResponder];
    
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
