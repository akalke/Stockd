//
//  ViewController.m
//  Stockd
//
//  Created by Amaeya Kalke on 11/5/14.
//  Copyright (c) 2014 Amaeya Kalke. All rights reserved.
//

#define peachBackground [UIColor colorWithRed:255.0/255.0 green:223.0/255.0 blue:181.0/255.0 alpha:1.0]
#define navBarColor [UIColor colorWithRed:231.0/255.0 green:95.0/255.0 blue:73.0/255.0 alpha:1.0]
#define turqouise [UIColor colorWithRed:0.0/255.0 green:191.0/255.0 blue:255.0/255.0 alpha:0.80]

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
@property (weak, nonatomic) IBOutlet UIButton *logOutButton;
@property PFUser *user;
@property BOOL isChangingPassword;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavBarDisplay];
    [self setTapGesture];
    [self setPasswordFields];
    
    // Hiding password elements
    [self hideSaveAndCancelButtons];
    [self hidePasswordFields];
    
    self.view.backgroundColor = peachBackground;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setViewContent];
}

#pragma mark - TextField Methods

// Moves view up for keyboard when any textfield begins editing
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    // Moves view up for keyboard
    [UIView animateWithDuration:0.3 animations:^{
        self.viewTopConstraint.constant = -200;
        self.viewBottomConstraint.constant = 200;
        [self.view layoutIfNeeded];
    }];
}

// Moves view back to origin when any textfield ends editing
- (void)textFieldDidEndEditing:(UITextField *)textField {
    // Moves view back to origin
    [UIView animateWithDuration:0.3 animations:^{
        self.viewTopConstraint.constant = 0;
        self.viewBottomConstraint.constant = 0;
        [self.view layoutIfNeeded];
    }];
}

#pragma mark - Helper Methods

- (void)setNavBarDisplay {
    // Setting navigation bar properties
    self.navigationItem.title = @"Settings";
    self.navigationController.navigationBar.barTintColor = navBarColor;
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName:[UIFont fontWithName:@"Avenir" size:18.0],NSForegroundColorAttributeName:[UIColor blackColor]};
    [self.navigationController.navigationBar setBarStyle:UIBarStyleDefault];
}

- (void)setViewContent {
    // Assigning user property to current user & setting text for usernameLabel
    self.user = [PFUser currentUser];
    self.usernameLabel.text = self.user.username;
    
    // Formatting date for accountCreatedAtLabel
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"MM-dd-yyyy"];
    NSString *date = [format stringForObjectValue:self.user.createdAt];
    self.accountCreatedAtLabel.text = [NSString stringWithFormat:@"Member Since: %@", date];
}

- (void)setTapGesture {
    // Setting up tap gesture to resign keyboard
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignKeyboardOnTap:)];
    [tapGesture setNumberOfTapsRequired:1];
    [tapGesture setNumberOfTouchesRequired:1];
    [self.view addGestureRecognizer:tapGesture];
}

// Method used by tapGesture to resign keyboard and move view back to origin
- (void)resignKeyboardOnTap:(UITapGestureRecognizer *)sender {
    [self resignKeyboard];
    
    // Moves view back to origin
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

- (void)setPasswordFields {
    // Setting up password text fields
    self.changePasswordTextField.placeholder = @"New Password";
    self.changePasswordTextField.delegate = self;
    self.confirmPasswordTextField.placeholder = @"Confirm Password";
    self.confirmPasswordTextField.delegate = self;
}

- (void)showPasswordFields {
    // Making change password field & logout button visible and hiding the password fields
    self.changePasswordButton.hidden = YES;
    self.logOutButton.hidden = YES;
    self.changePasswordTextField.text = @"";
    self.changePasswordTextField.hidden = NO;
    self.confirmPasswordTextField.text = @"";
    self.confirmPasswordTextField.hidden = NO;
}

- (void)hidePasswordFields {
    // Making change password field & logout hidden and showing password fields
    self.changePasswordButton.hidden = NO;
    self.logOutButton.hidden = NO;
    self.changePasswordTextField.hidden = YES;
    self.confirmPasswordTextField.hidden = YES;
}

- (void)hideSaveAndCancelButtons {
    // Making navbarbuttons hidden
    self.saveButton.tintColor = [UIColor clearColor];
    self.saveButton.enabled = NO;
    
    self.cancelButton.tintColor = [UIColor clearColor];
    self.cancelButton.enabled = NO;
}

- (void)showSaveAndCancelButtons {
    // Unhiding navbarbuttons
    self.saveButton.tintColor = [UIColor blackColor];
    self.saveButton.enabled = YES;
    
    self.cancelButton.tintColor = [UIColor blackColor];
    self.cancelButton.enabled = YES;
}

// Method saves password if conditionals are met, else an alert is presented
- (void)saveIfPassCondtionals {
    if ([self.changePasswordTextField.text isEqualToString:self.confirmPasswordTextField.text] && ![self.changePasswordTextField.text isEqualToString:@""]) {
        self.user.password = self.changePasswordTextField.text;
        [self.user saveInBackground];
        
        [self hideSaveAndCancelButtons];
        [self hidePasswordFields];
        [self resignKeyboard];
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Warning!" message:@"Passwords do not match." preferredStyle:UIAlertControllerStyleAlert];
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
    // Shows all necessary fields to change password, and makes changePasswordTextField first responder
    [self showPasswordFields];
    [self showSaveAndCancelButtons];
    [self.changePasswordTextField becomeFirstResponder];
}

- (IBAction)onCancelButtonPressed:(id)sender {
    // Hides all fields relating to changing passwords and calls resignKeyboard helper method
    [self hideSaveAndCancelButtons];
    [self hidePasswordFields];
    [self resignKeyboard];
}

- (IBAction)onSaveButtonPressed:(id)sender {
    [self saveIfPassCondtionals];
}

- (IBAction)logUserOutOnButtonPress:(id)sender {
    // Logs user out and presents loginViewController
    [PFUser logOut];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginViewController *loginViewController = [storyboard instantiateInitialViewController];
    [self presentViewController:loginViewController animated:YES completion:nil];
    return;
}

@end
