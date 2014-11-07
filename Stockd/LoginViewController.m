//
//  LoginViewController.m
//  Stockd
//
//  Created by Adam Duflo on 11/5/14.
//  Copyright (c) 2014 Amaeya Kalke. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()
@property (strong, nonatomic) IBOutlet UITextField *usernameTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    PFLogInViewController *login = [[PFLogInViewController alloc] init];
    [self presentViewController:login animated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showTabBarSegue"]) {
        UITabBarController *tabBarController = segue.destinationViewController;
        [tabBarController setSelectedIndex:0];
    }
}

- (IBAction)loginUserOnButtonPress:(id)sender {
    [PFUser logInWithUsernameInBackground:self.usernameTextField.text password:self.passwordTextField.text block:^(PFUser *user, NSError *error) {
        if(error){
            NSLog(@"Login Error! %@", error);
        }
        else{
            [self performSegueWithIdentifier:@"showTabBarSegue" sender:self];
        }
    }];
}


@end
