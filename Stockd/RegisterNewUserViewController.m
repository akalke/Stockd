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

@interface RegisterNewUserViewController () <UIGestureRecognizerDelegate>
@property (strong, nonatomic) IBOutlet UITextField *registerUsernameTextField;
@property (strong, nonatomic) IBOutlet UITextField *registerPasswordTextField;
@property (strong, nonatomic) IBOutlet UITextField *registerConfirmPasswordTextField;
@end

@implementation RegisterNewUserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignKeyboardOnTap:)];
    [self.view addGestureRecognizer:tapGesture];
}

- (void)resignKeyboardOnTap:(UITapGestureRecognizer *)sender {
    [self resignKeyboard];
}

- (void)resignKeyboard {
    [self.registerUsernameTextField resignFirstResponder];
    [self.registerPasswordTextField resignFirstResponder];
    [self.registerConfirmPasswordTextField resignFirstResponder];
}

-(void)createNewUser{
    NSLog(@"Create new user");
    PFUser *newUser = [PFUser user];
    newUser.username = self.registerUsernameTextField.text;
    newUser.password = self.registerPasswordTextField.text;
    newUser.email = self.registerUsernameTextField.text;
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(error){
            NSLog(@"%@", error);
        }
        else{
            if(succeeded){
                NSLog(@"User Created!");
                List *list = [[List alloc]init];
                [list createNewQuickList:newUser withBlock:^{
                    [PFUser logInWithUsernameInBackground:self.registerUsernameTextField.text password:self.registerPasswordTextField.text];
                    [self resignKeyboard];
                    [self performSegueWithIdentifier:@"registeredUserSegue" sender:self];
                }];
            }
            else{
                NSLog(@"User already exists!");
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Oops!" message:@"There was a problem with your request or that username exists already" preferredStyle:UIAlertControllerStyleActionSheet];
                UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    [self.registerUsernameTextField becomeFirstResponder];
                }];
                [alert addAction:action];
                [self presentViewController:alert animated:YES completion:nil];
            }
        }
    }];
}

- (IBAction)onCancelButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)createUserOnRegister:(id)sender {

    //TO DO: Check for existing username
        if([self.registerConfirmPasswordTextField.text isEqualToString:@""] || [self.registerPasswordTextField.text isEqualToString:@""] || [self.registerUsernameTextField.text isEqualToString:@""]){

            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Oops!" message:@"Please enter your information fully" preferredStyle:UIAlertControllerStyleActionSheet];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                return;
            }];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
        }
        else
        {
            if(![self.registerPasswordTextField.text isEqualToString:self.registerConfirmPasswordTextField.text]){

                NSLog(@"passwords do not match");
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Oops!" message:@"Passwords do not match! Please re-enter your passwords" preferredStyle:UIAlertControllerStyleActionSheet];
                UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    self.registerConfirmPasswordTextField.text = @"";
                    self.registerPasswordTextField.text = @"";
                    [self.registerPasswordTextField becomeFirstResponder];
                }];
                [alert addAction:action];
                [self presentViewController:alert animated:YES completion:nil];
            }
            else if(self.registerUsernameTextField.text && [self.registerUsernameTextField.text rangeOfString:@"@"].location == NSNotFound){
                NSLog(@"no valid email");
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Oops!" message:@"Please enter a valid email" preferredStyle:UIAlertControllerStyleActionSheet];
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
                // Implemented this line above in a block for createNewQuickList to make explicity order of operations
//                [PFUser logInWithUsernameInBackground:self.registerUsernameTextField.text password:self.registerPasswordTextField.text block:^(PFUser *user, NSError *error){
//                    return;
//                }];
            }
        }
}


@end
