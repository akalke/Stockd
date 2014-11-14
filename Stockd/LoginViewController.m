//
//  LoginViewController.m
//  Stockd
//
//  Created by Adam Duflo on 11/5/14.
//  Copyright (c) 2014 Amaeya Kalke. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController () <UIGestureRecognizerDelegate>
@property (strong, nonatomic) IBOutlet UITextField *usernameTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property BOOL loginSuccess;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignKeyboardOnTap:)];
    [self.view addGestureRecognizer:tapGesture];
}

-(void)viewDidAppear:(BOOL)animated{
    PFUser *user = [PFUser currentUser];
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

#pragma mark - Helper Methods

- (void)resignKeyboardOnTap:(UITapGestureRecognizer *)sender {
    [self resignKeyboard];
}

- (void)resignKeyboard {
    [self.usernameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
}

#pragma mark - IBActions

- (IBAction)loginUserOnButtonPress:(id)sender {
    [PFUser logInWithUsernameInBackground:self.usernameTextField.text password:self.passwordTextField.text block:^(PFUser *user, NSError *error) {

        if([self.usernameTextField.text isEqualToString:@""] || [self.passwordTextField.text isEqualToString:@""]) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Oops!" message:@"You need to enter a valid username and password!" preferredStyle:UIAlertControllerStyleActionSheet];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                return;
            }];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
        }
        else if(error){
            NSLog(@"Login Error! %@", error);
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Oops!" message:[NSString stringWithFormat:@"%@", error] preferredStyle:UIAlertControllerStyleActionSheet];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                return;
            }];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
        }
        else {
            self.loginSuccess = YES;
            NSLog(@"success!");
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
        return;
    }];
}

@end
