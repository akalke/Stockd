//
//  RegisterNewUserViewController.m
//  Stockd
//
//  Created by Amaeya Kalke on 11/12/14.
//  Copyright (c) 2014 Amaeya Kalke. All rights reserved.
//

#define stockdBlueColor [UIColor colorWithRed:32.0/255.0 green:59.0/255.0 blue:115.0/255.0 alpha:1.0]
#define stockdOrangeColor [UIColor colorWithRed:217.0/255.0 green:126.0/255.0 blue:0.0/255.0 alpha:1.0]

#import "RegisterNewUserViewController.h"
#import "List.h"

@interface RegisterNewUserViewController () <UIGestureRecognizerDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewBottomConstraint;
@property (strong, nonatomic) IBOutlet UITextField *registerUsernameTextField;
@property (strong, nonatomic) IBOutlet UITextField *registerPasswordTextField;
@property (strong, nonatomic) IBOutlet UITextField *registerConfirmPasswordTextField;
@end

@implementation RegisterNewUserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.registerUsernameTextField.delegate = self;
    self.registerPasswordTextField.delegate = self;
    self.registerConfirmPasswordTextField.delegate = self;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignKeyboardOnTap:)];
    [tapGesture setNumberOfTapsRequired:1];
    [tapGesture setNumberOfTouchesRequired:1];
    [self.view addGestureRecognizer:tapGesture];
    self.view.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:223.0/255.0 blue:181.0/255.0 alpha:1.0];
}

#pragma mark - TextField Methods

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [UIView animateWithDuration:0.3 animations:^{
        self.viewTopConstraint.constant = -140;
        self.viewBottomConstraint.constant = 140;
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
    [self.registerUsernameTextField resignFirstResponder];
    [self.registerPasswordTextField resignFirstResponder];
    [self.registerConfirmPasswordTextField resignFirstResponder];
}

-(void)createNewUser{
    PFUser *newUser = [PFUser user];
    newUser.username = self.registerUsernameTextField.text;
    newUser.password = self.registerPasswordTextField.text;
    newUser.email = self.registerUsernameTextField.text;
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(error){
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Oops!" message:@"Username might exist or there was an error with your request, please try again later." preferredStyle:UIAlertControllerStyleActionSheet];
            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                self.registerUsernameTextField.text = @"";
                self.registerPasswordTextField.text = @"";
                self.registerConfirmPasswordTextField.text = @"";
                [self.registerUsernameTextField becomeFirstResponder];
            }];
            [alert addAction:ok];
            [self presentViewController:alert animated:YES completion:nil];
        }
        else{
            if(succeeded){
                List *list = [[List alloc]init];
                [list createNewQuickList:newUser withBlock:^{
                    [PFUser logInWithUsernameInBackground:self.registerUsernameTextField.text password:self.registerPasswordTextField.text];
                    [self resignKeyboard];
                    [self performSegueWithIdentifier:@"registeredUserSegue" sender:self];
                }];
            }
        }
    }];
}

#pragma mark - IBActions

- (IBAction)onCancelButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)createUserOnRegister:(id)sender {
    
    if([self.registerUsernameTextField.text isEqualToString:@""] || [self.registerPasswordTextField.text isEqualToString:@""] || [self.registerConfirmPasswordTextField.text isEqualToString:@""]){
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Oops!" message:@"Information is missing!" preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            if ([self.registerUsernameTextField.text isEqualToString:@""]) {
                [self.registerUsernameTextField becomeFirstResponder];
            } else if ([self.registerPasswordTextField.text isEqualToString:@""]) {
                [self.registerPasswordTextField becomeFirstResponder];
            } else if ([self.registerConfirmPasswordTextField.text isEqualToString:@""]) {
                [self.registerConfirmPasswordTextField becomeFirstResponder];
            }
        }];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else
    {
        if(![self.registerPasswordTextField.text isEqualToString:self.registerConfirmPasswordTextField.text]){
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Oops!" message:@"Passwords do not match! Please re-enter your passwords." preferredStyle:UIAlertControllerStyleActionSheet];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                self.registerConfirmPasswordTextField.text = @"";
                self.registerPasswordTextField.text = @"";
                [self.registerPasswordTextField becomeFirstResponder];
            }];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
        }
        else if(self.registerUsernameTextField.text && [self.registerUsernameTextField.text rangeOfString:@"@"].location == NSNotFound){
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Oops!" message:@"Please enter a valid email address." preferredStyle:UIAlertControllerStyleActionSheet];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                self.registerConfirmPasswordTextField.text = @"";
                self.registerPasswordTextField.text = @"";
                [self.registerUsernameTextField becomeFirstResponder];
            }];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
        }
        else{
            [self createNewUser];
        }
    }
}


@end
