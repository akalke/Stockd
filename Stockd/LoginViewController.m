//
//  LoginViewController.m
//  Stockd
//
//  Created by Adam Duflo on 11/5/14.
//  Copyright (c) 2014 Amaeya Kalke. All rights reserved.
//

#define stockdBlueColor [UIColor colorWithRed:32.0/255.0 green:59.0/255.0 blue:115.0/255.0 alpha:1.0]
#define stockdOrangeColor [UIColor colorWithRed:217.0/255.0 green:126.0/255.0 blue:0.0/255.0 alpha:1.0]

#import "LoginViewController.h"

@interface LoginViewController () <UIGestureRecognizerDelegate, UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITextField *usernameTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewBottomConstraint;
@property BOOL loginSuccess;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setLoginScreen];
    
    // Setting delegates so view can move
    self.usernameTextField.delegate = self;
    self.passwordTextField.delegate = self;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    // Setting user
    PFUser *user = [PFUser currentUser];
    
    // Conditional that checks if there is a user and shows homeVC
    if(user.username != nil){
        [self performSegueWithIdentifier:@"showTabBarSegue" sender:self];
    }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString:@"showTabBarSegue"]) {
        if (self.loginSuccess == YES) {
            return YES;
        }
        else if ([identifier isEqualToString:@"registerNewUserSegue"]){
            return YES;
        }
    }
    return NO;
}

#pragma mark - TextField Methods

// Moves view up for keyboard when any textfield begins editing
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    // Moves view up for keyboard
    [UIView animateWithDuration:0.3 animations:^{
        self.viewTopConstraint.constant = -110;
        self.viewBottomConstraint.constant = 110;
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

// Method that sets up tapGesture & background
-(void)setLoginScreen{
    //Setup Login Screen
    self.view.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:223.0/255.0 blue:181.0/255.0 alpha:1.0];
    
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
    [self.usernameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
}

#pragma mark - IBActions

- (IBAction)loginUserOnButtonPress:(id)sender {
    [PFUser logInWithUsernameInBackground:self.usernameTextField.text password:self.passwordTextField.text block:^(PFUser *user, NSError *error) {
        
        // Conditional that checks if fields are empty
        if([self.usernameTextField.text isEqualToString:@""] || [self.passwordTextField.text isEqualToString:@""]) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Oops!" message:@"Email address or password missing!" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                if ([self.usernameTextField.text isEqualToString:@""]) {
                    self.passwordTextField.text = @"";

                    [self.usernameTextField becomeFirstResponder];
                } else if ([self.passwordTextField.text isEqualToString:@""]) {
                    [self.passwordTextField becomeFirstResponder];
                }
            }];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
        }
        // If error, alert is presented
        else if(error){
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Oops!" message:@"Invalid login credentials!" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                self.usernameTextField.text = @"";
                self.passwordTextField.text = @"";

                [self.usernameTextField becomeFirstResponder];
            }];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
        }
        // If success, logs in, resigns keyboard, and shows homeVC
        else {
            self.loginSuccess = YES;
            [self resignKeyboard];
            [self performSegueWithIdentifier:@"showTabBarSegue" sender:sender];
        }
    }];
}

- (IBAction)registerNewUser:(id)sender {
    [self performSegueWithIdentifier:@"registerNewUserSegue" sender:self];
}

- (IBAction)forgotPasswordOnButtonPress:(id)sender {
    [PFUser requestPasswordResetForEmailInBackground:self.usernameTextField.text block:^(BOOL succeeded, NSError *error) {
        
        // Conditional if error
        if(error){
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Oops!" message:@"There was an error with your request, please try again later." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                return;
            }];
            [alert addAction:ok];
            [self presentViewController:alert animated:YES completion:nil];
        }
        // Conditional if succeeded, alert shows with confirmation
        else if (succeeded){
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Email sent!" message:@"An email has been sent to you to reset your password" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                return;
            }];
            [alert addAction:ok];
            [self presentViewController:alert animated:YES completion:nil];
        }
        // Conditional if no success, alert shows with bad news :(
        else if(!succeeded){
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Oops!" message:@"We are unable to reset your password." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                return;
            }];
            [alert addAction:ok];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }];
}

@end
