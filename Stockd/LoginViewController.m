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
@property (strong, nonatomic) IBOutlet UIView *registerUserOverlayView;
@property (strong, nonatomic) IBOutlet UITextField *registerUsernameTextField;
@property (strong, nonatomic) IBOutlet UITextField *registerPasswordTextField;
@property (strong, nonatomic) IBOutlet UITextField *registerConfirmPasswordTextField;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *overlayViewLeftConstraint;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
        if(error || [self.usernameTextField.text isEqualToString:@""] || [self.passwordTextField.text isEqualToString:@""]) {
            NSLog(@"Login Error! %@", error);
        }
        else {
            self.loginSuccess = YES;
            NSLog(@"success!");
            [self resignKeyboard];
            [self performSegueWithIdentifier:@"showTabBarSegue" sender:sender];
        }
    }];
}

- (IBAction)registerUserOnButtonPress:(id)sender {
    [UIView animateWithDuration:0.3 animations:^{
        self.registerUserOverlayView.frame = self.view.frame;
    }];

}

- (IBAction)createUserOnRegister:(id)sender {


    //TO DO: Check for existing username
    if([self.registerUsernameTextField.text isEqualToString:self.registerConfirmPasswordTextField.text]){
        PFUser *newUser = [PFUser user];
        newUser.username = self.registerUsernameTextField.text;
        newUser.password = self.registerPasswordTextField.text;

        [UIView animateWithDuration:0.3 animations:^{
            self.overlayViewLeftConstraint.constant = -600;
        }];
        NSLog(@"User created");
    }ad
    else{
        NSLog(@"Passwords don't match");
    }

}

@end
