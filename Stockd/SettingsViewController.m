//
//  ViewController.m
//  Stockd
//
//  Created by Amaeya Kalke on 11/5/14.
//  Copyright (c) 2014 Amaeya Kalke. All rights reserved.
//

#import "SettingsViewController.h"
#import <Parse/Parse.h>
#import "LoginViewController.h"

@interface SettingsViewController ()
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UITextField *currentPasswordTextField;
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
    self.currentPasswordTextField.placeholder = @"Current Password";
    self.changePasswordTextField.placeholder = @"New Password";
    self.confirmPasswordTextField.placeholder = @"Confirm New Password";
    
    [self hidePasswordFields];
}

#pragma mark - Helper Methods

- (void)showPasswordFields {
    self.changePasswordButton.hidden = YES;
    self.currentPasswordTextField.hidden = NO;
    self.changePasswordTextField.hidden = NO;
    self.confirmPasswordTextField.hidden = NO;
    self.optionsView.hidden = NO;
}

- (void)hidePasswordFields {
    self.changePasswordButton.hidden = NO;
    self.currentPasswordTextField.hidden = YES;
    self.changePasswordTextField.hidden = YES;
    self.confirmPasswordTextField.hidden = YES;
    self.optionsView.hidden = YES;
}

- (void)saveIfPassCondtionals {
    NSLog(@"%@", self.user.password);
}

#pragma mark - IBActions

- (IBAction)onChangePasswordButtonPressed:(id)sender {
    [self showPasswordFields];
}

- (IBAction)onCancelButtonPressed:(id)sender {
    [self hidePasswordFields];
}

- (IBAction)onSaveButtonPressed:(id)sender {
    [self saveIfPassCondtionals];
//    [self hidePasswordFields];
}

- (IBAction)logUserOutOnButtonPress:(id)sender {
    [PFUser logOut];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginViewController *loginViewController = [storyboard instantiateInitialViewController];
    [self presentViewController:loginViewController animated:YES completion:nil];
    return;
}

@end
