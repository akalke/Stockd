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

    PFLogInViewController *login = [[PFLogInViewController alloc] init];
    [self presentViewController:login animated:YES completion:nil];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignKeyboardOnTap:)];
    [self.view addGestureRecognizer:tapGesture];
}

// If we want to change what bar is selected by default
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    if ([[segue identifier] isEqualToString:@"showTabBarSegue"]) {
//        UITabBarController *tabBarController = segue.destinationViewController;
//        [tabBarController setSelectedIndex:0];
//    }
//}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString:@"showTabBarSegue"]) {
        if (self.loginSuccess == YES) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - Helper Methods

- (void)resignKeyboardOnTap:(UITapGestureRecognizer *)sender {
    [self.usernameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
}

#pragma mark - IBActions

- (IBAction)loginUserOnButtonPress:(id)sender {
    [PFUser logInWithUsernameInBackground:self.usernameTextField.text password:self.passwordTextField.text block:^(PFUser *user, NSError *error) {
        if(error || [self.usernameTextField.text isEqualToString:@""] || [self.passwordTextField.text isEqualToString:@""]) {
            NSLog(@"Login Error! %@", error);
        }
        else {
            self.loginSuccess = YES;
            NSLog(@"success!");
            [self performSegueWithIdentifier:@"showTabBarSegue" sender:sender];
        }
    }];
}


@end
