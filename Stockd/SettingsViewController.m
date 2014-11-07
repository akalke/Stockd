//
//  ViewController.m
//  Stockd
//
//  Created by Amaeya Kalke on 11/5/14.
//  Copyright (c) 2014 Amaeya Kalke. All rights reserved.
//

#import "SettingsViewController.h"
#import <Parse/Parse.h>
#import "LoginViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)logUserOutOnButtonPress:(id)sender {
    [PFUser logOut];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginViewController *loginViewController = [storyboard instantiateInitialViewController];
    [self presentViewController:loginViewController animated:YES completion:nil];
    return;
}

@end
