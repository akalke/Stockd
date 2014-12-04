//
//  CreateListViewController.m
//  Stockd
//
//  Created by Adam Duflo on 11/5/14.
//  Copyright (c) 2014 Amaeya Kalke. All rights reserved.
//

#define peachBackground [UIColor colorWithRed:255.0/255.0 green:223.0/255.0 blue:181.0/255.0 alpha:1.0]
#define navBarColor [UIColor colorWithRed:231.0/255.0 green:95.0/255.0 blue:73.0/255.0 alpha:1.0]
#define turqouise [UIColor colorWithRed:0.0/255.0 green:191.0/255.0 blue:255.0/255.0 alpha:0.80]

#import "CreateItemViewController.h"
#import "CameraViewController.h"

@interface CreateItemViewController () <UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *itemDescriptionTextField;
@property (weak, nonatomic) IBOutlet UILabel *quickListLabel;
@property (weak, nonatomic) IBOutlet UISwitch *quickListSwitch;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIView *quickListView;

@end

@implementation CreateItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavBarDisplay];
    [self setTapGesture];
    
    self.view.backgroundColor = peachBackground;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setViewContent];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.itemDescriptionTextField resignFirstResponder];
}

#pragma mark - Helper Methods

- (void)setTapGesture {
    // Setting up tap gesture to hide keyboard
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignKeyboardOnTap:)];
    [tapGesture setNumberOfTapsRequired:1];
    [tapGesture setNumberOfTouchesRequired:1];
    [self.view addGestureRecognizer:tapGesture];
}

- (void)setNavBarDisplay {
    // Setting navigation bar properties
    self.navigationController.navigationBar.barTintColor = navBarColor;
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName:[UIFont fontWithName:@"Avenir" size:18.0f],NSForegroundColorAttributeName:[UIColor blackColor]};
    [self.navigationController.navigationBar setBarStyle:UIBarStyleDefault];
}

- (void) setViewContent {
    // Getting image for item if item already has image
    PFFile *image = [self.item objectForKey:@"image"];
    [image getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (error) {
            NSLog(@"Error Getting Image: %@", error);
        } else {
            self.imageView.image = [UIImage imageWithData:data];
        }
    }];
    
    // Conditionals to show certain elements if previous VC
    // was from MyPantry or ListDetail and if the user is editing or creating
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
            if (self.item.isInQuickList == NO) {
                [self hideQuickListObjects];
            }
            self.itemDescriptionTextField.text = self.item.type;
        }
    }
}

// Method used to hide QuickList view
- (void)hideQuickListObjects {
    self.quickListLabel.hidden = YES;
    self.quickListSwitch.hidden = YES;
    self.quickListView.hidden = YES;
    self.quickListSwitch.userInteractionEnabled = NO;
}


// Method use to show QuickList view
- (void)showQuickListObjects {
    self.quickListLabel.hidden = NO;
    self.quickListSwitch.hidden = NO;
    self.quickListSwitch.userInteractionEnabled = YES;
}

// Method used by tapGesture to hide keyboard
- (void)resignKeyboardOnTap:(UITapGestureRecognizer *)sender {
    [self.itemDescriptionTextField resignFirstResponder];
}

// Method that presents alert if item description is empty when
// user tries to create item
- (void)noDescriptionAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Cannot Save!" message:@"Please enter an item description." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okay = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
    }];
    
    [alert addAction:okay];
    [self presentViewController:alert animated:YES completion:nil];
}

// Method that popsVC and resets bools used to know
// what previous VC was
- (void)popViewControllerAndResetBOOLs {
    [self.navigationController popViewControllerAnimated:YES];
    self.fromMyPantry = NO;
    self.fromListDetails = NO;
    self.editingFromMyPantry = NO;
    self.editingFromListDetails = NO;
}

#pragma mark - IBActions

- (IBAction)addItemOnButtonPress:(id)sender {
    PFUser *user = [PFUser currentUser];
    // Conditional for if previous VC was from MyPantry or ListDetails & creating item
    if (self.fromMyPantry || self.fromListDetails) {
        Item *item = [[Item alloc] init];
        if ([self.itemDescriptionTextField.text isEqualToString:@""]) {
            [self noDescriptionAlert];
        } else {
            if (self.fromMyPantry == YES) {
                [item createNewItem:self.itemDescriptionTextField.text forUser:user inList:nil inPantry:YES isInQuickList:self.quickListSwitch.isOn withImage:self.imageView.image withBlock:^{
                    [self popViewControllerAndResetBOOLs];
                }];
            } else if (self.fromListDetails == YES) {
                [item createNewItem:self.itemDescriptionTextField.text forUser:user inList:self.listID inPantry:NO isInQuickList:NO withImage:self.imageView.image withBlock:^{
                    [self popViewControllerAndResetBOOLs];
                }];
            }
        }
        
    // Conditional for if previous VC was from MyPantry or ListDetails & editing item
    } else if (self.editingFromMyPantry || self.editingFromListDetails) {
        if ([self.itemDescriptionTextField.text isEqualToString:@""]) {
            [self noDescriptionAlert];
        } else {
            // Conditional for if the user is adding an image
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
                        [self popViewControllerAndResetBOOLs];
                    }
                }];
                
            // Conditional for if the user didn't add an image
            } else {
                if (self.editingFromMyPantry) {
                    [self.item setObject:[NSNumber numberWithBool:self.quickListSwitch.isOn] forKey:@"isInQuickList"];
                }
                [self.item setObject:self.itemDescriptionTextField.text forKey:@"type"];
                
                [self.item saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (error) {
                        NSLog(@"%@", error);
                    } else if (succeeded) {
                        [self popViewControllerAndResetBOOLs];
                    }
                }];
            }
        }
    }
}

- (IBAction)cancelItemCreationOnButtonPress:(id)sender {
    // Resigning keyboard
    [self.itemDescriptionTextField resignFirstResponder];
    
    // Calling popVC&ResetBOOLS method
    [self popViewControllerAndResetBOOLs];
}

// Method to reflect if item is already in QuickList or not
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
