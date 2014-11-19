//
//  ViewController.m
//  Stockd
//
//  Created by Amaeya Kalke on 11/5/14.
//  Copyright (c) 2014 Amaeya Kalke. All rights reserved.
//

#define stockdBlueColor [UIColor colorWithRed:32.0/255.0 green:59.0/255.0 blue:115.0/255.0 alpha:1.0]
#define stockdOrangeColor [UIColor colorWithRed:217.0/255.0 green:126.0/255.0 blue:0.0/255.0 alpha:1.0]
#define peachBackground [UIColor colorWithRed:255.0/255.0 green:223.0/255.0 blue:181.0/255.0 alpha:1.0]
#define navBarColor [UIColor colorWithRed:231.0/255.0 green:95.0/255.0 blue:73.0/255.0 alpha:1.0]


#import "SettingsViewController.h"
#import "LoginViewController.h"

@interface SettingsViewController () <UIGestureRecognizerDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewBottomConstraint;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *accountCreatedAtLabel;
@property (weak, nonatomic) IBOutlet UITextField *changePasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordTextField;
@property (weak, nonatomic) IBOutlet UIButton *changePasswordButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property PFUser *user;
@property BOOL isChangingPassword;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = peachBackground;
    
    self.changePasswordTextField.placeholder = @"New Password";
    self.changePasswordTextField.delegate = self;
    self.confirmPasswordTextField.placeholder = @"Confirm Password";
    self.confirmPasswordTextField.delegate = self;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignKeyboardOnTap:)];
    [tapGesture setNumberOfTapsRequired:1];
    [tapGesture setNumberOfTouchesRequired:1];
    [self.view addGestureRecognizer:tapGesture];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self hideSaveAndCancelButtons];
    [self hidePasswordFields];
    
    self.user = [PFUser currentUser];
    self.usernameLabel.text = self.user.username;
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"MM-dd-yyyy"];
    NSString *date = [format stringForObjectValue:self.user.createdAt];
    self.accountCreatedAtLabel.text = [NSString stringWithFormat:@"Member Since: %@", date];
    
    self.navigationItem.title = @"Settings";
    self.navigationController.navigationBar.barTintColor = navBarColor;
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName:[UIFont fontWithName:@"Avenir" size:18.0],NSForegroundColorAttributeName:[UIColor blackColor]};
    [self.navigationController.navigationBar setBarStyle:UIBarStyleDefault];
}

#pragma mark - TextField Methods

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [UIView animateWithDuration:0.3 animations:^{
        self.viewTopConstraint.constant = -90;
        self.viewBottomConstraint.constant = 90;
        [self.view layoutIfNeeded];
    }];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [UIView animateWithDuration:0.3 animations:^{
        self.viewTopConstraint.constant = 0;
        self.viewBottomConstraint.constant = 0;
        [self.view layoutIfNeeded];
    }];
}

#pragma mark - Helper Methods

- (void)resignKeyboardOnTap:(UITapGestureRecognizer *)sender {
    [self resignKeyboard];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.viewTopConstraint.constant = 0;
        self.viewBottomConstraint.constant = 0;
        [self.view layoutIfNeeded];
    }];
}

- (void)resignKeyboard {
    [self.changePasswordTextField resignFirstResponder];
    [self.confirmPasswordTextField resignFirstResponder];
}

- (void)showPasswordFields {
    self.changePasswordButton.hidden = YES;
    self.changePasswordTextField.text = @"";
    self.changePasswordTextField.hidden = NO;
    self.confirmPasswordTextField.text = @"";
    self.confirmPasswordTextField.hidden = NO;
}

- (void)hidePasswordFields {
    self.changePasswordButton.hidden = NO;
    self.changePasswordTextField.hidden = YES;
    self.confirmPasswordTextField.hidden = YES;
}

- (void)hideSaveAndCancelButtons {
    self.saveButton.tintColor = [UIColor clearColor];
    self.saveButton.enabled = NO;
    
    self.cancelButton.tintColor = [UIColor clearColor];
    self.cancelButton.enabled = NO;
}

- (void)showSaveAndCancelButtons {
    self.saveButton.tintColor = [UIColor blackColor];
    self.saveButton.enabled = YES;
    
    self.cancelButton.tintColor = [UIColor blackColor];
    self.cancelButton.enabled = YES;
}

- (void)saveIfPassCondtionals {
    if ([self.changePasswordTextField.text isEqualToString:self.confirmPasswordTextField.text] && ![self.changePasswordTextField.text isEqualToString:@""]) {
        self.user.password = self.changePasswordTextField.text;
        [self.user saveInBackground];
        
        [self hideSaveAndCancelButtons];
        [self hidePasswordFields];
        [self resignKeyboard];
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
    [self showSaveAndCancelButtons];
    [self.changePasswordTextField becomeFirstResponder];
}

- (IBAction)onCancelButtonPressed:(id)sender {
    [self hideSaveAndCancelButtons];
    [self hidePasswordFields];
    [self resignKeyboard];
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
