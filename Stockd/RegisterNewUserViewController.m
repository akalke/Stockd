//
//  RegisterNewUserViewController.m
//  Stockd
//
//  Created by Amaeya Kalke on 11/12/14.
//  Copyright (c) 2014 Amaeya Kalke. All rights reserved.
//

#import "RegisterNewUserViewController.h"

@interface RegisterNewUserViewController ()
@property (strong, nonatomic) IBOutlet UITextField *registerUsernameTextField;
@property (strong, nonatomic) IBOutlet UITextField *registerPasswordTextField;
@property (strong, nonatomic) IBOutlet UITextField *registerConfirmPasswordTextField;
@end

@implementation RegisterNewUserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
            }
            else{
                NSLog(@"User already exists!");
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Oops!" message:@"There was a problem with your request or that username exists already" preferredStyle:UIAlertControllerStyleActionSheet];
                UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    return;
                }];
                [alert addAction:action];
                [self presentViewController:alert animated:YES completion:nil];
            }
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
                }];
                [alert addAction:action];
                [self presentViewController:alert animated:YES completion:nil];
            }
            else{
                [self createNewUser];
                [PFUser logInWithUsernameInBackground:self.registerUsernameTextField.text password:self.registerPasswordTextField.text block:^(PFUser *user, NSError *error){
                    [self performSegueWithIdentifier:@"registeredUserSegue" sender:self];
                }];
            }
        }
}


@end
