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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)createUserOnRegister:(id)sender {

    //TO DO: Check for existing username
    if([self.registerUsernameTextField.text isEqualToString:self.registerConfirmPasswordTextField.text]){
        if([self.registerConfirmPasswordTextField.text isEqualToString:@""] || [self.registerPasswordTextField.text isEqualToString:@""] || [self.registerUsernameTextField.text isEqualToString:@""]){

            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Oops!" message:@"Please enter your information fully" preferredStyle:UIAlertControllerStyleActionSheet];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                return;
            }];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
        }
        else
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
                NSLog(@"Create new user");
                PFQuery *userQuery = [PFUser query];
                [userQuery whereKey:@"username" equalTo:self.registerUsernameTextField.text];
                NSLog(@"%@", userQuery);
                PFUser *newUser = [PFUser user];
                newUser.username = self.registerUsernameTextField.text;
                newUser.password = self.registerPasswordTextField.text;
            }
        }

}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
