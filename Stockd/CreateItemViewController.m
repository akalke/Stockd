//
//  CreateListViewController.m
//  Stockd
//
//  Created by Adam Duflo on 11/5/14.
//  Copyright (c) 2014 Amaeya Kalke. All rights reserved.
//

#import "CreateItemViewController.h"
#import "Item.h"

@interface CreateItemViewController ()
@property (weak, nonatomic) IBOutlet UITextField *itemDescriptionTextField;
@property (weak, nonatomic) IBOutlet UILabel *favoritesLabel;
@property (weak, nonatomic) IBOutlet UISwitch *favoritesSwitch;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation CreateItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.fromListDetails == YES) {
        self.favoritesLabel.hidden = YES;
        self.favoritesSwitch.hidden = YES;
        self.favoritesSwitch.userInteractionEnabled = NO;
    } else if (self.fromInventory == YES) {
        self.favoritesLabel.hidden = NO;
        self.favoritesSwitch.hidden = NO;
        self.favoritesSwitch.userInteractionEnabled = YES;
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
            [item createNewItemWithType:self.itemDescriptionTextField.text forUser:user inList:nil andInInventory:YES];
        } else if (self.fromListDetails == YES) {
            [item createNewItemWithType:self.itemDescriptionTextField.text forUser:user inList:self.listID andInInventory:NO];
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)cancelItemCreationOnButtonPress:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)uploadPhotoOnButtonPress:(id)sender {
    
}

@end
