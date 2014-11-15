//
//  ViewController.m
//  Stockd
//
//  Created by Amaeya Kalke on 11/5/14.
//  Copyright (c) 2014 Amaeya Kalke. All rights reserved.
//

#define stockdBlueColor [UIColor colorWithRed:32.0/255.0 green:59.0/255.0 blue:115.0/255.0 alpha:1.0]
#define stockdOrangeColor [UIColor colorWithRed:217.0/255.0 green:126.0/255.0 blue:0.0/255.0 alpha:1.0]

#import "SettingsViewController.h"
#import <Parse/Parse.h>
#import "LoginViewController.h"

@interface SettingsViewController ()
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *accountCreatedAtLabel;
@property (weak, nonatomic) IBOutlet UITextField *changePasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordTextField;
@property (weak, nonatomic) IBOutlet UIView *optionsView;
@property (weak, nonatomic) IBOutlet UIButton *changePasswordButton;
@property PFUser *user;
@property BOOL isChangingPassword;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.user = [PFUser currentUser];
    self.usernameLabel.text = self.user.username;
    self.changePasswordTextField.placeholder = @"New Password";
    self.confirmPasswordTextField.placeholder = @"Confirm Password";
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"MM-dd-yyyy"];
    NSString *date = [format stringForObjectValue:self.user.createdAt];
    self.accountCreatedAtLabel.text = [NSString stringWithFormat:@"Member Since: %@", date];
    
    [self hidePasswordFields];
    
    self.navigationController.navigationBar.barTintColor = stockdBlueColor;
    self.navigationController.navigationBar.tintColor = stockdOrangeColor;
    self.navigationController.navigationBar.translucent = NO;
    self.navigationItem.title = @"Settings";
    self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName:[UIFont fontWithName:@"Arial-BoldMT" size:24.0f],NSForegroundColorAttributeName:stockdOrangeColor};
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlackTranslucent];
}

#pragma mark - Helper Methods

- (void)showPasswordFields {
    self.changePasswordButton.hidden = YES;
    self.changePasswordTextField.text = @"";
    self.changePasswordTextField.hidden = NO;
    self.confirmPasswordTextField.text = @"";
    self.confirmPasswordTextField.hidden = NO;
    self.optionsView.hidden = NO;
}

- (void)hidePasswordFields {
    self.changePasswordButton.hidden = NO;
    self.changePasswordTextField.hidden = YES;
    self.confirmPasswordTextField.hidden = YES;
    self.optionsView.hidden = YES;
}

- (void)saveIfPassCondtionals {
    if ([self.changePasswordTextField.text isEqualToString:self.confirmPasswordTextField.text] && ![self.changePasswordTextField.text isEqualToString:@""]) {
        self.user.password = self.changePasswordTextField.text;
        [self.user saveInBackground];
        [self hidePasswordFields];
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Warning" message:@"Passwords don't match." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okay = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            self.changePasswordTextField.text = @"";
            self.confirmPasswordTextField.text = @"";
            [self.changePasswordTextField becomeFirstResponder];
        }];
        
        [alert addAction:okay];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

#pragma mark - IBActions

- (IBAction)onChangePasswordButtonPressed:(id)sender {
    [self showPasswordFields];
    [self.changePasswordTextField becomeFirstResponder];
}

- (IBAction)onCancelButtonPressed:(id)sender {
    [self hidePasswordFields];
}

- (IBAction)onSaveButtonPressed:(id)sender {
    [self saveIfPassCondtionals];
}

- (IBAction)logUserOutOnButtonPress:(id)sender {
    [PFUser logOut];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginViewController *loginViewController = [storyboard instantiateInitialViewController];
    [self presentViewController:loginViewController animated:YES completion:nil];
    return;
}

@end
